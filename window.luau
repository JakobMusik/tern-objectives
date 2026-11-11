--!strict
-- Objectives: the window script, the whole plugin. Registers the palette commands, the graph's
-- clicks (canvas_action) and the window events that keep a shown graph current; everything else
-- lives in lib/.

local Agents = require("./lib/agents")
local App = require("./lib/app")
local Layout = require("./lib/layout")
local Keys = require("./lib/keys")
local Refresh = require("./lib/refresh")

Refresh.init(App.render)

-- Reinstalled by every load, a plugin reload included. The edge sheet is drawn by each render.
tern.css("layout", Layout.css())

-- A plugin reload starts a new VM and drops its CSS sheets, while a shown graph survives and
-- window_start doesn't run again: draw the graph once more from a timer, which brings a cx. A canvas
-- a 0.1.x graph left behind is redrawn the same way (design G5). omp chats running before this
-- load are saved from here too (resume-omp-chats, design D2).
tern.timer(0, function(cx: WindowCx?)
	if cx ~= nil then
		App.render(cx)
		Agents.request()
	end
end)

-- The palette commands, their default keys from lib/keys.luau. Registered at load, and again after
-- Configure writes the user's keybinds, which drops every plugin's keys from the keymap until a run-time
-- registration (custom-order-and-direct-controls, design D7).
local function register_commands()
	tern.command({
		id = "open",
		title = "Objectives: Open graph",
		icon = "list-checks",
		group = "Objectives",
		keys = Keys.default_keys("open"),
		run = App.toggle,
	})

	-- ⌥⇧R, as the user asked (rename-key-shift-option-r). Like every plugin key it runs in every pane, so
	-- Option+Shift+R types nothing anywhere in Tern; outside the graph it shows a hint. A plain R can't
	-- work, not even inside the graph only: Tern keeps plain R for itself, a canvas gets no keys, and
	-- `available` doesn't gate a key (design D6).
	tern.command({
		id = "rename",
		title = "Objectives: Rename selected objective",
		icon = "pencil",
		group = "Objectives",
		keys = Keys.default_keys("rename"),
		available = App.can_rename,
		run = App.rename_selected,
	})

	-- ⌥N, as the user asked (design D5): a new objective, made in the graph, which opens first when it
	-- isn't shown here. Like ⌥⇧R it runs in every pane, whichever Option key.
	tern.command({
		id = "new",
		title = "Objectives: New objective",
		icon = "plus",
		group = "Objectives",
		keys = Keys.default_keys("new"),
		run = App.new_key,
	})

	-- ⌃⌥F (search-and-tab-marks, design D5): the search field over the graph, which opens first when
	-- it isn't shown here. ⌥F, the user's first choice, is Tern's own (canvas.fill_solid), and Tern
	-- leaves out a plugin's default on a key it binds.
	tern.command({
		id = "search",
		title = "Objectives: Search…",
		icon = "search",
		group = "Objectives",
		keys = Keys.default_keys("search"),
		run = App.search_key,
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

	-- The settings page: shortcuts and the new-objective defaults (design D6).
	tern.command({
		id = "configure",
		title = "Objectives: Configure",
		icon = "gear",
		group = "Objectives",
		run = App.configure,
	})
end

register_commands()
App.on_keybinds(register_commands)

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
	"float_moved",
	"session_ended",
} do
	tern.on(name, function(_ev: any, cx: WindowCx)
		Refresh.request(cx)
	end)
end

-- An agent's state changed: redraw, and at a turn's start save omp chats (resume-omp-chats, D2).
tern.on("agent_state", function(ev: AgentStateEvent, cx: WindowCx)
	Refresh.request(cx)
	if ev.new == "working" then
		Agents.request()
	end
end)

-- A turn ended: redraw, and save omp chats too, in case the turn was too short for Tern to see it
-- working (resume-closed-agents, D2). An exited or closed agent has no process left to read.
tern.on("agent_finished", function(ev: AgentFinishedEvent, cx: WindowCx)
	Refresh.request(cx)
	if ev.result == "done" or ev.result == "failed" then
		Agents.request()
	end
end)

-- A paused hook stops live refresh; say so in the log, where `tern plugin` users look.
tern.on("budget", function(ev: BudgetEvent, _cx: WindowCx)
	tern.log.warn("objectives: hook " .. ev.hook .. " " .. ev.state)
end)
