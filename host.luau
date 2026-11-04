--!strict
-- Objectives: host half. Defines the graph block (design P1–P4). It shows the view the window half
-- hands over through two files in the data folder, passes every click back to the window half as
-- an objectives:// link, and closes on Esc. Everything else lives in the window half.

local POLL_MS = 25

type State = { stem: string, n: string, tree: any }

-- The shown graph of each window, by view-file stem; a new graph replaces its window's old one.
local live: { [string]: { cx: BlockCx, s: State } } = {}

local function pct(s: string): string
	return (string.gsub(s, "[^%w%-%._~]", function(c)
		return string.format("%%%02X", string.byte(c))
	end))
end

-- Reads the window half's latest view into `s`; true when it changed. A missing or half-written
-- file leaves `s` as it was, so the next poll tries again.
local function load(s: State): boolean
	local b = tern.plugin.data .. "/view-" .. s.stem
	local ok, n = pcall(tern.fs.read, b .. ".seq", 64)
	if not ok or n == s.n then
		return false
	end
	local ok2, doc = pcall(function()
		return tern.json.decode(tern.fs.read(b .. ".json"))
	end)
	if not ok2 or type(doc) ~= "table" or doc.n ~= n then
		return false
	end
	s.n = n
	s.tree = doc.tree
	return true
end

local function poll()
	for stem, b in live do
		if load(b.s) and not pcall(function()
			b.cx:render()
		end) then
			live[stem] = nil
		end
	end
	tern.timer(POLL_MS, poll)
end
tern.timer(POLL_MS, poll)

tern.block.define("graph", {
	init = function(cx: BlockCx, args: { string }?, saved: any): State
		local stem = if type(saved) == "table" and type(saved.stem) == "string"
			then saved.stem
			elseif args ~= nil and args[1] ~= nil then args[1]
			else ""
		local s: State = { stem = stem, n = "", tree = nil }
		load(s)
		live[stem] = { cx = cx, s = s }
		return s
	end,
	-- People's text in the UI face, like the rest of Tern's panels.
	font = "sans",
	-- A region's root draws only its children, so the graph's root goes inside a column.
	view = function(s: State, _cx: BlockCx)
		local ui = tern.ui
		return { main = ui.col({ s.tree or ui.text("Loading objectives…") }) }
	end,
	event = function(_s: State, ev: UiEvent, cx: BlockCx)
		if type(ev.act) == "string" then
			cx:open("objectives://act/" .. pct(ev.act) .. "/" .. pct(tostring(ev.value or "")))
		end
	end,
	key = function(s: State, key: any, cx: BlockCx): boolean
		if key.name == "escape" then
			live[s.stem] = nil
			cx:exit(0)
		end
		return false
	end,
	save = function(s: State)
		return { stem = s.stem }
	end,
})
