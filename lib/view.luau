--!strict
-- Builds the graph's view tree and its edge sheet from the store, the window model and the VM's
-- UI state. Pure: no Tern calls.

local Store = require("./store")
local Model = require("./model")
local Layout = require("./layout")
local Edges = require("./edges")
local Dates = require("./dates")
local Review = require("./review")

local M = {}

export type Ui = {
	selected: string?,
	-- The tabs the selection was linked to when it was made; they stay first in the right column until
	-- the selection changes (design D3).
	pinned: { [number]: boolean }?,
	-- The pane the graph was opened from (design P5).
	origin: number?,
	today: Dates.Day,
	-- The type a pane row starts with, and its class (design R4).
	kind: (row: Model.Row) -> (string, string?),
	-- Detail lines for an open live pane row: plain {text, class}, or a message {label, text, tail}
	-- whose text CSS may cut before the tail (design R5).
	details: (row: Model.Row) -> { { text: string, class: string?, label: string?, tail: string? } },
	-- The Undo notice's text after marking done or removing, until it is dropped (review design D6).
	undo: string?,
	-- Review mode: the due done objectives with their rating buttons (review design D4).
	reviewing: boolean,
}

-- An element as a plain TSP wire node {k, p, c} (tern.d.luau Node), which `cx.canvas:set` takes as
-- is. tern.ui.el would convert every subtree again at each level of nesting: with every row open that
-- doubled the build time (task 3.3). `props` must be a fresh table.
local function el(tag: string, props: { [string]: any }, kids: { Node }?): Node
	props.tag = tag
	return { k = "el", p = props, c = kids } :: any
end

local function span(class: string, text: string, extra: { [string]: any }?): Node
	local props: { [string]: any } = { class = class, text = text }
	if extra ~= nil then
		for k, v in extra do
			props[k] = v
		end
	end
	return el("span", props)
end

-- Open objectives: priority, then due date (none last), then created; done ones most recent first.
local function sort_open(list: { Store.Objective })
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
		if a.created ~= b.created then
			return a.created < b.created
		end
		return a.id < b.id
	end)
end

local function sort_done(list: { Store.Objective })
	table.sort(list, function(a, b)
		local ta, tb = a.done_at or 0, b.done_at or 0
		if ta ~= tb then
			return ta > tb
		end
		return a.id < b.id
	end)
end

local function stamp(t: number?): string
	return if t ~= nil then os.date("%Y-%m-%d %H:%M", t) :: string else ""
end

local function tooltip(o: Store.Objective): string
	local parts = { o.title }
	if o.note ~= nil then
		table.insert(parts, o.note)
	end
	table.insert(parts, "Created " .. stamp(o.created))
	if o.done and o.done_at ~= nil then
		table.insert(parts, "Done " .. stamp(o.done_at))
	end
	if o.done and o.review ~= nil then
		table.insert(parts, string.format("Reviewed %d× · next %s", o.review.reps, o.review.due))
	end
	return table.concat(parts, "\n")
end

-- A done objective's review chip (review-done-objectives, design D8): due, or in how many days.
local function review_chip(r: Review.Schedule, today: Dates.Day): Node
	local d = Dates.parse(r.due)
	local n = if d ~= nil then Dates.diff(today, d) else 0
	if n <= 0 then
		return span("ob-chip ob-review-due", "review due")
	end
	return span("ob-chip", string.format("review in %dd", n))
end

-- `review`: review mode's node, with Hard, Good and Easy under it (review-done-objectives, design D4).
local function objective_node(o: Store.Objective, ui_state: Ui, first: string, review: boolean?): Node
	local selected = ui_state.selected == o.id
	local cls = "ob-obj ob-o-" .. o.id .. first
	if selected then
		cls ..= " ob-sel"
	end
	if o.done then
		cls ..= " ob-obj-done"
	end
	if review then
		cls ..= " ob-review"
	end
	local line2: { Node } = {}
	if o.note ~= nil then
		table.insert(line2, span("ob-note", o.note))
	end
	if o.done and o.review ~= nil then
		table.insert(line2, review_chip(o.review, ui_state.today))
	elseif o.due ~= nil and not o.done then
		local text, tone = Dates.chip(o.due, ui_state.today)
		table.insert(line2, span("ob-chip ob-due ob-due-" .. tone, text))
	end
	for _, tag in o.tags do
		table.insert(line2, span("ob-chip ob-tagchip", "#" .. tag))
	end
	-- Done is final (design D7): a done box has its own no-op click, so it doesn't select the card.
	local l1: { Node } = {
		span("ob-check" .. (if o.done then " ob-check-on" else ""), if o.done then "✓" else "", {
			key = "done",
			title = if o.done then "Done " .. stamp(o.done_at) else "Mark done",
			actions = { click = if o.done then "noop=" else "done=" .. o.id },
		}),
		span("ob-badge ob-p" .. o.priority, "P" .. o.priority, {
			key = "prio",
			title = "Priority: click to change",
			actions = { click = "prio=" .. o.id },
		}),
		span("ob-title", o.title, { key = "title" }),
	}
	if o.done then
		table.insert(l1, el("span", { class = "ob-trash", key = "trash", title = "Remove", actions = { click = "rm=" .. o.id } }, {
			{ k = "icon", p = { name = "trash" } } :: any,
		}))
	end
	table.insert(l1, span("ob-more", "⋯", { key = "more", title = "Rename, note, due date, tags, delete", actions = { click = "menu=" .. o.id } }))
	local lines: { Node } = {
		el("div", { class = "ob-l1", key = "l1" }, l1),
		el("div", { class = "ob-l2", key = "l2" }, line2),
	}
	if review and o.review ~= nil then
		-- Each button names the whole days its rating gives, as obsidian-spaced-repetition does.
		local days = Review.preview(o.review, ui_state.today)
		local row: { Node } = {}
		for _, g in { { "hard", "Hard", days.hard }, { "good", "Good", days.good }, { "easy", "Easy", days.easy } } do
			table.insert(row, span("ob-rate ob-rate-" .. g[1], string.format("%s · %dd", g[2], g[3]), {
				key = g[1],
				title = string.format("%s: next review in %d day%s", g[2], g[3], if g[3] == 1 then "" else "s"),
				actions = { click = "rate=" .. o.id .. ":" .. g[1] },
			}))
		end
		table.insert(lines, el("div", { class = "ob-l3", key = "l3" }, row))
	end
	return el("div", { class = cls, key = "o:" .. o.id, title = tooltip(o), actions = { click = "sel=" .. o.id } }, lines)
end

type Shown = { tab: Model.Tab, status: string }

-- The link bar a tab node shows while an objective is selected (design P6).
type Link = { unlink: boolean, title: string }

-- `resume`: a closed tab with a saved Claude session shows "Resume" (resume-closed-agents, design D4).
local function tab_node(t: Model.Tab, status: string, first: string, linked_open: boolean, link: Link?, menu: { any }, ui_state: Ui, expanded: { [string]: boolean }, resume: boolean): (Node, number)
	local cls = "ob-tab ob-t-" .. t.id .. first
	if status ~= "live" then
		cls ..= " ob-tab-ghost ob-tab-" .. status
	elseif not linked_open then
		cls ..= " ob-tab-unlinked"
	end
	-- position 0: a ghost with no saved snapshot, so there is no place to name.
	local place = if t.position > 0 then t.session_name .. " · tab " .. t.position else nil
	local where = place or ""
	if status == "closed" then
		where = if place ~= nil then "closed · " .. place else "closed"
	elseif status == "elsewhere" then
		where = if place ~= nil then "other window · " .. place else "other window"
	end
	local th1: { Node } = { span("ob-tlabel", t.label, { key = "label" }) }
	if resume then
		-- Its own click, so the rest of the header still says the tab is closed.
		table.insert(th1, span("ob-resume", "Resume", {
			key = "resume",
			title = "Reopen this tab's Claude chats in a new tab",
			actions = { click = "resume=" .. t.id },
		}))
	end
	local head_kids: { Node } = {
		el("div", { class = "ob-th1", key = "th1" }, th1),
		span("ob-line ob-dim", where, { key = "where" }),
	}
	local kids: { Node } = {
		el("div", { class = "ob-thead", key = "head", title = t.label, actions = { click = "tab=" .. t.id } }, head_kids),
	}
	local detail_lines = 0
	local holds_origin = false
	for _, r in t.rows do
		local live = status == "live"
		local open = live and expanded[tostring(r.pane)] == true
		local kind, kind_cls = ui_state.kind(r)
		local row_kids: { Node } = {
			span("ob-rtype" .. (if kind_cls ~= nil then " " .. kind_cls else ""), kind, { key = "type" }),
			span("ob-rlabel", r.title, { key = "label", title = r.title }),
		}
		if live then
			-- The row's only jump; a click anywhere else on the row opens or folds its details (design R7).
			table.insert(row_kids, el("span", { class = "ob-jump", key = "jump", title = "Go to this pane", actions = { click = "pane=" .. r.pane } }, {
				{ k = "icon", p = { name = "arrow-right" } } :: any,
			}))
		end
		local row_cls = "ob-row ob-r-" .. r.pane
		if live and r.pane == ui_state.origin then
			row_cls ..= " ob-row-origin"
			holds_origin = true
		end
		-- A ghost row has no details; its click says why the tab can't be reached.
		local row_click = if live then "exp=" .. r.pane else "tab=" .. t.id
		table.insert(kids, el("div", { class = row_cls, key = "r:" .. r.pane, actions = { click = row_click } }, row_kids))
		if open then
			for i, d in ui_state.details(r) do
				detail_lines += 1
				local key = "d:" .. r.pane .. ":" .. i
				local cls = "ob-detail" .. (if d.class ~= nil then " " .. d.class else "")
				if d.label ~= nil then
					-- Label, a head that CSS cuts with "…" when the line is too narrow, and a tail that
					-- always shows, so the message's beginning and end both stay (design R5).
					local parts: { Node } = {
						span("ob-mlabel", d.label, { key = "l" }),
						span("ob-mhead", d.text, { key = "h" }),
					}
					if d.tail ~= nil and d.tail ~= "" then
						table.insert(parts, span("ob-mtail", d.tail, { key = "t" }))
					end
					local whole = d.label .. " " .. d.text .. (d.tail or "")
					table.insert(kids, el("div", { class = cls .. " ob-d-msg", key = key, title = whole }, parts))
				else
					table.insert(kids, span(cls, d.text, { key = key, title = d.text }))
				end
			end
		end
	end
	if holds_origin then
		cls ..= " ob-origin"
	end
	-- Below the rows, away from the header whose click jumps, so a near miss doesn't jump.
	if link ~= nil then
		table.insert(kids, span("ob-linkbar" .. (if link.unlink then " ob-linkbar-on" else ""), if link.unlink then "× Unlink" else "＋ Link", {
			key = "linkbar",
			title = (if link.unlink then "Unlink from “" else "Link to “") .. link.title .. "”",
			actions = { click = "link=" .. t.id },
		}))
	end
	return el("div", { class = cls, key = "t:" .. t.id, actions = { menu = menu } }, kids), detail_lines
end

-- A closed or elsewhere tab drawn from its snapshot; a link without one (written by hand or lost to
-- a race) still shows, so it can be seen and pruned.
local function ghost(id: number, snap: Store.TabSnap?, status: string): Model.Tab
	local rows: { Model.Row } = {}
	if snap == nil then
		return { id = id, session = 0, session_name = "", position = 0, label = "Tab " .. id, focus = 0, rows = rows, status = status }
	end
	for _, p in snap.panes do
		table.insert(rows, { pane = p.pane, title = p.title, kind = p.kind, info = nil })
	end
	return {
		id = id,
		session = snap.session,
		session_name = snap.session_name,
		position = snap.position,
		label = snap.label,
		focus = 0,
		rows = rows,
		status = status,
	}
end

export type Built = {
	view: Node,
	css: string,
	closed: { number }, -- linked closed tabs shown (for prune)
	due: number, -- done objectives due for review under the filters; 0 ends review mode
}

function M.build(state: Store.State, win: Model.Window, ui_state: Ui): Built
	local view_state = state.view
	local selected = ui_state.selected

	-- Link facts.
	local linked_open: { [number]: boolean } = {}
	local status_of: { [number]: string } = {}
	for _, o in state.objectives do
		for _, tab in o.tabs do
			if not o.done then
				linked_open[tab] = true
			end
			if status_of[tab] == nil then
				local snap = state.tabs[tostring(tab)]
				status_of[tab] = Model.status(win, tab, if snap ~= nil then snap.window else nil)
			end
		end
	end

	-- The current session's tabs, live and closed (scope "This session").
	local in_session: { [number]: boolean } = {}
	for tab, st in status_of do
		if st == "live" then
			local t = win.tabs[tab]
			in_session[tab] = t ~= nil and t.session == win.current
		elseif st == "closed" then
			local snap = state.tabs[tostring(tab)]
			in_session[tab] = snap ~= nil and snap.session == win.current
		end
	end

	local function visible(o: Store.Objective): boolean
		if view_state.tag ~= nil and table.find(o.tags, view_state.tag) == nil then
			return false
		end
		if view_state.scope == "session" and o.id ~= selected then
			for _, tab in o.tabs do
				if in_session[tab] then
					return true
				end
			end
			return false
		end
		return true
	end

	local open_list, done_list = {}, {}
	for _, o in state.objectives do
		if visible(o) then
			table.insert(if o.done then done_list else open_list, o)
		end
	end
	sort_open(open_list)
	sort_done(done_list)

	-- Review mode's list (review-done-objectives, design D4): the done objectives the filters show whose
	-- review is due, the longest due first, then the most recently done. An empty list is normal mode.
	local due_list: { Store.Objective } = {}
	for _, o in done_list do
		if o.review ~= nil and Review.is_due(o.review, ui_state.today) then
			table.insert(due_list, o)
		end
	end
	table.sort(due_list, function(a, b)
		local da, db = (a.review :: Review.Schedule).due, (b.review :: Review.Schedule).due
		if da ~= db then
			return da < db
		end
		local ta, tb = a.done_at or 0, b.done_at or 0
		if ta ~= tb then
			return ta > tb
		end
		return a.id < b.id
	end)
	local reviewing = ui_state.reviewing and #due_list > 0

	-- Left column.
	local left = Layout.stack()
	local left_kids: { Node } = {}
	local obj_cy: { [string]: number } = {}
	local sel_obj: Store.Objective? = nil
	if reviewing then
		for _, o in due_list do
			local first = Layout.first(left)
			obj_cy[o.id] = Layout.add_obj(left, true)
			table.insert(left_kids, objective_node(o, ui_state, first, true))
			if o.id == selected then
				sel_obj = o
			end
		end
	elseif #state.objectives == 0 then
		local first = Layout.first(left)
		Layout.add_hint(left)
		table.insert(left_kids, el("div", { class = "ob-hint" .. first, key = "hint" }, {
			span("ob-line", "No objectives yet.", { key = "a" }),
			span("ob-line ob-dim", "Click ＋ New objective above to add one.", { key = "b" }),
		}))
	elseif #open_list == 0 and #done_list == 0 then
		local first = Layout.first(left)
		Layout.add_hint(left)
		table.insert(left_kids, el("div", { class = "ob-hint" .. first, key = "hint" }, {
			span("ob-line", "No objectives match this filter.", { key = "a" }),
		}))
	end
	for _, o in (if reviewing then {} else open_list) :: { Store.Objective } do
		local first = Layout.first(left)
		obj_cy[o.id] = Layout.add_obj(left)
		table.insert(left_kids, objective_node(o, ui_state, first))
		if o.id == selected then
			sel_obj = o
		end
	end
	if #done_list > 0 and not reviewing then
		local first = Layout.first(left)
		Layout.add_group(left)
		table.insert(left_kids, el("div", { class = "ob-group ob-donegrp" .. first, key = "donegrp", actions = { click = "donegrp=" } }, {
			span("ob-caret", if view_state.done_open then "▾" else "▸", { key = "caret" }),
			span("ob-gtext", string.format("Done (%d)", #done_list), { key = "text" }),
		}))
		if view_state.done_open then
			for _, o in done_list do
				local f = Layout.first(left)
				Layout.add_obj(left)
				table.insert(left_kids, objective_node(o, ui_state, f))
				if o.id == selected then
					sel_obj = o
				end
			end
		end
	end

	-- Right column.
	local right = Layout.stack()
	local right_kids: { Node } = {}
	local tab_cy: { [number]: number } = {}
	local sel_tabs: { [number]: boolean } = {}
	if sel_obj ~= nil then
		for _, tab in sel_obj.tabs do
			sel_tabs[tab] = true
		end
	end
	local function link_of(tab: number): Link?
		if sel_obj == nil then
			return nil
		end
		return { unlink = sel_tabs[tab] == true, title = sel_obj.title }
	end
	-- The tab menu's rows: every open objective in graph order, whatever the filters (design P6).
	local menu_objs: { Store.Objective } = {}
	for _, o in state.objectives do
		if not o.done then
			table.insert(menu_objs, o)
		end
	end
	sort_open(menu_objs)
	local function menu_of(tab: number): { any }
		if #menu_objs == 0 then
			return { { id = "none", label = "No objectives yet", disabled = "Create one with ＋ New objective" } }
		end
		local rows: { any } = { { header = "Link to" } }
		for _, o in menu_objs do
			table.insert(rows, { id = "lnk=" .. o.id .. ":" .. tab, label = o.title, checked = table.find(o.tabs, tab) ~= nil })
		end
		return rows
	end
	local function add_tab(t: Model.Tab, status: string)
		local first = Layout.first(right)
		local link = link_of(t.id)
		local resume = false
		if status == "closed" then
			for _, r in t.rows do
				-- Only a row stored as an agent: a session saved under a pane id another pane now holds
				-- must not turn a shell into a chat.
				if r.kind == "agent" and state.agents[tostring(r.pane)] ~= nil then
					resume = true
				end
			end
		end
		local node, details = tab_node(t, status, first, linked_open[t.id] == true, link, menu_of(t.id), ui_state, view_state.expanded, resume)
		tab_cy[t.id] = Layout.add_tab(right, #t.rows, details, link ~= nil)
		table.insert(right_kids, node)
	end
	-- The origin's session comes first, and its tab first inside it (design R1).
	local origin_tab: Model.Tab? = nil
	if ui_state.origin ~= nil then
		for _, t in win.tabs do
			for _, r in t.rows do
				if r.pane == ui_state.origin then
					origin_tab = t
				end
			end
		end
	end
	local placed: { { s: Model.Session, tabs: { Model.Tab } } } = {}
	for _, s in win.sessions do
		if view_state.scope == "all" or s.id == win.current then
			local tabs: { Model.Tab } = {}
			if origin_tab ~= nil and s.id == origin_tab.session then
				table.insert(tabs, origin_tab)
			end
			for _, t in s.tabs do
				if t ~= origin_tab then
					table.insert(tabs, t)
				end
			end
			local entry = { s = s, tabs = tabs }
			if origin_tab ~= nil and s.id == origin_tab.session then
				table.insert(placed, 1, entry)
			else
				table.insert(placed, entry)
			end
		end
	end
	local closed: { number } = {}
	local elsewhere: { number } = {}
	for tab, st in status_of do
		if st == "closed" and (view_state.scope == "all" or in_session[tab]) then
			table.insert(closed, tab)
		elseif st == "elsewhere" and view_state.scope == "all" then
			table.insert(elsewhere, tab)
		end
	end
	local function by_place(a: number, b: number): boolean
		local sa, sb = state.tabs[tostring(a)], state.tabs[tostring(b)]
		local ka = if sa ~= nil then sa.session_name .. string.format("%04d", sa.position) else ""
		local kb = if sb ~= nil then sb.session_name .. string.format("%04d", sb.position) else ""
		if ka ~= kb then
			return ka < kb
		end
		return a < b
	end
	table.sort(closed, by_place)
	table.sort(elsewhere, by_place)
	local function ghost_group(title: string, key: string, list: { number }, status: string)
		if #list == 0 then
			return
		end
		local first = Layout.first(right)
		Layout.add_group(right)
		table.insert(right_kids, el("div", { class = "ob-group" .. first, key = key }, {
			span("ob-gtext", title, { key = "text" }),
		}))
		for _, tab in list do
			add_tab(ghost(tab, state.tabs[tostring(tab)], status), status)
		end
	end
	-- Draws the column in the order above, for the tabs `keep` accepts (all without it). `prefix` keeps
	-- the keys of headings that show in both sections apart (design D4).
	local function place(keep: ((tab: number) -> boolean)?, prefix: string)
		local function kept(list: { number }): { number }
			if keep == nil then
				return list
			end
			local out: { number } = {}
			for _, tab in list do
				if keep(tab) then
					table.insert(out, tab)
				end
			end
			return out
		end
		for _, p in placed do
			local tabs = p.tabs
			if keep ~= nil then
				tabs = {}
				for _, t in p.tabs do
					if keep(t.id) then
						table.insert(tabs, t)
					end
				end
			end
			if keep == nil or #tabs > 0 then
				local s = p.s
				local first = Layout.first(right)
				Layout.add_session(right)
				table.insert(right_kids, el("div", { class = "ob-session" .. first .. (if s.current then " ob-session-current" else ""), key = prefix .. "s:" .. s.id }, {
					span("ob-sname", s.name, { key = "name" }),
					if s.current then span("ob-scur", "● current", { key = "cur" }) else nil :: any,
				}))
				for _, t in tabs do
					add_tab(t, "live")
				end
			end
		end
		ghost_group("Closed tabs", prefix .. "closedgrp", kept(closed), "closed")
		ghost_group("Other windows", prefix .. "elsegrp", kept(elsewhere), "elsewhere")
	end
	-- While an objective is selected, the shown tabs it was linked to when it was selected come first
	-- under a heading, and a divider leads to the rest (design D4).
	local pinned = if sel_obj ~= nil then ui_state.pinned else nil
	local n_top, n_rest = 0, 0
	if pinned ~= nil then
		local function count(tab: number)
			if pinned[tab] == true then
				n_top += 1
			else
				n_rest += 1
			end
		end
		for _, p in placed do
			for _, t in p.tabs do
				count(t.id)
			end
		end
		for _, tab in closed do
			count(tab)
		end
		for _, tab in elsewhere do
			count(tab)
		end
	end
	if sel_obj ~= nil and pinned ~= nil and n_top > 0 then
		local top = pinned
		local heading = "Linked to “" .. sel_obj.title .. "”"
		local first = Layout.first(right)
		Layout.add_group(right)
		table.insert(right_kids, el("div", { class = "ob-group ob-linkhead" .. first, key = "linkhead", title = heading }, {
			span("ob-gtext", heading, { key = "text" }),
		}))
		place(function(tab)
			return top[tab] == true
		end, "l")
		if n_rest > 0 then
			Layout.add_group(right)
			table.insert(right_kids, el("div", { class = "ob-group ob-divider", key = "divider" }, {
				span("ob-gtext", "Other tabs", { key = "text" }),
			}))
			place(function(tab)
				return top[tab] ~= true
			end, "")
		end
	else
		place(nil, "")
	end

	-- Edges: open objectives in the left column to tabs in the right column.
	local edges: { Edges.Edge } = {}
	-- Open objectives' lines, or in review mode the listed objectives' (review design D4).
	for _, o in (if reviewing then due_list else open_list) :: { Store.Objective } do
		local from = obj_cy[o.id]
		for _, tab in o.tabs do
			local to = tab_cy[tab]
			if from ~= nil and to ~= nil then
				table.insert(edges, {
					from = from,
					to = to,
					priority = o.priority,
					dashed = status_of[tab] ~= "live",
					selected = o.id == selected,
				})
			end
		end
	end
	local height = math.max(left.y, right.y)
	local css, layers = Edges.build(edges, height)
	local gap_kids: { Node } = {}
	for i, cls in layers do
		table.insert(gap_kids, el("div", { class = cls, key = "e" .. i }))
	end

	-- Header: scope, tag filter, prune, new.
	local head: { Node } = {
		el("div", { class = "ob-seg", key = "scope" }, {
			span("ob-segb" .. (if view_state.scope == "all" then " ob-on" else ""), "All", { key = "all", actions = { click = "scope=all" } }),
			span("ob-segb" .. (if view_state.scope == "session" then " ob-on" else ""), "This session", {
				key = "session",
				actions = { click = "scope=session" },
			}),
		}),
	}
	local tags: { Node } = {}
	for _, tag in Store.all_tags(state) do
		table.insert(tags, span("ob-chip ob-ftag" .. (if view_state.tag == tag then " ob-on" else ""), "#" .. tag, {
			key = tag,
			title = if view_state.tag == tag then "Show every tag" else "Show only #" .. tag,
			actions = { click = "tag=" .. tag },
		}))
	end
	table.insert(head, el("div", { class = "ob-ftags", key = "tags" }, tags))
	table.insert(head, el("div", { class = "ob-spacer", key = "sp" }))
	if ui_state.undo ~= nil then
		-- After marking done or removing (review design D6); any other click in the graph drops it.
		table.insert(head, el("div", { class = "ob-undo", key = "undo" }, {
			span("ob-undo-text", ui_state.undo .. " ·", { key = "text", title = ui_state.undo }),
			span("ob-undo-btn", "Undo", { key = "btn", actions = { click = "undo=" } }),
		}))
	end
	if #due_list > 0 then
		table.insert(head, span("ob-btn ob-btn-quiet ob-revbtn" .. (if reviewing then " ob-on" else ""), string.format("Review (%d)", #due_list), {
			key = "review",
			title = if reviewing then "Back to all objectives" else "Review the done objectives that are due",
			actions = { click = "rev=" },
		}))
	end
	if #closed > 0 then
		table.insert(head, span("ob-btn ob-btn-quiet", "Prune closed tabs", {
			key = "prune",
			title = string.format("Remove the links of %d closed tab%s", #closed, if #closed == 1 then "" else "s"),
			actions = { click = "prune=" },
		}))
	end
	table.insert(head, span("ob-btn ob-btn-primary", "＋ New objective", { key = "new", actions = { click = "new=" } }))

	local view = el("div", { class = "ob-root", key = "root", actions = { click = "bg=" } }, {
		el("div", { class = "ob-head", key = "head" }, head),
		el("div", { class = "ob-graph", key = "graph" }, {
			el("div", { class = "ob-col ob-col-l", key = "l" }, left_kids),
			el("div", { class = "ob-gap", key = "gap" }, gap_kids),
			el("div", { class = "ob-col ob-col-r", key = "r" }, right_kids),
		}),
	})
	return { view = view, css = css, closed = closed, due = #due_list }
end

return M
