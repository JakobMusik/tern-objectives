--!strict
-- Saved Claude sessions (design D1, D2). A Claude chat's `claude` process is started with its
-- session id. When a turn starts, the chats and their processes are paired by folder, and each
-- chat's id is saved under its pane, so a closed tab can resume it. A folder holding more than one
-- chat, or more than one such process, saves nothing: an unsure match could resume the wrong chat.

local Store = require("./store")

local M = {}

local UUID = "^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$"

-- Whether `s` is a session id: only these are ever typed into a shell (design D5).
function M.is_session_id(s: any): boolean
	return type(s) == "string" and string.match(s, UUID) ~= nil
end

-- The last path segment of a command's first word, or nil when there is none.
function M.base_name(s: any): string?
	local first = if type(s) == "string" then string.match(s, "^%s*(%S+)") else nil
	if first == nil then
		return nil
	end
	return string.match(first, "([^/]+)$") or first
end

-- Whether an agent is a Claude chat (design D1): its command runs claude or, with no command (a
-- chat typed at a shell prompt), its pane's program is claude.
function M.is_claude(a: AgentBlock, program: string?): boolean
	local cmd = M.base_name(a.command)
	if cmd ~= nil then
		return cmd == "claude"
	end
	return program == "claude"
end

-- A folder as Tern and the process table both name it: macOS's /tmp, /var and /etc are links into
-- /private, which processes report and Tern doesn't (source record).
function M.folder(path: string): string
	local p = string.gsub(path, "(.)/+$", "%1")
	for _, top in { "/tmp", "/var", "/etc" } do
		local linked = "/private" .. top
		if p == linked or string.sub(p, 1, #linked + 1) == linked .. "/" then
			return string.sub(p, #"/private" + 1)
		end
	end
	return p
end

-- The session id a claude process was started with: `--session-id` or `--resume`, as `=value` or
-- as the next argument (task 1.1 saw both forms); nil when it has none.
function M.session_of(argv: { string }): string?
	for i, arg in argv do
		local v = string.match(arg, "^%-%-session%-id=(.+)$") or string.match(arg, "^%-%-resume=(.+)$")
		if v == nil and (arg == "--session-id" or arg == "--resume") then
			v = argv[i + 1]
		end
		if v ~= nil and M.is_session_id(v) then
			return v
		end
	end
	return nil
end

-- This window's panes in sessions on this machine: `cx.procs` sees only this Mac (source record).
local function local_panes(cx: WindowCx): { [number]: boolean }
	local hosts: { [number]: boolean } = {}
	for _, h in cx.hosts:list() do
		if h.kind == "local" then
			hosts[h.id] = true
		end
	end
	local sessions: { [number]: boolean } = {}
	for _, s in cx.sessions:list() do
		if hosts[s.host] then
			sessions[s.id] = true
		end
	end
	local tabs: { [number]: boolean } = {}
	for _, s in cx.session:sessions() do
		if sessions[s.id] then
			for _, t in s.tabs do
				tabs[t] = true
			end
		end
	end
	local out: { [number]: boolean } = {}
	for _, p in cx.session:panes() do
		if p.tab ~= nil and tabs[p.tab] then
			out[p.pane] = true
		end
	end
	return out
end

-- `turned`: the chat has had a turn, so its conversation exists to resume (source record: the
-- session file appears with the first message).
type Chat = { pane: number, cwd: string, folder: string, turned: boolean }

-- Panes seen starting or ending a turn in this VM. A reload forgets them; a chat with a last reply
-- has had a turn anyway.
local turned: { [number]: boolean } = {}

-- The live Claude chats of this window's sessions on this machine.
local function chats(cx: WindowCx): { Chat }
	local here = local_panes(cx)
	local out: { Chat } = {}
	for _, a in cx.agents:list() do
		if here[a.pane] and type(a.cwd) == "string" and a.cwd ~= "" then
			local info = cx.session:pane(a.pane)
			if M.is_claude(a, if info ~= nil then info.program else nil) then
				local replied = type(a.last_message) == "string" and a.last_message ~= ""
				table.insert(out, { pane = a.pane, cwd = a.cwd, folder = M.folder(a.cwd), turned = turned[a.pane] == true or replied })
			end
		end
	end
	return out
end

-- Pairs chats with processes by folder: only a folder with one chat and one process with a session
-- id saves, under that chat's pane.
function M.pair(list: { Chat }, processes: { ProcessInfo }, now: number): { [string]: Store.AgentSession }
	local ids: { [string]: { string } } = {}
	for _, p in processes do
		if p.name == "claude" and p.cwd ~= nil then
			local id = M.session_of(p.command)
			if id ~= nil then
				local f = M.folder(p.cwd)
				local at = ids[f]
				if at == nil then
					at = {}
					ids[f] = at
				end
				table.insert(at, id)
			end
		end
	end
	local per_folder: { [string]: number } = {}
	for _, c in list do
		per_folder[c.folder] = (per_folder[c.folder] or 0) + 1
	end
	local found: { [string]: Store.AgentSession } = {}
	for _, c in list do
		local at = ids[c.folder]
		-- Every chat counts towards its folder, so a chat with no turn yet still makes the folder unsure.
		if c.turned and per_folder[c.folder] == 1 and at ~= nil and #at == 1 then
			found[tostring(c.pane)] = { agent = "claude", session = at[1], cwd = c.cwd, seen = now }
		end
	end
	return found
end

local pending = false

local function fail(msg: string)
	pending = false
	tern.log.warn("objectives: session capture " .. msg)
end

-- `cx.procs:list` answers with the sampler's latest finished sample and starts a new one, so after
-- a quiet spell its answer can be minutes old (task 2.2 saw a closed chat's process in it). The
-- first list only starts a fresh sample; a later one is used once its sample number has moved on.
local QUERY: ProcessQuery = { name = "claude", limit = 500 }
local WAIT_MS = 1000
local TRIES = 3

local function use(list: { Chat }, live: { [number]: boolean }, res: ProcessList, started: number)
	pending = false
	local found = M.pair(list, res.processes, os.time())
	local saved = 0
	for _ in found do
		saved += 1
	end
	Store.save_sessions(Store.read(), found, live)
	tern.log.info(string.format("objectives: session capture %.0f ms, %d chat(s), %d paired", tern.now() - started, #list, saved))
end

local function capture(cx: WindowCx)
	local list = chats(cx)
	if #list == 0 then
		pending = false
		return
	end
	local live: { [number]: boolean } = {}
	for _, p in cx.session:panes() do
		live[p.pane] = true
	end
	local started = tern.now()
	cx.procs:list(QUERY):next(function(first: ProcessList?, err: any)
		if first == nil then
			fail("could not list processes: " .. tostring(err))
			return
		end
		local function again(left: number)
			tern.timer(WAIT_MS, function(cx2: WindowCx?)
				if cx2 == nil then
					pending = false
					return
				end
				cx2.procs:list(QUERY):next(function(res: ProcessList?, err2: any)
					if res == nil then
						fail("could not list processes: " .. tostring(err2))
					elseif res.sample ~= first.sample then
						use(list, live, res, started)
					elseif left > 1 then
						again(left - 1)
					else
						fail("found no fresh process sample")
					end
				end)
			end)
		end
		again(TRIES)
	end)
end

-- `pane` started or ended a turn (design D2): capture half a second from now, unless one is
-- already under way.
function M.request(_cx: WindowCx, pane: number)
	turned[pane] = true
	if pending then
		return
	end
	pending = true
	tern.timer(500, function(cx: WindowCx?)
		if cx == nil then
			pending = false
			return
		end
		local ok, err = pcall(capture, cx)
		if not ok then
			fail("failed: " .. tostring(err))
		end
	end)
end

return M
