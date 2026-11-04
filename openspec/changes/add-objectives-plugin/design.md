# Design

## Context

Motivation is in proposal.md (Why). Requirements are in `specs/`.

Facts that shape the approach. Each was checked against `tern.d.luau` (Tern 0.9.11, cited as `L<n>`), the SDK book at docs.stencil.so/tern, or a spike run on 2026-11-04 in isolated headless Tern instances. The spike sources lived under `/tmp/ternprobe`, `/tmp/ternspike-ids` and `/tmp/ternspike-graph` and may not survive a reboot, so their results are recorded here.

| Fact | Source |
|---|---|
| A plugin has two halves. The window half runs one VM per window on the UI thread, with a 50 ms budget per call (4 ms for `available`). Overruns pause the hook. | L5–13; SDK "Architecture" |
| Only the window half can see sessions, tabs and agents, and focus panes. A host block's `cx` has just toast, open, copy, render, save, exit, frame and blob. | L1408–1437, L1706–1792, L792 |
| The window half sees every session of its own window, but not other windows' panes. | Probe: `cx.session:sessions()/tabs()/panes()` returned all three sessions while `beta` was current; L1705, L1717 |
| `cx.layout:focus(pane)` alone switches session and tab. | Probe `jump_focus_only`: from `beta`, focus(5) left `current = alpha, focused = 5` |
| Pane, tab and session ids are stable across `tern restart` handovers and cold daemon restarts. Each id is `(range << 32) \| counter`, never reused. Names and focus are restored. | IdStability spike: 3 cold restores and 1 handover, all ids identical |
| A canvas (`cx.canvas:open`) works as a glimpse over the tab. A button click reaches `tern.on("canvas_action")` as `{act, value, node, owner, pane}`, with a window `cx`. | Probe and ClickableGraph spike (B); L1497–1516, L2252 |
| A canvas rejects `image` and `media` nodes, and takes no keys. | Spike B: `canvas kind "image" is not supported` |
| Plugin CSS, both manifest `styles` and `tern.css`, reaches canvases through `[data-surface='plugin.tern.canvas']`. The `style` attribute is ignored; classes plus CSS are the only styling. | Spike B; SDK `elements/el` |
| `el` nodes placed absolutely, plus edges drawn as a runtime `data:image/svg+xml` CSS background, stayed aligned at 1400 px and 460 px, with real `tern ctl click` hits. | Spike B2: `b2_canvas_css_460.png`, `b2_canvas_css_sel_1400.png` |
| A `tern.css` sheet vanishes after a plugin reload until it is installed again. | Spike, failure modes |
| `tern.kv` is one JSON file rewritten whole on every set, and the last write wins. A key one half wrote was lost when the other half wrote. | L2086–2095; spike (`open_flow` lost) |
| `os.time`, `os.date`, `os.clock` and `os.difftime` are available. `os.time{...}` reads the table as local time. | SDK "Basics" (sandbox table) |
| `cx.agents:list()` covers agent blocks and shells running omp, with `last_message`. `transcript(pane, {last})` is synchronous; non-omp agents return `{}`. | L793–814; SDK "Agents cx" |
| `PaneInfo` carries `kind`, `tab`, `parked`, `floating`, `last {line,status,took_ms}`, `running {line,ms}`, `path`, `url` and `block`. | L523–556 |
| `pane_created` and `tab_created` fire only for panes this window adds, not those created by the CLI or restored. | SDK `reference/events` |
| `tern serve` is ephemeral: it numbers ids from 1 and loads plugins from `<STENCIL_FIXTURE_ROOT>/crates/plugins/fixtures` after `ctl plugins fixtures`. | Spikes |

## Goals / Non-Goals

**Goals:**
- One VM-local module set in the window half. One writer of `kv.json`. No host half.
- Rendering stays within the 50 ms budget with about 30 objectives and about 40 panes.
- Every behaviour in `specs/` can be checked by a real click, a screenshot or a kv dump in a headless Tern.

**Non-Goals:**
- A reusable graph widget, or support for any Tern older than 0.9.11.
- Coordination between windows beyond last-write-wins with read-before-write.
- Proving behaviour across a full daemon restart inside the test harness. `tern serve` is ephemeral, so that case relies on the IdStability spike.

## Decisions

### D1. Window half only
**Choice:** `plugin.toml` names `window = "window.luau"` and no host entry.

Every API the specs need lives in the window half:
- `cx.session`, `cx.sessions`, `cx.layout`, `cx.agents`, `cx.canvas`;
- `cx:pick` and `cx:prompt` (L1893, L1896);
- `tern.command`, `tern.css`.

**Alternative:** a host block with an SVG `image` (spike A). It renders well and supports keys. Rejected because it cannot focus panes, cannot see sessions, and would put a second writer on `kv.json`.

### D2. Canvas in a glimpse, reused
**Opening:** "Open graph" calls `cx.canvas:open{title = "Objectives", view, dock?, about, how = "glimpse"}`.

**Reuse:**
- The VM keeps the canvas pane id.
- On the next open, if `cx.canvas:get(id)` (L1572) still returns our canvas, the plugin `set`s it and focuses it.
- Otherwise it searches `cx.canvas:list()` (L1574) for any canvas with `owner = "objectives"` before opening a new one. This keeps a single canvas per window, as the spec requires.

**Fallback:** if the glimpse misbehaves (risk R1), switch to `how = "beside", ratio = 0.4`, a lasting side panel (L1451–1461). The decision is recorded in this file before going further.

### D3. Fixed-geometry layout from one constants table
The graph is a flex row of `tern.ui.el("div", {class = …})` nodes: a left column, a gap column for edges, and a right column. Every row type has a fixed pixel height:
- objective node;
- session heading;
- tab header;
- pane row;
- detail line;
- group headings;
- gaps.

All text is single-line with ellipsis. A Lua constants table is the single source of truth:
- the generated layout CSS (installed with `tern.css("layout", …)`) sets the heights;
- the edge geometry computes each node's vertical centre from the same numbers.

The spike showed that alignment holds exactly when the CSS and the edge geometry share one formula.

**Column widths:**
- Columns are percentages, so width changes only stretch the gap horizontally.
- The graph is capped with `max-width` on a wrapper; the spike needed a wrapper cap.

**Hover text:** full title, note and times go in the node's `title` prop.

### D4. Edges as masked layers coloured by theme variables
The gap column holds one absolutely positioned layer per priority (P0–P3), plus one "selected" layer. Each layer:
- draws its shapes with a `data:image/svg+xml` mask (`mask-image` and `-webkit-mask-image`);
- takes its colour from `background-color` set to a theme variable: `--bad` (P0), `--warn`, `--accent` and `--t3` respectively (SDK "Themes": `--accent`, `--ok`, `--bad`, `--warn`, `--t1`…`--t4`). This orange-for-P1 mapping is the one checked in task 2.2.

**SVG geometry:**
- `viewBox = "0 0 100 H"`, where H is the graph height in px, with `preserveAspectRatio = "none"` and `vector-effect = "non-scaling-stroke"`.
- Curves are cubic Béziers from x = 0 at the objective's centre y to x = 100 at the tab header's centre y.
- Closed and elsewhere tabs use `stroke-dasharray`.

**Selection:**
- Unselected layers get `opacity: .25`.
- The selected objective's edges go on the selected layer with a thicker stroke.

**Reinstalling:** the edge sheet (`tern.css("edges", …)`) is installed again on every render, on `window_start`, and at load, so a reload can't leave it missing. Install is skipped when the string is unchanged.

**Alternatives considered:**
- Spike B2's plain `background-image` with hard-coded colours. It is proven, but it can't follow the theme. It is the fallback if masks fail (R2), with the palette picked from the light/dark appearance.
- A mermaid chart, rejected: no clickable nodes and its own node order (spike B1).

### D5. Click protocol
Every clickable node carries `actions = {click = "<verb>=<arg>"}`. Tern splits this into `act` and `value` (UiEvent L382–386; spike: `act = "pick", value = "o1"`). Verbs:

| Verb | Argument | Action |
|---|---|---|
| `sel` | objective id | select or deselect |
| `done` | objective id | toggle done |
| `prio` | objective id | cycle priority |
| `menu` | objective id | open the ⋯ menu |
| `link` | tab id | toggle the link to the selected objective |
| `tab` | tab id | jump to the tab |
| `pane` | pane id | jump to the pane |
| `exp` | pane id | expand or collapse details |
| `scope` | `all` or `session` | set the scope filter |
| `tag` | tag | set or clear the tag filter |
| `new` | none | new objective |
| `prune` | none | prune closed tabs |
| `donegrp` | none | open or close the Done group |
| `bg` | none | clear the selection |

The nearest node with an action wins: in spike A, a child button's action beat its parent's `bg`. The handler returns `true` to consume the click.

### D6. Storage schema v1
All state is one value at `tern.kv` key `"state"`:

```json
{
  "version": 1,
  "next_id": 7,
  "objectives": [
    {"id": "o3", "title": "…", "done": false, "priority": 2,
     "created": 1793800000, "done_at": null,
     "note": "…", "due": "2026-11-20", "tags": ["web"], "tabs": [100000000004]}
  ],
  "tabs": {
    "100000000004": {"label": "…", "session": 100000000002, "session_name": "web",
      "position": 2, "window": "", "seen": 1793800000,
      "panes": [{"pane": 100000000003, "title": "…", "kind": "terminal"}]}
  },
  "view": {"scope": "all", "tag": null, "done_open": false, "expanded": {"100000000003": true}}
}
```

**Writes:** every mutation goes through `mutate(fn)`:
1. `tern.kv.get("state")`, which re-reads the file when it has changed (L2086–2087);
2. apply `fn`;
3. `tern.kv.set`.

Lists use `tern.json.array` so empty lists stay `[]`.

**Ids:**
- Tab and pane ids are JSON numbers, which are exact below 2^53 (SDK `reference/limits`).
- Objective ids are `"o" .. next_id`.

Selection is kept in VM memory only.

### D7. Time and dates
- `created` and `done_at` are `os.time()` epoch seconds.
- "Today" is `os.date("*t")`.
- Day differences use `os.time{year, month, day, hour = 12}`, divided by 86400 and rounded, so daylight-saving shifts cannot move a date.
- Date input is checked by round-tripping it through `os.time` and `os.date` and comparing the fields, which rejects dates such as 2026-02-30.

### D8. Link status is derived, never stored
**On each render:**
- A linked tab id found in `cx.session:tabs()` is **live**. Its snapshot is refreshed, including `window = cx:window_key()` (L1903).
- If it is not found and the snapshot's `window` equals this window's key, it is **closed**.
- Otherwise it is **elsewhere**.

**Why it is safe:**
- Nothing is destroyed until an explicit, confirmed prune.
- A transient render before sessions are restored can't lose data.
- Stable ids (IdStability spike) mean a restart brings links back as live.

### D9. Tab and pane model
**Sources:**
- Session order from `cx.session:sessions()` (L1708).
- Current session from `cx.sessions:current()` (L717).
- Tabs from `cx.session:tabs()` (L1734).
- Panes from `cx.session:panes()` (L1732), filtered by `tab` and `not parked`.

**Ordering and labels:**
- Pane order follows the leaves of `cx.session:layout(tab).root` (L1101–1105, L1710) from left to right, then floats.
- The label is `TabInfo.name`, or else the first leaf pane's title.
- The canvas's own pane is excluded.

### D10. Navigation
- A tab header calls `cx.layout:focus(TabInfo.pane)`, the tab's focused block (L1126–1130).
- A pane row calls `cx.layout:focus(pane)`.
- The probe showed focus alone switches session and tab. If a live run shows otherwise, call `cx.sessions:switch(TabInfo.session)` first (L721), as community plugins do.
- Closed and elsewhere targets only `cx:toast("info", …)`.

### D11. Pane details sources and budget
**Agents:**
- `cx.agents:list()` is read once per render and indexed by pane.
- The user's last message comes from `cx.agents:transcript(pane, {last = 10})`, scanned from the end for `role = "user"`. If none is found, it widens once to `last = 50`.

**Transcript cache:**
- Results are cached per pane, keyed by `(last_message, state)`.
- When an expanded agent row's key changes, the entry goes stale.
- A 250 ms tick refreshes at most one stale entry inside `pcall`, then re-renders. This follows the removed agentprogress plugin's one-transcript-per-tick pattern.

**Terminals:** use `PaneInfo.last` and `running`. Other kinds use `path`, `url`, `block` or `title`.

Text is normalised by collapsing whitespace and cutting to 160 characters plus "…".

### D12. Live refresh
**Events:** while the canvas exists, these events schedule one render 150 ms later, coalesced:
- `focus`, `pane_created`, `pane_closed`, `tab_created`, `tab_closed`, `title`;
- `command_started`, `command_finished`, `agent_state`, `agent_finished`, `float_moved`, `session_ended`.

These are registered with `tern.on` (L2247–2255).

**Polling:** `pane_created` and `tab_created` miss CLI-made and restored panes, so a 750 ms poll compares a cheap signature (tab ids, pane ids and tabs, titles) and renders when it differs.

**Running commands:** a 1 s timer runs only while an expanded row shows a running command.

All timers stop when the canvas is gone.

### D13. Commands
`tern.command` (L1186–1201, L2258) registers `open` (`keys = {"ctrl+cmd+o"}`), `link_tab` and `new_for_tab`, all with `group = "Objectives"`.
- ⌃⌘O appears neither in Tern's default action table (SDK `reference/actions`) nor in the user's `settings.json` keybinds.
- "This tab" means `cx.session:tab_of(cx.session:focused())` (L1716, L1736).

### D14. Test harness, kept outside the repo
**Setup:**
1. Work directory `/tmp/tobj`: `mkdir -p crates/app/goldens crates/plugins/fixtures`.
2. Copy the repo's package files into `crates/plugins/fixtures/objectives`. The copy is refreshed by each test step.

**Run:** `tern serve` runs as a named service with these environment changes:
- unset `TERN_PANE`, `TERN_PANE_SOCKET`, `TERN_WINDOW_KEY` and `TERN_WINDOW_SOCKET`;
- `TERN_CONFIG_DIR=/tmp/tobj/config`, `TERN_DAEMON_SOCKET=/tmp/tobj/daemon.sock`, `STENCIL_FIXTURE_ROOT=/tmp/tobj/crates/app`;
- `STENCIL_LOG=warn,tern::plugin=debug` and `STENCIL_LOG_DIR=/tmp/tobj/logs`.

**Driving it (`tern ctl --control /tmp/tobj/ctl.sock`):**
- set-up: `plugins fixtures`, `session new`, `split right`, `tab new`;
- actions: `plugins run plugin.objectives.<cmd>`, `click SEL|X Y`;
- inspection: `pick X Y`, `dump`, `shot NAME`, `state`.

**Results:** kv dumps are read from `/tmp/tobj/config/plugin-data/objectives/kv.json`.

**Agent rows:** run `omp --no-session` with a cheap model and one short prompt in a headless pane.

**Daemon-restart cases** are not re-run in the harness, because `serve` renumbers ids from 1 (R11).

### D15. Packaging
- `tern plugin install` copies everything except `.git` (SDK "Distribution"), so `openspec/` and the README ship along. That is harmless because the loader reads only the manifest, the entries, the modules they require and the styles.
- `tern.d.luau` and `.omp/` are gitignored.
- The plugin never writes into its package folder, which would trigger a reload.

## Risks / Trade-offs

- **R1. Glimpse behaviour is untested in three cases:** after a jump that switches sessions, when a picker opens over it, and when shown again after being dismissed. → Task 2.1 checks all three before any feature work. If any fails, switch to the side panel (D2) and record the change here.
- **R2. `mask-image` on a data-URL SVG is untested in Tern's renderer.** The spike only proved `background-image`. → Task 2.2 checks it first. If it fails, use per-appearance colour palettes on `background-image`.
- **R3. Last write wins between windows.** Two windows changing objectives at the same moment can lose one change. → Read-before-write narrows the window to milliseconds. This is acceptable because the user runs one window.
- **R4. Fixed one-line heights hide long text.** → Tooltips carry the full text, and titles are capped at 120 characters.
- **R5. The cost of a transcript read is unknown.** → At most one per 250 ms tick, inside `pcall`, cached. Render time is measured with `tern.now()` and logged as a warning above 20 ms.
- **R6. At startup, the window can render before sessions are restored, making tabs look closed.** → Status is derived, never stored, and prune always asks for confirmation.
- **R7. A tab held by a window that has since closed for good stays "elsewhere".** → The user can remove those links with × while an objective is selected.
- **R8. A disconnected remote host makes its tabs look closed.** → Links return on reconnect unless the user prunes them. The prune confirmation names the count.
- **R9. Terminal details need Tern's shell integration.** After a cold daemon restart, shells start fresh, so "last command" is empty until a new command runs (IdStability: shells re-spawn). → The row reads "no command yet".
- **R10. Canvas limits are 2000 nodes, depth 32 and 256 KiB per update (L1564).** → The estimate is under 700 nodes at the target size. The Done group stays collapsed by default.
- **R11. The harness cannot exercise a full daemon restart.** → That durability rests on the IdStability spike (ids identical across 3 cold restores and 1 handover) plus `kv.json` being a plain file. Restarting `serve` with existing links is avoided in tests, because ids restart at 1 and would collide.
- **R12. The 50 ms window budget.** → A render does no file reads other than `tern.kv.get` and no subprocesses. Its measured cost is logged.

## Migration Plan

- This is new. There is no data to migrate.
- **Rollout:** headless verification, then push to `JakobMusik/tern-objectives`, tag `v0.1.0`, then `tern plugin install github.com/JakobMusik/tern-objectives` in the live Tern.
- **Rollback:** `tern plugin remove objectives`. Data stays in `plugin-data/objectives/kv.json` until deleted by hand.
- **Later schema changes:** bump `version` and migrate inside `mutate` on read.

## Open Questions

- Which `cx.settings` key reports the current light/dark appearance. This is only needed if R2 forces the palette fallback. It changes no spec.
