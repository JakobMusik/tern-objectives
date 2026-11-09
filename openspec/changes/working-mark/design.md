# Design

## Context

See proposal.md for the request and the user's two choices: a chip with no ring, and the strongest mark only. The current code (attention-marks-and-titles D3):

- **`Details.attention(row)`** (`lib/details.luau:120–135`) returns "wait" for an omp agent in `waiting_input`, "replied" for one `idle` with its pane's unseen alert set, else nil. Other agents return nil.
- **`View.build`** (`lib/view.luau:545–586`): `call_of(tab)` takes each live tab's strongest call over its rows, "wait" above "replied", once per tab. `mark_of(o)` collects the tab labels per call over the objective's links and returns `{ kind, tabs }` for the strongest. Closed and elsewhere tabs are not in `win.tabs`, so they never mark.
- **`objective_node`** (`lib/view.luau:231–246`) adds `ob-att-<kind>` to the node, which draws the ring, and puts `span.ob-chip.ob-attchip.ob-attchip-<kind>` first on line 2, its text from `MARK_CHIP` and its tooltip from `MARK_TIP` plus the quoted labels.
- **CSS** (`styles.css:130–140`, 184–201): `.ob-attchip` is bold white text, and `-wait` and `-replied` give it a `--warn` or `--ok` fill. The rings are rules on `.ob-obj.ob-att-wait` and `.ob-obj.ob-att-replied`, with and without `.ob-sel`.
- **Accent text:** pane rows colour "omp · working" with `var(--accent)` (`.ob-d-working`, `styles.css:757`), and the "review due" chip is accent text on a 12 % accent fill (`styles.css:126–129`).
- **Refresh:** the `agent_state` handler in `window.luau` requests a render, and the 750 ms poll's signature holds each agent's state (`lib/refresh.luau:38–47`). A turn's start and end already redraw the graph.

### Source record

The SDK line numbers below refer to `/tmp/ternsdk/book.txt`, the text of `https://docs.stencil.so/tern/print.html` fetched 2026-11-09.

| Claim | Evidence |
|---|---|
| `cx.agents:list()` rows carry `state`, one of `working`, `waiting_input`, `idle`, `exited` | SDK "Agent cx" (L37063–37065) and the `agent_state` event (L38841–38846) |
| Tern samples agent states at most every 250 ms, and a change that reverts within one look fires nothing | SDK `agent_state` (L38846–38850) |
| Sending a message to an omp chat fires `agent_state` idle → working | resume-closed-agents, task 1.1: the helper's event log held `{pane 8, old idle, new working}` |
| A short turn may fire no `working` event while the harness clock stands still | resume-closed-agents, task 2.2 |
| `.ob-attchip-<kind>` rules come after `.ob-attchip` with the same specificity, so a later colour wins | `styles.css:131–140`: `-wait` and `-replied` already set the fill this way |

## Goals / Non-Goals

**Goals:**
- One more value from `Details.attention`, ranked through the existing per-tab and per-objective pass.
- The chip reuses the attention chip's place, tooltip and markup.

**Non-Goals:**
- Any change to "needs you", "replied", their rings, or when they clear.
- Marks from other agents, or on tab nodes.

## Decisions

### D1. "working" from the agent state
`Details.attention(row)` also returns "working" when the omp agent's `state` is `working`. The checks stay in order, so a row is "wait", "replied", "working" or nil. The comment and the `Ui.attention` type comment in `lib/view.luau` list the three values.

Alternative: count a turn from `agent_state` events in the plugin. Rejected: `cx.agents:list()` already gives the state each render reads, and the poll covers a missed event.

### D2. Ranking
- `RANK = { wait = 3, replied = 2, working = 1 }` in `lib/view.luau`.
- `call_of(tab)` keeps the row call with the highest rank and stops early at "wait". An empty call ranks 0.
- `mark_of(o)` gathers the tab labels for each kind in one map and returns the highest-ranked kind that has tabs. A tab counts under its own strongest call only, so a tab with one waiting chat and one working chat names that tab under "needs you" and nowhere else.

### D3. Chip, no ring
- **Node:** `ob-att-<kind>` is added for "wait" and "replied" only, so no ring rule can match a working node. A selected working node keeps the plain selection ring.
- **Chip:** the same `span.ob-chip.ob-attchip.ob-attchip-working` first on line 2. `MARK_CHIP.working = "working"`, and `MARK_TIP.working = "omp is working in "`, so the tooltip reads `omp is working in “Server”`, several tabs joined as now.
- **CSS:** `.ob-attchip-working`, after the other two, sets `color: var(--accent)` and `background: rgb(from var(--accent) r g b / 12%)`: accent text on a tint, like "omp · working" in pane rows and quieter than the solid "needs you" and "replied". `.ob-attchip` keeps it bold.
- **Rejected:** a dashed accent ring (the user's choice: it reads as the selection ring); a solid accent chip, as loud as the two that need the user.

### D4. README
The "See what needs you" bullet adds one clause: a linked omp chat at work shows a **working** chip, with no ring.

### D5. Release
0.20.0, a minor release: behaviour changes.

## Risks / Trade-offs

- [A turn shorter than Tern's sampling never shows "working"] → it needs no mark: the turn is over before the user could look. A turn's end still sets "replied" as now.
- [The "working" chip and a done objective's "review due" chip share their colours] → the texts differ, and "working" is bold and first on the line. Task 1.1 checks a done node with both.
- [Many chats at work turn many nodes blue-tinted] → no ring and a small chip keep it quiet, which is why the user chose it.
- [Light and dark appearances] → the chip uses the theme's accent like the "review due" chip, which both appearances already show. Task 1.1 checks shots in both.

## Migration Plan

None: nothing is stored. To roll back, reinstall 0.19.0.
