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
	dashed: boolean, -- closed or elsewhere tab
	selected: boolean, -- belongs to the selected objective
}

local SCOPE = Layout.SCOPE

local function pctenc(s: string): string
	return (string.gsub(s, '[%%#<>"]', function(c)
		return string.format("%%%02X", string.byte(c))
	end))
end

-- A dashed line can end inside a gap of its pattern, short of the node; a 4 px solid stub at each
-- end makes every line touch both nodes.
local STUB = 4

local function path(e: Edge, w: number, stroke: number): string
	local mid = w / 2
	local color = Layout.palette[e.priority + 1]
	local curve = string.format(
		"<path d='M0 %.1f C%.1f %.1f %.1f %.1f %d %.1f' stroke='%s' stroke-width='%g'%s/>",
		e.from,
		mid,
		e.from,
		mid,
		e.to,
		w,
		e.to,
		color,
		stroke,
		if e.dashed then " stroke-dasharray='5 4'" else ""
	)
	if not e.dashed then
		return curve
	end
	return curve
		.. string.format(
			"<path d='M0 %.1f H%d M%d %.1f H%d' stroke='%s' stroke-width='%g'/>",
			e.from,
			STUB,
			w - STUB,
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
