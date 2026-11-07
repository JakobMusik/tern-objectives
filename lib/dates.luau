--!strict
-- Calendar dates (design D7): `YYYY-MM-DD` in the machine's local calendar, computed at noon so a
-- daylight-saving shift can never move a day.

local M = {}

export type Day = { year: number, month: number, day: number }

local function noon(d: Day): number
	return os.time({ year = d.year, month = d.month, day = d.day, hour = 12 })
end

local function from_time(t: number): Day
	local f = os.date("*t", t) :: any
	return { year = f.year, month = f.month, day = f.day }
end

function M.today(): Day
	return from_time(os.time())
end

-- The local calendar day of a Unix time.
function M.day_of(t: number): Day
	return from_time(t)
end

function M.key(d: Day): string
	return string.format("%04d-%02d-%02d", d.year, d.month, d.day)
end

-- An objective's creation time as shown after its title, `MM-DD HH:MM` in local time; nil without a
-- time (creation-time-suffix D1).
function M.short(t: number?): string?
	if type(t) ~= "number" then
		return nil
	end
	return os.date("%m-%d %H:%M", t) :: string
end

-- The day `s` names, or nil when it isn't `YYYY-MM-DD` or not a real date (2026-02-30).
function M.parse(s: string): Day?
	local y, m, d = string.match(s, "^%s*(%d%d%d%d)-(%d%d)-(%d%d)%s*$")
	if y == nil then
		return nil
	end
	local want: Day = { year = tonumber(y) :: number, month = tonumber(m) :: number, day = tonumber(d) :: number }
	if want.month < 1 or want.month > 12 or want.day < 1 or want.day > 31 then
		return nil
	end
	local got = from_time(noon(want))
	if got.year ~= want.year or got.month ~= want.month or got.day ~= want.day then
		return nil
	end
	return want
end

function M.add(d: Day, days: number): Day
	return from_time(os.time({ year = d.year, month = d.month, day = d.day + days, hour = 12 }))
end

-- Whole days from `a` to `b` (negative when `b` is earlier).
function M.diff(a: Day, b: Day): number
	return math.floor((noon(b) - noon(a)) / 86400 + 0.5)
end

-- Days until the next `wday` (os.date: Sunday 1 … Saturday 7) strictly after `d`.
local function until_weekday(d: Day, wday: number): number
	local f = os.date("*t", noon(d)) :: any
	local n = (wday - f.wday) % 7
	return if n == 0 then 7 else n
end

-- The due-date presets: label and the date it sets.
function M.presets(today: Day): { { label: string, day: Day } }
	return {
		{ label = "Today", day = today },
		{ label = "Tomorrow", day = M.add(today, 1) },
		{ label = "Friday", day = M.add(today, until_weekday(today, 6)) },
		{ label = "Next Monday", day = M.add(today, until_weekday(today, 2)) },
		{ label = "In 1 week", day = M.add(today, 7) },
	}
end

-- The due chip for `due` seen on `today`: its text and tone ("bad", "warn" or "muted").
function M.chip(due: string, today: Day): (string, string)
	local d = M.parse(due)
	if d == nil then
		return "due " .. due, "muted"
	end
	local n = M.diff(today, d)
	if n < 0 then
		return string.format("overdue %dd", -n), "bad"
	elseif n == 0 then
		return "due today", "warn"
	elseif n == 1 then
		return "due tomorrow", "warn"
	end
	return string.format("due in %dd", n), "muted"
end

return M
