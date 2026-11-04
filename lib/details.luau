--!strict
-- Pane details (design D11): the lines an expanded pane row shows.

local Model = require("./model")

local M = {}

export type Line = { text: string, class: string? }

function M.lines(_cx: WindowCx, _row: Model.Row): { Line }
	return {}
end

return M
