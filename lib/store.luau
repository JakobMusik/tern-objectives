--!strict
-- The objective store (design D6): one JSON value under kv key "state". Every change re-reads the
-- stored state, applies itself and writes it back, so changes other windows saved are kept.

local Dates = require("./dates")
local Review = require("./review")
local Text = require("./text")

local M = {}

M.TITLE_MAX = 120
M.NOTE_MAX = 200

export type Objective = {
	id: string,
	title: string,
	done: boolean,
	priority: number,
	created: number,
	done_at: number?,
	note: string?,
	due: string?,
	tags: { string },
	tabs: { number },
	-- Once done: when it is next reviewed, and how (review-done-objectives, design D1).
	review: Review.Schedule?,
}

export type PaneSnap = { pane: number, title: string, kind: string }

export type TabSnap = {
	label: string,
	session: number,
	session_name: string,
	position: number,
	window: string,
	seen: number,
	panes: { PaneSnap },
}

export type ViewState = {
	scope: string, -- "all" or "session"
	tag: string?,
	done_open: boolean,
	-- Pane rows the user opened; every other live row starts folded (design R3).
	expanded: { [string]: boolean },
}

-- An omp chat, saved while it ran so its tab can be resumed after it closes (resume-omp-chats,
-- design D3).
export type AgentSession = {
	agent: string, -- "omp"
	session: string, -- the chat's file
	cwd: string, -- the chat's folder, as Tern lists it
	seen: number, -- when it was saved
}

-- Whether `s` is an omp chat file the plugin may save and type into a shell (design D3): an
-- absolute path to a `.jsonl` directly in a folder under a `sessions` folder, where subagents'
-- files sit a level deeper, with no control characters.
function M.is_chat_file(s: any): boolean
	if type(s) ~= "string" or string.sub(s, 1, 1) ~= "/" or string.find(s, "%c") ~= nil then
		return false
	end
	return string.match(s, "/sessions/[^/]+/[^/]+%.jsonl$") ~= nil
end

local function valid_session(a: any): boolean
	return type(a) == "table" and a.agent == "omp" and M.is_chat_file(a.session) and type(a.cwd) == "string"
end

export type State = {
	version: number,
	next_id: number,
	objectives: { Objective },
	tabs: { [string]: TabSnap },
	-- Saved sessions by pane id (design D3).
	agents: { [string]: AgentSession },
	view: ViewState,
}

local KEY = "state"
local VERSION = 1

local array = tern.json.array

local function default(): State
	return {
		version = VERSION,
		next_id = 1,
		objectives = array({}),
		tabs = {},
		agents = {},
		view = { scope = "all", done_open = false, expanded = {} },
	}
end

-- Tags lists as JSON arrays and fills absent fields, so a stored state always has every field.
local function normalize(raw: any): State
	if raw == nil then
		return default()
	end
	if type(raw) ~= "table" or raw.version ~= VERSION then
		error("objectives: stored state has an unsupported version (" .. tostring(type(raw) == "table" and raw.version) .. ")")
	end
	local s = raw :: State
	s.next_id = s.next_id or 1
	s.objectives = array(s.objectives or {})
	for _, o in s.objectives do
		o.tags = array(o.tags or {})
		o.tabs = array(o.tabs or {})
		o.priority = o.priority or 3
		o.done = o.done == true
		-- Done before 0.10.0: scheduled as if marked done on its done date, so it is due the day
		-- after; with no done date, today (design D1).
		if o.done and type(o.review) ~= "table" then
			o.review = if o.done_at ~= nil
				then Review.start(Dates.day_of(o.done_at))
				else Review.start(Dates.add(Dates.today(), -1))
		end
	end
	s.tabs = s.tabs or {}
	for _, t in s.tabs do
		t.panes = array(t.panes or {})
	end
	-- Absent before 0.9.0; an older plugin keeps it, since every change writes back the whole state.
	-- Only omp chats: Claude sessions saved by 0.9.0 to 0.10.0 go at the next write (design D3).
	local agents: { [string]: AgentSession } = {}
	if type(s.agents) == "table" then
		for key, a in s.agents do
			if valid_session(a) then
				agents[key] = a
			end
		end
	end
	s.agents = agents
	-- Rebuilt from the known fields only, so 0.4.0's `collapsed` list goes at the next write (design R3).
	local v = (s.view or {}) :: any
	s.view = {
		scope = if v.scope == "session" then "session" else "all",
		tag = if type(v.tag) == "string" then v.tag else nil,
		done_open = v.done_open == true,
		expanded = if type(v.expanded) == "table" then v.expanded else {},
	}
	return s
end

function M.read(): State
	return normalize(tern.kv.get(KEY))
end

-- Re-reads the state, runs `fn` on it and stores the result unless `fn` returns false.
function M.mutate(fn: (State) -> boolean?): State
	local s = M.read()
	if fn(s) ~= false then
		tern.kv.set(KEY, s)
	end
	return s
end

function M.find(s: State, id: string): Objective?
	for _, o in s.objectives do
		if o.id == id then
			return o
		end
	end
	return nil
end

-- ---- input rules ----

-- A trimmed one-line title of at most 120 characters, or nil when blank.
function M.clean_title(input: string): string?
	local t = Text.one_line(input)
	if t == "" then
		return nil
	end
	return (Text.cut(t, M.TITLE_MAX))
end

-- A one-line note of at most 200 characters, or nil (no note) when blank.
function M.clean_note(input: string): string?
	local t = Text.one_line(input)
	if t == "" then
		return nil
	end
	return (Text.cut(t, M.NOTE_MAX))
end

-- A tag: lowercase, trimmed, runs of spaces as one hyphen; nil when blank.
function M.clean_tag(input: string): string?
	local t = string.lower(Text.one_line(input))
	t = string.gsub(t, " ", "-")
	t = string.gsub(t, "^#+", "")
	if t == "" then
		return nil
	end
	return t
end

-- Every tag some objective holds, sorted.
function M.all_tags(s: State): { string }
	local seen, out = {}, {}
	for _, o in s.objectives do
		for _, tag in o.tags do
			if not seen[tag] then
				seen[tag] = true
				table.insert(out, tag)
			end
		end
	end
	table.sort(out)
	return out
end

-- ---- tab snapshots (design D8) ----

-- What a snapshot records of a live tab; `seen` is when it last changed.
export type TabFacts = {
	label: string,
	session: number,
	session_name: string,
	position: number,
	rows: { { pane: number, title: string, kind: string } },
}

local function snapshot(t: TabFacts, window: string, now: number): TabSnap
	local panes: { PaneSnap } = array({})
	for _, r in t.rows do
		table.insert(panes, { pane = r.pane, title = r.title, kind = r.kind })
	end
	return {
		label = t.label,
		session = t.session,
		session_name = t.session_name,
		position = t.position,
		window = window,
		seen = now,
		panes = panes,
	}
end

local function same(a: TabSnap, b: TabSnap): boolean
	if a.label ~= b.label or a.session ~= b.session or a.session_name ~= b.session_name or a.position ~= b.position or a.window ~= b.window or #a.panes ~= #b.panes then
		return false
	end
	for i, p in a.panes do
		local q = b.panes[i]
		if p.pane ~= q.pane or p.title ~= q.title or p.kind ~= q.kind then
			return false
		end
	end
	return true
end

-- ---- objective changes; each returns what it did, or nil when the objective is gone ----

function M.create(title: string, tab: number?, facts: TabFacts?, window: string?): string?
	local clean = M.clean_title(title)
	if clean == nil then
		return nil
	end
	local id = ""
	M.mutate(function(s)
		id = "o" .. s.next_id
		s.next_id += 1
		table.insert(s.objectives, {
			id = id,
			title = clean,
			done = false,
			priority = 3,
			created = os.time(),
			tags = array({}),
			tabs = array(if tab ~= nil then { tab } else {}),
		})
		if tab ~= nil and facts ~= nil then
			s.tabs[tostring(tab)] = snapshot(facts, window or "", os.time())
		end
		return true
	end)
	return id
end

local function change(id: string, fn: (Objective, State) -> boolean?): boolean
	local found = false
	M.mutate(function(s)
		local o = M.find(s, id)
		if o == nil then
			return false
		end
		found = true
		return fn(o, s)
	end)
	return found
end

function M.rename(id: string, title: string): boolean
	local clean = M.clean_title(title)
	if clean == nil then
		return false
	end
	return change(id, function(o)
		o.title = clean
		return true
	end)
end

-- What Undo needs to put an objective back as it was (review-done-objectives, design D2): the record
-- before the change, its place in the list, and what was removed with it.
export type Saved = {
	kind: string, -- "done" or "removed"
	record: Objective,
	index: number,
	tabs: { [string]: TabSnap },
	agents: { [string]: AgentSession },
}

-- A shallow copy. Stored values come from JSON with protected metatables, which `table.clone`
-- refuses (task 1.2).
local function copy(t: { [any]: any }): { [any]: any }
	local c = {}
	for k, v in t do
		c[k] = v
	end
	return c
end

local function copy_objective(o: Objective): Objective
	local c = copy(o) :: Objective
	c.tags = array(copy(o.tags) :: any)
	c.tabs = array(copy(o.tabs) :: any)
	if o.review ~= nil then
		c.review = copy(o.review) :: any
	end
	return c
end

-- Marks an open objective done on `day` and starts its review schedule. Done is final: a done one is
-- left alone. Returns what Undo needs, or nil when the objective is gone or already done.
function M.mark_done(id: string, day: Dates.Day): Saved?
	local saved: Saved? = nil
	M.mutate(function(s)
		for i, o in s.objectives do
			if o.id == id then
				if o.done then
					return false
				end
				saved = { kind = "done", record = copy_objective(o), index = i, tabs = {}, agents = {} }
				o.done = true
				o.done_at = os.time()
				o.review = Review.start(day)
				return true
			end
		end
		return false
	end)
	return saved
end

-- Rates a done objective whose review is due on `today`; returns false when it is gone.
function M.rate(id: string, grade: Review.Grade, today: Dates.Day): boolean
	return change(id, function(o)
		if not o.done or o.review == nil or not Review.is_due(o.review, today) then
			return false
		end
		o.review = Review.rate(o.review, grade, today)
		return true
	end)
end

function M.cycle_priority(id: string): boolean
	return change(id, function(o)
		-- Up one step, P0 wrapping back to P3 (raise-priority-in-place D1).
		o.priority = (o.priority + 3) % 4
		return true
	end)
end

function M.set_note(id: string, note: string): boolean
	local clean = M.clean_note(note)
	return change(id, function(o)
		o.note = clean
		return true
	end)
end

-- `due` must already be a valid `YYYY-MM-DD` (Dates.parse), or nil to clear it.
function M.set_due(id: string, due: string?): boolean
	return change(id, function(o)
		o.due = due
		return true
	end)
end

-- Adds `tag` when the objective lacks it, removes it when it has it.
function M.toggle_tag(id: string, tag: string): boolean
	return change(id, function(o)
		local idx = table.find(o.tags, tag)
		if idx ~= nil then
			table.remove(o.tags, idx)
		else
			table.insert(o.tags, tag)
			table.sort(o.tags)
		end
		return true
	end)
end

function M.add_tag(id: string, tag: string): boolean
	return change(id, function(o)
		if table.find(o.tags, tag) ~= nil then
			return false
		end
		table.insert(o.tags, tag)
		table.sort(o.tags)
		return true
	end)
end

-- Drops snapshots of tabs no objective links any more.
local function drop_orphans(s: State)
	local linked: { [string]: boolean } = {}
	for _, o in s.objectives do
		for _, tab in o.tabs do
			linked[tostring(tab)] = true
		end
	end
	for key in s.tabs do
		if not linked[key] then
			s.tabs[key] = nil
		end
	end
end

function M.delete(id: string): boolean
	local found = false
	M.mutate(function(s)
		for i, o in s.objectives do
			if o.id == id then
				table.remove(s.objectives, i)
				drop_orphans(s)
				found = true
				return true
			end
		end
		return false
	end)
	return found
end

-- Removes a done objective at once (its trash icon), with its links. Returns what Undo needs: the
-- record, its place, and the snapshots and saved sessions that went with it; nil when it is gone or
-- isn't done.
function M.remove(id: string): Saved?
	local saved: Saved? = nil
	M.mutate(function(s)
		for i, o in s.objectives do
			if o.id == id then
				if not o.done then
					return false
				end
				local before = copy(s.tabs) :: { [string]: TabSnap }
				table.remove(s.objectives, i)
				drop_orphans(s)
				local tabs: { [string]: TabSnap } = {}
				local agents: { [string]: AgentSession } = {}
				for key, snap in before do
					if s.tabs[key] == nil then
						tabs[key] = snap
						-- The next render drops these sessions with their snapshot; Undo brings both back.
						for _, p in snap.panes do
							local a = s.agents[tostring(p.pane)]
							if a ~= nil then
								agents[tostring(p.pane)] = a
							end
						end
					end
				end
				saved = { kind = "removed", record = o, index = i, tabs = tabs, agents = agents }
				return true
			end
		end
		return false
	end)
	return saved
end

-- Undo: puts the saved record back in its place, replacing the one with its id if there is one, and
-- the snapshots and sessions that went with it where they are missing.
function M.restore(saved: Saved)
	M.mutate(function(s)
		local at: number? = nil
		for i, o in s.objectives do
			if o.id == saved.record.id then
				at = i
			end
		end
		if at ~= nil then
			s.objectives[at] = saved.record
		else
			table.insert(s.objectives, math.clamp(saved.index, 1, #s.objectives + 1), saved.record)
		end
		for key, snap in saved.tabs do
			if s.tabs[key] == nil then
				s.tabs[key] = snap
			end
		end
		for key, a in saved.agents do
			if s.agents[key] == nil then
				s.agents[key] = a
			end
		end
		return true
	end)
end

-- ---- tab links and pruning ----

-- Links `id` to `tab` when it isn't, unlinks it when it is; records the tab's snapshot on linking.
-- A done objective's links are fixed (linked-section D3). Returns "linked", "unlinked", "done" when
-- nothing changed because it is done, or nil when the objective is gone.
function M.toggle_link(id: string, tab: number, facts: TabFacts?, window: string): string?
	local result: string? = nil
	change(id, function(o, s)
		if o.done then
			result = "done"
			return false
		end
		local idx = table.find(o.tabs, tab)
		if idx ~= nil then
			table.remove(o.tabs, idx)
			drop_orphans(s)
			result = "unlinked"
		else
			table.insert(o.tabs, tab)
			result = "linked"
			if facts ~= nil then
				s.tabs[tostring(tab)] = snapshot(facts, window, os.time())
			end
		end
		return true
	end)
	return result
end

-- Brings the snapshots of linked live tabs up to date; writes only when one changed.
function M.refresh_snapshots(s: State, live: { [number]: TabFacts }, window: string)
	local stale: { [string]: TabSnap } = {}
	local any = false
	local now = os.time()
	for _, o in s.objectives do
		for _, tab in o.tabs do
			local key = tostring(tab)
			local facts = live[tab]
			if facts ~= nil and stale[key] == nil then
				local fresh = snapshot(facts, window, now)
				local old = s.tabs[key]
				if old == nil or not same(old, fresh) then
					stale[key] = fresh
					any = true
				end
			end
		end
	end
	if not any then
		return
	end
	M.mutate(function(fresh_state)
		for key, snap in stale do
			fresh_state.tabs[key] = snap
		end
		return true
	end)
	for key, snap in stale do
		s.tabs[key] = snap
	end
end

-- Removes open objectives' links to the tabs in `closed` (close-linked-tabs D7), and the snapshot
-- and saved chats of each tab no done objective links; returns how many links went.
function M.prune(closed: { number }): number
	local gone = 0
	local set: { [number]: boolean } = {}
	for _, tab in closed do
		set[tab] = true
	end
	M.mutate(function(s)
		local kept: { [number]: boolean } = {}
		for _, o in s.objectives do
			for i = #o.tabs, 1, -1 do
				local tab = o.tabs[i]
				if set[tab] then
					if o.done then
						kept[tab] = true
					else
						table.remove(o.tabs, i)
						gone += 1
					end
				end
			end
		end
		for tab in set do
			if not kept[tab] then
				local snap = s.tabs[tostring(tab)]
				if snap ~= nil then
					-- A pruned tab is closed, so its panes aren't live: their saved sessions go with it.
					for _, p in snap.panes do
						s.agents[tostring(p.pane)] = nil
					end
				end
				s.tabs[tostring(tab)] = nil
			end
		end
		return true
	end)
	return gone
end

-- ---- saved omp chats (resume-closed-agents D3, resume-omp-chats D3) ----

-- A session saved this recently is kept even when its pane is neither live nor in a snapshot yet:
-- a resumed chat's new pane is listed only after the call that opened it (design D6).
local FRESH_S = 10

-- Saved sessions whose pane is neither in `live` nor a row of a snapshot: nothing could resume them.
local function orphan_sessions(s: State, live: { [number]: boolean }): { string }
	local in_snap: { [string]: boolean } = {}
	for _, snap in s.tabs do
		for _, p in snap.panes do
			in_snap[tostring(p.pane)] = true
		end
	end
	local now = os.time()
	local out = {}
	for key, entry in s.agents do
		local pane = tonumber(key)
		if not in_snap[key] and (pane == nil or not live[pane]) and now - (entry.seen or 0) > FRESH_S then
			table.insert(out, key)
		end
	end
	return out
end

local function same_session(a: AgentSession?, b: AgentSession): boolean
	return a ~= nil and a.agent == b.agent and a.session == b.session and a.cwd == b.cwd
end

-- Saves `found` (sessions by pane id) and drops orphans; writes only when something changes.
-- `s` is the render's or caller's copy, kept in step with what was written.
function M.save_sessions(s: State, found: { [string]: AgentSession }, live: { [number]: boolean })
	local changed = #orphan_sessions(s, live) > 0
	for key, entry in found do
		if not same_session(s.agents[key], entry) then
			changed = true
		end
	end
	if not changed then
		return
	end
	local fresh = M.mutate(function(st)
		for key, entry in found do
			if not same_session(st.agents[key], entry) then
				st.agents[key] = entry
			end
		end
		for _, key in orphan_sessions(st, live) do
			st.agents[key] = nil
		end
		return true
	end)
	s.agents = fresh.agents
end

-- The new tab a closed tab's chats were resumed into takes its place (design D6): every objective
-- linking `old` links `new` instead, in the same place; `old`'s snapshot and saved sessions go; and
-- `moved` (sessions by their new pane ids) is saved, so the new tab can be resumed again.
function M.adopt(old: number, new: number, moved: { [string]: AgentSession })
	M.mutate(function(s)
		for _, o in s.objectives do
			local i = table.find(o.tabs, old)
			if i ~= nil then
				if table.find(o.tabs, new) ~= nil then
					table.remove(o.tabs, i)
				else
					o.tabs[i] = new
				end
			end
		end
		local snap = s.tabs[tostring(old)]
		if snap ~= nil then
			for _, p in snap.panes do
				s.agents[tostring(p.pane)] = nil
			end
		end
		s.tabs[tostring(old)] = nil
		for key, entry in moved do
			s.agents[key] = entry
		end
		return true
	end)
end

-- ---- view settings ----

function M.set_view(fn: (ViewState) -> boolean?)
	M.mutate(function(s)
		return fn(s.view)
	end)
end

return M
