--!strict
-- Objectives: window half. Registers the palette commands, the two click paths (the link route
-- from the graph block in host.luau, and canvas_action from the canvas used in sessions on other
-- machines), and the window events that keep a shown graph current; everything else lives in lib/.

local App = require("./lib/app")
local Layout = require("./lib/layout")
local Refresh = require("./lib/refresh")

Refresh.init(App.render)

-- Reinstalled by every load, a plugin reload included. The edge sheet is drawn by each render.
tern.css("layout", Layout.css())

-- A plugin reload starts a new VM and drops its CSS sheets, while a shown graph survives and
-- window_start doesn't run again: draw the graph once more from a timer, which brings a cx. A canvas
-- a 0.1.x graph left behind is redrawn the same way (design G5).
tern.timer(0, function(cx: WindowCx?)
	if cx ~= nil then
		App.render(cx)
	end
end)

tern.command({
	id = "open",
	title = "Objectives: Open graph",
	icon = "list-checks",
	group = "Objectives",
	keys = { "ctrl+cmd+o" },
	run = App.toggle,
})

tern.command({
	id = "link_tab",
	title = "Objectives: Link this tab…",
	icon = "list-checks",
	group = "Objectives",
	run = App.link_tab,
})

tern.command({
	id = "new_for_tab",
	title = "Objectives: New objective for this tab…",
	icon = "list-checks",
	group = "Objectives",
	run = App.new_for_tab,
})

-- Clicks in the graph block arrive as objectives:// links (archived design P4).
tern.route.link(function(link: LinkRequest, cx: WindowCx): RouteDecision?
	return App.link(link, cx)
end)

-- Clicks in the canvas, the graph's surface in sessions on other machines (design G3).
tern.on("canvas_action", function(ev: CanvasAction, cx: WindowCx): boolean?
	if ev.owner ~= "objectives" then
		return nil
	end
	App.action({ act = ev.act, value = ev.value }, cx)
	return true
end)

-- Window events that change what the graph shows (design D12).
for _, name in {
	"focus",
	"pane_created",
	"pane_closed",
	"tab_created",
	"tab_closed",
	"title",
	"command_started",
	"command_finished",
	"agent_state",
	"agent_finished",
	"float_moved",
	"session_ended",
} do
	tern.on(name, function(_ev: any, cx: WindowCx)
		Refresh.request(cx)
	end)
end

-- A paused hook stops live refresh; say so in the log, where `tern plugin` users look.
tern.on("budget", function(ev: BudgetEvent, _cx: WindowCx)
	tern.log.warn("objectives: hook " .. ev.hook .. " " .. ev.state)
end)
