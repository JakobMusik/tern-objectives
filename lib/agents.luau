--!strict
-- Saved chats (resume-omp-chats, design D1, D2; resume-more-agents, design D1, D2). Every chat's
-- process carries its pane's id in its environment. omp holds its chat file open once the chat has
-- had a message, and a chat started from a file names it on its command line; Codex's chat server
-- and Antigravity hold theirs open; Claude keeps a record of each process's session. One process
-- run reads them all, and each chat's file is saved under its pane, so a closed tab can resume it.
-- A pane that more than one chat process names, or a process with more than one chat file open,
-- saves nothing: an unsure match could resume the wrong chat.

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

-- The chat processes' command lines (`a`); from their environments, the pane ids and where Claude
-- keeps its records (`e`); and the chat files and Antigravity conversation folders they hold open
-- (lsof's `p` and `n`), as tagged lines (design D1, D2). It ends with status 0 whatever the
-- pipelines found.
local SCRIPT = table.concat({
	[[p=$(/usr/bin/pgrep -d, -f '(^|/)(omp|claude|codex|agy)( |$)') || exit 0]],
	[[/bin/ps -ww -o pid=,args= -p "$p" | /usr/bin/sed 's/^ */a /']],
	[[/bin/ps -wwE -o pid=,command= -p "$p" | /usr/bin/grep -oE '^ *[0-9]+|TERN_(WINDOW_)?PANE=[0-9]+|(^| )(HOME|CLAUDE_CONFIG_DIR)=[^ ]+' | /usr/bin/sed 's/^ */e /']],
	[[/usr/sbin/lsof -a -p "$p" -Fpn 2>/dev/null | /usr/bin/grep -E '^p|\.jsonl$|/conversations/[0-9a-f-]{36}\.db$|/brain/[0-9a-f-]{36}$']],
	"exit 0",
}, "\n")

local AGENTS: { [string]: boolean } = { omp = true, claude = true, codex = true, agy = true }

export type Proc = {
	agent: string?, -- its command's base name, when that is omp, claude, codex or agy
	args: string?,
	tern_pane: number?, -- TERN_PANE
	window_pane: number?, -- TERN_WINDOW_PANE, set instead in a `tern serve` without a daemon
	home: string?, -- HOME
	claude_dir: string?, -- CLAUDE_CONFIG_DIR
	open: { string }, -- chat files and conversation folders it holds open
}

-- The script's output as processes by pid.
function M.parse(out: string): { [number]: Proc }
	local procs: { [number]: Proc } = {}
	local function get(pid: number): Proc
		local p = procs[pid]
		if p == nil then
			p = { agent = nil, args = nil, tern_pane = nil, window_pane = nil, home = nil, claude_dir = nil, open = {} }
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
				local base = M.base_name(args)
				p.agent = if base ~= nil and AGENTS[base] then base else nil
			end
		elseif tag == "e " then
			local pid = string.match(line, "^e (%d+)$")
			if pid ~= nil then
				env_of = tonumber(pid)
			elseif env_of ~= nil then
				-- The environment follows the command line, so the last value is the environment's.
				local p = get(env_of)
				local name, value = string.match(line, "^e (TERN_[%u_]*PANE)=(%d+)$")
				local home = string.match(line, "^e HOME=(.+)$")
				local dir = string.match(line, "^e CLAUDE_CONFIG_DIR=(.+)$")
				if name == "TERN_PANE" then
					p.tern_pane = tonumber(value)
				elseif name == "TERN_WINDOW_PANE" then
					p.window_pane = tonumber(value)
				elseif home ~= nil then
					p.home = home
				elseif dir ~= nil then
					p.claude_dir = dir
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

-- How the capture reads files: whether one exists, and a small regular file's text (nil if not).
export type Io = {
	exists: (string) -> boolean,
	read: (string) -> string?,
}

-- The distinct names among `files` that `ok` accepts.
local function distinct(files: { string }, ok: (string) -> boolean): { string }
	local out: { string } = {}
	for _, f in files do
		if ok(f) and table.find(out, f) == nil then
			table.insert(out, f)
		end
	end
	return out
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

local function omp_ok(f: string): boolean
	return Store.chat_file_ok("omp", f)
end

-- An omp chat's file (resume-omp-chats, design D1): the one chat file it holds open, else the one
-- its command line names; nil when there is none or more than one.
local function omp_file(p: Proc, io: Io): string?
	local open = distinct(p.open, omp_ok)
	if #open > 1 then
		return nil
	end
	local f = if #open == 1 then open[1] elseif p.args ~= nil then file_arg(p.args) else nil
	if f ~= nil and omp_ok(f) and io.exists(f) then
		return f
	end
	return nil
end

-- Claude names a project's folder after the project's path, every character but A-Z, a-z and 0-9
-- turned into "-" (design S6), one per UTF-16 unit.
local function claude_folder(cwd: string): string
	return (string.gsub(cwd, utf8.charpattern, function(c: string): string
		if string.match(c, "^%w$") then
			return c
		end
		return if #c == 4 then "--" else "-"
	end))
end

-- A Claude chat's transcript and folder (design D2; S5, S6): Claude's record of the process names its
-- current session and folder, and the transcript sits in that folder's project once it exists. The
-- records live in CLAUDE_CONFIG_DIR, else ~/.claude, as the process's own environment says.
local function claude_file(pid: number, p: Proc, io: Io): (string?, string?)
	local dir = p.claude_dir or (if p.home ~= nil then p.home .. "/.claude" else nil)
	local raw = if dir ~= nil then io.read(dir .. "/sessions/" .. tostring(pid) .. ".json") else nil
	if dir == nil or raw == nil then
		return nil, nil
	end
	local ok, rec = pcall(tern.json.decode, raw)
	if not ok or type(rec) ~= "table" or rec.kind ~= "interactive" or type(rec.sessionId) ~= "string" or type(rec.cwd) ~= "string" then
		return nil, nil
	end
	local f = dir .. "/projects/" .. claude_folder(rec.cwd) .. "/" .. rec.sessionId .. ".jsonl"
	if Store.chat_file_ok("claude", f) and io.exists(f) then
		return f, rec.cwd
	end
	return nil, nil
end

-- A Codex chat server's rollout file (design D1, S9): the one it holds open.
local function codex_file(p: Proc, io: Io): string?
	local open = distinct(p.open, function(f: string): boolean
		return Store.chat_file_ok("codex", f)
	end)
	if #open == 1 and io.exists(open[1]) then
		return open[1]
	end
	return nil
end

-- An Antigravity chat's conversation file (design D1; S12, S14): the one it holds open; with none
-- open, the one of the one conversation folder it holds open, which a long-idle chat keeps alone.
local function agy_file(p: Proc, io: Io): string?
	local dbs = distinct(p.open, function(f: string): boolean
		return Store.chat_file_ok("agy", f)
	end)
	local f: string? = nil
	if #dbs == 1 then
		f = dbs[1]
	elseif #dbs == 0 then
		local brains = distinct(p.open, function(name: string): boolean
			return string.match(name, "/brain/" .. Store.UUID .. "$") ~= nil
		end)
		if #brains == 1 then
			local root, id = string.match(brains[1], "^(.*)/brain/(" .. Store.UUID .. ")$")
			f = if root ~= nil and id ~= nil then root .. "/conversations/" .. id .. ".db" else nil
		end
	end
	if f ~= nil and Store.chat_file_ok("agy", f) and io.exists(f) then
		return f
	end
	return nil
end

-- A Codex server that runs one of Tern's chats alone (design D1, S9): `codex app-server` and nothing
-- more. The shared server Codex's own interface talks to takes more arguments, and holds every
-- thread (S11).
local function codex_server(p: Proc): boolean
	return p.args ~= nil and string.match(p.args, "^%S+%s+app%-server%s*$") ~= nil
end

-- A pane this window may save a chat for (design D2), with its folder: an agent block, or a shell
-- running a command, where an agent's own interface runs (`block` false).
export type Candidate = { cwd: string, block: boolean }

-- Whether `p` can be the chat of pane `c`: omp, and Codex's chat server, only in an agent block;
-- Claude and Antigravity there or in a running shell.
local function chat_of(p: Proc, c: Candidate): boolean
	if p.agent == "omp" then
		return c.block
	elseif p.agent == "codex" then
		return c.block and codex_server(p)
	end
	return p.agent == "claude" or p.agent == "agy"
end

-- Pairs candidate panes with chat processes by the pane id in their environment: a pane exactly one
-- chat process names saves that chat's file. Also says whether a Claude or Antigravity chat runs in
-- its own interface in one of the shells, which the 30-second save watches (design D4).
function M.pair(procs: { [number]: Proc }, panes: { [number]: Candidate }, io: Io, now: number): ({ [string]: Store.AgentSession }, boolean)
	local by_pane: { [number]: { number } } = {}
	local own = false
	for pid, p in procs do
		local pane = p.tern_pane or p.window_pane
		local c = if pane ~= nil then panes[pane] else nil
		if pane ~= nil and c ~= nil and chat_of(p, c) then
			local list = by_pane[pane]
			if list == nil then
				list = {}
				by_pane[pane] = list
			end
			table.insert(list, pid)
			own = own or not c.block
		end
	end
	local found: { [string]: Store.AgentSession } = {}
	for pane, pids in by_pane do
		if #pids == 1 then
			local pid = pids[1]
			local p = procs[pid]
			local cwd: string? = panes[pane].cwd
			local file: string? = nil
			if p.agent == "omp" then
				file = omp_file(p, io)
			elseif p.agent == "claude" then
				file, cwd = claude_file(pid, p, io)
			elseif p.agent == "codex" then
				file = codex_file(p, io)
			else
				file = agy_file(p, io)
			end
			if file ~= nil and cwd ~= nil and p.agent ~= nil then
				found[tostring(pane)] = { agent = p.agent, session = file, cwd = cwd, seen = now }
			end
		end
	end
	return found, own
end

-- Whether a shell command line runs Claude or Antigravity, maybe in its own interface (design D4):
-- one of its words, split at blanks and `;&|()`, has the base name claude or agy.
function M.starts_agent(line: any): boolean
	if type(line) ~= "string" then
		return false
	end
	for word in string.gmatch(line, "[^%s;&|()]+") do
		local base = string.match(word, "([^/]+)$")
		if base == "claude" or base == "agy" then
			return true
		end
	end
	return false
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

-- The panes of this window's sessions on this machine that may hold a chat (design D2): agent
-- blocks, and shells running a command.
local function candidates(cx: WindowCx): { [number]: Candidate }
	local here = local_panes(cx)
	local out: { [number]: Candidate } = {}
	for _, a in cx.agents:list() do
		if here[a.pane] and type(a.cwd) == "string" and a.cwd ~= "" then
			out[a.pane] = { cwd = a.cwd, block = true }
		end
	end
	for _, p in cx.session:panes() do
		if here[p.pane] and out[p.pane] == nil and p.kind == "terminal" and p.running ~= nil and type(p.cwd) == "string" and p.cwd ~= "" then
			out[p.pane] = { cwd = p.cwd, block = false }
		end
	end
	return out
end

-- A capture is waiting or under way; `again`: a request came meanwhile, so one more follows it.
local pending = false
local again = false
local TIMEOUT_MS = 5000

local function warn(msg: string)
	tern.log.warn("objectives: chat capture " .. msg)
end

-- Linked tabs' snapshots too, so a chat's row is stored as an agent even if its tab closes
-- before the graph is next drawn (resume-closed-agents, design D4).
local function refresh(cx: WindowCx?, state: Store.State)
	if cx ~= nil then
		local win = Model.read(cx, Surface.find(cx))
		Store.refresh_snapshots(state, win.tabs :: any, win.key)
	end
end

local IO: Io = {
	exists = tern.fs.exists,
	read = function(path: string): string?
		local ok, text = pcall(tern.fs.read, path, 65536)
		return if ok then text else nil
	end,
}

-- While a Claude or Antigravity chat runs in its own interface, which sends no turn events, one more
-- capture 30 s later (design D4); at most one waits, and none is armed once no such chat runs.
local watching = false
local WATCH_MS = 30000
local function watch()
	if watching then
		return
	end
	watching = true
	tern.timer(WATCH_MS, function(cx: WindowCx?)
		watching = false
		if cx ~= nil then
			M.request()
		end
	end)
end

local function use(cx: WindowCx?, list: { [number]: Candidate }, live: { [number]: boolean }, out: string, started: number)
	local found, own = M.pair(M.parse(out), list, IO, os.time())
	local saved = 0
	for _ in found do
		saved += 1
	end
	local state = Store.read()
	-- Saved first, then the snapshots: a shell running a saved chat in its own interface is then
	-- stored as an agent row (resume-more-agents, design D5), even if its tab closes before the graph
	-- next draws.
	Store.save_sessions(state, found, live)
	refresh(cx, state)
	if own then
		watch()
	end
	tern.log.info(string.format("objectives: chat capture %.0f ms, %d saved%s", tern.now() - started, saved, if own then ", watching" else ""))
end

-- One capture now. `done(ok, cx)` runs once the chats are saved and the snapshots refreshed, or
-- once that has failed; with no pane that may hold a chat, right after refreshing the snapshots.
local function capture(cx: WindowCx, done: (ok: boolean, cx: WindowCx?) -> ())
	local list = candidates(cx)
	if next(list) == nil then
		local ok, err = pcall(refresh, cx, Store.read())
		if not ok then
			warn("failed: " .. tostring(err))
		end
		done(ok, cx)
		return
	end
	local live: { [number]: boolean } = {}
	for _, p in cx.session:panes() do
		live[p.pane] = true
	end
	local started = tern.now()
	tern.process.run({ "/bin/sh", "-c", SCRIPT }, { timeout_ms = TIMEOUT_MS }, function(res: ProcessResult, cx2: WindowCx?)
		if res.timed_out or res.status ~= 0 then
			warn(string.format("failed: status %d%s %s", res.status, if res.timed_out then " (timed out)" else "", res.stderr))
			done(false, cx2)
			return
		end
		local ok, err = pcall(use, cx2, list, live, res.stdout, started)
		if not ok then
			warn("failed: " .. tostring(err))
		end
		done(ok, cx2)
	end)
end

-- Captures half a second from now (design D2): at a turn's start or end, at plugin start, when the
-- graph opens, when a shell starts Claude or Antigravity, and while one runs in its own interface.
-- At most one is under way. A request meanwhile isn't lost: one more capture follows that one, so a
-- turn's end still saves the chat file omp creates as the turn ends (resume-more-agents, design D4).
function M.request()
	if pending then
		again = true
		return
	end
	pending = true
	local function finish()
		pending = false
		if again then
			again = false
			M.request()
		end
	end
	tern.timer(500, function(cx: WindowCx?)
		if cx == nil then
			pending = false
			again = false
			return
		end
		local ok, err = pcall(capture, cx, finish)
		if not ok then
			warn("failed: " .. tostring(err))
			finish()
		end
	end)
end

-- Captures at once, whether or not one is under way, and calls `done(ok, cx)` once, when it has
-- saved (close-linked-tabs, design D4): closing a tab right after can't lose its chat.
function M.save_now(cx: WindowCx, done: (ok: boolean, cx: WindowCx?) -> ())
	local called = false
	local function once(ok: boolean, cx2: WindowCx?)
		if not called then
			called = true
			done(ok, cx2)
		end
	end
	local ok, err = pcall(capture, cx, once)
	if not ok then
		warn("failed: " .. tostring(err))
		once(false, cx)
	end
end

return M
