--!strict
-- Text helpers: one-line normalisation and cutting by characters (UTF-8 aware).

local M = {}

-- Collapses every run of whitespace, line breaks included, to one space and trims the ends.
function M.one_line(s: string): string
	local collapsed = string.gsub(s, "%s+", " ")
	return (string.match(collapsed, "^ ?(.-) ?$") or "")
end

-- The first `n` characters of `s` (bytes when `s` is not valid UTF-8), and whether it was cut.
function M.cut(s: string, n: number): (string, boolean)
	local len = utf8.len(s)
	if len == nil then
		if #s <= n then
			return s, false
		end
		return string.sub(s, 1, n), true
	end
	if len <= n then
		return s, false
	end
	local stop = utf8.offset(s, n + 1) :: number
	return string.sub(s, 1, stop - 1), true
end

-- One line of at most `n` characters, ending in "…" when it was cut.
function M.clip(s: string, n: number): string
	local text, cut = M.cut(M.one_line(s), n)
	return if cut then text .. "…" else text
end

-- One line keeping both ends: at most `n` characters, a longer text keeping its first 60 % and its
-- last characters around "…", so a middle cut drawn from it still shows the real end.
function M.squeeze(s: string, n: number): string
	local line = M.one_line(s)
	local len = utf8.len(line)
	if len == nil then
		return M.clip(line, n)
	end
	if len <= n then
		return line
	end
	local head = math.floor(n * 0.6)
	local tail = n - head - 1
	local head_end = utf8.offset(line, head + 1) :: number
	local tail_start = utf8.offset(line, len - tail + 1) :: number
	return string.sub(line, 1, head_end - 1) .. "…" .. string.sub(line, tail_start)
end

-- `s` split before its last `n` characters, the split moved forward to the next word start when one
-- is within the tail's first third; the tail is "" when `s` has `n` characters or fewer.
function M.split_end(s: string, n: number): (string, string)
	local len = utf8.len(s)
	if len == nil or len <= n then
		return s, ""
	end
	local start = utf8.offset(s, len - n + 1) :: number
	local space = string.find(s, " ", start, true)
	if space ~= nil and (utf8.len(s, start, space) :: number) <= n // 3 then
		start = space + 1
	end
	return string.sub(s, 1, start - 1), string.sub(s, start)
end

local function length(s: string): number
	return utf8.len(s) or #s
end

-- `s` broken at spaces into lines of at most `width` characters, onto at most `max` lines
-- (attention-marks-and-titles D1). Only a word longer than a line is split; a text that needs more
-- lines ends its last line in "…".
function M.wrap(s: string, width: number, max: number): { string }
	local words: { string } = {}
	for word in string.gmatch(M.one_line(s), "%S+") do
		while length(word) > width do
			local head = M.cut(word, width)
			table.insert(words, head)
			word = string.sub(word, #head + 1)
		end
		table.insert(words, word)
	end
	local lines: { string } = {}
	local line, n = "", 0
	for _, word in words do
		local w = length(word)
		if n == 0 then
			line, n = word, w
		elseif n + 1 + w <= width then
			line, n = line .. " " .. word, n + 1 + w
		else
			table.insert(lines, line)
			line, n = word, w
		end
	end
	if n > 0 then
		table.insert(lines, line)
	end
	if #lines > max then
		local last = M.cut(lines[max], width - 1)
		lines = table.move(lines, 1, max - 1, 1, {})
		table.insert(lines, last .. "…")
	end
	return lines
end

return M
