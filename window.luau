--!strict
-- Objectives: window half. Registers the palette commands, the canvas click handler and the window
-- events that keep a shown graph current; everything else lives in lib/.

local App = require("./lib/app")
local Layout = require("./lib/layout")
local Refresh = require("./lib/refresh")

Refresh.init(App.render)

-- Reinstalled by every load, a plugin reload included. The edge sheet is drawn by each render.
tern.css("layout", Layout.css())

-- A plugin reload keeps a shown canvas but starts a new VM and drops its CSS sheets, and
-- window_start doesn't run again: draw the graph once more from a timer, which brings a cx. The
-- first window event or click does the same if this timer comes late.
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

tern.on("canvas_action", function(ev: CanvasAction, cx: WindowCx): boolean?
	return App.action(ev, cx)
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
