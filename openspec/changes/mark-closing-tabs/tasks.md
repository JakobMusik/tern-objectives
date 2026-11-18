# Tasks

Checks run in the headless harness at `/tmp/tobj` unless marked **(live)**.
- **Harness:** `/tmp/tobj/bin/{env.sh,serve,ctl,sync,op,kv,pump}` and the helper plugin `tobjh` are in place from pin-new-objective.
  - Start the serve as a named service (`/tmp/tobj/bin/serve`, ready on "serving"), then run `ctl plugins fixtures`.
  - After each edit, run `/tmp/tobj/bin/sync` and `ctl plugins fixtures` again, then reopen the graph if it closed (`ctl tree '.ob-root'` tells).
  - Never source `/tmp/tobj/bin/env.sh` in a persistent shell, and never run `tern serve --help`, which serves.
- **Layout:** a fresh serve with session docs holding shell tabs named A, B and C (helper ops `new_tab` and `name_tab`), and a second session, ops, holding shell tab D (`new_session`).
- **Stores:** each check writes the objectives its scenario names into `/tmp/tobj/config/plugin-data/objectives/kv.json` (key `"state"`), linked to the tab ids from `op '{"n":"describe"}'`, then closes and opens the graph again.
- **Reading:**
  - `ctl tree '.ob-tab'` for each tab node's classes (`ob-tclosing`) and its chips (`.ob-closechip`, with its tooltip);
  - `ctl tree '.ob-askrow'` and `ctl tree '.ob-undo-text'` for a question's text and tooltip;
  - `ctl click` for real hit-testing;
  - `ctl shot NAME` for a PNG and layout JSON;
  - `op '{"n":"describe"}'` for the tabs the window holds, and kv dumps of `kv.json`;
  - the serve log, `/tmp/tobj/logs/tern-serve.log`, for render times and warnings.
- **After the checks:** stop the harness service, and remove the chat folders the checks created under `~/.omp/agent/sessions/`.

## 1. Marks on the tabs a close question would close

- [x] 1.1 Gather the tabs Close would close, and name them (design D1, D2, D4, D5). All of it goes in `lib/view.luau`:
  - **The `closing` set in `View.build`:**
    - for the bar, filled in `add_node` when it asks;
    - for the notice, filled before the columns, with the header reusing that list;
    - for the header, filled in `add_tab` when `confirm.kind == "done_tabs"`.
  - **`tab_node`:** takes `closing: boolean`, adds `ob-tclosing` and puts the "Closes" chip first in `.ob-tl2`.
  - **`names(list)`:** the three tooltips start with "Close " .. names .. "?". `Acts` carries the bar's names, and `add_tab` gathers the header's labels next to `done_tabs`.

  Verify objectives-graph "Tabs marked while a close asks", every scenario:
  - read the marks with `ctl tree '.ob-tab'` and the tooltips with `ctl tree '.ob-askrow'` or `ctl tree '.ob-undo-text'`. For "The notice expires", run `ctl wait 10500` after marking done, then read the tree;
  - for "Notice question", "Header question" and "Bar question with a tab that stays", also click Close afterwards and check the window with `op '{"n":"describe"}'`. It must hold exactly the tabs that showed no chip, and the kv dump must show the links unchanged;
  - re-run "Closing a done objective's tabs" ("Close two, keep one", "Cancelled"), "Closing tabs from the done notice" ("Offered after marking done", "Cancel keeps Undo"), "Closing tabs of done objectives" ("Button shows", "Closed after asking", "Cancelled") and "Inline confirmation" ("Asked in the bar", "Another click cancels"). They must still pass unchanged, with no "Closes" chip anywhere once each question has ended;
  - check that a tab's own trash icon question, "Close tab?", marks no tab node.

  Result (harness, 2026-11-18, Tern 0.9.27). The setup was a fresh serve: session docs held shell tabs A (3), B (5) and C (7), and session ops held D (10). A and B were made again after each Close, which gave them new ids.

  The helper is named `quote_list`, not `names`: `tab_mark` already has a local called `names`. The tabs a window holds were read with `op '{"name":"sessions"}'`, since the helper has no `describe` op for tabs. `ctl wait 10500` returned at once and fired no timer, so "The notice expires" waited 11.5 s in real time and then ran `/tmp/tobj/bin/pump 2`. The headless serve only runs timers when the window has activity.

  The marks are listed as ring/chip for each tab; "-" means none.
  - **Header question:** before the click, every tab read -/-. While asking, A read ring/Closes and B, C and D read -/-. The tooltip of `.ob-ask-head .ob-undo-text` read "Close “A”? Closing ends their programs; omp chats come back with Resume. No link changes." After Close, the window held B and C in docs and D in ops, the kv dump still linked X to A, and the header had no "done tab" button.
  - **Bar question with a tab that stays:** A and B read ring/Closes, and C and D read -/-. The `.ob-askrow` showed "Close 2 tabs? · 1 stays open", with the tooltip "Close “A” and “B”? 1 tab linked to an open objective stays open. Closing ends their programs; omp chats come back with Resume." After Close, docs held only C, and the kv dump kept X linked to all three tabs. A and B then showed as closed ghosts, with no marks.
  - **Notice question:** clicking X's done box gave "Marked done “X” ·", "Undo", "·", "Close 2 tabs". While asking, A and B read ring/Closes, and the tooltip read "Close “A” and “B”? Closing ends their programs; omp chats come back with Resume." After Cancel, there were no marks and the same four notice parts. After Close, in a second run, docs held only C, and the kv dump kept X done and linked to A and B.
  - **Another click ends the marks:** clicking empty space while the header asked left every tab at -/-, the button read "Close 1 done tab", and A was still open.
  - **The notice expires:** A and B read ring/Closes while asking. After the timer, the notice was gone, every tab read -/-, and docs still held C, A and B.
  - **A tab the graph doesn't show:** with "This session" on, A read ring/Closes, D's node wasn't drawn, and the tooltip read "Close “A” and “D”? …".
  - **Three or more names:** A, B and C read ring/Closes, and the tooltip read "Close “A”, “B” and “C”? …".
  - **Unchanged:**
    - "Close two, keep one" and "Cancelled" for the bar. After Cancel, the bar read Note, Tags and "Close 2 tabs", and the objectives in `kv.json` were byte-for-byte the same.
    - "Offered after marking done" and "Cancel keeps Undo". After Undo, X was open and A and B were still in docs.
    - "Button shows", "Closed after asking" and "Cancelled" for the header.
    - "Asked in the bar", with no picker (`ctl state`). "Another click cancels": after clicking empty space, selecting X again showed "Close 2 tabs".

    No "Closes" chip was left once any question had ended.
  - **Trash icon:** B's header read "Close tab?", "Cancel", "Close", and every tab read -/-.
- [x] 1.2 The look and the README (design D3, D4):
  - in `styles.css`, `.ob-tab.ob-tclosing` (a 2 px `--bad` outline, offset 1 px; -2 px after design D3's fallback, below) and `.ob-closechip` (bold `--bad` text on a 12% `--bad` tint);
  - in the README's "Finish cleanly" item, say that while one of these questions asks, the tabs it would close are marked with a red ring and **Closes**, and its tooltip names them.

  Verify, with "Bar question with a tab that stays" asking and with C the graph's origin tab, so it carries the origin ring:
  - a shot at 1400 px (`ctl resize 1400 900`): crops of A and C. A shows the red ring and the "Closes" chip before "docs · tab n". C shows its origin ring with no red ring and no chip. The layout JSON shows every tab node at the same height as before the question;
  - a shot with tab A selected (`tsel`) before asking: the accent ring stays visible inside the red one;
  - shots at 760 and 460 px: record whether the ring is whole on every side and whether the chip is whole. Any cut must take the "where" text first. If the ring is cut, apply design D3's fallback and record it;
  - shots in light and dark (`ctl appearance light`, `ctl appearance dark`), showing the ring and the chip's tint;
  - render times in the serve log stay within the 20 ms target.

  Result (harness, as task 1.1). The setup was "Bar question with a tab that stays", with C the origin tab: pane 6 was focused before opening the graph.
  - **1400 px, light, offset 1 px:**
    - A and B had the red ring outside their dashed border, and "Closes" before "docs · tab 2" and "docs · tab 3".
    - C kept its origin ring, with no red ring and no chip.
    - Every tab node's box in `ctl tree '.ob-tab'` was the same before and during the question; A was 594 × 92 in both.
  - **Selected A:** after a click on A's header, then "Close 2 tabs", A's classes were `ob-tsel ob-tclosing`. A zoomed crop showed the selected ring's solid accent line between the red ring and the dashed border.
  - **760 and 460 px, offset 1 px:** the ring was cut on the right of every marked node. Those nodes end at the edge of `.ob-root`, at x = 701.7 and x = 419.7, which is as far as the canvas draws once the graph fills the window. The chip was whole at both widths, 48 px wide, followed by the whole "docs · tab 2".
  - **Fallback applied (design D3, updated):** `outline-offset: -2px` puts the ring over the border.
    - At 1400, 760 and 460 px, the ring was whole on all four sides of A and B, and the chip was whole.
    - A selected A still showed its outer accent ring on the left, top and bottom. Its right side is cut at those widths, as it was before this change.
    - With X linking only C, the origin tab, C read ring/Closes. The red ring covered its origin ring, and its pane row kept the accent bar.
  - **Light and dark:** in light, a muted red ring and a chip with red text on a pale red tint. In dark, a bright red ring and a chip with bright red text on a dark red tint. Both are legible.
  - **README:** the "Finish cleanly" item says that while either question asks, each tab it would close shows a red ring and **Closes**, and the tooltip names them all.
  - **Render times:** 90 renders, the longest 3.6 ms. The only warning was the helper plugin's Esc probe, as before.

## 2. Release 0.31.0

- [x] 2.1 Version `0.31.0` in `plugin.toml`. Verify that an isolated `tern plugin install` of the repo folder prints `installed objectives 0.31.0`. Tick this box, then commit, push `main` and tag `v0.31.0` (annotated, message "objectives 0.31.0").

  Result: the install into `/tmp/tobj-inst310/config` printed `installed objectives 0.31.0 → /tmp/tobj-inst310/config/plugins/objectives`.
- [ ] 2.2 **(live)** After the push has finished, run `tern plugin install github.com/JakobMusik/tern-objectives --force` from a shell with no harness variables.

  Verify `tern plugin list` shows `objectives 0.31.0 … ready`, with the other plugins untouched.
- [ ] 2.3 **(live)** With the user:
  - "Close n done tabs" in the header, then the question: the tabs it would close show a red ring and "Closes", and its tooltip names them;
  - a done objective's "Close n tabs", in its button row and in the "Marked done" notice: only the tabs that close are marked, and not the ones an open objective keeps open;
  - Cancel, or a click elsewhere, removes the marks.

  Record the result here.

## Workflow follow-up

- Archive the change (`openspec archive mark-closing-tabs --yes`), run `openspec validate --specs --strict`, commit and push.
