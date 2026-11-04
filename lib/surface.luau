--!strict
-- The window's single objectives graph: a canvas glimpse over the current tab, filled from this
-- window, in every session on any machine (design G1, G2). A canvas needs nothing installed where the
-- session runs, which a plugin block would.
-- A glimpse that loses focus to a programmatic focus change docks into its tab as a split, so jumps
-- close the graph first, and only an undocked glimpse in the current tab is reused.

local OWNER = "objectives"
local TITLE = "Objectives"
local ABOUT = "Objectives graph: objectives on the left, tabs on the right. Clicks select, edit, link and jump."
-- 0.3.0's graph block and the view files it read (design G5).
local OLD_BLOCK = "objectives.graph"

local M = {}

local pane_id: number? = nil
-- False until a lookup has run in this VM. A plugin reload starts a new VM while a shown graph
-- survives, so the first event after it must look.
local looked = false

-- Closes a 0.3.0 graph block that survived the upgrade and removes this window's view files.
local function drop_old_block(cx: WindowCx)
	for _, p in cx.session:panes() do
		if p.kind == "plugin" and p.block == OLD_BLOCK then
			cx.layout:close(p.pane)
		end
	end
	local key = string.gsub(cx:window_key(), "[^%w_%-]", "_")
	local base = tern.plugin.data .. "/view-" .. (if key == "" then "window" else key)
	for _, path in { base .. ".json", base .. ".seq" } do
		if tern.fs.exists(path) then
			pcall(tern.fs.remove, path)
		end
	end
end

-- Whether a graph may exist: events skip the lookup only once one has found none.
function M.known(): boolean
	return pane_id ~= nil or not looked
end

-- The pane of this window's graph, or nil when none exists. A canvas a 0.1.x graph left behind is
-- adopted like any other (design G5).
function M.find(cx: WindowCx): number?
	if not looked then
		looked = true
		drop_old_block(cx)
	end
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

-- The graph when it is a glimpse over the current tab (not docked, not in another tab), else nil.
function M.here(cx: WindowCx): number?
	local existing = M.find(cx)
	if existing == nil then
		return nil
	end
	local info = cx.session:pane(existing)
	local tab = if info ~= nil then info.tab else nil
	if tab ~= nil and tab == current_tab(cx) and not docked(cx, existing, tab) then
		return existing
	end
	return nil
end

-- Hands a new view to the shown graph without focusing it; false when there is none.
function M.update(cx: WindowCx, view: Node): boolean
	local pane = M.find(cx)
	if pane == nil then
		return false
	end
	cx.canvas:set(pane, { view = view })
	return true
end

-- Shows `view` as a glimpse over the current tab and gives it focus: updates the glimpse already
-- there, else closes any graph (docked or in another tab) and opens a new one.
function M.show(cx: WindowCx, view: Node): (number?, string?)
	local here = M.here(cx)
	if here ~= nil then
		M.update(cx, view)
		cx.layout:focus(here)
		return here, nil
	end
	M.close(cx)
	local pane, err = cx.canvas:open({ title = TITLE, view = view, about = ABOUT, how = "glimpse" })
	if pane == nil then
		return nil, err or "This session's machine can't show the graph."
	end
	pane_id = pane
	cx.layout:focus(pane)
	return pane, nil
end

-- Closes the graph, so a jump leaves nothing over or beside its target.
function M.close(cx: WindowCx)
	local existing = M.find(cx)
	if existing ~= nil then
		cx.layout:close(existing)
	end
	pane_id = nil
end

return M
