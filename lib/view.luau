--!strict
-- Builds the graph's view tree and its edge sheet from the store, the window model and the VM's
-- UI state. Pure: no Tern calls.

local Store = require("./store")
local Model = require("./model")
local Layout = require("./layout")
local Edges = require("./edges")
local Dates = require("./dates")

local M = {}

export type Ui = {
	selected: string?,
	-- The pane the graph was opened from (design P5).
	origin: number?,
	today: Dates.Day,
	-- The type a pane row starts with, and its class (design R4).
	kind: (row: Model.Row) -> (string, string?),
	-- Detail lines for an open live pane row: plain {text, class}, or a message {label, text, tail}
	-- whose text CSS may cut before the tail (design R5).
	details: (row: Model.Row) -> { { text: string, class: string?, label: string?, tail: string? } },
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
	return table.concat(parts, "\n")
end

local function objective_node(o: Store.Objective, ui_state: Ui, first: string): Node
	local selected = ui_state.selected == o.id
	local cls = "ob-obj ob-o-" .. o.id .. first
	if selected then
		cls ..= " ob-sel"
	end
	if o.done then
		cls ..= " ob-obj-done"
	end
	local line2: { Node } = {}
	if o.note ~= nil then
		table.insert(line2, span("ob-note", o.note))
	end
	if o.due ~= nil and not o.done then
		local text, tone = Dates.chip(o.due, ui_state.today)
		table.insert(line2, span("ob-chip ob-due ob-due-" .. tone, text))
	end
	for _, tag in o.tags do
		table.insert(line2, span("ob-chip ob-tagchip", "#" .. tag))
	end
	return el("div", { class = cls, key = "o:" .. o.id, title = tooltip(o), actions = { click = "sel=" .. o.id } }, {
		el("div", { class = "ob-l1", key = "l1" }, {
			span("ob-check" .. (if o.done then " ob-check-on" else ""), if o.done then "✓" else "", {
				key = "done",
				title = if o.done then "Reopen" else "Mark done",
				actions = { click = "done=" .. o.id },
			}),
			span("ob-badge ob-p" .. o.priority, "P" .. o.priority, {
				key = "prio",
				title = "Priority: click to change",
				actions = { click = "prio=" .. o.id },
			}),
			span("ob-title", o.title, { key = "title" }),
			span("ob-more", "⋯", { key = "more", title = "Rename, note, due date, tags, delete", actions = { click = "menu=" .. o.id } }),
		}),
		el("div", { class = "ob-l2", key = "l2" }, line2),
	})
end

type Shown = { tab: Model.Tab, status: string }

-- The link bar a tab node shows while an objective is selected (design P6).
type Link = { unlink: boolean, title: string }

local function tab_node(t: Model.Tab, status: string, first: string, linked_open: boolean, link: Link?, menu: { any }, ui_state: Ui, expanded: { [string]: boolean }): (Node, number)
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
	local head_kids: { Node } = {
		el("div", { class = "ob-th1", key = "th1" }, {
			span("ob-tlabel", t.label, { key = "label" }),
		}),
		span("ob-line ob-dim", where, { key = "where" }),
	}
	local kids: { Node } = {
		el("div", { class = "ob-thead", key = "head", title = t.label, actions = { click = "tab=" .. t.id } }, head_kids),
	}
	local detail_lines = 0
	local holds_origin = false
	for _, r in t.rows do
		local open = status == "live" and expanded[tostring(r.pane)] == true
		local row_kids: { Node } = {}
		if status == "live" then
			table.insert(row_kids, span("ob-exp" .. (if open then " ob-exp-open" else ""), if open then "▾" else "▸", {
				key = "exp",
				title = if open then "Hide details" else "Show details",
				actions = { click = "exp=" .. r.pane },
			}))
		end
		local kind, kind_cls = ui_state.kind(r)
		table.insert(row_kids, span("ob-rtype" .. (if kind_cls ~= nil then " " .. kind_cls else ""), kind, { key = "type" }))
		table.insert(row_kids, span("ob-rlabel", r.title, {
			key = "label",
			title = r.title,
			actions = { click = if status == "live" then "pane=" .. r.pane else "tab=" .. t.id },
		}))
		local row_cls = "ob-row ob-r-" .. r.pane
		if status == "live" and r.pane == ui_state.origin then
			row_cls ..= " ob-row-origin"
			holds_origin = true
		end
		table.insert(kids, el("div", { class = row_cls, key = "r:" .. r.pane }, row_kids))
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

	-- Left column.
	local left = Layout.stack()
	local left_kids: { Node } = {}
	local obj_cy: { [string]: number } = {}
	local sel_obj: Store.Objective? = nil
	if #state.objectives == 0 then
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
	for _, o in open_list do
		local first = Layout.first(left)
		obj_cy[o.id] = Layout.add_obj(left)
		table.insert(left_kids, objective_node(o, ui_state, first))
		if o.id == selected then
			sel_obj = o
		end
	end
	if #done_list > 0 then
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
		local node, details = tab_node(t, status, first, linked_open[t.id] == true, link, menu_of(t.id), ui_state, view_state.expanded)
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
	local sessions: { Model.Session } = {}
	for _, s in win.sessions do
		if origin_tab ~= nil and s.id == origin_tab.session then
			table.insert(sessions, 1, s)
		else
			table.insert(sessions, s)
		end
	end
	for _, s in sessions do
		if view_state.scope == "all" or s.id == win.current then
			local first = Layout.first(right)
			Layout.add_session(right)
			table.insert(right_kids, el("div", { class = "ob-session" .. first .. (if s.current then " ob-session-current" else ""), key = "s:" .. s.id }, {
				span("ob-sname", s.name, { key = "name" }),
				if s.current then span("ob-scur", "● current", { key = "cur" }) else nil :: any,
			}))
			if origin_tab ~= nil and s.id == origin_tab.session then
				add_tab(origin_tab, "live")
			end
			for _, t in s.tabs do
				if t ~= origin_tab then
					add_tab(t, "live")
				end
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
	ghost_group("Closed tabs", "closedgrp", closed, "closed")
	ghost_group("Other windows", "elsegrp", elsewhere, "elsewhere")

	-- Edges: open objectives in the left column to tabs in the right column.
	local edges: { Edges.Edge } = {}
	for _, o in open_list do
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
	return { view = view, css = css, closed = closed }
end

return M
