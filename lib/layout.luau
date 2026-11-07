--!strict
-- Fixed-geometry layout (design D3). One constants table drives both the generated layout CSS and
-- the vertical centres the edges are drawn to, so the two can't drift apart.

local M = {}

-- Pixel geometry. Every row kind has a fixed height and the margin above it.
M.px = {
	obj_h = 48, -- objective node, border included
	obj_m = 8,
	review_h = 30, -- review mode's button row under an objective node: 8 px gap and 22 px buttons
	group_h = 24, -- "Done (n)", "Closed tabs", "Other windows"
	group_m = 14,
	divider_h = 32, -- "Other tabs" divider after the selected objective's tabs (linked-section D2)
	hint_h = 48, -- empty-state hint
	hint_m = 8,
	session_h = 22, -- session heading
	session_m = 14,
	tab_m = 8, -- margin above a tab node
	tab_border = 1, -- tab node border, top and bottom
	tab_head_h = 38, -- tab header: label and "<session> · tab <n>"
	row_h = 22, -- pane row
	detail_h = 18, -- one line of pane details
	tab_pad = 4, -- room under the last row
	link_h = 26, -- link bar at a tab node's foot, only while an objective is selected (design P6)
	first_m = 4, -- margin above the first item of a column
	gap_w = 120, -- the edge column between the two node columns
}

-- Priority colours P0..P3: red, orange, blue, grey. Mid tones that read on light and dark pages;
-- shared by the badges (CSS below) and the lines drawn inside the edge SVGs.
M.palette = { "#e5484d", "#f76b15", "#3b82f6", "#8b8d98" }

-- A done objective's lines, shown only while it is selected (linked-section D4): green like the done
-- box's tick, and unlike any priority colour.
M.done_color = "#30a46c"

-- The graph's canvas (design G4); every plugin rule is scoped under it.
M.SCOPE = "[data-surface='plugin.tern.canvas'] .ob-root"
local SCOPE = M.SCOPE

-- The layout sheet: heights and margins from M.px.
function M.css(): string
	local p = M.px
	local rules = {
		string.format("%s .ob-obj { height: %dpx; margin-top: %dpx; }", SCOPE, p.obj_h, p.obj_m),
		string.format("%s .ob-obj.ob-review { height: %dpx; }", SCOPE, p.obj_h + p.review_h),
		string.format("%s .ob-group { height: %dpx; line-height: %dpx; margin-top: %dpx; }", SCOPE, p.group_h, p.group_h, p.group_m),
		string.format("%s .ob-divider { height: %dpx; margin-top: %dpx; }", SCOPE, p.divider_h, p.group_m),
		string.format("%s .ob-hint { height: %dpx; margin-top: %dpx; }", SCOPE, p.hint_h, p.hint_m),
		string.format("%s .ob-session { height: %dpx; line-height: %dpx; margin-top: %dpx; }", SCOPE, p.session_h, p.session_h, p.session_m),
		string.format("%s .ob-tab { margin-top: %dpx; border-width: %dpx; padding-bottom: %dpx; }", SCOPE, p.tab_m, p.tab_border, p.tab_pad),
		string.format("%s .ob-thead { height: %dpx; }", SCOPE, p.tab_head_h),
		string.format("%s .ob-row { height: %dpx; line-height: %dpx; }", SCOPE, p.row_h, p.row_h),
		string.format("%s .ob-detail { height: %dpx; line-height: %dpx; }", SCOPE, p.detail_h, p.detail_h),
		string.format("%s .ob-linkbar { height: %dpx; line-height: %dpx; }", SCOPE, p.link_h, p.link_h),
		string.format("%s .ob-col > .ob-first { margin-top: %dpx; }", SCOPE, p.first_m),
		string.format("%s .ob-gap { width: %dpx; }", SCOPE, p.gap_w),
	}
	for i, color in M.palette do
		table.insert(rules, string.format("%s .ob-p%d { color: %s; background: %s1f; }", SCOPE, i - 1, color, color))
	end
	return table.concat(rules, "\n")
end

-- A column being stacked: each `add` returns the item's top and advances past it.
export type Stack = { y: number, count: number }

function M.stack(): Stack
	return { y = 0, count = 0 }
end

-- Margin above an item: the first item of a column takes first_m instead of its own margin.
local function margin(s: Stack, m: number): number
	return if s.count == 0 then M.px.first_m else m
end

local function add(s: Stack, m: number, h: number): number
	local top = s.y + margin(s, m)
	s.y = top + h
	s.count += 1
	return top
end

-- Objective node, taller with review mode's button row; returns its vertical centre.
function M.add_obj(s: Stack, review: boolean?): number
	local h = M.px.obj_h + (if review then M.px.review_h else 0)
	return add(s, M.px.obj_m, h) + h / 2
end

function M.add_group(s: Stack)
	add(s, M.px.group_m, M.px.group_h)
end

function M.add_divider(s: Stack)
	add(s, M.px.group_m, M.px.divider_h)
end

function M.add_hint(s: Stack)
	add(s, M.px.hint_m, M.px.hint_h)
end

function M.add_session(s: Stack)
	add(s, M.px.session_m, M.px.session_h)
end

-- Tab node with `rows` pane rows, `details` detail lines and, while an objective is selected, a link
-- bar; returns its header's vertical centre.
function M.add_tab(s: Stack, rows: number, details: number, bar: boolean): number
	local p = M.px
	local h = 2 * p.tab_border + p.tab_head_h + rows * p.row_h + details * p.detail_h + p.tab_pad
	if bar then
		h += p.link_h
	end
	local top = add(s, p.tab_m, h)
	return top + p.tab_border + p.tab_head_h / 2
end

-- Class for the first item of a column, which takes first_m.
function M.first(s: Stack): string
	return if s.count == 0 then " ob-first" else ""
end

return M
