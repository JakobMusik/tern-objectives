# Proposal

## Why

Asked by the user on 2026-11-09. An objective's node shows the omp chats in its linked tabs only when they need the user: "needs you" while one waits for input, "replied" while a reply is unseen. While a chat works on a turn the node shows nothing, so the graph can't tell an objective that is moving from one that sits untouched.

## What Changes

1. **A third mark, "working".** An objective node is marked "working" while an omp chat in a live tab of this window that it links is working on a turn. It shows a "working" chip first on its second line, in the accent colour, which pane rows already use for "omp · working". It has **no ring**: the user chose a chip alone, since it doesn't need them, and an accent ring would look like the selection ring.
2. **The strongest mark only.** "needs you" wins over "replied", which wins over "working". The user chose one mark over showing "working" beside the others.
3. **Like the other marks:** omp chats only, live tabs of this window only, on open, done and review nodes, and the chip's tooltip names the tabs ("omp is working in “Server”"). It goes when the chat stops working: a finished reply the user hasn't seen turns it into "replied".
4. **README:** the "See what needs you" bullet mentions "working".
5. **Release 0.20.0**, a minor release because behaviour changes.

Out of scope:
- Other agents (Claude) working: the marks stay omp-only, as the request names omp.
- A ring, an animation or a count of working chats.
- Retaking `docs/graph.png` and `docs/review.png`: their demo chats wait for input or have replied, and none is working, so they still show this version's nodes.
- Marks on tab nodes: pane rows already read "omp · working".

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `objectives-graph`: "Attention marks" gains the "working" mark, weakest of the three, with a chip and no ring.

## Impact

- `lib/details.luau`: `attention(row)` also returns "working".
- `lib/view.luau`: the per-tab and per-objective strongest mark ranks three kinds; the "working" chip and its tooltip; no ring class for it.
- `styles.css`: the "working" chip's colours.
- `README.md`: the Features bullet.
- `openspec/specs/objectives-graph/spec.md`: the delta above.
- `plugin.toml`: version 0.20.0.
- Stored data: none.
