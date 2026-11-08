# Design

## Context

- **Fixed geometry:** every objective node is 48 px tall (`lib/layout.luau:9`, sheet rule at line 46). `Layout.add_obj` returns its vertical centre, from those fixed heights (lines 86–89), and the link lines are SVG paths drawn to those centres (`lib/edges.luau`).
  - Node anatomy: 5 px padding and a 1 px border top and bottom, plus two 18 px rows `.ob-l1` and `.ob-l2` (`styles.css:159–167, 226–235`).
  - So a node's height must be known while the view is built.
- **Title:**
  - Line 1 holds the done box, the badge, then `.ob-name` with the `.ob-title` span and the `.ob-created` time, then the trash icon and ⋯ (`lib/view.luau:142–167`).
  - The title is one `nowrap` line cut with "…" (`styles.css:278–294`).
  - The node itself carries `click = "sel=<id>"` and the tooltip with the full title (`lib/view.luau:185`).
- **Rename:** `rename(cx, o)` opens `cx:prompt` filled with the title, saves through `Store.rename`, then `finish(cx2, true)` shows the graph again (`lib/app.luau:289–300`). ⋯ › Rename and ⌥R (`M.rename_selected`, line 757) both use it.
- **Agents:** `Details.begin` reads `cx.agents:list()` once per render into `agents[pane]` (`lib/details.luau:47–59`). `agent_name` tells omp from Claude and other agents (lines 88–96).
- **Panes:** `Model.read` keeps each live pane's `PaneInfo` as `row.info` (`lib/model.luau:7, 44–60`).
- **Refresh:** `agent_state` and `focus` events already request a render (`window.luau:75–98`). The 750 ms poll compares a signature of sessions, panes, tab names and agent states (`lib/refresh.luau:24–48`).
- **Selection ring:** `.ob-obj.ob-sel` has an accent border and a 1 px outer accent shadow (`styles.css:168–171`).

### Source record

| Claim | Evidence |
|---|---|
| A canvas can't hold a text input, so the title can't be edited in place | `tern.d.luau` L1443: "input, editor and image kinds are not allowed" |
| The plugin can't learn the canvas's pixel or cell width | No size in `CanvasSpec`, `CanvasInfo`, `PaneInfo` or `TabLayout` (`tern.d.luau` L523–556, L1105, L1440–1494); only a block (not a canvas) gets `cols`/`rows` (L1423–1426) |
| An inner element's `click` is delivered alone, without the card's `sel=` | raise-priority-in-place task 1.3: a badge click left no `ob-sel` and sent only `prio=` |
| A double-click on the title was unreliable live (0.7.0, dropped in 0.8.0) | archived rename-and-linked-tabs-first design D1 |
| `PaneInfo.alert` is a window-only "unseen alert"; `AgentBlock.state` is `idle`, `working`, `waiting_input` or `exited` | `tern.d.luau` L549–551, L772 |
| An omp reply that finishes in an unviewed tab sets that pane's `alert` (the tab reads `finished`), and the state goes `idle` | harness spike 2026-11-08: pane 4 in tab 5, "Reply with the single word ok." while tab 3 was shown; `working`/alert false, then `idle`/alert true after 3 s |
| Focusing the pane clears its alert | same spike: focusing pane 4 gave alert false at once |
| Focusing another pane of the same tab leaves a reply's alert set, and Tern keeps the tab marked `finished` | harness 2026-11-08, after the user's question about split tabs: tab "Split" with omp panes 4 (left) and 6 (right); after 6 replied unseen, focusing 4 left 6's alert true, and only focusing 6 cleared it |
| An omp question sets `waiting_input` and the alert (the tab reads `waiting`) | same spike: "Use your ask tool to ask me one yes/no question" gave `waiting_input`/alert true |
| Focusing a pane whose chat waits clears its alert but not the state | task 3.1, "Focusing keeps a question" |
| `--warn` and `--ok` are theme colours already used for Hard and Easy | `styles.css:206–220` |

## Goals / Non-Goals

**Goals:**
- Exact node heights for titles of one to three lines, so the lines stay on their nodes.
- One click on a title's text renames; the rest of the node still selects.
- A mark that tells "needs you" from "replied" at a glance, from what Tern already tracks.

**Non-Goals:**
- Line widths that follow the window, or wrapped side notes.
- Marks for other agents, closed tabs, or other windows.
- Editing a title inside the node.

## Decisions

### D1. The plugin breaks title lines
- **`Text.wrap(s, width, max)`** in `lib/text.luau`, with width 36 and max 3, UTF-8 aware. It fills lines greedily word by word at spaces.
  - A word longer than `width` is split at `width` characters.
  - If words remain after `max` lines, the last line is cut to `width - 1` characters plus "…".
  - It returns the lines.
- **View:** `.ob-name` becomes a column of `.ob-tline` rows. Each row holds one `.ob-title` span; the last row also holds `.ob-created`.
  - Each `.ob-title` is `nowrap` with an ellipsis, so a graph too narrow for a line cuts that line.
  - On the last row the title gives way before the time, as today.
  - The done box, badge, trash icon and ⋯ stay on the first line (`.ob-l1` gets `align-items: flex-start`).
- **Layout:**
  - `Layout.px.title_line_h = 18`. `Layout.add_obj(s, review, lines)` adds `(lines - 1) * 18` to the node's height and returns its centre.
  - The node gets class `ob-n2` or `ob-n3`, and the layout sheet sets those heights: 66 and 84 px, plus `review_h` in review mode. `.ob-l1` gets the matching heights.
- **Width choice (36):**
  - In the harness's 1280 px viewport the left column is 441 px wide, which leaves about 300 px for the title.
  - The graph's text is 12.5 px sans (`styles.css:7`), and the time is 11 px. 36 characters and the time should fit in that room.
  - The graph is at most 1200 px wide (`styles.css:9`), so the left column never gets much wider than about 490 px. The room a wide window leaves unused is bounded.
  - Task 1.1 measures this, and if it doesn't fit, the number changes in the spec and here before going on.

Alternative: CSS wrapping to the real width, with a height guessed from the title length. Rejected: a wrong guess leaves a blank line or hides text, and the lines would still meet a centre that may be wrong. The user chose the plugin's breaks (proposal).

### D2. A click on the title's text renames
- Each `.ob-title` span gets `actions = { click = "ren=<id>" }`, with no `title` of its own. The hover tooltip then comes from the node, if Tern shows an ancestor's title (risk below).
  - The span is as wide as its text (`flex: 0 1 auto`), so a click beside a short line reaches the node and selects.
- **Act `ren`** in `M.action`: find the objective, else `toast_gone`; call `rename(cx, o)`; set `later = true`, since `finish` draws.
  - `selected` is left as it is. As a click other than a badge's, it ends a held order (raise-priority-in-place D3).
- **Not selectable:** `.ob-title` joins the `user-select: none` rules. Dragging across a title then highlights nothing.
  - A press and release on the same title still makes a click, which renames, as intended.
  - The "Titles stay selectable" scenario goes, through a removed requirement and an added one, since a MODIFIED block can't drop a scenario.

Alternative: keep titles selectable for copying. Rejected: a click that ends on the title now opens the field anyway, and the full title can be copied from the field.

### D3. Attention from the agent state and the unseen alert
- **`Details.attention(row)`** returns `"wait"`, `"replied"` or nil for a live row:
  - nil unless `agents[row.pane]` exists and `agent_name(a, program)` is "omp";
  - `"wait"` when `a.state == "waiting_input"`;
  - `"replied"` when `a.state == "idle"` and `row.info.alert` is true.
- **`View.build`:** for each shown objective, walk its links. For each live tab (`win.tabs[tab]`), take the strongest attention over its rows, "wait" above "replied". The node gets `ob-att-wait` or `ob-att-replied`, plus a chip first on line 2 ("needs you" or "replied").
  - The chip's tooltip names the tab labels: `omp is waiting in “Server”` or `omp replied in “Server”`, with several tabs joined by commas.
  - Closed and elsewhere tabs have no live rows, so they never mark.
- **CSS:**
  - `.ob-att-wait`: border `var(--warn)` with a 1 px inset `--warn` shadow. `.ob-att-replied` is the same with `var(--ok)`.
  - With `.ob-sel` as well: the accent border and outer accent shadow, plus a 2 px inset ring in the attention colour, so both show.
  - The chips use the same colour with an 8 % fill, like the rating buttons.
- **Refresh:** `signature` in `lib/refresh.luau` adds each pane's `alert` (`!` when set). An alert that comes or goes without a state change then redraws within one poll. `agent_state` and `focus` events cover the usual cases already.

Alternatives:
- Track "replied" in the plugin from `agent_finished` until a `focus` lands in the tab. Rejected: Tern already keeps exactly this as the unseen alert, shared by every window.
- Use the tab-level `finished`/`waiting` text that `ctl state` shows. Rejected: it isn't in the plugin API; `PaneInfo.alert` is.

### D4. README
- **Features:** one line, "See what needs you", for the two marks.
- **Use section:** "click a title to rename it" beside ⌥R.

## Risks / Trade-offs

- **[Tooltip inheritance]** If Tern shows no tooltip for a span without its own `title`, hovering a cut title would show nothing. → Task 2.1 checks the hover. If it fails, each `.ob-title` gets the node's tooltip text as its own `title`.
- **[Fixed breaks]** A three-line title can leave room unused, up to the 1200 px cap. In a graph narrower than about 1000 px, a 36-character line may end in "…". → Chosen by the user. The tooltip always has the full title.
- **[`--warn` near P1 orange]** The theme's warning colour may sit close to the P1 badge's orange. → Task 3.1 compares them in shots of both appearances. If they look alike, the amber becomes a literal colour in the layout sheet, like the badge palette.
- **[Viewing a waiting chat]** The inference that viewing keeps `waiting_input` is unverified. → Task 3.1 runs "Viewing keeps a question". If the state changes on viewing, the spec follows what Tern does, after asking the user.
- **[Other agents' alerts]** Claude Code and others also raise alerts. → `Details.attention` returns nil for any agent but omp, per the proposal.
- **[Render cost]** One pass over each objective's links and their rows per render. → Tens of objectives and tabs. 1.x and 3.1 record render times.

## Migration Plan

Nothing stored changes. Release 0.16.0. To roll back, install `v0.15.0` again.
