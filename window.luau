--!strict
-- Objectives: window half. Registers the palette commands and the canvas click handler; everything
-- else lives in lib/.

local App = require("./lib/app")
local Layout = require("./lib/layout")

tern.css("layout", Layout.css())

tern.on("window_start", function(_cx: WindowCx)
	tern.css("layout", Layout.css())
	App.restore_css()
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
