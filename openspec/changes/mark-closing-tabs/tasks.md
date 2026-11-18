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

- [ ] 1.1 Gather the tabs Close would close, and name them (design D1, D2, D4, D5). All of it goes in `lib/view.luau`:
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
- [ ] 1.2 The look and the README (design D3, D4):
  - in `styles.css`, `.ob-tab.ob-tclosing` (a 2 px `--bad` outline, offset 1 px) and `.ob-closechip` (bold `--bad` text on a 12% `--bad` tint);
  - in the README's "Finish cleanly" item, say that while one of these questions asks, the tabs it would close are marked with a red ring and **Closes**, and its tooltip names them.

  Verify, with "Bar question with a tab that stays" asking and with C the graph's origin tab, so it carries the origin ring:
  - a shot at 1400 px (`ctl resize 1400 900`): crops of A and C. A shows the red ring and the "Closes" chip before "docs · tab n". C shows its origin ring with no red ring and no chip. The layout JSON shows every tab node at the same height as before the question;
  - a shot with tab A selected (`tsel`) before asking: the accent ring stays visible inside the red one;
  - shots at 760 and 460 px: record whether the ring is whole on every side and whether the chip is whole. Any cut must take the "where" text first. If the ring is cut, apply design D3's fallback and record it;
  - shots in light and dark (`ctl appearance light`, `ctl appearance dark`), showing the ring and the chip's tint;
  - render times in the serve log stay within the 20 ms target.

## 2. Release 0.31.0

- [ ] 2.1 Version `0.31.0` in `plugin.toml`. Verify that an isolated `tern plugin install` of the repo folder prints `installed objectives 0.31.0`. Tick this box, then commit, push `main` and tag `v0.31.0` (annotated, message "objectives 0.31.0").
- [ ] 2.2 **(live)** After the push has finished, run `tern plugin install github.com/JakobMusik/tern-objectives --force` from a shell with no harness variables.

  Verify `tern plugin list` shows `objectives 0.31.0 … ready`, with the other plugins untouched.
- [ ] 2.3 **(live)** With the user:
  - "Close n done tabs" in the header, then the question: the tabs it would close show a red ring and "Closes", and its tooltip names them;
  - a done objective's "Close n tabs", in its button row and in the "Marked done" notice: only the tabs that close are marked, and not the ones an open objective keeps open;
  - Cancel, or a click elsewhere, removes the marks.

  Record the result here.

## Workflow follow-up

- Archive the change (`openspec archive mark-closing-tabs --yes`), run `openspec validate --specs --strict`, commit and push.
