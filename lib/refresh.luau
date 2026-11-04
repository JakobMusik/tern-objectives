--!strict
-- Live refresh (design D12). While the canvas exists one 250 ms heartbeat runs:
-- - every beat: read one stale agent transcript (design D11);
-- - every 3rd beat (750 ms): compare a cheap window signature, since pane_created and tab_created
--   miss panes made by the CLI or restored;
-- - every 4th beat (1 s): redraw while a shown row is running a command, so its elapsed time moves.
-- Window events ask for one render 150 ms later, coalesced. Everything stops once the canvas is gone.

local Canvas = require("./canvas")
local Details = require("./details")

local M = {}

local render: (WindowCx) -> () = function(_cx) end
local beating = false
local beats = 0
local pending = false
local last_sig = ""

function M.init(fn: (WindowCx) -> ())
	render = fn
end

local function signature(cx: WindowCx): string
	local parts: { string } = {}
	for _, s in cx.session:sessions() do
		table.insert(parts, string.format("s%d%s:%s", s.id, if s.current then "*" else "", table.concat(s.tabs, ",")))
	end
	for _, p in cx.session:panes() do
		table.insert(parts, string.format("p%d@%s%s=%s", p.pane, tostring(p.tab), if p.parked then "^" else "", p.title))
	end
	for _, t in cx.session:tabs() do
		if t.name ~= nil then
			table.insert(parts, string.format("n%d=%s", t.id, t.name))
		end
	end
	-- Agents too: a missed agent_state or agent_finished event still shows within one poll.
	local ok, agents = pcall(function()
		return cx.agents:list()
	end)
	if ok then
		for _, a in agents do
			local reply = if type(a.last_message) == "string" then #a.last_message else 0
			table.insert(parts, string.format("a%d=%s/%d", a.pane, a.state, reply))
		end
	end
	return table.concat(parts, ";")
end

-- Records what the last render saw, so the poll only fires on real changes.
function M.rendered(cx: WindowCx)
	last_sig = signature(cx)
end

local function beat(cx: WindowCx?)
	if cx == nil or Canvas.find(cx) == nil then
		beating = false
		return
	end
	beats += 1
	local dirty = false
	if Details.has_stale() and Details.tick(cx) then
		dirty = true
	end
	if beats % 3 == 0 and signature(cx) ~= last_sig then
		dirty = true
	end
	if beats % 4 == 0 and Details.running_shown() then
		dirty = true
	end
	if dirty then
		render(cx)
	end
	tern.timer(250, beat)
end

-- Starts the heartbeat when it isn't running.
function M.start()
	if beating then
		return
	end
	beating = true
	tern.timer(250, beat)
end

-- A window event: render once, 150 ms from now, if the graph is shown.
function M.request(cx: WindowCx)
	if pending or not Canvas.known() or Canvas.find(cx) == nil then
		return
	end
	pending = true
	tern.timer(150, function(cx2: WindowCx?)
		pending = false
		if cx2 ~= nil and Canvas.find(cx2) ~= nil then
			render(cx2)
		end
	end)
end

return M
