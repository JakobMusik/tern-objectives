--!strict
-- The graph's behaviour: rendering, the click verbs (design D5), the objective menu and the palette
-- commands. Selection lives in this VM only (design D6).

local Store = require("./store")
local Model = require("./model")
local View = require("./view")
local Canvas = require("./canvas")
local Dates = require("./dates")
local Details = require("./details")
local Refresh = require("./refresh")

local M = {}

local selected: string? = nil
local edges_css = ""

local function toast_gone(cx: WindowCx)
	cx:toast("info", "That objective no longer exists")
end

-- Builds the view for the current state, refreshing tab snapshots and the edge sheet on the way.
local function build(cx: WindowCx): View.Built
	local started = tern.now()
	local state = Store.read()
	local win = Model.read(cx, Canvas.find(cx))
	Store.refresh_snapshots(state, win.tabs :: any, win.key)
	if selected ~= nil and Store.find(state, selected) == nil then
		selected = nil
	end
	Details.begin(cx)
	local built = View.build(state, win, {
		selected = selected,
		today = Dates.today(),
		details = function(row)
			return Details.lines(cx, row)
		end,
	})
	if built.css ~= edges_css then
		tern.css("edges", built.css)
		edges_css = built.css
	end
	local took = tern.now() - started
	if took > 20 then
		tern.log.warn(string.format("objectives: render took %.1f ms (budget is 50 ms)", took))
	else
		tern.log.debug(string.format("objectives: render %.1f ms", took))
	end
	return built
end

-- Draws the graph again when it is shown; does nothing otherwise.
function M.render(cx: WindowCx)
	if Canvas.find(cx) == nil then
		return
	end
	Canvas.update(cx, build(cx).view)
	Refresh.rendered(cx)
	Refresh.start()
end

function M.open(cx: WindowCx)
	local pane, err = Canvas.show(cx, build(cx).view)
	if pane == nil then
		cx:toast("error", "Objectives: could not open the graph", err)
		return
	end
	Refresh.rendered(cx)
	Refresh.start()
end

-- ---- the tab a command acts on ----

local function focused_tab(cx: WindowCx): (number?, Model.Tab?, string)
	local pane = cx.session:focused()
	local tab = if pane ~= nil then cx.session:tab_of(pane) else nil
	if tab == nil then
		return nil, nil, ""
	end
	local win = Model.read(cx, Canvas.find(cx))
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
	if from_graph and Canvas.find(cx) == nil then
		M.open(cx)
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
			selected = id
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
			selected = nil
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
	local win = Model.read(cx, Canvas.find(cx))
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
	Canvas.close(cx)
	cx.layout:focus(t.focus)
end

local function jump_pane(cx: WindowCx, pane: number)
	local info = cx.session:pane(pane)
	if info == nil or info.tab == nil or info.parked then
		cx:toast("info", "That pane is no longer open")
		return
	end
	Canvas.close(cx)
	cx.layout:focus(pane)
end

-- ---- clicks ----

function M.action(ev: CanvasAction, cx: WindowCx): boolean?
	local act, value = ev.act, ev.value or ""
	if act == "sel" then
		selected = if selected == value then nil else value
	elseif act == "bg" then
		if selected == nil then
			return true
		end
		selected = nil
	elseif act == "done" then
		if not Store.toggle_done(value) then
			toast_gone(cx)
		end
	elseif act == "prio" then
		if not Store.cycle_priority(value) then
			toast_gone(cx)
		end
	elseif act == "menu" then
		menu(cx, value)
		return true
	elseif act == "new" then
		new_objective(cx, nil, nil, "", true)
		return true
	elseif act == "link" then
		local tab = tonumber(value)
		if selected == nil or tab == nil then
			return true
		end
		local win = Model.read(cx, Canvas.find(cx))
		if Store.toggle_link(selected, tab, win.tabs[tab] :: any, win.key) == nil then
			toast_gone(cx)
		end
	elseif act == "tab" then
		local tab = tonumber(value)
		if tab ~= nil then
			jump_tab(cx, tab)
		end
		return true
	elseif act == "pane" then
		local pane = tonumber(value)
		if pane ~= nil then
			jump_pane(cx, pane)
		end
		return true
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
		return true
	else
		return nil
	end
	M.render(cx)
	return true
end

return M
