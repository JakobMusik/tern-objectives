--!strict
-- The window's single objectives graph, a glimpse over the current tab on one of two surfaces
-- (design G1, G2):
-- - in a session on this machine, the plugin block `objectives.graph`: the window half hands its view
--   over through two files in the data folder, and the block takes keys, so Esc closes it;
-- - in a session on another machine, a canvas filled from this window. A block would open on that
--   machine, which has neither the plugin nor this Mac's data folder.
-- A glimpse that loses focus to a programmatic focus change docks into its tab as a split, so jumps
-- close the graph first, and only an undocked glimpse in the current tab is reused.

local KIND = "objectives.graph"
local OWNER = "objectives"
local TITLE = "Objectives"
local ABOUT = "Objectives graph: objectives on the left, tabs on the right. Clicks select, edit, link and jump."

export type Kind = "block" | "canvas"

local M = {}

local pane_id: number? = nil
local pane_kind: Kind = "block"
-- False until a lookup has run in this VM. A plugin reload starts a new VM while a shown graph
-- survives, so the first event after it must look.
local looked = false
local stem_cache: string? = nil
local count = 0

-- This window's view-file stem: its window key, safe as a file name ("window" when the key is empty,
-- as in a headless Tern).
local function stem(cx: WindowCx): string
	if stem_cache == nil then
		local key = string.gsub(cx:window_key(), "[^%w_%-]", "_")
		stem_cache = if key == "" then "window" else key
	end
	return stem_cache :: string
end

local function base(cx: WindowCx): string
	return tern.plugin.data .. "/view-" .. stem(cx)
end

local function remove_files(cx: WindowCx)
	local b = base(cx)
	for _, path in { b .. ".json", b .. ".seq" } do
		if tern.fs.exists(path) then
			pcall(tern.fs.remove, path)
		end
	end
end

-- Hands `view` to the block: the tree first, then the sequence token the block polls. The token
-- carries the load time, so a reloaded VM never repeats one the block has already shown.
local function hand_over(cx: WindowCx, view: Node)
	count += 1
	local n = string.format("%d.%d.%d", os.time(), math.floor(tern.now()), count)
	local b = base(cx)
	tern.fs.write(b .. ".json", tern.json.encode({ n = n, tree = view }))
	tern.fs.write(b .. ".seq", n)
end

local function is_block(info: PaneInfo?): boolean
	return info ~= nil and info.kind == "plugin" and info.block == KIND
end

-- Whether `pane` is still this window's graph, as the kind it was found as.
local function alive(cx: WindowCx, pane: number, kind: Kind): boolean
	if kind == "block" then
		return is_block(cx.session:pane(pane))
	end
	local info = cx.canvas:get(pane)
	return info ~= nil and info.owner == OWNER
end

-- The surface the current session needs: the block on this machine, a canvas elsewhere.
local function wanted(cx: WindowCx): Kind
	local ok, host = pcall(function()
		return cx.hosts:current()
	end)
	return if not ok or host.kind == "local" then "block" else "canvas"
end

-- Whether a graph may exist: events skip the lookup only once one has found none.
function M.known(): boolean
	return pane_id ~= nil or not looked
end

-- The pane of this window's graph, block or canvas, or nil when none exists. A canvas a 0.1.x graph
-- left behind is adopted like any other (design G5). Noticing the block gone (Esc, a click outside,
-- a close) removes its view files.
function M.find(cx: WindowCx): number?
	looked = true
	if pane_id ~= nil then
		if alive(cx, pane_id, pane_kind) then
			return pane_id
		end
		if pane_kind == "block" then
			remove_files(cx)
		end
		pane_id = nil
	end
	for _, p in cx.session:panes() do
		if is_block(p) then
			pane_id, pane_kind = p.pane, "block"
			return p.pane
		end
	end
	for _, info in cx.canvas:list() do
		if info.owner == OWNER then
			pane_id, pane_kind = info.pane, "canvas"
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
	if pane_kind == "canvas" then
		cx.canvas:set(pane, { view = view })
	else
		hand_over(cx, view)
	end
	return true
end

-- Shows `view` as a glimpse over the current tab and gives it focus: updates the glimpse already
-- there when it is on the surface this session needs, else closes any graph (docked, in another
-- tab, or on the other surface) and opens a new one.
function M.show(cx: WindowCx, view: Node): (number?, string?)
	local want = wanted(cx)
	local here = M.here(cx)
	if here ~= nil and pane_kind == want then
		M.update(cx, view)
		cx.layout:focus(here)
		return here, nil
	end
	local existing = M.find(cx)
	if existing ~= nil then
		cx.layout:close(existing)
		pane_id = nil
	end
	remove_files(cx)
	if want == "canvas" then
		local pane, err = cx.canvas:open({ title = TITLE, view = view, about = ABOUT, how = "glimpse" })
		if pane == nil then
			return nil, err or "This session's machine can't show the graph."
		end
		pane_id, pane_kind = pane, "canvas"
		cx.layout:focus(pane)
		return pane, nil
	end
	-- The files go first: the block reads them in its init.
	hand_over(cx, view)
	local pane = cx:new_block(KIND, { stem(cx) }, "glimpse")
	if pane == nil then
		remove_files(cx)
		return nil, "No ready `objectives` plugin defines the graph block here."
	end
	pane_id, pane_kind = pane, "block"
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
	remove_files(cx)
end

return M
