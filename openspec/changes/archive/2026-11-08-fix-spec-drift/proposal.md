# Proposal

## Why

A read-only review of the OpenSpec documents on 2026-11-07 (after the history rewrite) found the specs valid but not fully correct. Several requirements disagree with the code or with each other, a few user-visible behaviours have no requirement, and one code bug leaves the graph empty with no way back.

Settled with the user on 2026-11-07:
- Resume keeps handing a closed tab's links to the new tab, done objectives' links included. The specs get one stated exception rather than a code change: the done objective follows its work to the reopened tab.
- Everything lands in one change, released as 0.14.1. The archived records get a separate docs commit.

## What Changes

1. **Code fixes:**
   - **Stale tag filter:** when the filtered tag disappears (its last objective loses it or is deleted), the filter is dropped. Today every objective stays hidden behind "No objectives match this filter." and no chip is left to clear it.
   - **"you: …" for other agents:** the waiting line shows only for omp agents. Other agents briefly showed it before the first transcript read found nothing.
   - **"Link this tab" order:** the picker uses the graph's own sort, which breaks ties by id. Two objectives created in the same second could come out in a different order.
2. **Specs aligned with the code:**
   - "Done objectives' links are fixed" names Resume as the one exception.
   - Closed and other-window tabs ("ghosts") are described as they are drawn: faint dashed border, no fill, half strength, struck-through label when closed, and a "closed · " or "other window · " prefix.
   - The "Other tabs" divider shows only when another tab follows it.
   - A new objective has no links unless it is created for a tab.
   - Undo's notice and review mode survive the graph being shown again after one of its pickers closed it.
3. **Specs for uncovered behaviour:**
   - the order inside "Closed tabs" and "Other windows";
   - the "No objectives match this filter." hint;
   - the tab menu's "Link to" heading;
   - closing a done objective's tabs while the graph sits in one of them;
   - Resume's case-insensitive session-name match.
4. **Wording:**
   - a scenario that couldn't happen ("Parked focus") and a mistitled one ("Rename hidden without a selection");
   - "Link lines" covers only shown objectives;
   - "saved session" becomes "saved omp chat";
   - a dangling "Neither";
   - a leftover CUDA example in pane-details;
   - two Purposes (objectives-graph, objective-store);
   - `openspec/config.yaml`'s observability rule makes room for plugin-package's repository checks.
5. **README:**
   - the done-objective and ghost-tab passages match the specs;
   - the known limit about Prune reflects that done objectives keep their links.
6. Release 0.14.1.

Out of scope:
- Corrections to archived change records (dead commit hashes, rename leftovers, wrong cross-references): a separate docs commit.
- A Resume scenario for a session on another machine: the headless Tern has no remote host, so it can't be observed.
- Any other change to Resume, done objectives, or the graph's look.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `objectives-graph`:
  - Empty state, Tab node content, Unlinked tabs look different, Link lines, Tag filter, Closing a done objective's tabs and Linked tabs section are modified;
  - Closed-tab order and Ghost tabs look different are new;
  - the Purpose is updated.
- `tab-links`: Focused pane without a tab, Link menu on tab nodes and Done objectives' links are fixed.
- `objective-store`: Objective record and Final done state; Purpose.
- `objective-review`: Leaving review mode and Undo after done or remove.
- `agent-resume`: Saved sessions follow their tabs and Where a chat resumes.
- `pane-details`: Agent last user message.
- `plugin-package`: Palette commands.

## Impact

- `lib/view.luau` (or `lib/app.luau`): drop a filter on a tag no objective holds; export the open-objective sort.
- `lib/app.luau`: "Link this tab" uses that sort.
- `lib/details.luau`: the "you: …" placeholder only for omp agents.
- `openspec/specs/*`: the deltas above and two Purposes.
- `openspec/config.yaml`: the observability rule.
- `README.md`, `plugin.toml` (0.14.1).
