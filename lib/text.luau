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

return M
