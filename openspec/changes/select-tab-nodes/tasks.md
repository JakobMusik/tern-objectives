# Tasks

Checks run in the headless harness at `/tmp/tobj` unless marked **(live)**.
- **Harness:** `/tmp/tobj/bin/{env.sh,serve,ctl,sync,op,kv,pump}` and the helper plugin `tobjh` are in place from sort-button.
  - Start the serve as a named service (`/tmp/tobj/bin/serve`, ready on "serving"), then run `ctl plugins fixtures`.
  - After each edit, run `/tmp/tobj/bin/sync` and `ctl plugins fixtures` again, then reopen the graph if it closed (`ctl tree '.ob-root'` tells).
  - Never source `/tmp/tobj/bin/env.sh` in a persistent shell, and never run `tern serve --help`, which serves.
- **Layout:** the README demo, rebuilt in a fresh serve as sort-button built it:
  - session docs: Guides (a shell) and Release notes (an omp pane);
  - session web: App build (panes app and tests) and Components (a shell and `todo.md`);
  - session api: Server (a shell and an omp pane) and Benchmarks (a shell).
  - A session "misc" with one shell tab, for the jump checks.
- **Stores:** each check writes the objectives its scenario names into `/tmp/tobj/config/plugin-data/objectives/kv.json` (key `"state"`), then closes and opens the graph again.
  - A closed tab is a snapshot under `tabs` with this window's key and no live tab. An other-window tab is a snapshot with another window's key.
  - Group 2 starts from the demo store saved in `/tmp/tobj/kv.demo-0270.json`, with its dates counted from the day of the shot and its tab ids remapped if the rebuilt layout's differ.
- **Reading:**
  - `ctl tree '.ob-tab'` and `ctl tree '.ob-obj'` for classes, tooltips and order;
  - `ctl click` for real hit-testing;
  - `ctl shot NAME` for a PNG and layout JSON;
  - `ctl state` for the shown session, tab and focus, and toasts;
  - kv dumps of `kv.json`;
  - the serve log, `/tmp/tobj/logs/tern-serve.log`, for render times and warnings.
- **After the checks:** stop the harness service, and remove the chat folders the checks created under `~/.omp/agent/sessions/`.

## 1. Selecting tabs

- [x] 1.1 Selecting a tab and the jump arrow (design D1, D2, D6, D7):
  - `selected_tab` and the `tsel` verb in `lib/app.luau`, with `sel`, `reopen`, creating an objective, `bg` and a fresh open clearing it, and `build` taking `Built.selected_tab`;
  - in `View.build`, the listed objectives and the right column's tabs worked out before the left column, `kept_closed` taking the selected tab, and `Built.selected_tab`;
  - `tab_node`'s `ob-tsel` class, the header's and ghost rows' `tsel` clicks, and the jump arrow;
  - `.ob-tab.ob-tsel` and its combinations, and `.ob-tjump`, in `styles.css`.

  Verify:
  - objectives-graph "Selecting a tab", every scenario. Read the classes in `ctl tree '.ob-tab'` and `ctl tree '.ob-obj'`, focus and the shown session in `ctl state`, and take a shot for "Select and clear";
  - objectives-graph "Done objectives' closed tabs", every scenario, "Kept while selected" among them;
  - objectives-graph "Selection on a fresh open": "Closed and opened again", "Selected tab cleared" and "Selected tab kept after a field";
  - tab-navigation "Tab jump arrow", both scenarios, with the sizes and right edges read from the shot's layout JSON; "Jump to a tab", every scenario, from session "misc"; "Closed tabs don't jump" and "Other-window tabs don't jump", every scenario, with no toast in `ctl state`;
  - tab-navigation "Jump to a pane": "Second pane of a split" and "Row name doesn't jump" still hold;
  - agent-resume "Resume button on a closed tab", every scenario, with a saved omp chat from the Server tab's omp pane;
  - objectives-graph "Linked tabs section": "Linked tabs on top" and "Linked closed tab" still hold, since the right column's lists moved (design risk);
  - objectives-graph "Closing a tab from its node": "Asked in the header" and "Header clicked while asking" still hold;
  - the selected look in light and dark (`ctl appearance`), on a linked tab, an unlinked tab, the origin's tab, and a tab marked "needs you", from crops;
  - render times in the serve log stay within the 20 ms target, with no objectives warnings or errors.

  Result (harness, 2026-11-18, Tern 0.9.21). A fresh serve in `/tmp/tobj/w/demo/guides` rebuilt the README demo with the same ids as before: docs 1 (Guides 3, pane 2; Release notes 5, omp pane 4), web 6 (App build 8, panes 7 and 9; Components 12, panes 11 and `todo.md` 20) and api 13 (Server 15, pane 14 and omp pane 16; Benchmarks 19, pane 18). Session misc 31 (tab 33, pane 32) came later, for the jumps. Unless a check says otherwise, the store held open "Fix login bug" (P0, Server and Benchmarks), "Speed up search" (P2, Server), "Write slides" and "Read about rate limiting" (P3, Guides), and done "Set up CI" (Server and Benchmarks), with the Done group open, opened from Guides.
  - **Toasts:** `ctl state` doesn't list toasts, and neither does a shot's layout JSON, so the checks read them from the shot's pixels: a 700 × 64 px strip where Tern draws toasts. The "Select an objective in the graph to rename it" toast lit 5451 of its pixels; with no toast it lit none.
  - **"Selecting a tab":**
    - **Select and clear:** a click on Benchmarks' label left the graph shown, focus on the graph's pane and docs current, and gave Benchmarks `ob-tsel` (shot `st_select`, crop `st_select_bench`: accent border and outer ring). No `.ob-linkbar` showed. A click on empty space removed the class.
    - **Clicking it again:** a click on the dimmed "api · tab 2" line deselected it.
    - **Replaces a selected objective:** with "Fix login bug" selected (action bar, 6 link bars, the `Linked to` heading), a click on Server's label left no `ob-sel`, no `.ob-acts`, no link bar and no heading, and Server selected.
    - **Replaced by an objective:** a click beside "Write slides"'s title selected it with its action bar and deselected Server.
    - **Live pane row doesn't select:** a click on Server's "server" row opened its details (`expanded` `{"14": true}`) and selected nothing; a second click folded it.
    - **Trash icon doesn't select:** Server's header asked "Close tab?" with Cancel and Close, and nothing was selected. Cancel brought the label back.
    - **Hidden by the scope:** opened from Benchmarks (api current), App build selected; after "This session" the column held only tabs 19 and 15, and after "All" App build was back without `ob-tsel`.
  - **"Done objectives' closed tabs":** a closed tab "Old notes" (90) linked only by done "Tidy the backlog", and a closed "Old API" (92) linked by it and by "Speed up search". With nothing selected, 90 had no node and 92 showed under "Closed tabs". Selecting "Tidy the backlog" showed both under "Closed tabs" in the `Linked to` section. **Kept while selected:** a click on Old notes' label deselected the objective and kept 90 under "Closed tabs", selected. After a click on empty space, 90 was gone.
  - **"Selection on a fresh open":**
    - **Closed and opened again:** "Fix login bug" selected, then two opens of the graph: nothing selected, no action bar. The rename command showed the toast "Select an objective in the graph to rename it" (shot `fo_rename`).
    - **Selected tab cleared:** Server selected; after two opens no tab had `ob-tsel`.
    - **Selected tab kept after a field:** Server selected, then Search, "login" and Enter. The graph came back listing only "Fix login bug", with the "login" chip and Server still selected.
  - **tab-navigation:**
    - **"Tab jump arrow":** every live header's last child is a 28 × 18 px arrow titled "Go to this tab". On App build, the arrow and both rows' jump buttons start at x 1161.55, each 28 px wide, so all three end at 1189.55. The closed and other-window nodes had no `.ob-tjump`, while the 7 live tabs had one each.
    - **"Jump to a tab":** Components' last focused pane was 11, and the graph was opened from misc's pane 32.
      - "Header doesn't jump": a click on Components' label left misc current, focus on the graph and the graph shown, with Components selected.
      - "Trash icon doesn't jump": its trash icon asked, with misc still current. Cancel followed.
      - "Tab in another session": its arrow showed web, with Components active and pane 11 focused, and the graph closed.
    - **"Closed tabs don't jump":** from misc, a click on Old API's label, then on its "logs" row, each selected it with misc current, focus unchanged and no toast pixels (shots `gh_closed_head`, `gh_closed_row`).
    - **"Other-window tabs don't jump":** a snapshot with window key "other-window" ("Remote build", 95, linked by "Fix login bug") showed under "Other windows". Its label and its row each selected it with no toast (shots `gh_else_head`, `gh_else_row`).
    - **"Jump to a pane":** from misc, a click on Server's "server" row name left misc current and focus unchanged, opening its details. The jump button on App build's "tests" row showed web with App build active and pane 9 focused.
  - **"Resume button on a closed tab":** the check used a scratch omp tab (tab 38, pane 37, in `demo/resumechat`) rather than the Server tab's omp pane, so the demo layout stayed whole. It answered "ready", which saved its chat file under pane 37. The tab was linked to "Speed up search" and closed.
    - It showed under "Closed tabs" with "Resume", and Old API (shells only) without.
    - **Header click selects:** a click on its label left focus on the graph, the window's 7 tabs unchanged and no toast pixels (shot `ar_head`). It selected the tab, with "Resume" still there.
    - **Chat file gone:** with the file renamed away, the next draw showed no "Resume".
  - **"Linked tabs section":** X linked to Components, Benchmarks and closed Old API, opened from Server, X selected. The column read `Linked to “X”`, api: Benchmarks, web: Components, "Closed tabs": Old API, the divider, api: Server, docs: Guides and Release notes, web: App build, misc: its tab. Old API wasn't listed again below the divider.
  - **"Closing a tab from its node":** Benchmarks' trash icon turned its first line into "Close tab?", Cancel and Close. A click on "Close tab?" left the graph shown, focus unchanged, the label back and the tab open, and selected nothing.
  - **Look** (crops `look_light_*`, `look_dark_*`, sheet `looks_sheet`):
    - each selected tab shows the accent border and outer ring in both appearances: Server, marked "needs you"; App build, unlinked; Guides, the origin; and Benchmarks;
    - Server keeps its amber ring inside the accent one;
    - App build keeps its dashed border and grey fill;
    - Guides keeps its inset origin ring and its row's accent bar.

    The origin's inset ring and the selection's outer ring are both accent-coloured and about as thick. On different tabs they look alike, though only the selected one has thick lines.
  - **Render times:** 163 renders since the serve started, the longest 17.4 ms, and no objectives warnings or errors.
- [x] 1.2 What a selected tab shows (design D3, D4, D5):
  - the focus tab and `lit` following `sel_tab`, for every listed objective;
  - the done and review objectives' edges to the selected tab;
  - `quick_tab` following `sel_tab`, with a ghost's label from its snapshot;
  - README:
    - the intro line: a click on a tab shows its objectives, and its arrow or a pane's goes there;
    - the "Link tabs to objectives" bullet: the link icon links the selected tab, else the tab the graph was opened from;
    - the "Jump anywhere" bullet: the → on a tab's header or a pane's row;
    - the selection paragraph: clicking a tab selects it, what it shows, and that selecting one clears the other;
    - the search paragraph: starting a search clears a selected objective, but not a selected tab.

  Verify:
  - objectives-graph "Selected tab's links", every scenario. Take shots for "Open objectives" and the done and review lines, read the line ends from the layout JSON, and capture "Line ends at two widths" at 1400 and 460 px wide;
  - objectives-graph "Origin tab's links", every scenario, "Selecting a tab takes over" among them;
  - tab-links "Link button on objective nodes" and "Link button clicks", every scenario, the selected-tab ones among them, with `ctl move` for the pointer, shots for the buttons and kv dumps for the links;
  - the README paragraphs, read back;
  - render times in the serve log stay within the 20 ms target, with no objectives warnings or errors.

  Result (harness, 2026-11-18, the same serve as 1.1). Line ends were read 3 px inside the gap: a strong line's end is 6 px tall at the shot's 2× scale, a normal one 4 px, a faded one 2 px. Server's omp chat (pane 16) was waiting for input from the start of these checks, as group 2 needs, so every objective linking Server carried the amber ring.
  - **"Selected tab's links":**
    - **Open objectives:** Server selected (shot `stl_open`). "Fix login bug" and "Speed up search" have 6 px ends in their priority colours and `ob-lit`; "Write slides" and "Read about rate limiting" have faded 2 px ends. At the right, Server has a 6 px end, and Guides and Benchmarks faded ones. No node moved: every objective's rect was the same before and after the click, and no action bar showed. Their borders were amber from Server's waiting chat, on the tint. A variant with "Speed up search" linking only Benchmarks, with Benchmarks selected, showed its accent border on the tint (crop `stl_bench_o2`).
    - **Done objective in the open Done group:** "Set up CI" has a green 6 px end, within 0.05 px of its centre, and `ob-lit`. Benchmarks' end is "Fix login bug"'s faded red alone, so no line joins "Set up CI" to it.
    - **Done group folded:** no green end and no `ob-lit` on "Set up CI".
    - **Review mode:** "Set up CI" and "Restyle the docs site" due, only "Set up CI" linking Server. With Server selected, the gap held one green 6 px end at each side, within 0.05 px, and only "Set up CI" was lit.
    - **Tab no objective links:** App build selected. One edge layer, `ob-e-all`, not dimmed; every end 4 px, and nothing lit.
    - **Line ends at two widths:** Server selected. At 1400 px every end was within 0.05 px; at 460 px wide (graph 379.5 px), within 0.45 px.
  - **"Origin tab's links":** with "Read about rate limiting" removed, as the scenarios have it.
    - **Opened from a linked tab:** opened from Server, "Fix login bug" and "Speed up search" have 6 px ends and are lit, with no action bar and no link bar. The other ends were faded.
    - **Selecting takes over:** "Write slides" selected: only its ends were thick, and nothing was lit.
    - **Clearing brings it back:** after a click on empty space, the same as when opened.
    - **Origin tab unlinked:** opened from App build: one undimmed layer, every end 4 px, nothing lit.
    - **Origin pane moves:** opened from a scratch pane split into Server, then moved into Guides. "Write slides" was lit with 6 px ends, the origin ring was on Guides, and Server's ends were faded. The scratch pane was closed after.
    - **Done objectives:** opened from Server with the Done group open, "Set up CI" was neither lit nor joined to anything.
    - **Review mode:** opened from Server, no node was lit and no edge layer drawn until "Set up CI" was selected.
    - **Highlighted and marked:** "Fix login bug" carried `ob-lit ob-att-wait`, drawn with the amber ring and "needs you" chip on the tint (shot `or_open`).
    - **Node size unchanged:** both lit nodes were 48 px tall.
    - **Selecting a tab takes over:** opened from Server, Guides selected. Only "Write slides" had thick ends and was lit. A first run, with "Read about rate limiting" also linking Guides, lit both, as the rule says.
  - **tab-links** (store: "Fix login bug" on Server, "Speed up search" on Benchmarks, "Write slides" with no link, "Read about rate limiting" on Guides; done "Set up CI" on Server and Benchmarks, and "Restyle the docs site" on Guides; opened from Guides). The checks read button opacities from the shots' layout JSON:
    - **"Shown while pointing":** pointing at "Speed up search" showed its button (opacity 1, `Link to “Guides”`); the other unlinked nodes' buttons had opacity 0.
    - **"Linked nodes keep it":** at rest, only "Read about rate limiting" and "Restyle the docs site" showed buttons, both highlighted, `Unlink from “Guides”`.
    - **"Review node":** "Set up CI"'s button showed at x 535.64, just before its trash icon at 563.64.
    - **"Origin pane closes":** opened from a scratch pane split into App build, with buttons reading `Link to “App build”`. 0.9 s after it closed, no `.ob-qlink` and no origin ring were left, and the graph was still shown.
    - **"While moving":** with "Speed up search" lifted and the pointer on "Read about rate limiting", no `.ob-qlink` was left.
    - **"Selected tab's buttons":** Server selected, pointing at "Speed up search". "Fix login bug" and "Set up CI" showed highlighted buttons, `Unlink from “Server”`; "Speed up search"'s read `Link to “Server”`; "Read about rate limiting"'s was hidden and not highlighted.
    - **"Link from the node":** "Speed up search" got Guides (`[19, 3]`), nothing was selected, and it was lit with a thick line to Guides and a highlighted button. The graph stayed shown, with focus unchanged.
    - **"Unlink from the node":** `[19]`, not lit, and its only end was Benchmarks' faded one.
    - **"Selection kept":** "Fix login bug" stayed selected with its action bar, and "Speed up search" held `[19, 3]`.
    - **"Done objective":** "Set up CI" held `[15, 19, 3]`, still done, with a highlighted button.
    - **"Origin pane moved":** a scratch pane of App build moved into Server. The button read `Link to “Server”`, and "Speed up search" held `[19, 15]`, with no App build link.
    - **"Ends the Undo notice":** after "Marked done “Write slides” ·", a click on "Speed up search"'s button removed the notice and stored `[19, 3]`.
    - **"Link to the selected tab":** Server selected; "Speed up search" held `[19, 15]`, not Guides, and Server stayed selected. "Speed up search" was lit with a 6 px end to Server.
    - **"Selected closed tab":** Old API selected; "Write slides" held `[92]`. Its line and "Fix login bug"'s were thick and dashed (crop `lc_closed_c`).
  - **README:** the intro line, the "Link tabs to objectives" and "Jump anywhere" bullets, the selection paragraph and the search paragraph read back as listed. The search paragraph wasn't in the plan: it said starting a search clears the selection, and a selected tab now stays.
  - **Render times:** 163 renders over 1.1 and 1.2, the longest 17.4 ms, with no objectives warnings or errors.

## 2. The README screenshots

- [x] 2.1 Take `docs/graph.png` and `docs/review.png` again, as sort-button took them, since every live tab header now shows its arrow:
  - **`graph.png`:**
    - Release notes' omp chat replies while Guides has focus, and Server's waits for input;
    - the same window size (`ctl resize 1045 928`) and crop (914 × 808);
    - opened from Guides, with nothing selected, the Done group open and the pointer off the graph.
  - **`review.png`:**
    - review mode with "Restyle the docs site" and "Profile slow search queries" due, and the latter selected;
    - opened from Guides, and cropped to the header, the two review nodes and the `Linked to` section, 1828 px wide.

  Update both alt texts to name the arrows on live tab headers. Show both drafts to the user before committing them.

  Verify:
  - plugin-package "README": "README contents" and "Graph screenshot first";
  - plugin-package "Screenshots match this version": open nodes show grips, and no node in either image shows ⋯;
  - every live tab header in both shots ends in its arrow, and no closed tab's does;
  - every line end in both shots sits within 2 px of its node and tab header centres, read from the layout JSON;
  - the user approved both drafts.

  Result (harness, 2026-11-18, the same serve as group 1):
  - **Layout and store:**
    - session misc was closed first, so the column held docs, web and api as before;
    - the demo store was written again with dates counted from today, `sort` "priority", the Done group open and Release notes' row open; its ids matched the rebuilt layout's;
    - Server's omp chat had waited for input since 1.2, asking "Restart the server before deploying?";
    - with Guides focused, Release notes' chat answered "In two short sentences, say what release notes for a web app should cover." in 3.2 s (`idle` with its alert).
  - **`graph.png`** (1828 × 1616):
    - `ctl resize 1045 928`, opened from pane 2 in Guides, the pointer at (3, 3), once `ctl state` listed no banners;
    - the glimpse was at 65.34, 76.95, 914.31 × 808.08, as before, and was cropped there;
    - "Fix login bug" and Server are marked "needs you", "Write release notes" and Release notes "replied". "Read about rate limiting" is the one node tinted, nothing is selected, the Done group is open, and its row shows "you:" and "omp:";
    - all 7 open nodes have grips, and no node has ⋯. All 6 live tab headers end in their arrows, in line with their rows' arrows;
    - all 7 left and 6 right line ends sit within 0.3 px of their centres.
  - **`review.png`** (1828 × 857):
    - review mode, opened from Guides, listing "Profile slow search queries" (Hard · 1d, Good · 3d, Easy · 4d) and "Restyle the docs site" (Hard · 2d, Good · 10d, Easy · 14d);
    - the first is selected, with Note and Tags, and Benchmarks under `Linked to` with "× Unlink";
    - cropped from the glimpse's top to 8 px below the Guides node; Benchmarks and Guides show their arrows;
    - the green line's ends sit within 0.3 px. The gap column's other marks were at y 872 and 905, in the footer below the crop.
  - **Alt texts:** both now say that each tab's header ends in an arrow that goes to it.
  - **README checks:** the README has two images, `docs/graph.png` first (line 5), then `docs/review.png` (line 26). "README contents" still holds: the graph shot has the Done group open and Server marked "needs you", and the review shot has Hard, Good and Easy.
  - **Approval:** the user approved both drafts before they were committed.
  - **Cleanup:**
    - the serve was stopped with `ctl quit`;
    - the chat folders this run created were removed: `--private-tmp-tobj-w-demo-notes--`, `--private-tmp-tobj-w-demo-serverchat--` and `--private-tmp-tobj-w-demo-resumechat--` (task 1.1's scratch chat);
    - `--private-tmp-tobj-w-docs--` and `--private-tmp-tobj-w-server--`, from earlier runs, were left as they were.

## 3. Release 0.28.0

- [x] 3.1 Version `0.28.0` in `plugin.toml`. Verify that an isolated `tern plugin install` of the repo folder prints `installed objectives 0.28.0`. Tick this box, then commit, push `main` and tag `v0.28.0` (annotated, message "objectives 0.28.0").

  Result: the install into `/tmp/tobj-inst280/config` printed `installed objectives 0.28.0 → /tmp/tobj-inst280/config/plugins/objectives`.
- [x] 3.2 **(live)** After the push has finished, run `tern plugin install github.com/JakobMusik/tern-objectives --force` from a shell with no harness variables.

  Verify `tern plugin list` shows `objectives 0.28.0 … ready`, with the other plugins untouched.

  Result: `installed objectives 0.28.0 → ~/Library/Application Support/Tern/plugins/objectives`. `tern plugin list` shows `objectives 0.28.0 … window ready`, and the other plugins ready as before: `external-editor 0.1.0`, `omp-narration 0.1.0`, `open-below 0.2.0`, `reply-selection 0.1.0` and `tabnav 0.1.0`. The tag `v0.28.0` (`c70ac4e`) is signed and on GitHub.
- [x] 3.3 **(live)** With the user:
  - clicking a tab's header keeps the graph open and selects the tab: thick lines to it, its objectives tinted, done ones too while the Done group is open;
  - the arrow at the right end of the header's second line goes to the tab;
  - while a tab is selected, an objective's link icon links or unlinks that tab.

  Record the result here.

  Result (user, 0.28.0): not as intended. The user wrote: "currently when i select an objective node with connected tab nodes, the tab nodes would also be selected while being put to the top, but then if i click on the these tab nodes, they get deselected, which is not ok. the intended behavior should be that when these nodes are selected 'again' after an objective node is selected, the node that get's click selected 'again' would not be deselected but instead show the other connection lines coming from other objective nodes that are connecting to it so that it's easy to know what other objective nodes are connected to the tab node".

  0.28.0 cleared the selected objective when a tab was selected. The `Linked to` section went with it, and the tab moved back down the column, so it read as deselected. The user reported nothing about the arrow or the link buttons.

  The user then chose, on 2026-11-18, a fix released as 0.28.1:
  - **Selecting:** an objective and a tab can be selected together. Selecting one keeps the other, clicking either again clears only it, and a click on empty graph space clears both.
  - **Lines:** with both selected, the objective's lines and every line into the tab are thick, and all other lines fade.

  Groups 4 and 5 do this.

## 4. An objective and a tab selected together

- [x] 4.1 Both selections at once (design D1, D3, D4):
  - `tsel` keeps `selected`, and `sel`, `reopen` and creating an objective keep `selected_tab`, in `lib/app.luau`; `bg` still clears both;
  - in `View.build`, the selected objective isn't tinted, and the selected tab's done lines skip the selected objective, whose lines `add_edges` already draws;
  - README: the selection paragraph says an objective and a tab can be selected together.

  Verify:
  - objectives-graph "Selecting a tab", every scenario;
  - objectives-graph "Selected tab's links": "With a selected objective", "Open objectives" and "Done objective in the open Done group";
  - objectives-graph "Done objectives' closed tabs": "Kept while selected";
  - objectives-graph "Linked tabs section": "Linked tabs on top", then a click on Benchmarks, which leaves the column as it was;
  - tab-links "Link button clicks": "Selection kept" and "Link to the selected tab", and both with an objective and a tab selected;
  - the README paragraph, read back;
  - render times in the serve log stay within the 20 ms target, with no objectives warnings or errors.

  Result (harness, 2026-11-18). A fresh serve rebuilt the demo with the same ids as in 1.1. No chat was waiting this time, so no node carried an attention ring. The stores were the ones group 1 used.
  - **"Selecting a tab":**
    - **Select and clear:** a click on Benchmarks' label selected it, with the graph shown, focus unchanged and no link bar. A click on empty space cleared it.
    - **Clicking it again:** a click on its dimmed second line cleared it.
    - **Kept with a selected objective:** with "Fix login bug" selected, a click on Server's label selected Server. "Fix login bug" kept `ob-sel` and its action bar, and the column still started with `Linked to “Fix login bug”`, with all 6 tab nodes' link bars. Server's rect and the whole column's order were the same before and after the click.
    - **Clicking it again keeps the objective:** a second click on Server's label cleared only Server, leaving "Fix login bug" selected with its action bar and heading.
    - **Objective selected with a tab:** Server selected, then a click beside "Write slides"'s title. "Write slides" was selected with its action bar, and Server stayed selected.
    - **Another tab:** Server selected, then Benchmarks' label: only Benchmarks was selected.
    - **Empty space clears both:** with "Fix login bug" and Server selected, a click on empty space left nothing selected, no action bar and no link bar.
    - **Live pane row doesn't select:** Server's "server" row opened its details, with nothing selected.
    - **Trash icon doesn't select:** the trash icon asked "Close tab?", with nothing selected.
    - **Hidden by the scope:** opened from Benchmarks, App build selected. "This session" hid it, and "All" listed it again, not selected.
  - **"Selected tab's links":**
    - **With a selected objective:** "Fix login bug" selected, then Server (shot `b_both`, crop `b_both_graph`).
      - Thick: "Fix login bug" (red, to Server and Benchmarks), "Speed up search" (blue) and done "Set up CI" (green, to Server only).
      - Faded: "Write slides" and "Read about rate limiting".
      - Tinted: "Speed up search" and "Set up CI". "Fix login bug" kept `ob-sel ob-acts-on` with no `ob-lit`.
    - **Open objectives:** Server alone selected. "Fix login bug", "Speed up search" and "Set up CI" have 6 px ends and are lit, with no action bar. Server is the one thick right end.
    - **Done objective in the open Done group:** "Set up CI"'s green end is within 0.05 px, and Benchmarks' end is red, from "Fix login bug" alone.
  - **"Done objectives' closed tabs" "Kept while selected":** "Tidy the backlog" selected, then Old notes' label: both selected, under `Linked to`. A click beside "Tidy the backlog"'s title cleared it, and Old notes stayed under "Closed tabs", selected. A click on empty space removed Old notes from the column.
  - **"Linked tabs section":** X selected, opened from Server. The column read `Linked to “X”`, api: Benchmarks, web: Components, "Closed tabs": Old API, the divider, then api: Server, docs: Guides and Release notes, web: App build. A click on Benchmarks' label selected it and left that column exactly as it was, with X still selected.
  - **tab-links "Link button clicks":**
    - **Selection kept:** "Fix login bug" stayed selected with its action bar, and "Speed up search" held `[19, 3]`.
    - **Link to the selected tab:** Server selected; "Speed up search" held `[19, 15]`, Server stayed selected, and "Speed up search" was lit with a 6 px end.
    - **Both selected:** with "Fix login bug" and Server selected, "Speed up search"'s button read `Link to “Server”`. A click stored `[19, 15]`, and both selections stayed. "Speed up search" and "Set up CI" were lit, but not "Fix login bug".
  - **README:** the selection paragraph now says an objective and a tab can be selected together, and how each clears, read back.
  - **Render times:** 52 renders, the longest 10.4 ms, with no objectives warnings or errors.
  - **Cleanup:** the serve was stopped. Its two omp panes had made empty chat folders, `--private-tmp-tobj-w-demo-notes--` and `--private-tmp-tobj-w-demo-serverchat--`, which were removed.

## 5. Release 0.28.1

- [x] 5.1 Version `0.28.1` in `plugin.toml`. Verify that an isolated `tern plugin install` of the repo folder prints `installed objectives 0.28.1`. Tick this box, then commit, push `main` and tag `v0.28.1` (annotated, message "objectives 0.28.1").

  Result: the install into `/tmp/tobj-inst281/config` printed `installed objectives 0.28.1 → /tmp/tobj-inst281/config/plugins/objectives`.
- [ ] 5.2 **(live)** After the push has finished, run `tern plugin install github.com/JakobMusik/tern-objectives --force` from a shell with no harness variables.

  Verify `tern plugin list` shows `objectives 0.28.1 … ready`, with the other plugins untouched.
- [ ] 5.3 **(live)** With the user:
  - select an objective, then click one of its tabs under `Linked to`: the objective stays selected, the tab stays where it is with the selection ring, and the lines from the other objectives linked to that tab turn thick, those objectives tinted;
  - clicking that tab again clears only the tab; a click on empty space clears both;
  - the arrow still goes to the tab, and the link icons still link the selected tab.

  Record the result here.

## Workflow follow-up

- Archive the change (`openspec archive select-tab-nodes --yes`), run `openspec validate --specs --strict`, commit and push.
- In the same commit, update tab-navigation's Purpose, which still says a click on a tab's header takes the user there, to name the header's arrow.
