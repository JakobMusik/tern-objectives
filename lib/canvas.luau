--!strict
-- The window's single objectives canvas (design D2): a glimpse over the current tab.
-- A glimpse that loses focus to a programmatic focus change docks into its tab as a split, so jumps
-- close the canvas first, and only an undocked glimpse in the current tab is reused.

local OWNER = "objectives"
local TITLE = "Objectives"
local ABOUT = "Objectives graph: objectives on the left, tabs on the right. Clicks select, edit, link and jump."

local M = {}

local pane_id: number? = nil

-- The pane of this window's objectives canvas, or nil when none exists.
function M.find(cx: WindowCx): number?
	if pane_id ~= nil then
		local info = cx.canvas:get(pane_id)
		if info ~= nil and info.owner == OWNER then
			return pane_id
		end
		pane_id = nil
	end
	for _, info in cx.canvas:list() do
		if info.owner == OWNER then
			pane_id = info.pane
			return info.pane
		end
	end
	return nil
end

local function current_tab(cx: WindowCx): number?
	local focused = cx.session:focused()
	return if focused ~= nil then cx.session:tab_of(focused) else nil
end

-- Whether `pane` sits in its tab's split tree or floats: docked, no longer a glimpse.
local function docked(cx: WindowCx, pane: number, tab: number): boolean
	local layout = cx.session:layout(tab)
	if layout == nil then
		return false
	end
	for _, f in layout.floats do
		if f.pane == pane then
			return true
		end
	end
	local function walk(t: TabTree): boolean
		if t.pane ~= nil then
			return t.pane == pane
		end
		return (t[1] ~= nil and walk(t[1])) or (t[2] ~= nil and walk(t[2]))
	end
	return walk(layout.root)
end

-- Shows `view` as a glimpse over the current tab: updates and focuses the glimpse already there,
-- else closes any canvas (docked, or in another tab) and opens a new glimpse.
function M.show(cx: WindowCx, view: Node): (number?, string?)
	local existing = M.find(cx)
	if existing ~= nil then
		local info = cx.session:pane(existing)
		local tab = if info ~= nil then info.tab else nil
		if tab ~= nil and tab == current_tab(cx) and not docked(cx, existing, tab) then
			cx.canvas:set(existing, { view = view })
			cx.layout:focus(existing)
			return existing, nil
		end
		cx.layout:close(existing)
		pane_id = nil
	end
	local pane, err = cx.canvas:open({ title = TITLE, view = view, about = ABOUT, how = "glimpse" })
	pane_id = pane
	if pane ~= nil then
		cx.layout:focus(pane)
	end
	return pane, err
end

-- Replaces the view of the existing canvas without focusing it; false when there is none.
function M.update(cx: WindowCx, view: Node): boolean
	local existing = M.find(cx)
	if existing == nil then
		return false
	end
	cx.canvas:set(existing, { view = view })
	return true
end

-- Closes the canvas, so a jump leaves nothing over or beside its target.
function M.close(cx: WindowCx)
	local existing = M.find(cx)
	if existing ~= nil then
		cx.layout:close(existing)
	end
	pane_id = nil
end

return M
