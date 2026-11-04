# Design

## Context

Motivation is in proposal.md. The graph is one canvas filled from window Lua (archived change `2026-11-05-graph-in-any-session`). Relevant code as of 0.4.0:

- `View.build` lists sessions in `win.sessions` order and tabs in `s.tabs` order (`lib/view.luau` 369–381). `Model.read` takes both from `cx.session:sessions()`.
- The origin is the pane focused at a fresh open, kept after the graph's pickers (archived P5). It reaches the view as `ui_state.origin`.
- `.ob-tab-unlinked` is `opacity: 0.55`, a dashed border and a transparent background. Linked tabs use `var(--card)` (`styles.css` 262–276).
- Rows are open unless their pane is in `view.collapsed` (`view.luau` 158, `store.luau` 41–42, the `exp` action in `app.luau` 498–502). The toggle `.ob-exp` is 22 px wide in the 12.5 px body face.
- Agent details are a state line, `you  <msg>` and `omp  <reply>`, each cut by `Text.clip` to 160 characters at the tail (`lib/details.luau` 74–94). CSS then cuts again at the line's end.

### Spike and source record

| Fact | Source |
|---|---|
| omp typed at a shell is listed by `cx.agents:list()` with `command = nil`; its `PaneInfo` has `kind = "agent"` and `program = "omp"` | harness 2026-11-05: `omp --no-session` in pane 19, helper ops `agents` and `dump` |
| `cx:run` types text; a trailing `"\r"` runs it | `tern.d.luau` L1877 |
| `PaneKind` is terminal, agent, plugin, browser, file, git, database, notebook, board, canvas, procs, screen, profile or carly | `tern.d.luau` L518–520 |
| A note is a file pane whose path is `note:<hash>` | live 0.4.0 window: `tern ls --json` lists block file `note:1f70c632…`, and the graph printed that path as the row's detail, which only the file branch of `Details.lines` does |
| `cx:open("note:…")` opens nothing in the headless Tern | harness 2026-11-05 |
| A `text` node (`{k = "text", p = {spans, truncate, wrap}}`) with `truncate = "middle"` keeps both ends (`ab…yz`), cuts only when the text overflows its element's width, recuts on resize, and gets the full text as its tooltip | SDK "Building Views › `text`" |
| Spans are `{t, s?}`, with `s` holding style tokens such as `"strong"` | `tern.d.luau` L122–132 |
| A `text` node renders as `div.sf.sf-text` and has no `class` prop | SDK "Props every node takes" |
| `user-select` and `white-space: pre` are supported | SDK "Supported CSS" |

## Goals / Non-Goals

**Goals:** the six refinements in the proposal, with the existing layout arithmetic (node and row heights, line ends) unchanged.

**Non-Goals:**
- reordering Tern's own tabs;
- middle cuts for anything but agent messages;
- detecting notes in closed tabs.

## Decisions

### R1. Origin first
`View.build` looks up the live tab whose rows hold `ui_state.origin`. If there is one, its session is listed first and that tab first within it. Everything else keeps `win.sessions` / `s.tabs` order. The model stays in Tern's order, and only the view reorders, so link status, scope and snapshots are untouched. The order follows the origin: the same after a picker, a new one after a fresh open, and Tern's order once the origin pane is gone.

The origin's session is in practice the current one (the graph opens from the focused pane), so "● current" usually ends up on the first heading. The rule doesn't depend on that.

**Alternative:** a pinned node above all groups (rejected by the user: it splits a session's tabs).

### R2. Unlinked fill
`.ob-tab-unlinked` loses its opacity. It gets `background: linear-gradient(ink 8%, ink 8%), var(--card)`, the card colour under an 8 % layer of `--t1`, with the dashed border at 30 %. The gradient form is from SDK "Supported CSS" (`background-image` accepts `linear-gradient()`).

The first try, a 5 % ink layer over the page, failed in the dark appearance. The dark page `(21,24,32)` is darker than the dark card `(29,32,40)`, so the fill landed on `(32,35,43)`, 3 levels from the card (task 2.2). Over the card, the fill is 16 levels from it in both appearances: light `239` vs `255`, dark `(45,48,56)` vs `(29,32,40)`.

Ghost tabs (closed or elsewhere) keep their 0.5 opacity: they are history, not unlinked tabs.

### R3. Toggle and fold state
- `.ob-exp` becomes 28 px wide, full row height, with a 15 px glyph and `user-select: none`. Rows stay 22 px (`Layout.px.row_h`), so line ends don't move.
- `view.expanded` (`{[pane] = true}`) replaces `view.collapsed`: a live row is open only when its pane is in `expanded`, and the `exp` action toggles that.
- `Store.read` no longer reads `collapsed`, so the next write drops it. Rows folded under 0.4.0 start folded, which is what the user folded them for.

### R4. Pane type
`Details.type(row)` returns the label at the start of each row:
- **agent** (in `cx.agents:list()` or `kind == "agent"`): the base name of `PaneInfo.program`; else the first word of `AgentBlock.command`; else `agent`;
- **terminal** (or no kind): `shell`;
- **file:** `note` when the path starts `note:`, else `file`;
- **browser:** `browser`;
- **anything else:** the kind itself (`git`, `board`, `plugin`, `canvas`…).

Ghost rows have no `PaneInfo`, only the stored kind, so they map it the same way (an agent there reads `agent`). The label is a span `.ob-rtype` before the title: 11 px, `--t3`, `flex: none`.

For agents it reads `<name> · <state>` with the state words of 0.4.0 (working, waiting for input, idle, exited), coloured by the existing state classes (`ob-d-working`, `ob-d-waiting_input`). The state line leaves the details.

### R5. Agent lines with a middle cut
Each agent detail is `el("div", {class = "ob-detail ob-d-msg"})` holding one `text` node:
`{k = "text", p = {spans = {{t = "you: ", s = "strong"}, message}, wrap = "none", truncate = "middle"}}`.
- Tern cuts the middle only when the line overflows. The cut uses the element's real width, so a wide window shows more of both ends, and the full text becomes the tooltip for free.
- The 18 px detail height stays from the layout sheet (`.ob-detail`).
- Messages are no longer cut to 160 characters. `Text.squeeze(s, 1000)` keeps whole messages up to 1000 characters, and longer ones as their first 600 and last 399 joined by "…", so the true end still shows while the view stays small.
- The labels are `you:` and the agent's name from R4 plus `:`. The unread placeholder is `you: …`.
- Terminal, file and other details keep `Text.clip` and the CSS tail cut.

**Alternative:** splitting the text into a shrinking head span and a fixed tail span in CSS. It needs a hand-picked tail length and space handling at the split, where the native `truncate = "middle"` handles both.

### R6. Unselectable controls
`user-select: none` on `.ob-chip` (tag and due chips, the header's tag filters), `.ob-badge`, `.ob-segb`, `.ob-btn` and `.ob-exp`. This is the same property the link bar uses since 0.2.1.

## Risks / Trade-offs

- **Middle cut in the canvas.** The SDK documents `truncate = "middle"` for `text` nodes. That it renders inside our sans-face canvas, within `.ob-detail`, is unproven. → Task 3.2 checks it in a shot. If it fails, fall back to the two-span split (R5 alternative) and record it.
- **Dark-mode fill.** The 5 % light fill may sit close to the dark card colour. → Task 2.2 checks the dark shot and adjusts the alpha if needed.
- **Notes untestable headless.** `cx:open("note:…")` opens nothing there. → The live check covers the `note` label.
- **Agent tests cost a model call.** → Use `omp --no-session --model haiku --max-cost 0.05`, as in archived task 7.x.

## Migration Plan

Release 0.5.0: tag `v0.5.0`, then `tern plugin install … --force` live. `view.collapsed` disappears from `kv.json` on the next write; objectives, links and snapshots are unchanged. Rollback is a reinstall of `v0.4.0`, where every row starts open again (its `collapsed` list is gone).
