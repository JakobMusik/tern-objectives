--!strict
-- Builds the graph's view tree and its edge sheet from the store, the window model and the VM's
-- UI state. Pure: no Tern calls.

local Store = require("./store")
local Model = require("./model")
local Layout = require("./layout")
local Edges = require("./edges")
local Dates = require("./dates")
local Review = require("./review")
local Text = require("./text")
local Keys = require("./keys")

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
	-- The Undo notice's text after marking done or removing, until it is dropped (review design D6).
	undo: string?,
	-- After marking done: the objective and the count for the notice's "Close <n> tabs"
	-- (close-linked-tabs, design D8).
	undo_close: { id: string, n: number }?,
	-- Review mode: the due done objectives with their rating buttons (review design D4).
	reviewing: boolean,
	-- An omp row's call: "wait", "replied", "working" or nil (attention-marks-and-titles D3,
	-- working-mark D1).
	attention: (row: Model.Row) -> string?,
	-- The open objective lifted by its grip, until it is dropped or the move ends
	-- (custom-order-and-direct-controls, design D2).
	moving: string?,
	-- The question an action asks in place, if one is showing (custom-order-and-direct-controls, D4):
	-- "close" for an objective's tabs, asked in its bar or in the done notice, "done_tabs" (D11),
	-- "reopen" for a done objective, asked in its bar (reopen-done-objectives, D1), or "tab" for one
	-- tab's trash icon, asked in its header, with the tab id (close-tab-from-node, D3).
	confirm: { kind: string, id: string?, where: string? }?,
	-- While badge clicks hold the order (sort-by-priority, design D3): the priority each open objective
	-- had at the first of them, which the sorted order keeps using until the hold ends.
	held: { [string]: number }?,
}

-- An objective's attention mark: the strongest call over its live tabs, and those tabs' labels.
type Mark = { kind: string, tabs: { string } }

local MARK_CHIP = { wait = "needs you", replied = "replied", working = "working" }
local MARK_TIP = { wait = "omp is waiting in ", replied = "omp replied in ", working = "omp is working in " }
-- The strongest mark wins (working-mark D2); no call ranks 0.
local RANK: { [string]: number } = { wait = 3, replied = 2, working = 1 }

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

local function plural(n: number, word: string): string
	return string.format("%d %s%s", n, word, if n == 1 then "" else "s")
end

-- The tabs of done objective `o` this window holds that no open objective links, which its "Close
-- n tabs" closes, and how many of its open tabs an open objective keeps (close-linked-tabs D1). The
-- app counts with it again when it closes them.
function M.closable(state: Store.State, win: Model.Window, o: Store.Objective): ({ number }, number)
	local open_links: { [number]: boolean } = {}
	for _, other in state.objectives do
		if not other.done then
			for _, tab in other.tabs do
				open_links[tab] = true
			end
		end
	end
	local tabs: { number } = {}
	local kept = 0
	for _, tab in o.tabs do
		if win.tabs[tab] ~= nil then
			if open_links[tab] then
				kept += 1
			else
				table.insert(tabs, tab)
			end
		end
	end
	return tabs, kept
end

-- What the selected node's action bar offers (design D3): `close` and `kept` count a done objective's
-- tabs, and `ask` turns the bar into a question: "close" for "Close n tabs?" (D4), "reopen" for
-- "Reopen “<title>”?" (reopen-done-objectives, D1). A question takes its own row over the answers
-- (reopen-done-objectives, D1a).
type Acts = { close: number, kept: number, ask: string? }

local function act_button(key: string, icon: string, label: string, act: string, tip: string): Node
	return el("span", { class = "ob-act ob-act-" .. key, key = key, title = tip, actions = { click = act } }, {
		{ k = "icon", p = { name = icon } } :: any,
		span("ob-act-l", label, { key = "l" }),
	})
end

-- The node's last lines: the bar, or a question's row and the answers under it.
local function action_bar(o: Store.Objective, acts: Acts): { Node }
	if acts.ask == "close" then
		local q = "Close " .. plural(acts.close, "tab") .. "?"
		local shown = q
		local tip = q
		if acts.kept > 0 then
			shown ..= " · " .. acts.kept .. (if acts.kept == 1 then " stays" else " stay") .. " open"
			tip ..= " " .. plural(acts.kept, "tab") .. " linked to an open objective " .. (if acts.kept == 1 then "stays" else "stay") .. " open."
		end
		tip ..= " Closing ends their programs; omp chats come back with Resume."
		return {
			el("div", { class = "ob-askrow", key = "ask", title = tip }, { span("ob-ask", shown, { key = "q" }) }),
			el("div", { class = "ob-acts ob-acts-ask", key = "acts" }, {
				act_button("cfm", "x-circle", "Close", "cfm=", "Close " .. plural(acts.close, "tab")),
				act_button("cfx", "x", "Cancel", "cfx=", "Keep them open"),
			}),
		}
	elseif acts.ask == "reopen" then
		-- "Reopen “" and "”?" stay whole; only the title between them is cut.
		return {
			el("div", {
				class = "ob-askrow",
				key = "ask",
				title = "Reopen “" .. o.title .. "”. Keep review: its schedule carries on when it is done again. Reset review: it starts over.",
			}, {
				span("ob-ask-fix", "Reopen “", { key = "a" }),
				span("ob-ask ob-ask-title", o.title, { key = "t" }),
				span("ob-ask-fix", "”?", { key = "b" }),
			}),
			el("div", { class = "ob-acts ob-acts-ask", key = "acts" }, {
				act_button("rkeep", "history", "Keep review", "rkeep=", "Reopen; when it is done again, its review schedule carries on"),
				act_button("rreset", "eraser", "Reset review", "rreset=", "Reopen and drop its review schedule; done again, it starts over"),
				act_button("cfx", "x", "Cancel", "cfx=", "Keep it done"),
			}),
		}
	end
	local kids: { Node }
	if o.done then
		kids = {
			act_button("note", "note", "Note", "note=" .. o.id, "Side note"),
			act_button("tags", "tag", "Tags", "tags=" .. o.id, "Tags"),
		}
		if acts.close > 0 then
			table.insert(kids, act_button("close", "x-circle", "Close " .. plural(acts.close, "tab"), "close=" .. o.id, "Close its open tabs no open objective links; asks first"))
		end
	else
		kids = {
			act_button("note", "note", "Note", "note=" .. o.id, "Side note"),
			act_button("due", "clock", "Due", "due=" .. o.id, "Due date"),
			act_button("tags", "tag", "Tags", "tags=" .. o.id, "Tags"),
			act_button("del", "trash", "Delete", "del=" .. o.id, "Delete; Undo brings it back"),
		}
	end
	return { el("div", { class = "ob-acts", key = "acts" }, kids) }
end

-- While sorting by priority (sort-by-priority, design D4): `lifted` is the lifted objective's priority,
-- the only one whose nodes take its drop.
type Sorting = { lifted: number? }

-- `title`: the title's lines (Text.wrap). `mark`: its attention mark, if any (D3). `review`: review
-- mode's node, with Hard, Good and Easy under it (review-done-objectives, design D4). `acts`: the
-- selected node's action bar (custom-order-and-direct-controls, design D3). `lit`: it links the
-- focus tab (highlight-origin-tab-links, design D4). `sorting`: set while sorting by priority.
local function objective_node(o: Store.Objective, ui_state: Ui, first: string, title: { string }, mark: Mark?, review: boolean?, acts: Acts?, lit: boolean?, sorting: Sorting?): Node
	local selected = ui_state.selected == o.id
	local cls = "ob-obj ob-o-" .. o.id .. first
	if #title > 1 then
		cls ..= " ob-n" .. #title
	end
	if selected then
		cls ..= " ob-sel"
	end
	if acts ~= nil then
		cls ..= " ob-acts-on"
		if acts.ask ~= nil then
			cls ..= " ob-asking"
		end
	end
	if o.done then
		cls ..= " ob-obj-done"
	end
	if review then
		cls ..= " ob-review"
	end
	if lit then
		cls ..= " ob-lit"
	end
	-- Only "needs you" and "replied" ring the node; "working" is its chip alone (working-mark D3).
	if mark ~= nil and mark.kind ~= "working" then
		cls ..= " ob-att-" .. mark.kind
	end
	-- Moving (design D2): open nodes outside review mode have a grip; the lifted one is drawn lifted,
	-- and every other one takes the drop on its upper or lower half.
	local movable = not o.done and not review
	if movable and ui_state.moving == o.id then
		cls ..= " ob-lifted"
	end
	local line2: { Node } = {}
	if mark ~= nil then
		table.insert(line2, span("ob-chip ob-attchip ob-attchip-" .. mark.kind, MARK_CHIP[mark.kind], {
			key = "att",
			title = MARK_TIP[mark.kind] .. "“" .. table.concat(mark.tabs, "”, “") .. "”",
		}))
	end
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
	local l1: { Node } = {}
	if movable then
		table.insert(l1, el("span", {
			class = "ob-grip",
			key = "grip",
			title = if ui_state.moving == o.id
				then "Put it back"
				elseif sorting ~= nil then "Move within P" .. o.priority .. ": click, then click where it goes"
				else "Move: click, then click where it goes",
			actions = { click = "lift=" .. o.id },
		}, { { k = "icon", p = { name = "grip" } } :: any }))
	end
	-- A done box asks whether to reopen (reopen-done-objectives, D1); its own click doesn't select the
	-- card through it, the app selects it to ask in its bar.
	table.insert(l1, span("ob-check" .. (if o.done then " ob-check-on" else ""), if o.done then "✓" else "", {
		key = "done",
		title = if o.done then "Done " .. stamp(o.done_at) .. " · click to reopen" else "Mark done",
		actions = { click = if o.done then "reopen=" .. o.id else "done=" .. o.id },
	}))
	table.insert(l1, span("ob-badge ob-p" .. o.priority, "P" .. o.priority, {
		key = "prio",
		title = "Priority: click to change",
		actions = { click = "prio=" .. o.id },
	}))
	-- The title's lines, one row each (attention-marks-and-titles D1). The creation time, which tells
	-- same-titled objectives apart, follows the last line, clipped only once that line is down to
	-- 3em (creation-time-suffix D2).
	local created = Dates.short(o.created)
	local rows: { Node } = {}
	-- Each line's text renames on a click (attention-marks-and-titles D2); beside it, the card selects.
	-- No `title` of its own, so hovering shows the card's tooltip with the whole title.
	for i, line in title do
		local row: { Node } = { span("ob-title", line, { key = "title", actions = { click = "ren=" .. o.id } }) }
		if i == #title and created ~= nil then
			table.insert(row, span("ob-created", created, { key = "created" }))
		end
		table.insert(rows, el("div", { class = "ob-tline", key = "t" .. i }, row))
	end
	table.insert(l1, el("div", { class = "ob-name", key = "name" }, rows))
	if o.done then
		table.insert(l1, el("span", { class = "ob-trash", key = "trash", title = "Remove", actions = { click = "rm=" .. o.id } }, {
			{ k = "icon", p = { name = "trash" } } :: any,
		}))
	end
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
	if acts ~= nil then
		for _, line in action_bar(o, acts) do
			table.insert(lines, line)
		end
	end
	-- While sorting, only the lifted objective's priority takes its drop (sort-by-priority, D4).
	if movable and ui_state.moving ~= nil and ui_state.moving ~= o.id and (sorting == nil or sorting.lifted == o.priority) then
		-- Over the node's content, so they take the click; their :hover draws the insertion line.
		table.insert(lines, el("div", { class = "ob-drop ob-drop-top", key = "dropt", actions = { click = "drop=" .. o.id .. ":before" } }))
		table.insert(lines, el("div", { class = "ob-drop ob-drop-bot", key = "dropb", actions = { click = "drop=" .. o.id .. ":after" } }))
	end
	return el("div", { class = cls, key = "o:" .. o.id, title = tooltip(o), actions = { click = "sel=" .. o.id } }, lines)
end

type Shown = { tab: Model.Tab, status: string }

-- The link bar a tab node shows while an objective, open or done, is selected (design P6, D10).
type Link = { unlink: boolean, title: string }

-- `resume`: a closed tab with a saved omp chat shows "Resume" (resume-omp-chats, design D4). `linked`:
-- any objective links it. `asking`: its trash icon's question is open (close-tab-from-node, D3).
local function tab_node(t: Model.Tab, status: string, first: string, linked_open: boolean, link: Link?, menu: { any }, ui_state: Ui, expanded: { [string]: boolean }, resume: boolean, linked: boolean, asking: boolean): (Node, number)
	local live = status == "live"
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
	local th1: { Node }
	if asking then
		-- In place of the label line, same height (close-tab-from-node D3): the question, cut first,
		-- then Cancel, and Close where the icon was.
		local tip = if linked
			then "Closing ends its programs; omp chats come back with Resume."
			else "Closing ends its programs. No objective links it, so it won't show under Closed tabs."
		th1 = {
			span("ob-ask", "Close tab?", { key = "q", title = tip }),
			span("ob-tbtn", "Cancel", { key = "cfx", title = "Keep it open", actions = { click = "cfx=" } }),
			span("ob-tbtn ob-tbtn-close", "Close", { key = "cfm", title = "Close this tab", actions = { click = "cfm=" } }),
		}
	else
		th1 = { span("ob-tlabel", t.label, { key = "label" }) }
		if resume then
			-- Its own click, so the rest of the header still says the tab is closed.
			table.insert(th1, span("ob-resume", "Resume", {
				key = "resume",
				title = "Reopen this tab's omp chats in a new tab",
				actions = { click = "resume=" .. t.id },
			}))
		end
		if live then
			-- Shown only while the pointer is on the node (close-tab-from-node, D2); its own click
			-- asks, and doesn't jump.
			table.insert(th1, el("span", { class = "ob-trash ob-tclose", key = "tclose", title = "Close this tab; asks first", actions = { click = "tclose=" .. t.id } }, {
				{ k = "icon", p = { name = "trash" } } :: any,
			}))
		end
	end
	local head_kids: { Node } = {
		el("div", { class = if asking then "ob-th1 ob-th1-ask" else "ob-th1", key = "th1" }, th1),
		span("ob-line ob-dim", where, { key = "where" }),
	}
	-- While it asks, a click on the header ends the question instead of jumping (D3).
	local kids: { Node } = {
		el("div", { class = "ob-thead", key = "head", title = t.label, actions = { click = if asking then "cfx=" else "tab=" .. t.id } }, head_kids),
	}
	local detail_lines = 0
	local holds_origin = false
	for _, r in t.rows do
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
-- a race) still shows, so it can be seen and unlinked.
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
	closed: { number }, -- linked closed tabs shown
	-- The live tabs shown that only done objectives link: "Close n done tabs" closes them
	-- (custom-order-and-direct-controls, design D11).
	done_tabs: { number },
	due: number, -- done objectives due for review under the filters; 0 ends review mode
}

function M.build(state: Store.State, win: Model.Window, ui_state: Ui): Built
	local view_state = state.view
	local selected = ui_state.selected

	-- Link facts.
	local linked_open: { [number]: boolean } = {}
	local linked_done: { [number]: boolean } = {}
	local status_of: { [number]: string } = {}
	for _, o in state.objectives do
		for _, tab in o.tabs do
			if o.done then
				linked_done[tab] = true
			else
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

	-- Open objectives in the graph's order: the user's, by priority first while sorting
	-- (sort-by-priority, design D2); filters only leave some out. The Done group sorts by when each
	-- was done.
	local open_list, done_list = {}, {}
	for _, o in Store.open_in_order(state, ui_state.held) do
		if visible(o) then
			table.insert(open_list, o)
		end
	end
	for _, o in state.objectives do
		if o.done and visible(o) then
			table.insert(done_list, o)
		end
	end
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

	-- The tab holding the origin pane, first in the right column (design R1).
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
	-- The focus tab (highlight-origin-tab-links, design D2): with nothing selected, outside review mode,
	-- the origin's tab when the right column shows it. Its lines are drawn strong and the open
	-- objectives linking it tinted.
	local focus_tab: number? = nil
	if selected == nil and not reviewing and origin_tab ~= nil and (view_state.scope == "all" or origin_tab.session == win.current) then
		focus_tab = origin_tab.id
	end

	-- Left column.
	local left = Layout.stack()
	local left_kids: { Node } = {}
	local obj_cy: { [string]: number } = {}
	local sel_obj: Store.Objective? = nil
	-- Attention (attention-marks-and-titles D3): each live tab's strongest omp call, worked out once,
	-- then per objective the strongest over its live tabs, ranked by RANK (working-mark D2). Closed
	-- and elsewhere tabs have no live rows, so they never mark.
	local tab_call: { [number]: string } = {}
	local function call_of(tab: number): string
		local known = tab_call[tab]
		if known ~= nil then
			return known
		end
		local call = ""
		local t = win.tabs[tab]
		if t ~= nil then
			for _, row in t.rows do
				local a = ui_state.attention(row)
				if a ~= nil and (RANK[a] or 0) > (RANK[call] or 0) then
					call = a
					if a == "wait" then
						break
					end
				end
			end
		end
		tab_call[tab] = call
		return call
	end
	local function mark_of(o: Store.Objective): Mark?
		local kind = ""
		local tabs: { string } = {}
		for _, tab in o.tabs do
			local call = call_of(tab)
			local rank = RANK[call] or 0
			if rank > (RANK[kind] or 0) then
				kind, tabs = call, { win.tabs[tab].label }
			elseif rank > 0 and call == kind then
				table.insert(tabs, win.tabs[tab].label)
			end
		end
		return if kind ~= "" then { kind = kind, tabs = tabs } else nil
	end
	-- While sorting by priority, the lifted objective's priority bounds its drop (sort-by-priority, D4).
	local sorting: Sorting? = nil
	if state.settings.sort_priority then
		local lifted = if ui_state.moving ~= nil then Store.find(state, ui_state.moving) else nil
		sorting = { lifted = if lifted ~= nil then lifted.priority else nil }
	end
	-- One objective node; its title lines set its height (attention-marks-and-titles D1).
	local function add_node(o: Store.Objective, review: boolean?)
		local first = Layout.first(left)
		local title = Text.wrap(o.title, Layout.title.width, Layout.title.lines)
		local acts: Acts? = nil
		if o.id == selected then
			local tabs, kept = {}, 0
			if o.done then
				tabs, kept = M.closable(state, win, o)
			end
			local c = ui_state.confirm
			local ask: string? = nil
			if c ~= nil and c.kind == "close" and c.where == "bar" and c.id == o.id and #tabs > 0 then
				ask = "close"
			elseif c ~= nil and c.kind == "reopen" and c.id == o.id and o.done then
				ask = "reopen"
			end
			acts = { close = #tabs, kept = kept, ask = ask }
		end
		obj_cy[o.id] = Layout.add_obj(left, review, #title, acts ~= nil, acts ~= nil and acts.ask ~= nil)
		local lit = focus_tab ~= nil and not o.done and table.find(o.tabs, focus_tab) ~= nil
		table.insert(left_kids, objective_node(o, ui_state, first, title, mark_of(o), review, acts, lit, sorting))
		if o.id == selected then
			sel_obj = o
		end
	end
	if reviewing then
		for _, o in due_list do
			add_node(o, true)
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
		add_node(o)
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
				add_node(o)
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
	-- Open or done, the selected objective's links change through these bars
	-- (custom-order-and-direct-controls, design D10).
	local function link_of(tab: number): Link?
		if sel_obj == nil then
			return nil
		end
		return { unlink = sel_tabs[tab] == true, title = sel_obj.title }
	end
	-- The tab menu's rows: every open objective in the graph's order, whatever the filters (design P6;
	-- sort-by-priority D2).
	local menu_objs = Store.open_in_order(state, ui_state.held)
	-- Each row's label carries the creation time; a menu row's `detail` is only a tooltip
	-- (creation-time-suffix D3). Formatted once, not once per tab.
	local menu_labels: { [string]: string } = {}
	for _, o in menu_objs do
		local created = Dates.short(o.created)
		menu_labels[o.id] = if created ~= nil then o.title .. " · " .. created else o.title
	end
	local function menu_of(tab: number): { any }
		if #menu_objs == 0 then
			return { { id = "none", label = "No objectives yet", disabled = "Create one with ＋ New objective" } }
		end
		local rows: { any } = { { header = "Link to" } }
		for _, o in menu_objs do
			table.insert(rows, { id = "lnk=" .. o.id .. ":" .. tab, label = menu_labels[o.id], checked = table.find(o.tabs, tab) ~= nil })
		end
		return rows
	end
	local done_tabs: { number } = {}
	local function add_tab(t: Model.Tab, status: string)
		local first = Layout.first(right)
		local link = link_of(t.id)
		local resume = false
		if status == "closed" then
			for _, r in t.rows do
				-- Only a row stored as an agent: a chat saved under a pane id another pane now holds
				-- must not turn a shell into a chat. Its file must still be there (design D4).
				local s = if r.kind == "agent" then state.agents[tostring(r.pane)] else nil
				if s ~= nil and tern.fs.exists(s.session) then
					resume = true
				end
			end
		end
		-- The trash icon's question, for a live tab only (close-tab-from-node, D3).
		local c = ui_state.confirm
		local asking = status == "live" and c ~= nil and c.kind == "tab" and c.id == tostring(t.id)
		local linked = linked_open[t.id] == true or linked_done[t.id] == true
		local node, details = tab_node(t, status, first, linked_open[t.id] == true, link, menu_of(t.id), ui_state, view_state.expanded, resume, linked, asking)
		tab_cy[t.id] = Layout.add_tab(right, #t.rows, details, link ~= nil)
		table.insert(right_kids, node)
		if status == "live" and linked_done[t.id] and not linked_open[t.id] then
			table.insert(done_tabs, t.id)
		end
	end
	-- The origin's session comes first, and its tab first inside it (design R1).
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
	-- A closed tab only done objectives link shows only for the selected objective, or for those
	-- review mode lists (close-linked-tabs D6).
	local kept_closed: { [number]: boolean } = {}
	if sel_obj ~= nil then
		for _, tab in sel_obj.tabs do
			kept_closed[tab] = true
		end
	end
	if reviewing then
		for _, o in due_list do
			for _, tab in o.tabs do
				kept_closed[tab] = true
			end
		end
	end
	local closed: { number } = {}
	local elsewhere: { number } = {}
	for tab, st in status_of do
		if st == "closed" and (view_state.scope == "all" or in_session[tab]) and (linked_open[tab] or kept_closed[tab]) then
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
	-- While an objective is selected, the shown tabs it links now come first under a heading, and a
	-- divider leads to the rest; a link change moves its tab on the next render (linked-section D1).
	local n_top, n_rest = 0, 0
	if sel_obj ~= nil then
		local function count(tab: number)
			if sel_tabs[tab] == true then
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
	if sel_obj ~= nil and n_top > 0 then
		local heading = "Linked to “" .. sel_obj.title .. "”"
		local first = Layout.first(right)
		Layout.add_group(right)
		table.insert(right_kids, el("div", { class = "ob-group ob-linkhead" .. first, key = "linkhead", title = heading }, {
			span("ob-gtext", heading, { key = "text" }),
		}))
		place(function(tab)
			return sel_tabs[tab] == true
		end, "l")
		if n_rest > 0 then
			Layout.add_divider(right)
			table.insert(right_kids, el("div", { class = "ob-divider", key = "divider" }, {
				el("div", { class = "ob-drule", key = "a" }),
				span("ob-dpill", "Other tabs", { key = "text" }),
				el("div", { class = "ob-drule", key = "b" }),
			}))
			place(function(tab)
				return sel_tabs[tab] ~= true
			end, "")
		end
	else
		place(nil, "")
	end

	-- Edges: open objectives' lines outside review mode, and the selected objective's when it is done,
	-- in review mode too (linked-section D4). Strong: the selected objective's, or those ending at the
	-- focus tab (highlight-origin-tab-links, design D3).
	local edges: { Edges.Edge } = {}
	local function add_edges(o: Store.Objective)
		local from = obj_cy[o.id]
		for _, tab in o.tabs do
			local to = tab_cy[tab]
			if from ~= nil and to ~= nil then
				table.insert(edges, {
					from = from,
					to = to,
					priority = o.priority,
					done = o.done,
					dashed = status_of[tab] ~= "live",
					strong = o.id == selected or (focus_tab ~= nil and tab == focus_tab),
				})
			end
		end
	end
	if not reviewing then
		for _, o in open_list do
			add_edges(o)
		end
	end
	if sel_obj ~= nil and sel_obj.done then
		add_edges(sel_obj)
	end
	local height = math.max(left.y, right.y)
	local css, layers = Edges.build(edges, height)
	local gap_kids: { Node } = {}
	for i, cls in layers do
		table.insert(gap_kids, el("div", { class = cls, key = "e" .. i }))
	end

	-- Header: scope, tag filter, notices, review, new.
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
	local lifted = if ui_state.moving ~= nil then Store.find(state, ui_state.moving) else nil
	if lifted ~= nil then
		-- While a node is lifted (design D2); the lifting click already dropped any Undo notice.
		local text = "Moving “" .. lifted.title .. "”"
		table.insert(head, el("div", { class = "ob-undo ob-moving", key = "moving" }, {
			span("ob-undo-text", text .. " ·", { key = "text", title = text .. ": click above or below another objective" }),
			span("ob-undo-btn", "Cancel", { key = "btn", actions = { click = "unlift=" } }),
		}))
	end
	if ui_state.undo ~= nil then
		-- After marking done or removing (review design D6); any other click in the graph drops it.
		local kids: { Node } = {
			span("ob-undo-text", ui_state.undo .. " ·", { key = "text", title = ui_state.undo }),
			span("ob-undo-btn", "Undo", { key = "btn", actions = { click = "undo=" } }),
		}
		local close = ui_state.undo_close
		local c = ui_state.confirm
		local target = if close ~= nil then Store.find(state, close.id) else nil
		local n = if target ~= nil then #(M.closable(state, win, target)) else 0
		if close ~= nil and target ~= nil and n > 0 and c ~= nil and c.kind == "close" and c.where == "notice" and c.id == close.id then
			-- The notice's "Close n tabs" asks in place (D4); Cancel brings the notice back as it was.
			kids = {
				span("ob-undo-text", "Close " .. plural(n, "tab") .. " of “" .. target.title .. "”? ·", {
					key = "text",
					title = "Closing ends their programs; omp chats come back with Resume.",
				}),
				span("ob-undo-btn ob-undo-close", "Close", { key = "cfm", actions = { click = "cfm=" } }),
				span("ob-undo-sep", "·", { key = "sep" }),
				span("ob-undo-btn", "Cancel", { key = "cfx", actions = { click = "cfx=" } }),
			}
		elseif close ~= nil and n > 0 then
			-- After marking done, the tabs "Close n tabs" would close (close-linked-tabs D8).
			table.insert(kids, span("ob-undo-sep", "·", { key = "sep" }))
			table.insert(kids, span("ob-undo-btn ob-undo-close", "Close " .. plural(n, "tab"), {
				key = "close",
				title = "Close this objective's tabs; asks first",
				actions = { click = "closetabs=" .. close.id },
			}))
		end
		table.insert(head, el("div", { class = "ob-undo", key = "undo" }, kids))
	end
	if #done_tabs > 0 then
		-- The live tabs shown that only done objectives link (D11); it asks in place first (D4).
		local what = plural(#done_tabs, "done tab")
		local c = ui_state.confirm
		if c ~= nil and c.kind == "done_tabs" then
			table.insert(head, el("div", { class = "ob-undo ob-ask-head", key = "closedone" }, {
				span("ob-undo-text", "Close " .. what .. "? ·", {
					key = "text",
					title = "Closing ends their programs; omp chats come back with Resume. No link changes.",
				}),
				span("ob-undo-btn ob-undo-close", "Close", { key = "cfm", actions = { click = "cfm=" } }),
				span("ob-undo-sep", "·", { key = "sep" }),
				span("ob-undo-btn", "Cancel", { key = "cfx", actions = { click = "cfx=" } }),
			}))
		else
			table.insert(head, span("ob-btn ob-btn-quiet ob-closedone", "Close " .. what, {
				key = "closedone",
				title = "Close the " .. what .. ", which only done objectives link; asks first",
				actions = { click = "closedone=" },
			}))
		end
	end
	if #due_list > 0 then
		table.insert(head, span("ob-btn ob-btn-quiet ob-revbtn" .. (if reviewing then " ob-on" else ""), string.format("Review (%d)", #due_list), {
			key = "review",
			title = if reviewing then "Back to all objectives" else "Review the done objectives that are due",
			actions = { click = "rev=" },
		}))
	end
	-- Configure's settings page (custom-order-and-direct-controls, design D6).
	table.insert(head, el("span", { class = "ob-btn ob-btn-quiet ob-gear", key = "gear", title = "Configure", actions = { click = "page=settings" } }, {
		{ k = "icon", p = { name = "gear" } } :: any,
	}))
	table.insert(head, span("ob-btn ob-btn-primary", "＋ New objective", { key = "new", actions = { click = "new=" } }))

	local view = el("div", { class = "ob-root", key = "root", actions = { click = "bg=" } }, {
		el("div", { class = "ob-head", key = "head" }, head),
		el("div", { class = "ob-graph", key = "graph" }, {
			el("div", { class = "ob-col ob-col-l", key = "l" }, left_kids),
			el("div", { class = "ob-gap", key = "gap" }, gap_kids),
			el("div", { class = "ob-col ob-col-r", key = "r" }, right_kids),
		}),
	})
	return { view = view, css = css, closed = closed, done_tabs = done_tabs, due = #due_list }
end

-- A segmented choice of the settings page: `options` are {value, label}; `act` takes the value.
local function segments(key: string, current: string, options: { { string } }, act: string): Node
	local kids: { Node } = {}
	for _, o in options do
		table.insert(kids, span("ob-segb" .. (if o[1] == current then " ob-on" else ""), o[2], {
			key = o[1],
			actions = { click = act .. "=" .. o[1] },
		}))
	end
	return el("div", { class = "ob-seg", key = key }, kids)
end

local function setting_row(key: string, label: string, kids: { Node }): Node
	local row: { Node } = { span("ob-slabel", label, { key = "label" }) }
	for _, k in kids do
		table.insert(row, k)
	end
	return el("div", { class = "ob-srow", key = key }, row)
end

-- Configure's settings page, drawn in the graph's canvas in place of the columns (design D6): the
-- plugin's shortcuts as Tern's keymap has them (`keys`, by command id; D7), the new-objective
-- defaults (D8) and the order (sort-by-priority, design D5). No edges.
function M.build_settings(state: Store.State, keys: { [string]: { string } }): Built
	local rows: { Node } = { el("div", { class = "ob-sh", key = "h", text = "Shortcuts" }) }
	for _, c in Keys.COMMANDS do
		local chords = keys[c.id] or {}
		local shown: { string } = {}
		for _, chord in chords do
			table.insert(shown, Keys.display(chord))
		end
		local at_default = if c.default ~= nil
			then #chords == 1 and Keys.canon(chords[1]) == Keys.canon(c.default :: string)
			else #chords == 0
		local kids: { Node } = {
			span("ob-skeys" .. (if #shown == 0 then " ob-dim" else ""), if #shown > 0 then table.concat(shown, "  ") else "none", { key = "keys" }),
			span("ob-btn ob-btn-quiet ob-sbtn", "Change", { key = "chg", title = "Type a new shortcut", actions = { click = "kchg=" .. c.id } }),
			span("ob-btn ob-btn-quiet ob-sbtn", "Remove", { key = "rm", title = "No shortcut", actions = { click = "krm=" .. c.id } }),
		}
		if not at_default then
			table.insert(kids, span("ob-btn ob-btn-quiet ob-sbtn", "Reset", {
				key = "rst",
				title = if c.default ~= nil then "Back to " .. Keys.display(c.default :: string) else "Back to no shortcut",
				actions = { click = "krst=" .. c.id },
			}))
		end
		table.insert(rows, setting_row("k:" .. c.id, c.label, kids))
	end
	table.insert(rows, span("ob-line ob-dim ob-snote", "Shortcuts are saved in Tern's keybinds, so Settings › Keyboard shows them too.", { key = "note" }))
	local set = state.settings
	local defaults: { Node } = {
		el("div", { class = "ob-sh", key = "h", text = "New objectives" }),
		setting_row("prio", "Start at", {
			segments("seg", tostring(set.start_priority), { { "0", "P0" }, { "1", "P1" }, { "2", "P2" }, { "3", "P3" } }, "setprio"),
		}),
		setting_row("place", "Place", {
			segments("seg", set.new_place, { { "top", "Top" }, { "bottom", "Bottom" } }, "setplace"),
		}),
	}
	local order: { Node } = {
		el("div", { class = "ob-sh", key = "h", text = "Order" }),
		setting_row("sort", "Sort by priority", {
			segments("seg", if set.sort_priority then "on" else "off", { { "on", "On" }, { "off", "Off" } }, "setsort"),
		}),
		span("ob-line ob-dim ob-snote", "Within one priority, objectives keep your order. Off shows your order as it is.", { key = "note" }),
	}
	local head: { Node } = {
		span("ob-stitle", "Settings", { key = "title" }),
		el("div", { class = "ob-spacer", key = "sp" }),
		span("ob-btn ob-btn-quiet", "Back to graph", { key = "back", actions = { click = "page=graph" } }),
	}
	local view = el("div", { class = "ob-root ob-settings", key = "root" }, {
		el("div", { class = "ob-head", key = "head" }, head),
		el("div", { class = "ob-ssec", key = "keys" }, rows),
		el("div", { class = "ob-ssec", key = "defaults" }, defaults),
		el("div", { class = "ob-ssec", key = "order" }, order),
	})
	return { view = view, css = "", closed = {}, done_tabs = {}, due = 0 }
end

return M
