--!strict
-- The graph's behaviour: rendering, the click verbs (design D5, P4), the action bar, the settings page
-- and the palette commands. Selection lives in this VM only (design D6).

local Agents = require("./agents")
local Store = require("./store")
local Model = require("./model")
local View = require("./view")
local Surface = require("./surface")
local Dates = require("./dates")
local Details = require("./details")
local Refresh = require("./refresh")
local Keys = require("./keys")

local M = {}

-- Which page the graph's canvas shows (custom-order-and-direct-controls, design D6): "graph", or
-- "settings" for Configure. Never stored; a fresh open shows the graph.
local page = "graph"

-- Registers the plugin's commands again: every keybinds write drops all plugins' keys from the keymap
-- until a run-time registration (design D7). `window.luau` hands it over at load.
local reregister: (() -> ())? = nil

function M.on_keybinds(fn: () -> ())
	reregister = fn
end

local selected: string? = nil

-- The open objective lifted by its grip (custom-order-and-direct-controls, design D2); never stored.
local moving: string? = nil

-- The question an action is asking in place (custom-order-and-direct-controls, design D4), never
-- stored: "close" for an objective's tabs, from its bar or from the done notice, and "done_tabs" for
-- the header's "Close n done tabs" (D11). Any other click ends it.
type Confirm = { kind: string, id: string?, where: string? }
local confirm: Confirm? = nil

-- The pane that had focus when the graph was last opened fresh (design P5); never stored.
local origin: number? = nil
local edges_css = ""

-- The Undo notice after marking done or removing (review-done-objectives, design D6); never stored.
-- `close`: after marking done, the objective whose tabs its "Close <n> tabs" button closes, and n
-- (close-linked-tabs, design D8).
export type NoticeClose = { id: string, n: number }
type Undo = { text: string, saved: Store.Saved, timer: TimerHandle?, close: NoticeClose? }
local undo: Undo? = nil
local UNDO_MS = 10000

local function drop_undo()
	if undo ~= nil and undo.timer ~= nil then
		undo.timer:cancel()
	end
	undo = nil
end

-- Shows the notice for 10 s, or until the next click in the graph.
local function offer_undo(text: string, saved: Store.Saved, close: NoticeClose?)
	drop_undo()
	local entry: Undo = { text = text, saved = saved, timer = nil, close = close }
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

-- Review mode (review-done-objectives, design D4): never stored, so each window has its own and a
-- plugin reload forgets it. A fresh open keeps it (remember-review-mode, design D1); it ends once
-- nothing is due, on the active Review button, and on ⌥N.
local reviewing = false

local function toast_gone(cx: WindowCx)
	cx:toast("info", "That objective no longer exists")
end

-- Builds the view for the current state, refreshing tab snapshots and the edge sheet on the way.
local function build(cx: WindowCx): View.Built
	local state = Store.read()
	if page == "settings" then
		-- The settings page reads no window model and no agents (design D6). Its rows show the keys
		-- layered from the user's keybinds, which hold at once after a write (task 5.2).
		local built = View.build_settings(state, Keys.in_effect(cx.settings:keybinds()))
		if built.css ~= edges_css then
			tern.css("edges", built.css)
			edges_css = built.css
		end
		return built
	end
	local win = Model.read(cx, Surface.find(cx))
	Store.refresh_snapshots(state, win.tabs :: any, win.key)
	Store.save_sessions(state, {}, win.live)
	if selected ~= nil and Store.find(state, selected) == nil then
		selected = nil
	end
	local lifted = if moving ~= nil then Store.find(state, moving) else nil
	if lifted == nil or lifted.done then
		moving = nil
	end
	-- A filter on a tag no objective holds any more has no chip left to clear it: drop it here, which
	-- covers every way a tag can go, other windows' changes included (fix-spec-drift D1).
	local tag = state.view.tag
	if tag ~= nil and table.find(Store.all_tags(state), tag) == nil then
		Store.set_view(function(v)
			if v.tag ~= tag then
				return false
			end
			v.tag = nil
			return true
		end)
		state.view.tag = nil
	end
	Details.begin(cx, state.agents)
	local built = View.build(state, win, {
		selected = selected,
		origin = origin,
		today = Dates.today(),
		kind = Details.type,
		details = function(row)
			return Details.lines(cx, row)
		end,
		undo = if undo ~= nil then undo.text else nil,
		undo_close = if undo ~= nil then undo.close else nil,
		reviewing = reviewing,
		attention = Details.attention,
		moving = moving,
		confirm = confirm,
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
		moving = nil
		confirm = nil
		page = "graph"
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
	-- Restored chats nobody has written to are saved only from here or the plugin's start (D2).
	Agents.request()
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
			selected = id
		else
			cx2:toast("success", "Objective created for this tab")
		end
		finish(cx2, from_graph)
	end)
end

-- ⌥N (custom-order-and-direct-controls, design D5): a new objective in the graph, as "＋ New objective"
-- makes it, so it lands selected; when the graph isn't shown over this tab, a fresh open comes first.
-- Review mode ends first, since it hides open objectives (remember-review-mode, design D3).
function M.new_key(cx: WindowCx)
	local was_reviewing = reviewing
	reviewing = false
	if Surface.here(cx) == nil then
		M.open(cx)
	elseif page ~= "graph" or was_reviewing then
		page = "graph"
		M.render(cx)
	end
	new_objective(cx, nil, nil, "", true)
end

-- ---- Configure (custom-order-and-direct-controls, design D6–D8) ----

-- "Objectives: Configure" and the header's gear button: the settings page, over this tab.
function M.configure(cx: WindowCx)
	if Surface.here(cx) == nil then
		M.open(cx)
	end
	page = "settings"
	M.render(cx)
end

-- Writes `kb` as the user's keybinds, then registers the commands again so every plugin's keys come
-- back (design D7). False, with nothing written, when Tern refuses the map.
local function write_keybinds(cx: WindowCx, kb: { [string]: any }): boolean
	local ok = pcall(function()
		cx.settings:set("keybinds", kb)
	end)
	if reregister ~= nil then
		reregister()
	end
	return ok
end

-- Change, Remove or Reset on a shortcut row: edits the user's keybinds, checks the keys now in effect,
-- and puts the old map back when they aren't what was asked for.
local function apply_keys(cx: WindowCx, id: string, op: string, new: string?)
	local c = Keys.command(id)
	if c == nil then
		return
	end
	local before = cx.settings:keybinds()
	if not write_keybinds(cx, Keys.edited(before, id, op, new)) then
		cx:toast("error", "Tern refused that shortcut", "Nothing was changed.")
		return
	end
	local want: string? = if op == "change" then new elseif op == "reset" then (if c.default ~= nil then Keys.canon(c.default :: string) else nil) else nil
	-- The user layer shows at once, while the plugins' own keys come back with the keymap rebuild the
	-- registration asks for, a moment later (task 5.2). So the check is that no other keys run the
	-- command, and that a changed shortcut, which is a user entry, already does.
	local got = Keys.effective(cx.actions:keys())[id] or {}
	local ok = true
	for _, chord in got do
		if Keys.canon(chord) ~= want then
			ok = false
		end
	end
	if op == "change" and #got == 0 then
		ok = false
	end
	if not ok then
		write_keybinds(cx, before)
		cx:toast("error", "That shortcut didn't take", "Your keybinds are back as they were.")
		return
	end
	if op == "change" then
		cx:toast("success", c.label .. ": " .. Keys.display(new :: string))
	elseif op == "remove" then
		cx:toast("info", c.label .. " has no shortcut now")
	else
		cx:toast("info", c.label .. ": " .. (if want ~= nil then Keys.display(want) else "no shortcut"))
	end
end

-- Change on a shortcut row: a field for the new keys, spelled as Tern's keybinds spell them; refused
-- when it doesn't parse, lacks ⌃, ⌥ or ⌘, or runs something else already (design D7).
local function change_keys(cx: WindowCx, id: string)
	local c = Keys.command(id)
	if c == nil then
		return
	end
	local current = Keys.in_effect(cx.settings:keybinds())[id] or {}
	cx:prompt({
		value = current[1] or "",
		placeholder = "Shortcut for " .. c.label .. ", for example ctrl+alt+n",
		icon = "keyboard",
		action = "set",
	}):next(function(text, _err, cx2)
		if text == nil or cx2 == nil then
			finish(cx2, true)
			return
		end
		local canon = Keys.canon(text)
		if canon == nil then
			cx2:toast("error", "“" .. text .. "” isn't a shortcut", "Spell it as in Tern's keybinds, for example ctrl+alt+n.")
		elseif not Keys.has_modifier(canon) then
			cx2:toast("error", "A shortcut needs ⌃, ⌥ or ⌘", "Otherwise it would take that key away from typing everywhere.")
		else
			local action = Keys.action(id)
			local other = Keys.in_use(cx2.actions:keys(), canon, action)
			if other ~= nil then
				local ok, info = pcall(function()
					return cx2.actions:describe(other :: string)
				end)
				local name = if ok and info ~= nil and info.label ~= nil then info.label else other
				cx2:toast("error", Keys.display(canon) .. " is already in use", "It runs “" .. name .. "”. Pick another shortcut.")
			elseif c.default ~= nil and Keys.canon(c.default :: string) == canon then
				apply_keys(cx2, id, "reset", nil)
			else
				apply_keys(cx2, id, "change", canon)
			end
		end
		finish(cx2, true)
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

-- The open objectives in the custom order (custom-order-and-direct-controls, design D1).
local function open_in_order(state: Store.State): { Store.Objective }
	local list = {}
	for _, o in state.objectives do
		if not o.done then
			table.insert(list, o)
		end
	end
	return list
end

function M.link_tab(cx: WindowCx)
	local tab, facts, window = focused_tab(cx)
	if tab == nil then
		no_tab(cx)
		return
	end
	local open = open_in_order(Store.read())
	if #open == 0 then
		cx:toast("info", "No objectives yet", "Create one with Objectives: New objective for this tab…")
		return
	end
	local items: { PickItem } = {}
	for _, o in open do
		-- The creation time tells same-titled objectives apart; the label stays the plain title for
		-- typing and the toast (creation-time-suffix D3).
		local created = Dates.short(o.created)
		table.insert(items, {
			label = o.title,
			detail = "P" .. o.priority .. (if created ~= nil then " · " .. created else ""),
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

-- ---- closing tabs (close-linked-tabs, design D1–D5; custom-order-and-direct-controls, D4) ----

local function plural(n: number, word: string): string
	return string.format("%d %s%s", n, word, if n == 1 then "" else "s")
end

-- Saves the omp chats, then closes every pane of the tabs `count` gives, counted again now; the graph
-- first when it is over one of them, since a tab holding only the graph would stay open. `count`
-- returns the tabs and the toast's ending, or nil when what it counts is gone. No link changes.
local function close_tabs(cx: WindowCx, count: (cx: WindowCx, state: Store.State, win: Model.Window) -> ({ number }?, string))
	Agents.save_now(cx, function(ok: boolean, cx2: WindowCx?)
		if cx2 == nil then
			return
		end
		if not ok then
			cx2:toast("error", "Objectives: couldn't save the omp chats, so no tab was closed")
			finish(cx2, true)
			return
		end
		local win = Model.read(cx2, Surface.find(cx2))
		local tabs, what = count(cx2, Store.read(), win)
		if tabs == nil then
			toast_gone(cx2)
			finish(cx2, true)
			return
		end
		if #tabs == 0 then
			cx2:toast("info", "No open tab left to close")
			finish(cx2, true)
			return
		end
		local graph = Surface.find(cx2)
		local graph_tab = if graph ~= nil then cx2.session:tab_of(graph) else nil
		if graph_tab ~= nil and table.find(tabs, graph_tab) ~= nil then
			Surface.close(cx2)
		end
		for _, tab in tabs do
			for _, r in (win.tabs[tab] :: Model.Tab).rows do
				cx2.layout:close(r.pane)
			end
		end
		cx2:toast("success", "Closed " .. plural(#tabs, "tab") .. what)
		finish(cx2, true)
	end)
end

-- A done objective's "Close n tabs", from its action bar or its done notice, once confirmed.
local function close_objective_tabs(cx: WindowCx, id: string)
	close_tabs(cx, function(_cx, state, win)
		local o = Store.find(state, id)
		if o == nil then
			return nil, ""
		end
		return (View.closable(state, win, o)), " of “" .. o.title .. "”"
	end)
end

-- "Close n done tabs" in the header, once confirmed (custom-order-and-direct-controls, design D11): the
-- live tabs the graph shows that only done objectives link, counted again from a fresh build.
local function close_done_tabs(cx: WindowCx)
	close_tabs(cx, function(cx2, _state, _win)
		return build(cx2).done_tabs, " that only done objectives link"
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

-- ---- resuming a closed tab's omp chats (resume-closed-agents D5, D6; resume-omp-chats D5;
-- resume-in-original-session D1–D4) ----

-- The session a closed tab's chats come back in (resume-in-original-session, D1): the one with the
-- snapshot's session id, else the first with its name, exactly, then ignoring case; nil when none.
-- Names are matched here, not with `find_session`, which would take a name such as "3" for an id.
local function home_of(cx: WindowCx, snap: Store.TabSnap): SessionInfo?
	local sessions = cx.session:sessions()
	for _, s in sessions do
		if s.id == snap.session then
			return s
		end
	end
	local name = snap.session_name or ""
	for _, s in sessions do
		if s.name == name then
			return s
		end
	end
	for _, s in sessions do
		if string.lower(s.name) == string.lower(name) then
			return s
		end
	end
	return nil
end

-- Whether session `id` runs on this Mac (D2).
local function on_this_mac(cx: WindowCx, id: number): boolean
	local here: { [number]: boolean } = {}
	for _, h in cx.hosts:list() do
		if h.kind == "local" then
			here[h.id] = true
		end
	end
	for _, s in cx.sessions:list() do
		if s.id == id then
			return here[s.host] == true
		end
	end
	return false
end

local function resume(cx: WindowCx, tab: number)
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
		-- Only an agent row's chat, and only a chat file that is still there, is ever typed into
		-- the shell; the store holds no other kind of entry (design D3).
		if s ~= nil and Store.is_chat_file(s.session) and tern.fs.exists(s.session) then
			table.insert(chats, s)
		end
	end
	if #chats == 0 then
		cx:toast("info", "That tab has no omp chat left to resume")
		return
	end
	-- Its own session, else the current one (D1); never one on another machine (D2).
	local home = home_of(cx, snap)
	local target = home
	if target == nil then
		for _, s in cx.session:sessions() do
			if s.current then
				target = s
			end
		end
	end
	if target == nil or not on_this_mac(cx, target.id) then
		cx:toast("info", "Resume works in a session on this Mac")
		return
	end
	Surface.close(cx)
	-- Switching first opens the tab in that session, in this same call (D3, task 1.1).
	if not target.current then
		cx.sessions:switch(target.id)
	end
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
		cx:run(pane, "omp --resume " .. Agents.quote(s.session) .. "\r")
		moved[tostring(pane)] = { agent = s.agent, session = s.session, cwd = s.cwd, seen = os.time() }
		first = first or pane
		previous = pane
	end
	local new_tab = if first ~= nil then cx.session:tab_of(first) else nil
	if new_tab == nil then
		cx:toast("error", "Objectives: could not open a tab to resume in")
		return
	end
	-- Its old place (D4): a new tab is the last, so only an earlier position needs a move. The
	-- session's tabs were read before the new one opened.
	if home ~= nil and snap.position > 0 and snap.position <= #target.tabs then
		cx.layout:order_tab(new_tab, snap.position)
	end
	if home == nil then
		local name = snap.session_name or ""
		cx:toast("info", if name ~= "" then "Session “" .. name .. "” is gone: resumed here" else "Its session is gone: resumed here")
	end
	Store.adopt(tab, new_tab, moved)
	-- The window lists the new tab only after this call: store its snapshot once it does. Its panes
	-- are still shells starting omp, so the resumed ones are stored as agents, as they will be.
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
	-- Any click ends a question asked in place; Close and Cancel act on the one they answer (D4).
	local asked = confirm
	confirm = nil
	-- Any click but Undo, the notice's own "Close n tabs" and that question's Cancel drops the Undo
	-- notice (review design D6; close-linked-tabs D8).
	local had_undo = undo ~= nil
	local notice_kept = act == "closetabs" or (act == "cfx" and asked ~= nil and asked.where == "notice")
	if act ~= "undo" and not notice_kept then
		drop_undo()
	end
	-- Any click but the grips' and the drop zones' ends a move (design D2).
	local was_moving = moving ~= nil
	if act ~= "lift" and act ~= "drop" then
		moving = nil
	end
	-- Set by verbs whose own flow draws the graph later, or closes it.
	local later = false
	if act == "sel" then
		selected = if selected == value then nil else value
	elseif act == "bg" then
		if selected == nil and not had_undo and not was_moving and asked == nil then
			return
		end
		selected = nil
	elseif act == "lift" then
		-- The grip lifts its node; the lifted node's grip puts it back.
		moving = if moving == value then nil else value
	elseif act == "unlift" then
		-- The Moving notice's Cancel: the move already ended above.
	elseif act == "drop" then
		-- "<target>:<before|after>" from a drop zone: the lifted objective goes to that line.
		local target, where = string.match(value, "^([^:]+):(%a+)$")
		local id = moving
		moving = nil
		if id ~= nil and target ~= nil and not Store.move(id, target, where :: string) then
			toast_gone(cx)
		end
	elseif act == "done" then
		local saved = Store.mark_done(value, Dates.today())
		if saved ~= nil then
			-- D8: the notice offers to close the tabs that "Close linked tabs" would close.
			local state = Store.read()
			local o = Store.find(state, value)
			local n = if o ~= nil then #(View.closable(state, Model.read(cx, Surface.find(cx)), o)) else 0
			offer_undo("Marked done “" .. saved.record.title .. "”", saved, if n > 0 then { id = value, n = n } else nil)
		elseif Store.find(Store.read(), value) == nil then
			toast_gone(cx)
		end
	elseif act == "rm" or act == "del" then
		-- A done objective's trash icon, or Delete in an open one's action bar: removed at once, with
		-- Undo (review design D7; custom-order-and-direct-controls D3).
		local saved = Store.remove(value)
		if saved ~= nil then
			if selected == value then
				selected = nil
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
	elseif act == "close" then
		-- "Close n tabs" in a done objective's bar asks in the bar (D4).
		confirm = { kind = "close", id = value, where = "bar" }
	elseif act == "closetabs" then
		-- The done notice's "Close n tabs" (close-linked-tabs D8) asks in the notice, which keeps its
		-- Undo until the question is answered (D4).
		confirm = { kind = "close", id = value, where = "notice" }
	elseif act == "closedone" then
		-- The header's "Close n done tabs" asks in the header (D4, D11).
		confirm = { kind = "done_tabs" }
	elseif act == "cfm" then
		-- Close: the notice went above, with its Undo of done, as confirming always ended it.
		if asked ~= nil and asked.kind == "close" and asked.id ~= nil then
			close_objective_tabs(cx, asked.id)
			later = true
		elseif asked ~= nil and asked.kind == "done_tabs" then
			close_done_tabs(cx)
			later = true
		end
	elseif act == "cfx" then
		-- Cancel: the question ended above.
	elseif act == "note" or act == "due" or act == "tags" then
		-- The action bar's buttons open their field or picker directly (D3); `finish` draws after.
		local o = Store.find(Store.read(), value)
		if o == nil then
			toast_gone(cx)
		else
			if act == "note" then
				side_note(cx, o)
			elseif act == "due" then
				due_date(cx, o)
			else
				tags(cx, o)
			end
			later = true
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
		-- Priority no longer sorts, so the node stays where it is (custom-order-and-direct-controls, D1).
		if not Store.cycle_priority(value) then
			toast_gone(cx)
		end
	elseif act == "ren" then
		-- A click on a title (attention-marks-and-titles D2): the Rename field, the selection left as
		-- it is; `finish` draws once the field closes.
		local o = Store.find(Store.read(), value)
		if o == nil then
			toast_gone(cx)
		else
			rename(cx, o)
			later = true
		end
	elseif act == "new" then
		new_objective(cx, nil, nil, "", true)
		later = true
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
		later = true
	elseif act == "resume" then
		local tab = tonumber(value)
		if tab ~= nil then
			resume(cx, tab)
		end
		later = true
	elseif act == "pane" then
		local pane = tonumber(value)
		if pane ~= nil then
			jump_pane(cx, pane)
		end
		later = true
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
	elseif act == "page" then
		-- The header's gear button and the settings page's "Back to graph" (design D6).
		page = if value == "settings" then "settings" else "graph"
	elseif act == "setprio" then
		-- Configure: the priority new objectives start at (design D8).
		local n = tonumber(value)
		if n ~= nil and n >= 0 and n <= 3 then
			Store.set_settings(function(s)
				if s.start_priority == n then
					return false
				end
				s.start_priority = n :: number
				return true
			end)
		end
	elseif act == "setplace" then
		-- Configure: where new objectives go in the custom order (design D8).
		local place = if value == "bottom" then "bottom" else "top"
		Store.set_settings(function(s)
			if s.new_place == place then
				return false
			end
			s.new_place = place
			return true
		end)
	elseif act == "kchg" then
		change_keys(cx, value)
		later = true
	elseif act == "krm" then
		apply_keys(cx, value, "remove", nil)
	elseif act == "krst" then
		apply_keys(cx, value, "reset", nil)
	else
		return
	end
	if not later then
		M.render(cx)
	end
end

return M
