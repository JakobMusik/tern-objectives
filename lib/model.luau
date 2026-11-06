--!strict
-- What the window holds (design D9): sessions in Tern's order, their tabs in order, and each tab's
-- pane rows (split leaves left to right, then floats). Link status is derived here (design D8).

local M = {}

export type Row = { pane: number, title: string, kind: string, info: PaneInfo? }

export type Tab = {
	id: number,
	session: number,
	session_name: string,
	position: number,
	label: string,
	focus: number, -- the pane last focused in it
	rows: { Row },
	status: string, -- "live", "closed" or "elsewhere"
}

export type Session = { id: number, name: string, current: boolean, tabs: { Tab } }

export type Window = {
	key: string,
	current: number?, -- current session id
	sessions: { Session },
	tabs: { [number]: Tab }, -- live tabs by id
	live: { [number]: boolean }, -- every live pane id, parked ones included
}

local function leaves(tree: TabTree, out: { number })
	if tree.pane ~= nil then
		table.insert(out, tree.pane)
		return
	end
	if tree[1] ~= nil then
		leaves(tree[1], out)
	end
	if tree[2] ~= nil then
		leaves(tree[2], out)
	end
end

-- The window's live sessions and tabs. `skip` is the graph's own pane, never listed.
function M.read(cx: WindowCx, skip: number?): Window
	local panes: { [number]: PaneInfo } = {}
	local by_tab: { [number]: { PaneInfo } } = {}
	for _, p in cx.session:panes() do
		panes[p.pane] = p
		if p.tab ~= nil and not p.parked and p.pane ~= skip then
			local list = by_tab[p.tab]
			if list == nil then
				list = {}
				by_tab[p.tab] = list
			end
			table.insert(list, p)
		end
	end
	local infos: { [number]: TabInfo } = {}
	for _, t in cx.session:tabs() do
		infos[t.id] = t
	end

	local win: Window = { key = cx:window_key(), current = nil, sessions = {}, tabs = {}, live = {} }
	for id in panes do
		win.live[id] = true
	end
	for _, s in cx.session:sessions() do
		local session: Session = { id = s.id, name = s.name, current = s.current, tabs = {} }
		if s.current then
			win.current = s.id
		end
		for position, tab_id in s.tabs do
			local info = infos[tab_id]
			local layout = cx.session:layout(tab_id)
			local order: { number } = {}
			if layout ~= nil then
				leaves(layout.root, order)
				for _, f in layout.floats do
					table.insert(order, f.pane)
				end
			end
			local rows: { Row } = {}
			local listed: { [number]: boolean } = {}
			local function add(id: number)
				local p = panes[id]
				if p == nil or listed[id] or p.parked or id == skip or p.tab ~= tab_id then
					return
				end
				listed[id] = true
				table.insert(rows, { pane = id, title = p.title, kind = p.kind or "terminal", info = p })
			end
			for _, id in order do
				add(id)
			end
			for _, p in by_tab[tab_id] or {} do
				add(p.pane)
			end
			local name = if info ~= nil and info.name ~= nil and info.name ~= "" then info.name else nil
			local label = name or (if rows[1] ~= nil then rows[1].title else (if info ~= nil then info.title else "tab"))
			local focus = if layout ~= nil then layout.focus elseif info ~= nil then info.pane else (if rows[1] then rows[1].pane else 0)
			local tab: Tab = {
				id = tab_id,
				session = s.id,
				session_name = s.name,
				position = position,
				label = label,
				focus = focus,
				rows = rows,
				status = "live",
			}
			table.insert(session.tabs, tab)
			win.tabs[tab_id] = tab
		end
		table.insert(win.sessions, session)
	end
	return win
end

-- "live" when the window holds the tab, "closed" when its snapshot came from this window, else
-- "elsewhere". Never stored.
function M.status(win: Window, tab_id: number, snapshot_window: string?): string
	if win.tabs[tab_id] ~= nil then
		return "live"
	end
	if snapshot_window == nil or snapshot_window == win.key then
		return "closed"
	end
	return "elsewhere"
end

return M
