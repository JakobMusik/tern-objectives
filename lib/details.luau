--!strict
-- Pane details (design D11): the lines an open pane row shows. Agents come from one
-- cx.agents:list() per render; the user's last message comes from a transcript cache that reads at
-- most one transcript per tick.

local Model = require("./model")
local Text = require("./text")

local M = {}

export type Line = { text: string, class: string? }

local CLIP = 160

local STATE_TEXT: { [string]: string } = {
	working = "working",
	waiting_input = "waiting for input",
	idle = "idle",
	exited = "exited",
}

-- Agents of the current render, by pane.
local agents: { [number]: AgentBlock } = {}

-- Transcript cache: the user's last message per agent pane, valid while `key` matches.
type Entry = { key: string, you: string?, read: boolean }
local cache: { [number]: Entry } = {}
local stale: { [number]: boolean } = {}

-- Whether any shown row is running a command, so its elapsed time needs a 1 s refresh.
local running_shown = false

local function agent_key(a: AgentBlock): string
	return a.state .. "\n" .. (if type(a.last_message) == "string" then a.last_message else "")
end

-- Reads the agents once for the render that follows.
function M.begin(cx: WindowCx)
	agents = {}
	running_shown = false
	local ok, list = pcall(function()
		return cx.agents:list()
	end)
	if ok then
		for _, a in list do
			agents[a.pane] = a
		end
	end
end

function M.duration(ms: number): string
	if ms < 1000 then
		return string.format("%dms", math.floor(ms))
	end
	local s = ms / 1000
	if s < 60 then
		return string.format("%.1fs", s)
	end
	local total = math.floor(s)
	if total < 3600 then
		return string.format("%dm%02ds", total // 60, total % 60)
	end
	return string.format("%dh%02dm", total // 3600, (total % 3600) // 60)
end

local function home_short(path: string): string
	local home = tern.getenv("HOME")
	if home ~= nil and home ~= "" and string.sub(path, 1, #home) == home then
		return "~" .. string.sub(path, #home + 1)
	end
	return path
end

local function agent_lines(pane: number, a: AgentBlock): { Line }
	local out: { Line } = {
		{ text = STATE_TEXT[a.state] or a.state, class = "ob-d-state ob-d-" .. a.state },
	}
	local key = agent_key(a)
	local entry = cache[pane]
	if entry == nil or entry.key ~= key then
		stale[pane] = true
	end
	if entry == nil or not entry.read then
		table.insert(out, { text = "you  …", class = "ob-d-wait" })
	elseif entry.you ~= nil then
		table.insert(out, { text = "you  " .. entry.you })
	end
	if type(a.last_message) == "string" and a.last_message ~= "" then
		-- omp ends a turn's text with a footer block ("\n·\n1.6s · 557 tok · …"): not part of the reply.
		local reply = string.match(a.last_message, "^(.-)\n·\n[^\n]*$") or a.last_message
		table.insert(out, { text = "omp  " .. Text.clip(reply, CLIP) })
	end
	return out
end

local function terminal_lines(info: PaneInfo): { Line }
	if info.running ~= nil then
		running_shown = true
		return { { text = "⟳ " .. M.duration(info.running.ms) .. "  " .. Text.clip(info.running.line, CLIP), class = "ob-d-run" } }
	end
	if info.last ~= nil then
		local ok = info.last.status == 0
		return {
			{
				text = string.format("%s %d · %s  %s", if ok then "✓" else "✗", info.last.status, M.duration(info.last.took_ms), Text.clip(info.last.line, CLIP)),
				class = if ok then "ob-d-ok" else "ob-d-bad",
			},
		}
	end
	return { { text = "no command yet" } }
end

-- The detail lines for one live pane row.
function M.lines(_cx: WindowCx, row: Model.Row): { Line }
	local a = agents[row.pane]
	if a ~= nil then
		return agent_lines(row.pane, a)
	end
	local info = row.info
	if info == nil then
		return { { text = row.title } }
	end
	if info.kind == nil or info.kind == "terminal" or info.kind == "agent" then
		return terminal_lines(info)
	elseif info.kind == "file" and info.path ~= nil then
		return { { text = home_short(info.path) } }
	elseif info.kind == "browser" and info.url ~= nil then
		return { { text = info.url } }
	elseif info.kind == "plugin" and info.block ~= nil then
		return { { text = info.block } }
	end
	return { { text = row.title } }
end

function M.running_shown(): boolean
	return running_shown
end

-- Reads one stale transcript; true when an entry changed (the caller then renders again).
function M.tick(cx: WindowCx): boolean
	local pane = next(stale)
	if pane == nil then
		return false
	end
	stale[pane] = nil
	local a = agents[pane]
	if a == nil then
		cache[pane] = nil
		return false
	end
	local you: string? = nil
	local ok = pcall(function()
		for _, last in { 10, 50 } do
			local msgs = cx.agents:transcript(pane, { last = last })
			for i = #msgs, 1, -1 do
				if msgs[i].role == "user" then
					you = Text.clip(msgs[i].text, CLIP)
					return
				end
			end
			if #msgs < last then
				return
			end
		end
	end)
	cache[pane] = { key = agent_key(a), you = if ok then you else nil, read = true }
	return true
end

function M.has_stale(): boolean
	return next(stale) ~= nil
end

return M
