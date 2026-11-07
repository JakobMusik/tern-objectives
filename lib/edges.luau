--!strict
-- Link lines (design D4): SVG `background-image` layers in the fixed-width gap column, drawn 1:1 in
-- graph pixels (x 0..gap width, y 0..graph height). Tern's renderer ignores `url()` masks, so the
-- colours are literal, from the palette in lib/layout.luau.

local Layout = require("./layout")

local M = {}

export type Edge = {
	from: number, -- objective centre y
	to: number, -- tab header centre y
	priority: number, -- 0..3
	done: boolean, -- a done objective's line, drawn in Layout.done_color (linked-section D4)
	dashed: boolean, -- closed or elsewhere tab
	selected: boolean, -- belongs to the selected objective
}

local SCOPE = Layout.SCOPE

local function pctenc(s: string): string
	return (string.gsub(s, '[%%#<>"]', function(c)
		return string.format("%%%02X", string.byte(c))
	end))
end

-- Every line leaves and enters its nodes level, through a 4 px straight stub at each end with the
-- curve between them. A steep curve would otherwise meet the node edge at a slant (task 5.1), and a
-- dashed line could end inside a gap of its pattern, short of the node.
local STUB = 4

local function path(e: Edge, w: number, stroke: number): string
	local a, b, mid = STUB, w - STUB, w / 2
	local color = if e.done then Layout.done_color else Layout.palette[e.priority + 1]
	return string.format(
		"<path d='M%d %.1f C%.1f %.1f %.1f %.1f %d %.1f' stroke='%s' stroke-width='%g'%s/>"
			.. "<path d='M0 %.1f H%d M%d %.1f H%d' stroke='%s' stroke-width='%g'/>",
		a,
		e.from,
		mid,
		e.from,
		mid,
		e.to,
		b,
		e.to,
		color,
		stroke,
		if e.dashed then " stroke-dasharray='5 4'" else "",
		e.from,
		a,
		b,
		e.to,
		w,
		color,
		stroke
	)
end

local function layer_rule(class: string, paths: { string }, w: number, h: number): string
	local svg = string.format(
		"<svg xmlns='http://www.w3.org/2000/svg' width='%d' height='%d' viewBox='0 0 %d %d'>"
			.. "<g fill='none' stroke-linecap='round'>%s</g></svg>",
		w,
		h,
		w,
		h,
		table.concat(paths)
	)
	return string.format('%s .%s { background-image: url("data:image/svg+xml,%s"); }', SCOPE, class, pctenc(svg))
end

-- Builds the edge sheet and the classes of the layers to draw. `height` is the graph height in px.
-- Edges of the selected objective go on their own thicker layer; the rest dim while one is selected.
function M.build(edges: { Edge }, height: number): (string, { string })
	local w = Layout.px.gap_w
	local h = math.max(1, math.ceil(height))
	local normal, selected = {}, {}
	for _, e in edges do
		if e.selected then
			table.insert(selected, path(e, w, 3))
		else
			table.insert(normal, path(e, w, 1.5))
		end
	end
	local rules = {
		string.format("%s .ob-e { height: %dpx; background-size: %dpx %dpx; }", SCOPE, h, w, h),
	}
	local layers: { string } = {}
	if #normal > 0 then
		table.insert(rules, layer_rule("ob-e-all", normal, w, h))
		table.insert(layers, if #selected > 0 then "ob-e ob-e-all ob-e-dim" else "ob-e ob-e-all")
	end
	if #selected > 0 then
		table.insert(rules, layer_rule("ob-e-sel", selected, w, h))
		table.insert(layers, "ob-e ob-e-sel")
	end
	return table.concat(rules, "\n"), layers
end

return M
