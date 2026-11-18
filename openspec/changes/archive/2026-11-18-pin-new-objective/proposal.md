# Proposal

## Why

The user asked on 2026-11-18 that a newly created objective be put at the top of the objective list for a while, so it is easy to see and its buttons and links are at hand. Today "＋ New objective" and ⌥N select the new objective, but sorted by priority, the default, a new P3 objective lands below every P0–P2 one, often far down the list.

The user chose on 2026-11-18:
- **How long:** while it stays selected. Its own controls, the tabs' link bars and selecting a tab keep it on top. Selecting another objective, clearing the selection, lifting a grip or closing the graph ends it.
- **Which ways of creating:** "＋ New objective" and ⌥N only, the two that already select it in the graph.
- **Under a tag filter:** it shows at the top anyway while it is on top. A new objective has no tags, so today a tag filter hides it.
- **Marker:** a small "New" chip after its title while it is on top.

## What Changes

1. **A new objective is listed first.** Right after "＋ New objective" or ⌥N creates it, it is the first open objective, whatever the sort method: Priority, Your order with new objectives at the bottom, or Newest, where it is first anyway. The tab menu and the "Link this tab…" picker list it first too, as they follow the left column's order.
2. **While it stays selected.** Clicks that keep the selection keep it first: its badge, Note, Due, Tags, its title, its link button, the tabs' link bars, selecting a tab, the sort buttons, the filters and the Done group's fold. It goes to its sorted place when:
   - another objective is selected, or the selection is cleared (empty graph space, its node again, a search);
   - a grip lifts a node;
   - it is marked done or removed;
   - the graph opens fresh.
   Nothing is stored: the stored order is the one Configure's place gives it, as today, and other windows list it at its sorted place.
3. **A "New" chip** ends its title's last line, after the creation time, while it is first.
4. **Tag filter:** while it is first, a tag filter doesn't hide it. The search and "This session" already keep the selected objective in view.
5. **"＋ New objective" ends review mode first**, as ⌥N does. Today the button leaves review mode on, so the new objective isn't shown, which would defeat item 1. This is an assumption: the user didn't ask for it, but the feature needs the objective in view.
6. **README:** the order paragraph says a new objective stays first, with a "New" chip, while selected; the review-mode paragraph says "＋ New objective" leaves review mode too. The screenshots show no new objective and stay as they are.
7. **Release 0.30.0**, a minor release for the new behaviour.

Out of scope:
- **"Objectives: New objective for this tab…"** from the palette: it doesn't select the objective, and stays as it is.
- **A time limit,** or keeping it first after it is deselected.
- **Stored state:** the pin isn't written to `kv.json` and doesn't survive a fresh open or a reload.
- **The Done group and review mode's lists:** a new objective is open, and neither lists it.
- **Other filters:** the scope and search keep the selected objective in view as today; nothing changes there.
- **A setting** to turn it off.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `objectives-graph`:
  - new requirement "New objective listed first": first while selected, whatever the sort method and Configure's place; the "New" chip; what ends it; the tag filter; the tab menu and picker;
  - "New objective button": it ends review mode first, and the new objective is listed first;
  - "Tag filter": the new objective listed first stays shown.

  "Custom order" and "Sorted by priority" keep their text: their descriptions are 497 and 288 characters, and "Custom order" can't take a clause under the 500-character limit. The new requirement states the exception for every sort method, so neither is modified.
- `plugin-settings`:
  - "New objective defaults": its text stays (490 characters), since the place is still where the objective is stored. The two bottom-place scenarios read the list after a click on empty graph space, once the objective is no longer listed first.

## Impact

- **`lib/app.luau`:** a `pinned` id, never stored, set when "＋ New objective" or ⌥N creates an objective, cleared by `build` once the objective isn't selected or open, by a grip's lift and by a fresh open; passed to `View.build` and to `Store.open_in_order` for the "Link this tab…" picker. The `new` verb ends review mode.
- **`lib/store.luau`:** `Store.open_in_order(s, held?, pinned?)` puts the pinned objective first.
- **`lib/view.luau`:** `Ui.pinned`; the tag filter lets it through; the left column and the tab menu pass it on; `objective_node` adds the "New" chip.
- **`styles.css`:** the chip's accent tint.
- **`README.md`**.
- **`plugin.toml`:** version 0.30.0.
- **Stored data:** none.
