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

- [ ] 1.1 Probe D6 before coding, in a throwaway copy of the plugin in the fixtures folder, not in the repo. With 0.22.0's code:
  - open the graph over "Guides", the only tab of "docs", which only the done "Set up CI" links;
  - close it with "Close 1 done tab".

  Record:
  - whether an error toast shows;
  - whether the graph comes back;
  - what `cx.session:sessions()` lists for the current session right after the closes, through a log line in the copy.

  Then keep D6 or drop it, and update design.md and the "Last tab of its session" scenario if what Tern does differs from them. Remove the copy.

- [ ] 1.2 The icon, the question and the close (design D1–D6):
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

## 2. Release 0.23.0

- [ ] 2.1 Version `0.23.0` in `plugin.toml`. Verify that an isolated `tern plugin install` of the repo folder prints `installed objectives 0.23.0`. Tick this box, then commit, push `main` and tag `v0.23.0` (annotated, message "objectives 0.23.0").
- [ ] 2.2 **(live)** After the push has finished, run `tern plugin install github.com/JakobMusik/tern-objectives --force` from a shell with no harness variables.

  Verify `tern plugin list` shows `objectives 0.23.0 … ready`, with the other plugins untouched.
- [ ] 2.3 **(live)** With the user:
  - pointing at a tab node shows the trash icon, and only on that node;
  - clicking it asks "Close tab?" in the header, and Cancel leaves the tab open;
  - Close closes the tab: a linked one shows under "Closed tabs" with Resume for its omp chats.

  Record the result here.

## Workflow follow-up

- Archive the change (`openspec archive close-tab-from-node --yes`), run `openspec validate --specs --strict`, commit and push.
