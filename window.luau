--!strict
-- Objectives: the window script, the whole plugin. Registers the palette commands, the graph's
-- clicks (canvas_action) and the window events that keep a shown graph current; everything else
-- lives in lib/.

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

-- ⌃⌘R, the partner of ⌃⌘O. Tern keeps plain R for itself, and a plugin's Shift+R would take every
-- capital R typed in any pane: a plugin key runs whatever `available` says (design D6).
tern.command({
	id = "rename",
	title = "Objectives: Rename selected objective",
	icon = "pencil",
	group = "Objectives",
	keys = { "ctrl+cmd+r" },
	available = App.can_rename,
	run = App.rename_selected,
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

-- Clicks in the graph's canvas (design G3).
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
