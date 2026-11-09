--!strict
-- Pane details (design D11): each row's type (design R4) and the lines an open pane row shows.
-- Agents come from one cx.agents:list() per render; the user's last message comes from a transcript
-- cache that reads at most one transcript per tick.

local Agents = require("./agents")
local Model = require("./model")
local Store = require("./store")
local Text = require("./text")

local M = {}

-- A detail line: plain text cut at its end, or a message (`label` set) drawn as label, head and
-- tail, whose head the view lets CSS cut (design R5).
export type Line = { text: string, class: string?, label: string?, tail: string? }

local CLIP = 160
-- Agent messages keep both ends up to SQUEEZE characters; the last TAIL always show (design R5).
local SQUEEZE = 1000
local TAIL = 28

local STATE_TEXT: { [string]: string } = {
	working = "working",
	waiting_input = "waiting for input",
	idle = "idle",
	exited = "exited",
}

-- Agents of the current render, by pane.
local agents: { [number]: AgentBlock } = {}
-- Saved omp chats by pane id, which name closed tabs' chats.
local saved: { [string]: Store.AgentSession } = {}

-- Transcript cache: the user's last message per agent pane, valid while `key` matches.
type Entry = { key: string, you: string?, read: boolean }
local cache: { [number]: Entry } = {}
local stale: { [number]: boolean } = {}

-- Whether any shown row is running a command, so its elapsed time needs a 1 s refresh.
local running_shown = false

local function agent_key(a: AgentBlock): string
	return a.state .. "\n" .. (if type(a.last_message) == "string" then a.last_message else "")
end

-- Reads the agents once for the render that follows; `sessions` are the store's saved sessions.
function M.begin(cx: WindowCx, sessions: { [string]: Store.AgentSession })
	agents = {}
	saved = sessions
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

-- An agent's name (design R4). An agent block's command names its program. A chat typed at a shell
-- prompt has no command (`tern.json.null`, SDK "Agent cx"): it is Claude when its pane's program is
-- claude (resume-closed-agents, design D1), else omp. Beyond that the program is no guide: it is the
-- foreground process, which can be zsh while Tern still lists omp in the pane (task 8.1).
local function agent_name(a: AgentBlock?, program: string?): string
	if a == nil then
		return "agent"
	end
	if Agents.is_claude(a, program) then
		return "claude"
	end
	return Agents.base_name(a.command) or "omp"
end

-- The type a pane row starts with, and the class that colours it: an agent's name with its state,
-- "shell", "note", "file", or the pane's kind (design R4). Ghost rows have only their stored kind.
function M.type(row: Model.Row): (string, string?)
	local a = agents[row.pane]
	local info = row.info
	-- A snapshot written before kinds were stored has none: those panes were terminals.
	local kind = (if info ~= nil and info.kind ~= nil then info.kind else row.kind) or "terminal"
	if a ~= nil then
		return agent_name(a, if info ~= nil then info.program else nil) .. " · " .. (STATE_TEXT[a.state] or a.state), "ob-d-" .. a.state
	elseif kind == "agent" then
		-- A closed tab's chat: its saved omp chat names it (resume-omp-chats, design D4).
		local s = saved[tostring(row.pane)]
		return if s ~= nil then s.agent else agent_name(nil, nil), nil
	elseif kind == "terminal" then
		return "shell", nil
	elseif kind == "file" then
		local path = if info ~= nil then info.path else nil
		return if path ~= nil and string.sub(path, 1, 5) == "note:" then "note" else "file", nil
	end
	return kind, nil
end

-- An omp row's call on the user (attention-marks-and-titles D3): "wait" while its chat waits for
-- input, "replied" while it sits idle with a reply the user hasn't seen (Tern's unseen alert, cleared
-- once that pane gets focus, not by focusing another pane of its tab), "working" while it works on a
-- turn (working-mark D1), else nil. Other agents never call.
function M.attention(row: Model.Row): string?
	local a = agents[row.pane]
	local info = row.info
	if a == nil or agent_name(a, if info ~= nil then info.program else nil) ~= "omp" then
		return nil
	end
	if a.state == "waiting_input" then
		return "wait"
	elseif a.state == "idle" and info ~= nil and info.alert == true then
		return "replied"
	elseif a.state == "working" then
		return "working"
	end
	return nil
end

-- "you: …" and "<agent>: …", each kept whole up to SQUEEZE characters and split before its last
-- TAIL characters for the view's middle cut. Only omp has a chat to read "you:" from, so other agents
-- get the reply line alone and no transcript read (fix-spec-drift D2).
local function agent_lines(row: Model.Row, a: AgentBlock): { Line }
	local out: { Line } = {}
	local name = agent_name(a, if row.info ~= nil then row.info.program else nil)
	if name == "omp" then
		local key = agent_key(a)
		local entry = cache[row.pane]
		if entry == nil or entry.key ~= key then
			stale[row.pane] = true
		end
		if entry == nil or not entry.read then
			table.insert(out, { label = "you:", text = "…", class = "ob-d-wait" })
		elseif entry.you ~= nil then
			local head, tail = Text.split_end(entry.you, TAIL)
			table.insert(out, { label = "you:", text = head, tail = tail })
		end
	end
	if type(a.last_message) == "string" and a.last_message ~= "" then
		-- omp ends a turn's text with a footer block ("\n·\n1.6s · 557 tok · …"): not part of the reply.
		local reply = string.match(a.last_message, "^(.-)\n·\n[^\n]*$") or a.last_message
		local head, tail = Text.split_end(Text.squeeze(reply, SQUEEZE), TAIL)
		table.insert(out, { label = name .. ":", text = head, tail = tail })
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
		return agent_lines(row, a)
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
					you = Text.squeeze(msgs[i].text, SQUEEZE)
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
