--!strict
-- Saved omp chats (resume-omp-chats, design D1, D2). Every omp process carries its pane's id in its
-- environment, and holds its chat file open once the chat has had a message; a chat started from a
-- file names that file on its command line. One process run reads all three, and each chat's file
-- is saved under its pane, so a closed tab can resume it. A pane that more than one omp process
-- names, or a process with more than one chat file open, saves nothing: an unsure match could
-- resume the wrong chat.

local Model = require("./model")
local Store = require("./store")
local Surface = require("./surface")

local M = {}

-- The last path segment of a command's first word, or nil when there is none.
function M.base_name(s: any): string?
	local first = if type(s) == "string" then string.match(s, "^%s*(%S+)") else nil
	if first == nil then
		return nil
	end
	return string.match(first, "([^/]+)$") or first
end

-- Whether an agent is a Claude chat, which names its row (pane-details "Pane type"): its command
-- runs claude or, with no command (a chat typed at a shell prompt), its pane's program is claude.
function M.is_claude(a: AgentBlock, program: string?): boolean
	local cmd = M.base_name(a.command)
	if cmd ~= nil then
		return cmd == "claude"
	end
	return program == "claude"
end

-- `s` quoted for a POSIX shell (design D5).
function M.quote(s: string): string
	return "'" .. (string.gsub(s, "'", "'\\''")) .. "'"
end

-- The omp processes' command lines (`a`), pane ids from their environments (`e`), and the
-- `.jsonl` files they hold open (lsof's `p` and `n`), as tagged lines (design D1). It ends with
-- status 0 whatever the pipelines found.
local SCRIPT = table.concat({
	[[p=$(/usr/bin/pgrep -d, -f '(^|/)omp( |$)') || exit 0]],
	[[/bin/ps -ww -o pid=,args= -p "$p" | /usr/bin/sed 's/^ */a /']],
	[[/bin/ps -wwE -o pid=,command= -p "$p" | /usr/bin/grep -oE '^ *[0-9]+|TERN_(WINDOW_)?PANE=[0-9]+' | /usr/bin/sed 's/^ */e /']],
	[[/usr/sbin/lsof -a -p "$p" -Fpn 2>/dev/null | /usr/bin/grep -E '^p|\.jsonl$']],
	"exit 0",
}, "\n")

export type Proc = {
	omp: boolean, -- its command's base name is omp
	args: string?,
	tern_pane: number?, -- TERN_PANE
	window_pane: number?, -- TERN_WINDOW_PANE, set instead in a `tern serve` without a daemon
	open: { string }, -- chat files it holds open
}

-- The script's output as processes by pid.
function M.parse(out: string): { [number]: Proc }
	local procs: { [number]: Proc } = {}
	local function get(pid: number): Proc
		local p = procs[pid]
		if p == nil then
			p = { omp = false, args = nil, tern_pane = nil, window_pane = nil, open = {} }
			procs[pid] = p
		end
		return p
	end
	local env_of: number? = nil
	local open_of: number? = nil
	for line in string.gmatch(out, "[^\n]+") do
		local tag = string.sub(line, 1, 2)
		if tag == "a " then
			local pid, args = string.match(line, "^a (%d+)%s+(.*)$")
			if pid ~= nil and args ~= nil then
				local p = get(tonumber(pid) :: number)
				p.args = args
				p.omp = M.base_name(args) == "omp"
			end
		elseif tag == "e " then
			local pid = string.match(line, "^e (%d+)$")
			if pid ~= nil then
				env_of = tonumber(pid)
			elseif env_of ~= nil then
				-- The environment follows the command line, so the last value is the environment's.
				local name, value = string.match(line, "^e (TERN_[%u_]*PANE)=(%d+)$")
				if name == "TERN_PANE" then
					get(env_of).tern_pane = tonumber(value)
				elseif name == "TERN_WINDOW_PANE" then
					get(env_of).window_pane = tonumber(value)
				end
			end
		else
			local pid = string.match(line, "^p(%d+)$")
			if pid ~= nil then
				open_of = tonumber(pid)
			else
				local name = string.match(line, "^n(.+)$")
				if name ~= nil and open_of ~= nil then
					table.insert(get(open_of).open, name)
				end
			end
		end
	end
	return procs
end

-- The chat file a command line resumes or restores: the value after `--resume`, `--restore` or
-- `-r`, as `=value` or a separate argument running to `.jsonl` or the end (paths may hold spaces).
local function file_arg(args: string): string?
	local line = " " .. args
	for _, flag in { "--resume", "--restore", "-r" } do
		local rest = string.match(line, "%s" .. string.gsub(flag, "%-", "%%-") .. "[=%s]%s*(.+)$")
		if rest ~= nil then
			return string.match(rest, "^(.-%.jsonl)%s") or (string.gsub(rest, "%s+$", ""))
		end
	end
	return nil
end

-- A process's chat file (design D1): the one chat file it holds open, else the one its command line
-- names; nil when there is none or more than one.
function M.file_of(p: Proc, exists: (string) -> boolean): string?
	local open: { string } = {}
	for _, f in p.open do
		if Store.is_chat_file(f) and table.find(open, f) == nil then
			table.insert(open, f)
		end
	end
	if #open > 1 then
		return nil
	end
	local f = if #open == 1 then open[1] elseif p.args ~= nil then file_arg(p.args) else nil
	if f ~= nil and Store.is_chat_file(f) and exists(f) then
		return f
	end
	return nil
end

-- Pairs agent panes (`chats`: pane id → folder) with omp processes by the pane id in their
-- environment: a pane exactly one omp process names saves that process's chat file.
function M.pair(procs: { [number]: Proc }, chats: { [number]: string }, exists: (string) -> boolean, now: number): { [string]: Store.AgentSession }
	local by_pane: { [number]: { Proc } } = {}
	for _, p in procs do
		local pane = p.tern_pane or p.window_pane
		if p.omp and pane ~= nil then
			local list = by_pane[pane]
			if list == nil then
				list = {}
				by_pane[pane] = list
			end
			table.insert(list, p)
		end
	end
	local found: { [string]: Store.AgentSession } = {}
	for pane, cwd in chats do
		local list = by_pane[pane]
		if list ~= nil and #list == 1 then
			local f = M.file_of(list[1], exists)
			if f ~= nil then
				found[tostring(pane)] = { agent = "omp", session = f, cwd = cwd, seen = now }
			end
		end
	end
	return found
end

-- This window's panes in sessions on this machine: `ps` and `lsof` see only this Mac.
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

-- The agent panes of this window's sessions on this machine, with their folders.
local function chats(cx: WindowCx): { [number]: string }
	local here = local_panes(cx)
	local out: { [number]: string } = {}
	for _, a in cx.agents:list() do
		if here[a.pane] and type(a.cwd) == "string" and a.cwd ~= "" then
			out[a.pane] = a.cwd
		end
	end
	return out
end

local pending = false
local TIMEOUT_MS = 5000

local function fail(msg: string)
	pending = false
	tern.log.warn("objectives: chat capture " .. msg)
end

local function use(cx: WindowCx?, list: { [number]: string }, live: { [number]: boolean }, out: string, started: number)
	pending = false
	local found = M.pair(M.parse(out), list, tern.fs.exists, os.time())
	local saved = 0
	for _ in found do
		saved += 1
	end
	local state = Store.read()
	-- Linked tabs' snapshots too, so a chat's row is stored as an agent even if its tab closes
	-- before the graph is next drawn (resume-closed-agents, design D4).
	if cx ~= nil then
		local win = Model.read(cx, Surface.find(cx))
		Store.refresh_snapshots(state, win.tabs :: any, win.key)
	end
	Store.save_sessions(state, found, live)
	tern.log.info(string.format("objectives: chat capture %.0f ms, %d saved", tern.now() - started, saved))
end

local function capture(cx: WindowCx)
	local list = chats(cx)
	if next(list) == nil then
		pending = false
		return
	end
	local live: { [number]: boolean } = {}
	for _, p in cx.session:panes() do
		live[p.pane] = true
	end
	local started = tern.now()
	tern.process.run({ "/bin/sh", "-c", SCRIPT }, { timeout_ms = TIMEOUT_MS }, function(res: ProcessResult, cx2: WindowCx?)
		if res.timed_out or res.status ~= 0 then
			fail(string.format("failed: status %d%s %s", res.status, if res.timed_out then " (timed out)" else "", res.stderr))
			return
		end
		local ok, err = pcall(use, cx2, list, live, res.stdout, started)
		if not ok then
			fail("failed: " .. tostring(err))
		end
	end)
end

-- Captures half a second from now (design D2), unless one is already under way: at a turn's start
-- or end, at plugin start and when the graph opens.
function M.request()
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
