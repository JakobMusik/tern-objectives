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

- [x] 1.1 Build the harness again under `/tmp/tobj` (add-objectives-plugin D14):
  - the fixtures copy of the repo's package files;
  - `bin/serve`, `bin/ctl`, `bin/sync` and `bin/pump`;
  - the helper plugin `tobjh` and `bin/op`, with the ops the checks above use: `kv`, `keys_all`, `agents` and `run`.

  Verify that `ctl plugins fixtures` loads `objectives` and `tobjh` with no plugin errors in the serve log, `ctl state` answers, and `op keys_all` lists `ctrl+cmd+o → plugin.objectives.open`.

  Result (harness, 2026-11-11):
  - **Scripts:** `bin/env.sh`, `serve`, `ctl`, `sync`, `op`, `kv` and `pump`, and the helper's `plugin.toml` and `window.luau`, were restored from their last versions in this session's history. The helper's two throwaway ops that required copies of `lib/` under `./rev` were left out.
  - **Fixture root:** with `STENCIL_FIXTURE_ROOT=/tmp/tobj`, as the restored `env.sh` had it, Tern 0.9.16 loaded no plugin: `ctl plugins fixtures` answered ok, and `plugins expect objectives` timed out. With `/tmp/tobj/crates/app`, the root D14 names, both plugins loaded.
  - **Checks:** `ctl state` answered. `op keys_all` listed `ctrl+cmd+o → plugin.objectives.open`. The log's only warning was the helper's own `esc_probe` on Escape.
  - **Layout:**
    - session "web" (1): App build (tab 3, pane 2) and Docs (tab 5, pane 4);
    - session "api" (6): Server (tab 8, shells 7 and 9), Benchmarks (tab 12, pane 11) and Split (tab 14, panes 13 and 15).
  - **Slip:** before the harness was up, `tern serve --help` was run in the work shell to read its options. It took no `--help` and served for about a minute, with no harness variables, until `tern ctl --control /tmp/tern.sock quit` stopped it. No file under `~/Library/Application Support/Tern` changed in that time (`find -newermt`).
- [x] 1.2 The search (design D1–D4):
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

  Result (harness, 2026-11-11). Store: open "Fix login bug" (P0, #api, linked to Server), "Write slides" (P2, side note "for the Monday demo", linked to Docs) and "Login page copy" (P3, #web); done "Set up CI" and "Restyle the docs site", both due today. The graph was shown over Benchmarks. Text went into the field with `ctl type`, then Enter.
  - **"Search":**
    - "A word of the title": "login" listed "Fix login bug" and "Login page copy". The header showed the chip "login", tooltip "Search: “login” · click to change", with no `.ob-searchbtn`. The tab nodes were the same five, in the same order.
    - "Every word must match": "login API" listed "Fix login bug" alone.
    - "Side note": "monday" listed "Write slides" alone.
    - "Done objectives": "docs" showed "▸Done (1)"; opened, it listed "Restyle the docs site" alone.
    - "Nothing matches": "zebra" left only "No objectives match this filter.", with the chip "zebra" and no Done group.
    - "Lines of hidden objectives": in crop `sr_lines_search_crop.png`, no line reached Docs, while `sr_lines_none_crop.png`, without the search, shows Write slides' blue line ending at its header.
    - "Changing the search": a click on the chip opened the field holding "login". "slides" then listed "Write slides" alone, with the chip "slides".
    - "Ending with ×" and "Empty text": both listed all three again, with the Search button back and no chip.
    - "Field dismissed": Escape left the same two objectives and the chip "login".
  - **"Search and other filters":**
    - "With the tag filter": with "#web" on, "login" listed "Login page copy" alone.
    - "Selection cleared": with "Write slides" selected, "login" left nothing selected and no `.ob-acts`.
    - "Created during a search": "＋ New objective" and "Write notes" listed "Fix login bug", "Write notes" (selected, at the top of P3) and "Login page copy". After a click on the gap, the other two were listed alone.
    - "In review mode": "Review (2)" listed both done objectives. "docs" left "Restyle the docs site" alone, with "Review (1)" active.
    - "Ended by a fresh open": after ⌃⌘O twice (`plugins run plugin.objectives.open`), every objective was listed, with the Search button and no chip.
    - "Kept after a field": with "login" on and "Fix login bug" selected, Note opened the field. The graph was then closed while the field was open, as a click into the field closes it live. "check the logs" and Enter showed the graph again with the chip "login", the same two objectives, "Fix login bug" selected, and its note stored.
  - **"Selection on a fresh open":**
    - "Filters kept, search ended": "#api" and "login" on, then a fresh open: the "#api" chip active, "Fix login bug" listed, and the Search button.
    - "Closed and opened again": nothing selected and no `.ob-acts`.
    - "Review mode kept": "Review (2)" still active, listing both.
    - "Kept after a picker" is "Kept after a field" above, and "New objective by key" is unchanged code: `M.new_key` still selects what it creates.
  - **objective-review "Review button":**
    - "Search narrows the count": "docs" outside review mode showed "Review (1)", which listed "Restyle the docs site" alone.
    - "One due": with one review due tomorrow, "Review (1)".
    - "Nothing due": with both due tomorrow, no Review button.
  - **Plain text:** "1.2 (beta" found "Ship v1.2 (beta)". "1x2" and "50%" found nothing and raised no error.
  - **Case folding** (design risk):
    - "Écrire la doc" was found by "Écrire", "ÉCRIRE" and "la DOC", but not by "écrire" or "ecrire". Only A to Z fold: "É" and "é" stay apart.
    - The README says "ignoring the case of the letters A to Z".
    - `ctl type` sends `\u` escapes as typed text, so accented text went in as raw UTF-8.
  - **Shots:** `sr_chip_crop.png` shows the chip after the scope segment, accent-filled, with the magnifier, "login" and ×. `sr_longchip_crop.png` shows a 61-character search cut at 220 px with "…".
  - **README:** the paragraph after the one on selecting, read back.
  - **Log:** 71 renders since the serve started, the longest 7.3 ms, and no objectives warnings or errors.
- [x] 1.3 The key (design D5):
  - the `search` entry in `Keys.COMMANDS`;
  - the "Objectives: Search…" command in `window.luau`;
  - `App.search_key`;
  - README: the commands table's Search row with ⌃⌥F, and ⌃⌥F in the keys note.

  Verify:
  - `op keys_all` lists `ctrl+alt+f → plugin.objectives.search`, and the serve log has no `bind left out` for it;
  - objectives-graph "Search key": every scenario, pressing keys with `ctl key Ctrl+Alt+f`. "Letters still reach the panes" uses `ctl type fF` in the Benchmarks shell;
  - plugin-package "Palette commands": its three scenarios, from the palette's rows in `ctl state`;
  - plugin-settings "Shortcut rows": "Defaults", "Search key changed" and "Rename moved to ⌥⇧R before this version", with `ctl tree` for the rows and `op` for the keybinds. After a Reset on Search, the keybinds equal the starting map;
  - plugin-package "README": `grep` finds the Search row with ⌃⌥F, the keys note and the search paragraph.

  Result (harness, 2026-11-11):
  - **Spike first:** `op keys_all` read `alt+f → canvas.fill_solid`, and `alt+shift+f → canvas.fill_pattern`. A throwaway helper command with `keys = { "alt+f" }` logged `plugin bind left out: the preset binds these keys keys="alt+f"`, and `ctl key Alt+f` didn't run it. The artifacts were updated, and the user picked ⌃⌥F (`ctrl+alt+f`, free in the keymap).
  - **Keymap:** `ctrl+alt+f → plugin.objectives.search`, with no `bind left out` for it.
  - **"Search key":**
    - "From a shell": with no graph shown and the Benchmarks shell focused, ⌃⌥F showed the graph over Benchmarks with the field open. "login" listed the two matches with the chip "login", and the shell's text was the same before and after.
    - "In the graph": with "login" on, ⌃⌥F opened the field holding "login".
    - "From the settings page": ⌃⌥F and "login" showed the columns with the two matches.
    - "Letters still reach the panes": `ctl type fF` in the Benchmarks shell left "fF" at its prompt, with no field and no graph.
  - **"Palette commands"**, read with `ctl palette objectives` and `ctl tree '#pal [role=option]'`:
    - "Commands listed": with "Fix login bug" selected, the seven commands: Open graph ⌃⌘O, Rename selected objective ⌥⇧R, New objective ⌥N, Search… ⌃⌥F, Link this tab…, New objective for this tab… and Configure.
    - "Rename hidden without the graph" and "Rename hidden without a selection": the other six.
  - **"Shortcut rows":**
    - "Defaults": Open graph ⌃⌘O, Rename selected objective ⌥⇧R, New objective ⌥N, Search ⌃⌥F, the other three "none", and no Reset.
    - "Search key changed": Change opened the field holding `ctrl+alt+f`. `ctrl+alt+s` made the row "⌃⌥S" with Reset. The keybinds then held `ctrl+alt+s → plugin.objectives.search` and an empty `ctrl+alt+f`. In the Benchmarks shell, ⌃⌥S showed the graph with the field, and ⌃⌥F did nothing.
    - Reset brought back "⌃⌥F" without Reset, and the keybinds were `{}` again, as at the start.
    - "Rename moved to ⌥⇧R before this version": with `alt+shift+r` and an empty `alt+r` written through `op`, the row read "⌥⇧R" with no Reset. With "Fix login bug" selected, ⌥⇧R opened the field holding its title. The keybinds were then set back to `{}`.
  - **README:** the commands table's row "Objectives: Search… | ⌃⌥F", and the keys note naming ⌃⌥F.

## 2. Marks on tab nodes

- [x] 2.1 The marks (design D6, D7):
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

  Result (harness, 2026-11-11):
  - **Setup:**
    - omp ran in Server's right pane (9), in both Split panes (13, 15), and in a pane split off Benchmarks (296). They were driven through the helper's `ask` op while Benchmarks' shell (11) had focus.
    - Store: open "Fix login bug" (P0) linked to Server, "Write slides" (P2) linked to Docs, and "Ship docs" (P1) with no link.
  - **"Tab attention marks":**
    - "Chat working": during `sleep 90`, the Server node had no `ob-tatt-*` class. Its second line started with a "working" chip, tooltip `omp is working in “<the pane's title>”`. Crop `tm_working_server.png`.
    - "Reply unseen": once the turn ended (`idle`, alert set), Server got `ob-tatt-replied` and a "replied" chip, while its row still read "omp · idle". Crop `tm_replied_server.png`.
    - "Focusing the pane clears a reply": after focusing pane 9, then 11, and opening the graph again, Server had no class and no chip.
    - "Question waiting": asked for a yes/no question, pane 9 went `waiting_input`. Server got `ob-tatt-wait` and "needs you" before "api · tab 1", with its tooltip naming the pane's title. Crop `tm_wait_server.png`.
    - "Objective and tab together": "Fix login bug" got `ob-att-wait` and "needs you" (`omp is waiting in “Server”`) at the same time.
    - "Origin tab marked": opened from Server's shell (pane 7), the node had `ob-origin` and `ob-tatt-wait`. Crop `tm_origin_server.png` shows the accent ring outside and the amber ring inside.
    - "Needs you wins": with pane 13 waiting and pane 15's reply unseen, Split showed only "needs you", whose tooltip named pane 13's title alone.
    - "Unlinked tab": Split, then linked to nothing, kept `ob-tab-unlinked` beside `ob-tatt-wait`. Crop `tm_unlinked_split.png` shows the grey fill and the dashed border, drawn amber.
    - "Closed tab": with Split linked to "Ship docs", panes 13 and 15 were closed. Split showed under "Closed tabs" as `ob-tab-ghost`, with Resume, no `ob-tatt-*` and no chip, and "Ship docs" lost its mark.
  - **"Attention marks", unchanged:**
    - "Question waiting": `omp is waiting in “Server”`.
    - "Two chats in one tab": "Ship docs", linked to Split, named "Split" once.
    - "Needs you wins": "Write slides" linked to Benchmarks (replied) and Server (waiting) showed "needs you" naming Server only. "Bench only", linked to Benchmarks alone, showed "replied" for Benchmarks.
    - Benchmarks kept "replied" while its other pane (11) had focus.
  - **Light and dark** (`ctl appearance`):
    - `tm_themes.png`: Benchmarks as the origin tab with "replied", and Server with "needs you", in both themes.
    - `tm_w_themes.png`: Benchmarks as the origin tab with "working" (origin ring only).
    - The chips and rings read clearly in both themes.
  - **"Alignment at two widths":** with Server and Benchmarks marked, at `ctl resize 1600 1000` (graph capped at 1200 px wide) and `ctl resize 560 1000` (graph 467.5 px wide), pixels at the gap column's edges placed all 4 left line ends and all 3 right line ends within 0.05 px of their node and tab-header centres.
  - **Log:** 260 renders since the serve started, all but one at most 9.9 ms. One reached 21.0 ms (build 10.9, hand-over 10.1, both about twice the usual) while `pump` was opening and closing tabs during an omp turn. A burst of 40 renders afterwards, with three omp chats and the marks shown, peaked at 12.6 ms. No objectives errors.
  - **README:** "See what needs you" now says each tab is marked the same way for its own omp chats, linked or not.

## 3. The README screenshot

- [x] 3.1 Take `docs/graph.png` again (design D8):
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

  Result (harness, 2026-11-11):
  - **Layout:** a fresh serve in `/tmp/tobj/w/demo/guides` held:
    - docs: Guides 3, and Release notes 5, with omp in pane 4;
    - web: App build 8, split into app and tests; Components 12, with the shell `ui` and `todo.md`;
    - api: Server 15, with a shell and omp in pane 16; Benchmarks 19.
  - **Store:** rebuilt from the old image's titles, priorities, created times, tags, notes and chips. Due dates were set from today, so the chips read "overdue 2d", "overdue 4d", "due tomorrow", "overdue 1d", "due today", "review due" and "review in 4d" as before. Release notes' omp row was stored open.
  - **Chats:** Release notes' chat answered "In two short sentences, say what release notes for a web app should cover." while Guides had focus. Server's chat put a yes/no question about restarting the server and waited (`idle` with its alert, and `waiting_input`).
  - **Window and crop:** `ctl resize 1045 928`, the glimpse cropped at its 914.31 × 808.08 box, so `graph.png` is 1828 × 1616 as before.
  - **Content:**
    - opened from pane 2 in Guides, with nothing selected and the Done group open;
    - "Read about rate limiting" is tinted, with its thick line to Guides;
    - Release notes is ringed green with "replied" and its "you:"/"omp:" lines; Server is ringed amber with "needs you"; "Fix login bug" and "Write release notes" keep their marks;
    - the header shows the Search button after the scope segment;
    - every open node has a grip, and no node has ⋯.
  - **Line ends:** measured 3 px inside the gap column's edges against the shot's layout JSON, all 7 left ends sit within 0.3 px of their objective nodes' centres, and all 6 right ends within 0.3 px of their tab headers' centres. 1 px inside, the right column hit the tab cards' borders instead.
  - **Alt text:** it now names the Search button, Release notes ringed green with "replied", and Server ringed amber with "needs you". "Graph screenshot first": the README's first image is still `docs/graph.png` (line 5).
  - **Approval:** the user approved the draft before it was committed.
  - **Cleanup:**
    - the serve was stopped with `ctl quit`;
    - removed the chat folders this run created: `--private-tmp-tobj-w-bench--`, `-demo-notes--`, `-demo-serverchat--` and `-split--`, and this run's chat in `--private-tmp-tobj-w-server--`;
    - left as they were: that folder's chat from 2026-11-09, and `--private-tmp-tobj-w-docs--` (2026-11-09).

## 4. Release 0.25.0

- [ ] 4.1 Version `0.25.0` in `plugin.toml`. Verify that an isolated `tern plugin install` of the repo folder prints `installed objectives 0.25.0`. Tick this box, then commit, push `main` and tag `v0.25.0` (annotated, message "objectives 0.25.0").
- [ ] 4.2 **(live)** After the push has finished, run `tern plugin install github.com/JakobMusik/tern-objectives --force` from a shell with no harness variables.

  Verify `tern plugin list` shows `objectives 0.25.0 … ready`, with the other plugins untouched.
- [ ] 4.3 **(live)** With the user:
  - the header's Search button filters the objectives by title, note and tags, the chip's × ends the search, and reopening the graph ends it too;
  - ⌃⌥F in a shell opens the graph with the search field;
  - a tab whose omp chat asks a question shows an amber ring and "needs you", and a chat that replied while you were elsewhere marks its tab "replied" until you click into its pane.

  Record the result here.

## Workflow follow-up

- Archive the change (`openspec archive search-and-tab-marks --yes`), run `openspec validate --specs --strict`, commit and push.
