--!strict
-- The objective store (design D6): one JSON value under kv key "state". Every change re-reads the
-- stored state, applies itself and writes it back, so changes other windows saved are kept.

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
	-- Pane rows the user folded; every other live row shows its details (design P7).
	collapsed: { [string]: boolean },
}

export type State = {
	version: number,
	next_id: number,
	objectives: { Objective },
	tabs: { [string]: TabSnap },
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
		view = { scope = "all", done_open = false, collapsed = {} },
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
		o.priority = o.priority or 2
		o.done = o.done == true
	end
	s.tabs = s.tabs or {}
	for _, t in s.tabs do
		t.panes = array(t.panes or {})
	end
	-- Rebuilt from the known fields only, so a 0.1.x `expanded` map goes at the next write.
	local v = (s.view or {}) :: any
	s.view = {
		scope = if v.scope == "session" then "session" else "all",
		tag = if type(v.tag) == "string" then v.tag else nil,
		done_open = v.done_open == true,
		collapsed = if type(v.collapsed) == "table" then v.collapsed else {},
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
			priority = 2,
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

function M.toggle_done(id: string): boolean
	return change(id, function(o)
		o.done = not o.done
		o.done_at = if o.done then os.time() else nil
		return true
	end)
end

function M.cycle_priority(id: string): boolean
	return change(id, function(o)
		o.priority = (o.priority + 1) % 4
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

-- ---- tab links and pruning ----

-- Links `id` to `tab` when it isn't, unlinks it when it is; records the tab's snapshot on linking.
-- Returns "linked", "unlinked" or nil when the objective is gone.
function M.toggle_link(id: string, tab: number, facts: TabFacts?, window: string): string?
	local result: string? = nil
	change(id, function(o, s)
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

-- Removes every link to the tabs in `closed` and their snapshots; returns how many links went.
function M.prune(closed: { number }): number
	local gone = 0
	local set: { [number]: boolean } = {}
	for _, tab in closed do
		set[tab] = true
	end
	M.mutate(function(s)
		for _, o in s.objectives do
			for i = #o.tabs, 1, -1 do
				if set[o.tabs[i]] then
					table.remove(o.tabs, i)
					gone += 1
				end
			end
		end
		for tab in set do
			s.tabs[tostring(tab)] = nil
		end
		return true
	end)
	return gone
end

-- ---- view settings ----

function M.set_view(fn: (ViewState) -> boolean?)
	M.mutate(function(s)
		return fn(s.view)
	end)
end

return M
