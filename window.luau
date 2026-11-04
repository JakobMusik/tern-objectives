--!strict
-- Objectives: window half. Registers the palette commands, the canvas click handler and the window
-- events that keep a shown graph current; everything else lives in lib/.

local App = require("./lib/app")
local Layout = require("./lib/layout")
local Refresh = require("./lib/refresh")

Refresh.init(App.render)
tern.css("layout", Layout.css())

tern.on("window_start", function(cx: WindowCx)
	tern.css("layout", Layout.css())
	App.restore_css()
	Refresh.resume(cx)
end)

tern.command({
	id = "open",
	title = "Objectives: Open graph",
	icon = "list-checks",
	group = "Objectives",
	keys = { "ctrl+cmd+o" },
	run = App.open,
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
