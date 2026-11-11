--!strict
-- The plugin's shortcuts, kept in Tern's own keybinds (custom-order-and-direct-controls, design D7):
-- the commands and their default chords, chord parsing and display, the keys in effect, and the
-- edits Configure makes to the user's keybinds map. Pure but for `tern.json.array`.

local M = {}

export type Command = { id: string, label: string, default: string? }

-- Every palette command, in the settings page's order; `window.luau` takes the default chords from here.
local COMMANDS: { Command } = {
	{ id = "open", label = "Open graph", default = "ctrl+cmd+o" },
	{ id = "rename", label = "Rename selected objective", default = "alt+shift+r" },
	{ id = "new", label = "New objective", default = "alt+n" },
	{ id = "search", label = "Search", default = "ctrl+alt+f" },
	{ id = "link_tab", label = "Link this tab", default = nil },
	{ id = "new_for_tab", label = "New objective for this tab", default = nil },
	{ id = "configure", label = "Configure", default = nil },
}
M.COMMANDS = COMMANDS

function M.command(id: string): Command?
	for _, c in M.COMMANDS do
		if c.id == id then
			return c
		end
	end
	return nil
end

function M.action(id: string): string
	return "plugin.objectives." .. id
end

-- A command's default chords as `tern.command` takes them.
function M.default_keys(id: string): { string }?
	local c = M.command(id)
	return if c ~= nil and c.default ~= nil then { c.default :: string } else nil
end

local MODS: { [string]: string } = {
	ctrl = "ctrl",
	control = "ctrl",
	alt = "alt",
	opt = "alt",
	option = "alt",
	shift = "shift",
	cmd = "cmd",
	command = "cmd",
	super = "cmd",
}
-- Apple's order, ⌃⌥⇧⌘; the spelling Configure writes, and what every chord is compared in.
local ORDER = { "ctrl", "alt", "shift", "cmd" }
local SYMBOL: { [string]: string } = { ctrl = "⌃", alt = "⌥", shift = "⇧", cmd = "⌘" }

-- One chord in the fixed order, or nil when it names no key or an unknown modifier.
local function canon_chord(chord: string): string?
	local parts = string.split(chord, "+")
	local key = parts[#parts]
	if key == nil or key == "" then
		return nil
	end
	local held: { [string]: boolean } = {}
	for i = 1, #parts - 1 do
		local m = MODS[parts[i]]
		if m == nil then
			return nil
		end
		held[m] = true
	end
	local out: { string } = {}
	for _, m in ORDER do
		if held[m] then
			table.insert(out, m)
		end
	end
	table.insert(out, key)
	return table.concat(out, "+")
end

-- `text` as Configure writes it: lowercase, modifiers in the fixed order, chords of a sequence joined by
-- ">"; nil when it doesn't parse. Tern still has the last word: a write it refuses raises.
function M.canon(text: string): string?
	local t = string.lower((string.gsub(text, "%s", "")))
	if t == "" then
		return nil
	end
	local out: { string } = {}
	for _, chord in string.split(t, ">") do
		local c = canon_chord(chord)
		if c == nil then
			return nil
		end
		table.insert(out, c)
	end
	return table.concat(out, ">")
end

-- Whether a canonical shortcut starts with ⌃, ⌥ or ⌘, or is a function key: anything else would take
-- typing away from every pane.
function M.has_modifier(canon: string): boolean
	local first = string.split(canon, ">")[1]
	local parts = string.split(first, "+")
	local key = parts[#parts]
	if #parts == 1 then
		return string.match(key, "^f%d%d?$") ~= nil
	end
	for i = 1, #parts - 1 do
		local m = parts[i]
		if m == "ctrl" or m == "alt" or m == "cmd" then
			return true
		end
	end
	return string.match(key, "^f%d%d?$") ~= nil
end

local KEY_NAMES: { [string]: string } = {
	escape = "Esc",
	enter = "↩",
	["return"] = "↩",
	space = "Space",
	tab = "⇥",
	backspace = "⌫",
	delete = "⌦",
	up = "↑",
	down = "↓",
	left = "←",
	right = "→",
	plus = "+",
	minus = "-",
	comma = ",",
	period = ".",
	slash = "/",
	backslash = "\\",
	bracket_left = "[",
	bracket_right = "]",
}

local function key_symbol(key: string): string
	local named = KEY_NAMES[key]
	if named ~= nil then
		return named
	end
	local physical = string.match(key, "^key_(%a)$") or string.match(key, "^digit_(%d)$")
	if physical ~= nil then
		return string.upper(physical)
	end
	return string.upper(key)
end

-- "ctrl+cmd+o" as ⌃⌘O; a sequence's chords joined by a space.
function M.display(chord: string): string
	local canon = M.canon(chord) or chord
	local out: { string } = {}
	for _, c in string.split(canon, ">") do
		local parts = string.split(c, "+")
		local s = ""
		for i = 1, #parts - 1 do
			s ..= SYMBOL[parts[i]] or parts[i]
		end
		table.insert(out, s .. key_symbol(parts[#parts]))
	end
	return table.concat(out, " ")
end

-- The chords in effect for each of the plugin's commands, from `cx.actions:keys()`, each as Tern spells it.
function M.effective(keys: { [string]: { string } }): { [string]: { string } }
	local out: { [string]: { string } } = {}
	for chord, actions in keys do
		for _, a in actions do
			local id = string.match(a, "^plugin%.objectives%.(.+)$")
			if id ~= nil then
				out[id] = out[id] or {}
				table.insert(out[id], chord)
			end
		end
	end
	for _, list in out do
		table.sort(list)
	end
	return out
end

-- The keys each command runs on, worked out from the user's keybinds map the way Tern layers it: the
-- user's entries naming the command, plus its default chord unless a user entry claims that chord. It
-- holds at once after a write, while `cx.actions:keys()` lacks every plugin's keys until the keymap
-- rebuilds (task 5.2).
function M.in_effect(kb: { [string]: any }): { [string]: { string } }
	local claimed: { [string]: boolean } = {}
	local out: { [string]: { string } } = {}
	for chord, v in kb do
		local canon = M.canon(chord)
		if canon ~= nil then
			claimed[canon] = true
		end
		local actions: { any } = if type(v) == "table" then v else { v }
		for _, a in actions do
			local id = if type(a) == "string" then string.match(a, "^plugin%.objectives%.(.+)$") else nil
			if id ~= nil then
				out[id] = out[id] or {}
				table.insert(out[id], chord)
			end
		end
	end
	for _, c in COMMANDS do
		if c.default ~= nil and not claimed[M.canon(c.default :: string) :: string] then
			out[c.id] = out[c.id] or {}
			table.insert(out[c.id], c.default :: string)
		end
	end
	for _, list in out do
		table.sort(list)
	end
	return out
end

-- The first action other than `action` that runs on `canon`'s keys, comparing every chord canonically.
function M.in_use(keys: { [string]: { string } }, canon: string, action: string): string?
	for chord, actions in keys do
		if M.canon(chord) == canon then
			for _, a in actions do
				if a ~= action then
					return a
				end
			end
		end
	end
	return nil
end

local function copy_entry(v: any): any
	if type(v) == "table" then
		local list = {}
		for _, a in v do
			table.insert(list, a)
		end
		return tern.json.array(list)
	end
	return v
end

-- The user's keybinds map after `op` ("change", "remove" or "reset") on command `id` (design D7). First
-- the action leaves every entry: a string naming it goes, a list loses it and goes once empty; other
-- entries, the user's own [] among them, stay. Then:
-- - change: `new` runs it, and its default chord, when it differs, gets [] so it stops running it;
-- - remove: its default chord gets [];
-- - reset: an [] on its default chord goes, which gives the plugin's default back.
function M.edited(kb: { [string]: any }, id: string, op: string, new: string?): { [string]: any }
	local action = M.action(id)
	local c = M.command(id)
	local default = if c ~= nil then c.default else nil
	local out: { [string]: any } = {}
	for chord, v in kb do
		if v == action then
			continue
		end
		if type(v) == "table" and table.find(v, action) ~= nil then
			local rest = {}
			for _, a in v do
				if a ~= action then
					table.insert(rest, a)
				end
			end
			if #rest > 0 then
				out[chord] = tern.json.array(rest)
			end
			continue
		end
		out[chord] = copy_entry(v)
	end
	local function unbound(v: any): boolean
		return type(v) == "table" and #v == 0
	end
	if op == "change" and new ~= nil then
		out[new] = action
		if default ~= nil and M.canon(default) ~= new then
			out[default] = tern.json.array({})
		end
	elseif op == "remove" then
		if default ~= nil then
			out[default] = tern.json.array({})
		end
	elseif op == "reset" then
		if default ~= nil and unbound(out[default]) then
			out[default] = nil
		end
	end
	return out
end

return M
