# Tasks

Checks run in the headless harness at `/tmp/tobj` unless marked **(live)**.
- **Harness:** it was under `/tmp` and is gone, so task 1.1 builds it again (add-objectives-plugin D14). After that:
  - start the serve as a named service (`/tmp/tobj/bin/serve`, ready on "serving"), then run `ctl plugins fixtures`;
  - after each edit, run `/tmp/tobj/bin/sync` and `ctl plugins fixtures` again, then reopen the graph if it closed (`ctl tree '.ob-root'` tells);
  - never source `/tmp/tobj/bin/env.sh` in a persistent shell;
  - the headless serve runs plugin timers only while the window has activity, so keep it busy with `/tmp/tobj/bin/pump N` while an omp turn runs.
- **Layout:**
  - session "web": tabs "App build" and "Docs";
  - session "api": tabs "Server" (a shell and an omp pane), "Benchmarks" (a shell) and "Split" (two omp panes side by side).
- **Store** (search checks): open "Fix login bug" (tagged "api", linked to Server), "Write slides" (side note "for the Monday demo", linked to Docs alone), "Login page copy" (tagged "web"); done "Set up CI" and "Restyle the docs site", both due for review today. It goes in through `/tmp/tobj/config/plugin-data/objectives/kv.json` (key `"state"`), then the graph is closed and opened again.
- **Chats** (mark checks), driven through the helper's `run` op while another tab has focus:
  - **working:** "Run `sleep 90` in bash, then reply with exactly: done";
  - **waiting for input:** ask it to put a yes/no question to the user with its ask tool;
  - **unseen reply:** a short turn ("Reply with exactly: ok") that ends while another tab has focus.
- **Reading:**
  - `ctl tree '.ob-obj'`, `ctl tree '.ob-tab'`, `ctl tree '.ob-head'` and `ctl tree '.ob-attchip'` for nodes, classes, texts and tooltips;
  - `ctl state` for fields, pickers and the palette;
  - `ctl shot NAME` for a PNG and layout JSON;
  - `/tmp/tobj/bin/op agents` for each chat's state, and `op keys_all` for the keymap;
  - kv dumps of `kv.json`;
  - the serve log, `/tmp/tobj/logs/tern-serve.log`, for render times and warnings.
- **After the checks:** stop the harness service, and remove the chat folders the checks created.

## 1. Search

- [ ] 1.1 Build the harness again under `/tmp/tobj` (add-objectives-plugin D14):
  - the fixtures copy of the repo's package files;
  - `bin/serve`, `bin/ctl`, `bin/sync` and `bin/pump`;
  - the helper plugin `tobjh` and `bin/op`, with the ops the checks above use: `kv`, `keys_all`, `agents` and `run`.

  Verify that `ctl plugins fixtures` loads `objectives` and `tobjh` with no plugin errors in the serve log, `ctl state` answers, and `op keys_all` lists `ctrl+cmd+o → plugin.objectives.open`.
- [ ] 1.2 The search (design D1–D4):
  - `Store.search_words` and `Store.matches`;
  - the check in `visible`, and `ui_state.search`;
  - the header's Search button and chip, with their CSS;
  - in `lib/app.luau`: the `search` state, its end in a fresh `M.open`, the field (`ask_search`), and the `search` and `unsearch` verbs;
  - README: a paragraph on searching, after the paragraph on selecting.

  Verify:
  - objectives-graph "Search": every scenario, by `ctl tree '.ob-obj'` and `ctl tree '.ob-head'`, with `ctl state` for the field and its value. "Lines of hidden objectives" is checked on a shot: no line ends at the "Docs" header;
  - objectives-graph "Search and other filters": every scenario;
  - objectives-graph "Selection on a fresh open": "Filters kept, search ended", and the other four scenarios still hold;
  - objective-review "Review button": "Search narrows the count", "One due" and "Nothing due";
  - plain text: "Ship v1.2 (beta)" is found by "1.2 (beta" and not by "1x2";
  - case folding (design risk): "Écrire la doc" searched as "écrire" and as "ÉCRIRE". Record which of them find it;
  - a shot of the header with the chip, and one with a 60-character search, its chip cut with "…";
  - the README paragraph, read back;
  - render times in the serve log stay within the 20 ms target, with no objectives warnings or errors.
- [ ] 1.3 The key (design D5):
  - the `search` entry in `Keys.COMMANDS`;
  - the "Objectives: Search…" command in `window.luau`;
  - `App.search_key`;
  - README: the commands table's Search row with ⌥F, and the keys note. Before writing which character Option+F types, check it on the US layout with a throwaway Swift script calling `UCKeyTranslate` on `com.apple.keylayout.US`, as rename-key-shift-option-r did for "‰", then delete the script.

  Verify:
  - `op keys_all` lists `alt+f → plugin.objectives.search`, and the serve log has no `bind left out`;
  - objectives-graph "Search key": every scenario, pressing keys with `ctl key Alt+f`. "Letters still reach the panes" uses `ctl type fF` in the Benchmarks shell;
  - plugin-package "Palette commands": its three scenarios, from the palette's rows in `ctl state`;
  - plugin-settings "Shortcut rows": "Defaults", "Search key changed" and "Rename moved to ⌥⇧R before this version", with `ctl tree` for the rows and `op` for the keybinds. After a Reset on Search, the keybinds equal the starting map;
  - plugin-package "README": `grep` finds the Search row with ⌥F, the keys note and the search paragraph.

## 2. Marks on tab nodes

- [ ] 2.1 The marks (design D6, D7):
  - `tab_mark` in `View.build`, replacing `call_of`, with `Mark.names`;
  - `mark_of` built on it;
  - the tab node's second line as `.ob-tl2`, its chip, and the `ob-tatt-*` classes;
  - the rings in `styles.css`, the origin's included;
  - README: "See what needs you" names tab nodes.

  Verify, with `op agents`, `ctl tree '.ob-tab'`, `ctl tree '.ob-attchip'` and shots:
  - objectives-graph "Tab attention marks": every scenario. "Unlinked tab", "Origin tab marked" and "Question waiting" are also checked on crops;
  - objectives-graph "Attention marks": "Question waiting", "Needs you wins" and "Two chats in one tab" are unchanged, their tooltips still naming tabs;
  - "Light and dark themes": shots under `ctl appearance light` and `ctl appearance dark`, cropped to a "needs you" tab, a "replied" tab, a "working" tab and the marked origin tab;
  - "Link lines", "Alignment at two widths": with a marked tab, at 1400 and 460 px wide, every line end sits within 2 px of its tab header's centre, read from the shots' layout JSON;
  - render times in the serve log stay within the 20 ms target, with no objectives warnings or errors.

## 3. The README screenshot

- [ ] 3.1 Take `docs/graph.png` again (design D8):
  - the demo layout and store rebuilt from the current image: docs (Guides; Release notes, with an omp pane whose reply is unseen), web (App build, split into app and tests; Components, with a shell and `todo.md`), api (Server, with a shell and an omp pane waiting for input; Benchmarks);
  - due dates set so that the chips read as in the current image;
  - the same window size (`ctl resize 1045 928`) and crop (914 × 808);
  - opened from Guides, with nothing selected and the Done group open.

  Update the alt text: Server marked "needs you", Release notes marked "replied", and the header's Search button. Show the draft to the user before committing it.

  Verify:
  - plugin-package "README": "README contents" (a tab node marked "needs you" in the screenshot) and "Graph screenshot first";
  - "Screenshots match this version": open nodes show grips, and no node shows ⋯;
  - every line end sits within 2 px of its node and tab header centres, read from the shot's layout JSON;
  - the user approved the draft.

## 4. Release 0.25.0

- [ ] 4.1 Version `0.25.0` in `plugin.toml`. Verify that an isolated `tern plugin install` of the repo folder prints `installed objectives 0.25.0`. Tick this box, then commit, push `main` and tag `v0.25.0` (annotated, message "objectives 0.25.0").
- [ ] 4.2 **(live)** After the push has finished, run `tern plugin install github.com/JakobMusik/tern-objectives --force` from a shell with no harness variables.

  Verify `tern plugin list` shows `objectives 0.25.0 … ready`, with the other plugins untouched.
- [ ] 4.3 **(live)** With the user:
  - the header's Search button filters the objectives by title, note and tags, the chip's × ends the search, and reopening the graph ends it too;
  - ⌥F in a shell opens the graph with the search field;
  - a tab whose omp chat asks a question shows an amber ring and "needs you", and a chat that replied while you were elsewhere marks its tab "replied" until you click into its pane.

  Record the result here.

## Workflow follow-up

- Archive the change (`openspec archive search-and-tab-marks --yes`), run `openspec validate --specs --strict`, commit and push.
