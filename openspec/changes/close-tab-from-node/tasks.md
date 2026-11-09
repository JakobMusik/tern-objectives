# Tasks

Checks run in the headless harness at `/tmp/tobj` unless marked **(live)**.
- **Harness setup:**
  - Start the serve as a named service (`/tmp/tobj/bin/serve`, ready on "serving"), then run `ctl plugins fixtures`.
  - After each edit, run `/tmp/tobj/bin/sync` and `ctl plugins fixtures` again, then reopen the graph if it closed (`ctl tree '.ob-root'` tells).
  - Never source `/tmp/tobj/bin/env.sh` in a persistent shell.
- **Layout:**
  - session "web": tab "App build", with a shell and an omp chat that has replied, and tab "Components", which no objective links;
  - session "misc": tab "Scratch";
  - session "docs": one tab, "Guides".
- **Store:**
  - open "Fix login bug" links App build and Scratch;
  - done "Set up CI" links Guides;
  - a closed tab and an other-window tab come from snapshots, the second with another window key.

  The store goes in through `/tmp/tobj/config/plugin-data/objectives/kv.json` (key `"state"`), then the graph is closed and opened again.
- **Reading:**
  - `ctl hover <selector>`, then `ctl shot NAME` for a PNG and layout JSON;
  - `ctl tree '.ob-tab'` for node classes and texts;
  - `ctl state` for the window's tabs, sessions and focus;
  - the serve log for toasts.
- **After the checks:** stop the harness service, and remove the omp chat folders the run created under `~/.omp/agent/sessions/`.

## 1. Closing a tab from its node

- [x] 1.1 Probe D6 before coding, in a throwaway copy of the plugin in the fixtures folder, not in the repo. With 0.22.0's code:
  - open the graph over "Guides", the only tab of "docs", which only the done "Set up CI" links;
  - close it with "Close 1 done tab".

  Record:
  - whether an error toast shows;
  - whether the graph comes back;
  - what `cx.session:sessions()` lists for the current session right after the closes, through a log line in the copy.

  Then keep D6 or drop it, and update design.md and the "Last tab of its session" scenario if what Tern does differs from them. Remove the copy.

  Result (harness, today 2026-11-09). A fresh serve started in `/tmp/tobj/w/web`, with:
  - "web" (id 1): App build 3 (pane 2 shell, pane 4 omp in `w/ompclose`) and Components 7 (pane 6);
  - "misc" (id 8): Scratch 10 (pane 9);
  - "docs" (id 11): Guides 13 (pane 12).

  The store held open o1 "Fix login bug" → App build and Scratch, and open o3 "Read old notes" → closed tab 50 and other-window tab 60, both from snapshots. It also held done o2 "Set up CI" → Guides. The copy logged each session and the graph's pane right after the closes.
  - Opened from pane 12, the header showed "Close 1 done tab". Close then closed Guides.
  - **Log:** "docs current=true tabs=0" and "graph=nil" right after the closes, so the tab list is current within the same call.
  - **Error toast:** none.
  - **The graph came back,** but in a new tab of its own: tab 16, "Objectives", whose only pane (15) was the graph.
  - **⌃⌘O there** didn't close it. It opened the graph again in another new tab (18, pane 17), which was then closed by hand.

  D6 stays, as design.md now records. The scenario's THEN now also says that "docs" has no tab and that no tab holds the graph. The next sync replaces the copy with the repo's code.

- [x] 1.2 The icon, the question and the close (design D1–D6):
  - `tab_node` and `add_tab` in `lib/view.luau`;
  - `tclose`, `cfm` for a `tab` question, `close_tab` and the `close_tabs` toast change in `lib/app.luau`;
  - `.ob-tclose` hidden until `.ob-tab:hover`, `.ob-th1-ask` and its two buttons in `styles.css`;
  - the README's "Finish cleanly" bullet: "Point at a tab to show its trash icon, which closes that one tab after asking right there."

  Verify with `ctl hover`, `ctl click`, shots, `ctl tree`, `ctl state` and kv dumps:
  - objectives-graph "Closing a tab from its node", every scenario:
    - "Icon while pointing": a shot after `ctl hover` on App build's node, with the icon's rect from the layout JSON at least 22 × 18 px;
    - "No icon on ghosts": hover each ghost and take a shot, and check `ctl tree` holds no `.ob-tclose` in either;
    - "Asked in the header": every `.ob-obj` and `.ob-tab` rect, and the edge sheet, unchanged from before the click;
    - "Closed after asking" and "Chat ready to resume" on App build;
    - "Unlinked tab" on Components;
    - "Cancelled", "Header clicked while asking" and "Another click ends the question", each with a kv dump compared before and after;
    - "The graph's own tab" on Scratch, opened from Scratch;
    - "Last tab of its session" on Guides;
    - "Narrow graph" after `ctl resize 460 700`;
  - tab-navigation "Jump to a tab": "Trash icon doesn't jump", with "misc" shown, and "Tab in another session" still holds;
  - "Closing a done objective's tabs" "Close two, keep one" and "Closing tabs of done objectives" "Closed after asking" still toast as before;
  - "Direct controls don't select text": a drag across Cancel and Close leaves no highlight in the shot;
  - "Light and dark themes": crops of the icon, hovered and not, and of the question under `ctl appearance light` and `ctl appearance dark`;
  - render times in `/tmp/tobj/logs/tern-serve.log`, with no objectives warnings or errors;
  - the README bullet, read back.

  Result (harness, today 2026-11-09). Same serve and layout as 1.1. "docs" got Guides back as tab 20 (pane 19), which done o2 then linked. The omp chat in pane 4 had answered "OK" and was saved under pane 4 in the store. Opened from Scratch (pane 9) unless said otherwise.
  - **Icon while pointing:** `ctl tree` showed `.ob-tclose` on the four live tabs only, each 22 × 18 px. In shot `ct_hover3`, hovering App build's row, App build's icon had opacity 1 and the three others 0. The crop shows the trash icon at the right end of App build's label line only.
  - **No icon on ghosts:** with closed tab 50, then other-window tab 60 hovered, every `.ob-tclose` had opacity 0, none sat inside either ghost, and the crop shows no icon.
  - **Asked in the header:** a click on Components' icon turned its line into "Close tab?", Cancel and Close, with no field or picker. Close's right edge was 1181.5, as the icon's had been. Every `.ob-obj`, `.ob-tab` and `.ob-e` rect and class was unchanged, as was `kv.json`, and the window still held Components.
  - **Tooltips:** for unlinked Components the question's tooltip reads "Closing ends its programs. No objective links it, so it won't show under Closed tabs."; for linked Guides it reads "Closing ends its programs; omp chats come back with Resume."
  - **Cancelled, Header clicked while asking, Another click ends the question:** Cancel, a click on the question's text, and a click on the gap each brought the label back. Components stayed open, and `kv.json` was byte for byte unchanged. After the click on the text, the graph was still shown, focus was still on the graph (pane 21) and Scratch was still the active tab.
  - **Trash icon doesn't jump:** with "misc" shown, a click on App build's icon left "misc" current, kept focus on pane 21, and made App build's header ask. **Tab in another session:** after Cancel, a click on App build's header showed "web" with App build active and focused pane 4.
  - **Narrow graph:** at `ctl resize 460 700`, App build's node was 142.7 px wide. Cancel (306.0–358.7) and Close (364.7–410.8) sat inside it (277.0–419.8), and the question was cut to "…".
  - **Light and dark themes:** `/tmp/tobj/shots/ct_themes.png` shows App build's icon and Components asking, both readable in each appearance. Hovered, the icon turns red on a pale red square (`ct_iconhover_crop.png`).
  - **Direct controls don't select text:** a press beside "Close tab?", dragged right past Close, left the line's pixels unchanged mid-drag (no diff in the crop). The release ended the question and opened nothing.
  - **Closed after asking, Chat ready to resume:** Close on App build toasted "Closed “App build”", and the window no longer held tab 3. App build showed under "Closed tabs" with Resume and its rows "shell" and "omp", o1 still linked 3 and 10, and the graph stayed shown.
  - **The graph's own tab:** a tab "Notes" (26) was added to "misc", and the graph was opened from Scratch. Close on Scratch toasted "Closed “Scratch”". The graph came back over Notes as pane 30, beside Notes' shell, and no tab held only the graph. Scratch showed under "Closed tabs".
  - **Unlinked tab:** Close on Components, then the only tab of "web", toasted "Closed “Components”". No node or snapshot for tab 7 remained, the graph stayed over Notes, and "web" was left with no tab.
  - **Last tab of its session:** opened from Guides, the only tab of "docs", Close toasted "Closed “Guides”" and no error. "docs" was listed with no tab, the window held only Notes' pane 25, and no pane held the graph.
  - **Regressions:** with o2 linking two new tabs, "Close 2 done tabs" then Close toasted "Closed 2 tabs that only done objectives link". With o2 linking one new tab, o2's bar showed "Close 1 tab" and asked "Close 1 tab?", and Close toasted "Closed 1 tab of “Set up CI”". Both closed their tabs. The kept-tab count of "Close two, keep one" wasn't exercised: its code is unchanged.
  - **Log:** 52 renders and no objectives warnings or errors. The longest render, 16.7 ms (build 2.0, hand-over 14.8), was a fresh open by ⌃⌘O; every other render took 6.2 ms or less.
  - **README:** the "Finish cleanly" bullet now has "Point at a tab to show its trash icon, which closes that one tab after asking right there."
  - **Cleanup:** the harness serve was stopped, and this run's chat folder `--private-tmp-tobj-w-ompclose--` was removed.

## 2. Release 0.23.0

- [x] 2.1 Version `0.23.0` in `plugin.toml`. Verify that an isolated `tern plugin install` of the repo folder prints `installed objectives 0.23.0`. Tick this box, then commit, push `main` and tag `v0.23.0` (annotated, message "objectives 0.23.0").

  Result: the install into `/tmp/tobj-inst230/config` printed `installed objectives 0.23.0 → /tmp/tobj-inst230/config/plugins/objectives`.
- [ ] 2.2 **(live)** After the push has finished, run `tern plugin install github.com/JakobMusik/tern-objectives --force` from a shell with no harness variables.

  Verify `tern plugin list` shows `objectives 0.23.0 … ready`, with the other plugins untouched.
- [ ] 2.3 **(live)** With the user:
  - pointing at a tab node shows the trash icon, and only on that node;
  - clicking it asks "Close tab?" in the header, and Cancel leaves the tab open;
  - Close closes the tab: a linked one shows under "Closed tabs" with Resume for its omp chats.

  Record the result here.

## Workflow follow-up

- Archive the change (`openspec archive close-tab-from-node --yes`), run `openspec validate --specs --strict`, commit and push.
