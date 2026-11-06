# Proposal

## Why

The user wants to look back over finished objectives on a spaced-repetition schedule, as the obsidian-spaced-repetition plugin schedules notes. Each done objective works as a card whose metadata records its review status.

The user settled the shape in discussion (2026-11-06):
- Review is a mode of the graph, not new content. It lists the done objectives that are due, all at once, as the usual nodes with their links. Hard, Good and Easy buttons only update each objective's review metadata.
- An objective can't be "un-done", which avoids handling an unchecked box.
- A done objective can be removed with one click on an icon on its node.
- A short Undo follows marking done and removing, for mistakes.

## What Changes

1. **Done is final.**
   - Clicking an open objective's box marks it done, as today.
   - A done objective's box does nothing, and its tooltip gives the done date. Reopening is gone.
2. **Undo.**
   - After marking an objective done, or removing one, the header shows "Marked done “<title>” · Undo" or "Removed “<title>” · Undo".
   - It stays until the next click in the graph, the graph closing, or 10 seconds.
   - Undo puts the objective back exactly as it was before the click: its links, place in the list and saved tab rows included.
3. **One-click remove.** Done nodes get a trash icon that removes the objective at once, with the Undo above. ⋯ › Delete still asks first.
4. **Review schedule.**
   - Marking done schedules the first review for the next day, with ease 250%, interval 1 day and no reviews.
   - Objectives done before this version are scheduled the same way from their done date, so they are due at once.
   - Ratings follow obsidian-spaced-repetition's SM-2-OSR with its default settings, without load balancing:
     - Easy raises the ease by 20 and grows the interval by the ease and a 1.3 bonus;
     - Good grows the interval by the ease;
     - Hard lowers the ease by 20, to no less than 130, and halves the interval, to no less than 1 day;
     - days overdue count as obsidian counts them.
5. **Review status on done nodes:** a chip reads "review due" or "review in <n>d". The tooltip adds the review count and the next review date.
6. **Review mode.**
   - The header shows "Review (n)" while n done objectives that pass the scope and tag filters are due.
   - Clicking it lists only those, oldest due first, each with Hard, Good and Easy buttons that show the next interval. Their link lines are drawn, and the open list and the Done group are hidden.
   - A rated objective leaves the list. The mode ends when the list is empty, when the button is clicked again, or when the graph closes.
7. Release as 0.10.0, with the README updated.

Out of scope:
- Undo of a rating: a mis-rated objective comes back at its new date.
- Changing the schedule's settings, an "Again" rating, load balancing and fuzz.
- Keys for review: the canvas gets no keys of its own (rename-and-linked-tabs-first, design D6).
- Review of open objectives, and remembering review mode across opens.
- Text written for the cards. The nodes show only what the objective already holds.
- The heading selection fix (change `unselectable-group-headers`) and agent resume (change `resume-closed-agents`).

## Capabilities

### New Capabilities

- `objective-review`: the review schedule of done objectives, review mode and its ratings, one-click removal and the Undo after marking done or removing.

### Modified Capabilities

- `objective-store`:
  - "Objective record" gains the review schedule;
  - "Done state" is replaced by "Final done state", which drops reopening;
  - "Deleting an objective" allows the trash icon's unconfirmed removal.
- `objectives-graph`:
  - "Done group" is replaced by "Done objectives group", where the box only marks done;
  - "Objective node content": the trash icon, the review chip and the tooltip;
  - "Link lines": also drawn for objectives listed in review mode;
  - "Larger hit areas": the trash icon and review buttons, and taller nodes in review mode.

## Impact

- `lib/store.luau`:
  - the `review` field and its default in `normalize`;
  - marking done, rating, removing, and restoring for Undo.
- New `lib/review.luau`: the scheduling arithmetic.
- `lib/app.luau`: review mode, the Undo notice and its timer, and the new actions.
- `lib/view.luau`, `lib/layout.luau`, `styles.css`: the review button, review nodes, the chip, the trash icon and the Undo notice.
- `README.md`, `plugin.toml` (0.10.0).
- Stored state stays version 1. Older plugins keep the new field but can still reopen a done objective.
