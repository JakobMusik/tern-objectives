--!strict
-- Objectives: window half. Task 2.2 stub: fixed nodes and masked edge layers.

local Canvas = require("./lib/canvas")
local Layout = require("./lib/layout")
local Edges = require("./lib/edges")
local ui = tern.ui

tern.css("layout", Layout.css())

local selected: string? = nil

local OBJS = {
	{ id = "o1", p = 0, title = "Fix login bug" },
	{ id = "o2", p = 1, title = "Review pull requests, a deliberately long title that has to end in an ellipsis inside its node" },
	{ id = "o3", p = 2, title = "API notes" },
	{ id = "o4", p = 3, title = "Read papers" },
}
local SESSIONS = {
	{ name = "alpha", tabs = { { id = "t1", label = "App status check", rows = { "zsh ~/app", "omp" } }, { id = "t2", label = "Guides", rows = { "zsh ~/guides" } } } },
	{ name = "beta", tabs = { { id = "t3", label = "API Learning", rows = { "nvim cache.go" } } } },
}
local LINKS = { { "o1", "t1" }, { "o2", "t2" }, { "o3", "t1" }, { "o3", "t3", dashed = true }, { "o4", "t3" } }
local SWATCHES = { "bad", "warn", "ink-pen", "accent", "ansi4", "sf-info", "t3" }

local function view(): Node
	local left, right = Layout.stack(), Layout.stack()
	local lk, rk = {}, {}
	local ocy, tcy, prio = {}, {}, {}
	for _, o in OBJS do
		local cls = "ob-obj ob-o-" .. o.id .. Layout.first(left)
		ocy[o.id] = Layout.add_obj(left)
		prio[o.id] = o.p
		table.insert(lk, ui.el("div", { class = cls, key = o.id, title = o.title, actions = { click = "sel=" .. o.id } }, {
			ui.el("span", { class = "ob-line", text = "P" .. o.p .. "  " .. o.title }),
			ui.el("span", { class = "ob-line ob-dim", text = "side note · due tomorrow · #tag" }),
		}))
	end
	for si, s in SESSIONS do
		local scls = "ob-session" .. Layout.first(right)
		Layout.add_session(right)
		table.insert(rk, ui.el("div", { class = scls, key = "s" .. si, text = s.name }))
		for ti, t in s.tabs do
			local tcls = "ob-tab ob-t-" .. t.id .. Layout.first(right)
			tcy[t.id] = Layout.add_tab(right, #t.rows, 0)
			local kids = {
				ui.el("div", { class = "ob-thead", key = "h" }, {
					ui.el("span", { class = "ob-line", text = t.label }),
					ui.el("span", { class = "ob-line ob-dim", text = s.name .. " · tab " .. ti }),
				}),
			}
			for ri, r in t.rows do
				table.insert(kids, ui.el("div", { class = "ob-row", key = "r" .. ri, text = r }))
			end
			table.insert(rk, ui.el("div", { class = tcls, key = t.id }, kids))
		end
	end
	local edges: { Edges.Edge } = {}
	for _, l in LINKS do
		table.insert(edges, { from = ocy[l[1]], to = tcy[l[2]], priority = prio[l[1]], dashed = l.dashed == true, selected = l[1] == selected })
	end
	local height = math.max(left.y, right.y)
	local css, layers = Edges.build(edges, height)
	tern.css("edges", css)
	local gap = {}
	for i, cls in layers do
		table.insert(gap, ui.el("div", { class = cls, key = "e" .. i }))
	end
	local sw = {}
	for _, name in SWATCHES do
		table.insert(sw, ui.el("span", { class = "ob-sw ob-sw-" .. name, key = name, text = name }))
	end
	return ui.el("div", { class = "ob-root", key = "root", actions = { click = "bg=" } }, {
		ui.el("div", { class = "ob-swatches", key = "sw" }, sw),
		ui.el("div", { class = "ob-graph", key = "graph" }, {
			ui.el("div", { class = "ob-col ob-col-l", key = "l" }, lk),
			ui.el("div", { class = "ob-gap", key = "gap" }, gap),
			ui.el("div", { class = "ob-col ob-col-r", key = "r" }, rk),
		}),
	})
end

local swcss = {}
for _, name in SWATCHES do
	table.insert(swcss, string.format("[data-surface='plugin.tern.canvas'] .ob-sw-%s { background: var(--%s); color: white; padding: 2px 6px; margin-right: 6px; border-radius: 4px; }", name, name))
end
tern.css("probe", table.concat(swcss, "\n"))

tern.command({
	id = "open",
	title = "Objectives: Open graph",
	group = "Objectives",
	keys = { "ctrl+cmd+o" },
	run = function(cx)
		local pane, err = Canvas.show(cx, view())
		if pane == nil then
			cx:toast("error", "Objectives: could not open the graph", err)
		end
	end,
})

tern.on("canvas_action", function(ev: CanvasAction, cx: WindowCx): boolean?
	if ev.act == "sel" then
		selected = if selected == ev.value then nil else ev.value
	elseif ev.act == "bg" then
		selected = nil
	else
		return nil
	end
	Canvas.update(cx, view())
	return true
end)
