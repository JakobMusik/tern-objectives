--!strict
-- The graph's behaviour: rendering, the click verbs (design D5, P4), the objective menu and the
-- palette commands. Selection lives in this VM only (design D6).

local Agents = require("./agents")
local Store = require("./store")
local Model = require("./model")
local View = require("./view")
local Surface = require("./surface")
local Dates = require("./dates")
local Details = require("./details")
local Refresh = require("./refresh")

local M = {}

local selected: string? = nil
-- The tabs the selection was linked to when it was made: they stay first in the right column until
-- the selection changes, whatever is linked meanwhile (design D3). Never stored, like the selection.
local pinned: { [number]: boolean }? = nil

-- Every change of the selection goes through here, so the fixed set always matches it.
local function select(id: string?)
	selected = id
	pinned = nil
	if id ~= nil then
		local o = Store.find(Store.read(), id)
		if o ~= nil then
			local set: { [number]: boolean } = {}
			for _, tab in o.tabs do
				set[tab] = true
			end
			pinned = set
		end
	end
end

-- The pane that had focus when the graph was last opened fresh (design P5); never stored.
local origin: number? = nil
local edges_css = ""

-- The Undo notice after marking done or removing (review-done-objectives, design D6); never stored.
type Undo = { text: string, saved: Store.Saved, timer: TimerHandle? }
local undo: Undo? = nil
local UNDO_MS = 10000

local function drop_undo()
	if undo ~= nil and undo.timer ~= nil then
		undo.timer:cancel()
	end
	undo = nil
end

-- Shows the notice for 10 s, or until the next click in the graph.
local function offer_undo(text: string, saved: Store.Saved)
	drop_undo()
	local entry: Undo = { text = text, saved = saved, timer = nil }
	entry.timer = tern.timer(UNDO_MS, function(cx: WindowCx?)
		if undo == entry then
			undo = nil
			if cx ~= nil then
				M.render(cx)
			end
		end
	end)
	undo = entry
end

-- Review mode (review-done-objectives, design D4): never stored; a fresh open of the graph starts
-- without it, and it ends once nothing is due.
local reviewing = false

local function toast_gone(cx: WindowCx)
	cx:toast("info", "That objective no longer exists")
end

-- Builds the view for the current state, refreshing tab snapshots and the edge sheet on the way.
local function build(cx: WindowCx): View.Built
	local state = Store.read()
	local win = Model.read(cx, Surface.find(cx))
	Store.refresh_snapshots(state, win.tabs :: any, win.key)
	Store.save_sessions(state, {}, win.live)
	if selected ~= nil and Store.find(state, selected) == nil then
		select(nil)
	end
	Details.begin(cx, state.agents)
	local built = View.build(state, win, {
		selected = selected,
		pinned = pinned,
		origin = origin,
		today = Dates.today(),
		kind = Details.type,
		details = function(row)
			return Details.lines(cx, row)
		end,
		undo = if undo ~= nil then undo.text else nil,
		reviewing = reviewing,
	})
	if built.due == 0 then
		reviewing = false
	end
	if built.css ~= edges_css then
		tern.css("edges", built.css)
		edges_css = built.css
	end
	return built
end

-- Logs a render's cost: building the view, then handing it to the canvas.
local function report(started: number, built: number)
	local done = tern.now()
	local total = done - started
	local msg = string.format("objectives: render %.1f ms (build %.1f, hand-over %.1f)", total, built - started, done - built)
	if total > 20 then
		tern.log.warn(msg .. ", over the 20 ms target (the budget is 50 ms)")
	else
		tern.log.debug(msg)
	end
end

-- Draws the graph again when it is shown; does nothing otherwise.
function M.render(cx: WindowCx)
	if Surface.find(cx) == nil then
		return
	end
	local started = tern.now()
	local view = build(cx).view
	local built = tern.now()
	Surface.update(cx, view)
	report(started, built)
	Refresh.rendered(cx)
	Refresh.start()
end

-- Shows the graph over the current tab (design G1). A fresh open takes the focused pane as the
-- origin; `keep_origin` (the reopen after one of the graph's pickers) keeps the one it had.
function M.open(cx: WindowCx, keep_origin: boolean?)
	if not keep_origin then
		drop_undo()
		reviewing = false
		local focused = cx.session:focused()
		if focused ~= nil and focused ~= Surface.find(cx) then
			origin = focused
		end
	end
	local started = tern.now()
	local view = build(cx).view
	local built = tern.now()
	local pane, err = Surface.show(cx, view)
	report(started, built)
	if pane == nil then
		cx:toast("error", "Objectives: could not open the graph", err)
		return
	end
	Refresh.rendered(cx)
	Refresh.start()
end

-- ⌃⌘O: closes the graph shown over this tab, else opens it here.
function M.toggle(cx: WindowCx)
	if Surface.here(cx) ~= nil then
		Surface.close(cx)
		return
	end
	M.open(cx)
end

-- ---- the tab a command acts on ----

local function focused_tab(cx: WindowCx): (number?, Model.Tab?, string)
	local pane = cx.session:focused()
	local tab = if pane ~= nil then cx.session:tab_of(pane) else nil
	if tab == nil then
		return nil, nil, ""
	end
	local win = Model.read(cx, Surface.find(cx))
	return tab, win.tabs[tab], win.key
end

local function no_tab(cx: WindowCx)
	cx:toast("error", "The focused pane is not in a tab", "Focus a pane in a tab, then run the command again.")
end

-- ---- pickers and fields started from the graph ----

-- Tern opens cx:pick and cx:prompt at window level, outside the glimpse, so a click on the field
-- (or on the graph while it is open) counts as a click outside and closes the glimpse. Every flow the
-- graph starts ends here, answered or dismissed: it shows the graph again if that happened.
local function finish(cx: WindowCx?, from_graph: boolean)
	if cx == nil then
		return
	end
	if from_graph and Surface.find(cx) == nil then
		M.open(cx, true)
	else
		M.render(cx)
	end
end

-- ---- creating ----

local function new_objective(cx: WindowCx, tab: number?, facts: Model.Tab?, window: string, from_graph: boolean)
	cx:prompt({ placeholder = "New objective title", icon = "list-checks", action = "create" }):next(function(text, _err, cx2)
		if text == nil or cx2 == nil then
			finish(cx2, from_graph)
			return
		end
		local id = Store.create(text, tab, facts :: any, window)
		if id == nil then
			cx2:toast("error", "An objective needs a title")
		elseif tab == nil then
			select(id)
		else
			cx2:toast("success", "Objective created for this tab")
		end
		finish(cx2, from_graph)
	end)
end

function M.new_for_tab(cx: WindowCx)
	local tab, facts, window = focused_tab(cx)
	if tab == nil then
		no_tab(cx)
		return
	end
	new_objective(cx, tab, facts, window, false)
end

-- ---- linking from the palette ----

local function sorted_open(state: Store.State): { Store.Objective }
	local list = {}
	for _, o in state.objectives do
		if not o.done then
			table.insert(list, o)
		end
	end
	table.sort(list, function(a, b)
		if a.priority ~= b.priority then
			return a.priority < b.priority
		end
		if a.due ~= b.due then
			if a.due == nil then
				return false
			elseif b.due == nil then
				return true
			end
			return (a.due :: string) < (b.due :: string)
		end
		return a.created < b.created
	end)
	return list
end

function M.link_tab(cx: WindowCx)
	local tab, facts, window = focused_tab(cx)
	if tab == nil then
		no_tab(cx)
		return
	end
	local open = sorted_open(Store.read())
	if #open == 0 then
		cx:toast("info", "No objectives yet", "Create one with Objectives: New objective for this tab…")
		return
	end
	local items: { PickItem } = {}
	for _, o in open do
		table.insert(items, {
			label = o.title,
			detail = "P" .. o.priority,
			current = table.find(o.tabs, tab) ~= nil,
			id = o.id,
		})
	end
	cx:pick({ items = items, placeholder = "Link this tab to an objective", icon = "list-checks", action = "toggle link" }):next(function(item, _err, cx2)
		if item == nil or cx2 == nil then
			return
		end
		local result = Store.toggle_link(item.id, tab :: number, facts :: any, window)
		if result == "linked" then
			cx2:toast("success", "Linked to " .. item.label)
		elseif result == "unlinked" then
			cx2:toast("info", "Unlinked from " .. item.label)
		end
		M.render(cx2)
	end)
end

-- ---- the objective menu (always started from the graph) ----

local function rename(cx: WindowCx, o: Store.Objective)
	cx:prompt({ value = o.title, placeholder = "Objective title", action = "rename" }):next(function(text, _err, cx2)
		if text ~= nil and cx2 ~= nil then
			if Store.clean_title(text) == nil then
				cx2:toast("error", "An objective needs a title")
			elseif not Store.rename(o.id, text) then
				toast_gone(cx2)
			end
		end
		finish(cx2, true)
	end)
end

local function side_note(cx: WindowCx, o: Store.Objective)
	cx:prompt({ value = o.note or "", placeholder = "Side note (one line, empty removes it)", action = "save" }):next(function(text, _err, cx2)
		if text ~= nil and cx2 ~= nil and not Store.set_note(o.id, text) then
			toast_gone(cx2)
		end
		finish(cx2, true)
	end)
end

local function pick_date(cx: WindowCx, o: Store.Objective)
	cx:prompt({ value = o.due or Dates.key(Dates.today()), placeholder = "Due date, YYYY-MM-DD", action = "set" }):next(function(text, _err, cx2)
		if text ~= nil and cx2 ~= nil then
			local day = Dates.parse(text)
			if day == nil then
				cx2:toast("error", "Not a date: " .. text, "Use YYYY-MM-DD, for example 2026-11-20.")
			elseif not Store.set_due(o.id, Dates.key(day)) then
				toast_gone(cx2)
			end
		end
		finish(cx2, true)
	end)
end

local function due_date(cx: WindowCx, o: Store.Objective)
	local today = Dates.today()
	local items: { PickItem } = {}
	for _, p in Dates.presets(today) do
		local key = Dates.key(p.day)
		table.insert(items, {
			label = p.label,
			detail = os.date("%a %Y-%m-%d", os.time({ year = p.day.year, month = p.day.month, day = p.day.day, hour = 12 })) :: string,
			current = o.due == key,
			due = key,
		})
	end
	table.insert(items, { label = "Pick date…", detail = "YYYY-MM-DD", op = "pick" })
	table.insert(items, { label = "Clear", detail = if o.due ~= nil then o.due else "no due date", op = "clear" })
	cx:pick({ items = items, placeholder = "Due date for " .. o.title, icon = "calendar" }):next(function(item, _err, cx2)
		if item ~= nil and cx2 ~= nil then
			if item.op == "pick" then
				pick_date(cx2, o)
				return
			end
			if not Store.set_due(o.id, if item.op == "clear" then nil else item.due) then
				toast_gone(cx2)
			end
		end
		finish(cx2, true)
	end)
end

local function new_tag(cx: WindowCx, o: Store.Objective)
	cx:prompt({ placeholder = "New tag", action = "add" }):next(function(text, _e, cx2)
		if text ~= nil and cx2 ~= nil then
			local tag = Store.clean_tag(text)
			if tag == nil then
				cx2:toast("error", "A tag needs a name")
			elseif not Store.add_tag(o.id, tag) and Store.find(Store.read(), o.id) == nil then
				toast_gone(cx2)
			end
		end
		finish(cx2, true)
	end)
end

local function tags(cx: WindowCx, o: Store.Objective)
	local items: { PickItem } = {}
	for _, tag in Store.all_tags(Store.read()) do
		table.insert(items, { label = "#" .. tag, current = table.find(o.tags, tag) ~= nil, tag = tag })
	end
	table.insert(items, { label = "New tag…", op = "new" })
	cx:pick({ items = items, placeholder = "Tags for " .. o.title, icon = "tag", action = "toggle" }):next(function(item, _err, cx2)
		if item ~= nil and cx2 ~= nil then
			if item.op == "new" then
				new_tag(cx2, o)
				return
			end
			if not Store.toggle_tag(o.id, item.tag) then
				toast_gone(cx2)
			end
		end
		finish(cx2, true)
	end)
end

local function delete(cx: WindowCx, o: Store.Objective)
	cx:pick({
		items = {
			{ label = "Delete “" .. o.title .. "”", detail = "removes it and its links", op = "delete", icon = "trash" },
			{ label = "Cancel", op = "cancel" },
		},
		placeholder = "Delete this objective?",
		icon = "trash",
	}):next(function(item, _err, cx2)
		if item ~= nil and item.op == "delete" and Store.delete(o.id) and selected == o.id then
			select(nil)
		end
		finish(cx2, true)
	end)
end

local function menu(cx: WindowCx, id: string)
	local o = Store.find(Store.read(), id)
	if o == nil then
		toast_gone(cx)
		return
	end
	local tag_list = {}
	for _, tag in o.tags do
		table.insert(tag_list, "#" .. tag)
	end
	cx:pick({
		items = {
			{ label = "Rename", detail = o.title, op = "rename", icon = "pencil" },
			{ label = "Side note", detail = o.note or "none", op = "note", icon = "note" },
			{ label = "Due date", detail = o.due or "none", op = "due", icon = "calendar" },
			{ label = "Tags", detail = if #tag_list > 0 then table.concat(tag_list, " ") else "none", op = "tags", icon = "tag" },
			{ label = "Delete", detail = "asks first", op = "delete", icon = "trash" },
		},
		placeholder = o.title,
		icon = "list-checks",
	}):next(function(item, _err, cx2)
		if item == nil or cx2 == nil then
			finish(cx2, true)
			return
		end
		-- Re-read: the objective may have changed while the picker was open.
		local fresh = Store.find(Store.read(), id)
		if fresh == nil then
			toast_gone(cx2)
			finish(cx2, true)
		elseif item.op == "rename" then
			rename(cx2, fresh)
		elseif item.op == "note" then
			side_note(cx2, fresh)
		elseif item.op == "due" then
			due_date(cx2, fresh)
		elseif item.op == "tags" then
			tags(cx2, fresh)
		elseif item.op == "delete" then
			delete(cx2, fresh)
		end
	end)
end

-- ---- pruning ----

local function prune(cx: WindowCx)
	local closed = build(cx).closed
	local n = #closed
	if n == 0 then
		return
	end
	local what = string.format("%d closed tab%s", n, if n == 1 then "" else "s")
	cx:pick({
		items = {
			{ label = "Prune " .. what, detail = "removes their links and saved rows", op = "prune", icon = "trash" },
			{ label = "Cancel", op = "cancel" },
		},
		placeholder = "Remove the links of " .. what .. "?",
		icon = "trash",
	}):next(function(item, _err, cx2)
		if item ~= nil and item.op == "prune" then
			Store.prune(closed)
		end
		finish(cx2, true)
	end)
end

-- ---- navigation (design D10) ----

local function jump_tab(cx: WindowCx, tab: number)
	local state = Store.read()
	local win = Model.read(cx, Surface.find(cx))
	local t = win.tabs[tab]
	if t == nil then
		local snap = state.tabs[tostring(tab)]
		if Model.status(win, tab, if snap ~= nil then snap.window else nil) == "elsewhere" then
			cx:toast("info", "That tab is in another Tern window")
		else
			cx:toast("info", "That tab is closed")
		end
		return
	end
	Surface.close(cx)
	cx.layout:focus(t.focus)
end

local function jump_pane(cx: WindowCx, pane: number)
	local info = cx.session:pane(pane)
	if info == nil or info.tab == nil or info.parked then
		cx:toast("info", "That pane is no longer open")
		return
	end
	Surface.close(cx)
	cx.layout:focus(pane)
end

-- ---- resuming a closed tab's Claude chats (resume-closed-agents, design D5, D6) ----

local function resume(cx: WindowCx, tab: number)
	if cx.hosts:current().kind ~= "local" then
		cx:toast("info", "Resume works in a session on this Mac")
		return
	end
	local state = Store.read()
	local win = Model.read(cx, Surface.find(cx))
	local snap = state.tabs[tostring(tab)]
	if win.tabs[tab] ~= nil or snap == nil then
		cx:toast("info", "That tab is no longer closed")
		return
	end
	local chats: { Store.AgentSession } = {}
	for _, p in snap.panes do
		local s = if p.kind == "agent" then state.agents[tostring(p.pane)] else nil
		-- Only an agent row's session, and only a session id, is ever typed into the shell.
		if s ~= nil and Agents.is_session_id(s.session) then
			table.insert(chats, s)
		end
	end
	if #chats == 0 then
		cx:toast("info", "That tab has no saved Claude chat to resume")
		return
	end
	Surface.close(cx)
	-- `new_tab` and `split` return the new shell pane; typing into it at once works (task 1.2).
	local moved: { [string]: Store.AgentSession } = {}
	local first: number? = nil
	local previous: number? = nil
	for _, s in chats do
		local pane = if previous == nil
			then cx.layout:new_tab({ cwd = s.cwd })
			else cx.layout:split(previous, "right", { cwd = s.cwd }, { focus = false })
		if pane == nil then
			break
		end
		cx:run(pane, "claude --resume " .. s.session .. "\r")
		moved[tostring(pane)] = { agent = s.agent, session = s.session, cwd = s.cwd, seen = os.time() }
		first = first or pane
		previous = pane
	end
	local new_tab = if first ~= nil then cx.session:tab_of(first) else nil
	if new_tab == nil then
		cx:toast("error", "Objectives: could not open a tab to resume in")
		return
	end
	Store.adopt(tab, new_tab, moved)
	-- The window lists the new tab only after this call: store its snapshot once it does. Its panes
	-- are still shells starting claude, so the resumed ones are stored as agents, as they will be.
	tern.timer(250, function(cx2: WindowCx?)
		if cx2 == nil then
			return
		end
		local w = Model.read(cx2, Surface.find(cx2))
		local t = w.tabs[new_tab]
		if t ~= nil then
			for _, r in t.rows do
				if moved[tostring(r.pane)] ~= nil then
					r.kind = "agent"
				end
			end
		end
		Store.refresh_snapshots(Store.read(), w.tabs :: any, w.key)
	end)
end

-- ---- the rename key (design D6) ----

-- ⌥R: the Rename field for the selected objective, while the graph is shown over this tab. A plugin
-- key runs wherever focus is, whatever `available` says, so without both it says what it needs.
function M.rename_selected(cx: WindowCx)
	local o = if selected ~= nil then Store.find(Store.read(), selected) else nil
	if o == nil or Surface.here(cx) == nil then
		cx:toast("info", "Select an objective in the graph to rename it")
		return
	end
	rename(cx, o)
end

-- Whether the palette lists the rename command: an objective is selected in a graph shown here.
function M.can_rename(cx: WindowCx): boolean
	return selected ~= nil and Surface.here(cx) ~= nil
end

-- ---- clicks ----

export type Action = { act: string, value: string? }

function M.action(ev: Action, cx: WindowCx)
	local act, value = ev.act, ev.value or ""
	-- Any click but Undo drops the Undo notice (review design D6).
	local had_undo = undo ~= nil
	if act ~= "undo" then
		drop_undo()
	end
	if act == "sel" then
		select(if selected == value then nil else value)
	elseif act == "bg" then
		if selected == nil and not had_undo then
			return
		end
		select(nil)
	elseif act == "done" then
		local saved = Store.mark_done(value, Dates.today())
		if saved ~= nil then
			offer_undo("Marked done “" .. saved.record.title .. "”", saved)
		elseif Store.find(Store.read(), value) == nil then
			toast_gone(cx)
		end
	elseif act == "rm" then
		-- A done objective's trash icon: removed at once, with Undo (review design D7).
		local saved = Store.remove(value)
		if saved ~= nil then
			if selected == value then
				select(nil)
			end
			offer_undo("Removed “" .. saved.record.title .. "”", saved)
		elseif Store.find(Store.read(), value) == nil then
			toast_gone(cx)
		end
	elseif act == "undo" then
		if undo ~= nil then
			Store.restore(undo.saved)
			drop_undo()
		end
	elseif act == "noop" then
		-- A done objective's box: done is final, so the click only drops the notice (design D7).
	elseif act == "rev" then
		reviewing = not reviewing
	elseif act == "rate" then
		-- "<objective>:<hard|good|easy>" from a review node's buttons (review design D4).
		local id, grade = string.match(value, "^([^:]+):(%a+)$")
		if id ~= nil and (grade == "hard" or grade == "good" or grade == "easy") then
			if not Store.rate(id, grade :: any, Dates.today()) then
				toast_gone(cx)
			end
		end
	elseif act == "prio" then
		if not Store.cycle_priority(value) then
			toast_gone(cx)
		end
	elseif act == "menu" then
		menu(cx, value)
		return
	elseif act == "new" then
		new_objective(cx, nil, nil, "", true)
		return
	elseif act == "link" then
		local tab = tonumber(value)
		if selected == nil or tab == nil then
			return
		end
		local win = Model.read(cx, Surface.find(cx))
		if Store.toggle_link(selected, tab, win.tabs[tab] :: any, win.key) == nil then
			toast_gone(cx)
		end
	elseif act == "lnk" then
		-- A row of a tab node's menu: "<objective>:<tab>", no selection needed (design P6).
		local id, tab_text = string.match(value, "^([^:]+):(%d+)$")
		local tab = tonumber(tab_text)
		if id == nil or tab == nil then
			return
		end
		local win = Model.read(cx, Surface.find(cx))
		if Store.toggle_link(id, tab, win.tabs[tab] :: any, win.key) == nil then
			toast_gone(cx)
		end
	elseif act == "tab" then
		local tab = tonumber(value)
		if tab ~= nil then
			jump_tab(cx, tab)
		end
		return
	elseif act == "resume" then
		local tab = tonumber(value)
		if tab ~= nil then
			resume(cx, tab)
		end
		return
	elseif act == "pane" then
		local pane = tonumber(value)
		if pane ~= nil then
			jump_pane(cx, pane)
		end
		return
	elseif act == "exp" then
		Store.set_view(function(v)
			v.expanded[value] = if v.expanded[value] then nil else true
			return true
		end)
	elseif act == "scope" then
		Store.set_view(function(v)
			if v.scope == value then
				return false
			end
			v.scope = if value == "session" then "session" else "all"
			return true
		end)
	elseif act == "tag" then
		Store.set_view(function(v)
			v.tag = if v.tag == value then nil else value
			return true
		end)
	elseif act == "donegrp" then
		Store.set_view(function(v)
			v.done_open = not v.done_open
			return true
		end)
	elseif act == "prune" then
		prune(cx)
		return
	else
		return
	end
	M.render(cx)
end

return M
