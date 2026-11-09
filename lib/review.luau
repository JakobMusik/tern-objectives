--!strict
-- The review schedule of done objectives (review-done-objectives, design D3): obsidian-spaced-
-- repetition's SM-2-OSR with its default settings (base ease 250, Hard halves the interval, Easy's
-- bonus 1.3, ease never below 130), without its load balancing. No Tern calls, so the arithmetic
-- can be checked with plain inputs.

local Dates = require("./dates")

local M = {}

export type Schedule = {
	due: string, -- the next review, YYYY-MM-DD
	interval: number, -- days, one decimal
	ease: number, -- percent
	reps: number, -- reviews so far
}

export type Grade = "hard" | "good" | "easy"

M.BASE_EASE = 250
local MIN_EASE = 130
local EASE_STEP = 20
local HARD_FACTOR = 0.5 -- obsidian's lapsesIntervalChange
local EASY_BONUS = 1.3

-- The schedule of an objective marked done on `day`: its first review is the next day.
function M.start(day: Dates.Day): Schedule
	return { due = Dates.key(Dates.add(day, 1)), interval = 1, ease = M.BASE_EASE, reps = 0 }
end

-- The schedule kept by a reopened objective, marked done again on `day` (reopen-done-objectives,
-- design D3): interval, ease and count carry on, and the next review is its stored date, or the next
-- day when that date is `day` or earlier, or unreadable.
function M.resume(s: Schedule, day: Dates.Day): Schedule
	local tomorrow = Dates.add(day, 1)
	local d = if type(s.due) == "string" then Dates.parse(s.due) else nil
	local due = if d ~= nil and Dates.diff(tomorrow, d) > 0 then d else tomorrow
	return { due = Dates.key(due), interval = s.interval, ease = s.ease, reps = s.reps }
end

-- Whether the review is due on `today`: its date is today or earlier (an unreadable date counts).
function M.is_due(s: Schedule, today: Dates.Day): boolean
	local d = Dates.parse(s.due)
	return d == nil or Dates.diff(today, d) <= 0
end

-- Whole days the review is overdue on `today`, never negative.
local function late(s: Schedule, today: Dates.Day): number
	local d = Dates.parse(s.due)
	return if d == nil then 0 else math.max(0, Dates.diff(d, today))
end

-- Interval and ease after `grade`, `days_late` whole days after the review was due (osrSchedule).
local function step(s: Schedule, grade: Grade, days_late: number): (number, number)
	local interval = math.max(1, s.interval)
	local ease = s.ease
	if grade == "easy" then
		ease += EASE_STEP
		interval = (interval + days_late) * ease / 100 * EASY_BONUS
	elseif grade == "good" then
		interval = (interval + days_late / 2) * ease / 100
	else
		ease = math.max(MIN_EASE, ease - EASE_STEP)
		interval = math.max(1, (interval + days_late / 4) * HARD_FACTOR)
	end
	return math.round(interval * 10) / 10, ease
end

-- Whole days to the next review: the interval rounded, as moment rounds fractional days.
local function whole(interval: number): number
	return math.max(1, math.round(interval))
end

function M.rate(s: Schedule, grade: Grade, today: Dates.Day): Schedule
	local interval, ease = step(s, grade, late(s, today))
	return { due = Dates.key(Dates.add(today, whole(interval))), interval = interval, ease = ease, reps = s.reps + 1 }
end

-- The whole days each grade would give, for the buttons' labels.
function M.preview(s: Schedule, today: Dates.Day): { hard: number, good: number, easy: number }
	local d = late(s, today)
	local function days(grade: Grade): number
		local interval = step(s, grade, d)
		return whole(interval)
	end
	return { hard = days("hard"), good = days("good"), easy = days("easy") }
end

return M
