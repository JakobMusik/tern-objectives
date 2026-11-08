# Tasks

Checks run in the headless harness at `/tmp/tobj` unless marked **(live)**.
- **Harness setup:** start the serve as a named service (`/tmp/tobj/bin/serve`, ready on "serving"), then `ctl plugins fixtures`. After each edit, run `/tmp/tobj/bin/sync` and `ctl plugins fixtures` again, then reopen the graph if it closed (`ctl tree '.ob-root'` tells). Right after a reload, force a fresh render with a click on "All" before reading the graph. Never source `/tmp/tobj/bin/env.sh` in a persistent shell.
- **Reading:**
  - `ctl tree SEL` for texts, classes, titles and rects;
  - `/tmp/tobj/bin/kv` for the store;
  - `ctl state` for fields, pickers and tabs;
  - `ctl shot NAME` for a PNG and layout JSON, and `/tmp/tobj/bin/edgecheck.py` for line ends;
  - the helper ops `new_tab`, `run`, `ask`, `agents`, `pane`, `focus` and `close` (`/tmp/tobj/bin/op`) for omp chats.
- **Data:** demo names follow the specs: objectives "Fix login bug", "Write slides", "Review pull requests"; tab "Server".
- **After the checks:** stop the harness service, and delete `~/.omp/agent/sessions/--private-tmp-tobj-*` if a chat was started.

## 1. Title lines

- [x] 1.1 Title lines (D1): `Text.wrap`, the title rows in `View.build`, `Layout.add_obj` with a line count, and the `ob-n2`/`ob-n3` heights in the layout sheet and `styles.css`.

  Verify first the width choice: at the harness's 1280 px viewport, a node with a 36-character line and the time shows both whole (`ctl tree` text and a shot). If not, stop and change the width in design D1 and the "Title lines" requirement.

  Then each scenario, from `ctl tree` rects and texts and the shots:
  - "Title lines": "Short title", "Two lines" (with `edgecheck.py` on the shot), "More than three lines", and "Same breaks at any width" at 1400 and 900 px.
  - "Creation time after the title": "Long title" at 1400 px; "Done and review nodes" with a two-line title in the Done group and in review mode.
  - "Objective node content": "Long note".
  - "Larger hit areas": "Measured hit areas" and "Review nodes", with one-line and two-line titles present.
  - The log's render times, and no errors.

  Result (harness; o1 "Fix login bug" with a 200-character note; o2 "Write the onboarding guide for new contributors to the API" linked to tab 3; o3 "Prepare the quarterly planning slide", 36 characters; o4 the 120-character "Write a detailed migration plan … and owners", linked to tab 3; done o5 "Document the release checklist for the mobile app team" and o6 "Set up CI", both due for review):
  - **Width choice:** at 1280 × 800, o3's 36-character line and its time `11-08 14:42` show whole, with about a third of the line to spare (shot `t1_1280`). The width stays 36.
  - **Short title:** o1 takes one line, 48 px.
  - **Two lines:** o2 reads `Write the onboarding guide for new` over `contributors to the API` and is 66 px tall. `edgecheck.py t1_1280` passed: both left line ends, for o2 and o4, sit 0.1 px from their nodes' centres.
  - **More than three lines:** o4 reads `Write a detailed migration plan for` / `moving the billing service onto a` / `new event pipeline, with rollback…`, 84 px tall. The node's tooltip holds the whole title.
  - **Same breaks at any width:** at 1400 × 900 and 900 × 900 (`ctl resize`), o2 and o4 break the same way. At 900 px each line is cut with "…" to fit the 291 px column, and the time stays whole (shot `t1_900`). `edgecheck.py` passed on both shots.
  - **Long title:** at 1400 px, o4's three lines end in `rollback…`, followed by the whole time.
  - **Done and review nodes:** o5 in the Done group shows two struck-through lines and its time, 66 px. In review mode o5 is 96 px and o6 78 px, each with its time and 22 px Hard, Good and Easy buttons (shot `t1_review`). Neither links a tab, so that shot has no lines and `edgecheck.py` has nothing to measure.
  - **Long note:** o1 stays 48 px, its note is cut with "…" on screen, and the node's tooltip holds all 200 characters.
  - **Measured hit areas:** done boxes, trash icons and ⋯ are 22 × 18 px; jump buttons 28 × 22 px; pane rows 22 px; one-line nodes 48 px. The badge sits 1 px below the top of line 1 on one- and two-line nodes, centred as before.
  - **A word longer than a line:** a new objective titled `Check https://status.example.com/incidents/2026-11-08-checkout-timeouts today` reads `Check` / `https://status.example.com/incidents` / `/2026-11-08-checkout-timeouts today`, 84 px.
  - **Log:** renders took at most 4.3 ms; no errors (the one warning is the helper plugin's own Escape binding).

## 2. Click the title to rename

- [x] 2.1 Rename by clicking the title (D2): `ren=` on each title line, act `ren` in `M.action`, `user-select: none` on `.ob-title`. README: in the commands table, "Rename" also by clicking a title.

  Verify, with `ctl click` on the title's rect and the Rename field read from `ctl state`:
  - "Rename by clicking the title": "Rename by click", "Selection unchanged", "Beside a short title", and "Second line of a title";
  - "Selection": "Select and clear" (a click beside the title) and "Selecting a done objective" (a click on the second line);
  - "Controls and titles don't select text": "Drag across a title" and "Drag across a node's badge and chips";
  - "Creation time after the title": "Rename keeps the time";
  - the title click in review mode opens the field, and ⌥R still renames the selected objective;
  - the tooltip risk: hovering a cut title shows the node's tooltip with the whole title (shot). If it shows none, give the title lines the node's tooltip, and say so here.

  Result (harness, data of 1.1; each title span has class `sf-act`, the pointing hand):
  - **Rename by click:** a click on o1's title `Fix login bug` opened the field (`ctl state` picker mode `prompt`, query `Fix login bug`). ⌘A, then typing `Fix login timeout` and Enter, left the graph shown with the node reading `Fix login timeout` and the kv title the same. Nothing was selected before or after.
  - **Rename keeps the time:** the field held the title without the time, and the node kept `11-08 14:40`.
  - **Beside a short title:** a click between o1's time and its ⋯ selected o1 and opened no field.
  - **Selection unchanged:** with o1 selected, a click on o3's title opened the field with `Prepare the quarterly planning slide`. Escape left o1 selected, o3 unselected and o3's title unchanged.
  - **Second line of a title:** a click on `contributors to the API` opened the field with the whole title of o2.
  - **Select and clear:** a click beside o2's first line selected it. The one tab node showed its link bar, and the edge layers became `ob-e-all ob-e-dim` plus `ob-e-sel` (shot `t2_selected`). A click on empty space cleared all of that (`t2_cleared`).
  - **Selecting a done objective:** a click on o5's second line, right of its review chip, selected it with no link bar and no field.
  - **Done and review titles:** a click on o5's title opened the field with its title, and Escape kept o5 selected. In review mode a click on o6's title opened the field with `Set up CI`, and review mode stayed on after Escape.
  - **⌥R:** `plugins run plugin.objectives.rename` with o5 selected opened the field with o5's title.
  - **Drag across a title:** a press on o1's note, dragged up across the title and released beside it, left the title and time pixels unchanged against a clean shot (mean difference 0.0), and no field opened.
  - **Drag across a node's badge and chips:** o1 got a due date (Today) and the tag `api` through ⋯. A drag from the note across the due and tag chips left both chips unchanged (0.0), while the selectable note changed (12.5), which shows the measure catches a highlight. A drag from the title across the badge to the line's start left the badge and title unchanged (0.0), with no field and priority still P3.
  - **Tooltip:** hovering the cut third line of o4's title showed Tern's tooltip with the whole title and `Created 2026-11-08 14:43` (shot `t2_hover`). Hovering takes the card's tooltip, so no fallback was needed.
  - **Log:** renders took at most 2.5 ms; no errors.

## 3. Attention marks

- [x] 3.1 Attention marks (D3): `Details.attention`, the per-objective mark and chip in `View.build`, the rings and chips in `styles.css`, and alerts in the refresh signature. README: the Features line.

  Verify with omp chats in harness tabs, read through the `agents` and `pane` helper ops, `ctl tree` classes and texts, and shots:
  - "Attention marks": "Question waiting" (chip tooltip from `ctl tree`), "Reply unseen", "Needs you wins" (two omp tabs), and "Not linked".
  - "Attention marks clear":
    - "Viewing clears a reply";
    - "Viewing keeps a question". This checks the design's inference. If Tern drops `waiting_input` on viewing, stop and ask the user;
    - "Selected and marked" (shot).
  - "Live refresh": with the graph shown, a reply finishing in a linked tab marks the node within a second, with no click.
  - "Light and dark themes": "Both appearances" under `ctl appearance light` and `ctl appearance dark`. Also compare the amber ring with the P1 badge's orange; if they look alike, apply the design's fallback and say so here.
  - A Done-group node and a review node linked to the waiting tab carry the mark.
  - The log's render times, and no errors.

  Result (harness; omp chats in tab 5 "Server" (pane 4) and tab 7 "Docs" (pane 6), both started unviewed from tab 3; links made in the graph: o1 "Fix login bug" → Server, o2 → Docs and later Server, o4 → Docs; done o5, due for review, → tab 3):
  - **Question waiting:** asked to put a yes/no question to me, the Server chat went `waiting_input`. o1 got `ob-att-wait` and a `needs you` chip with tooltip `omp is waiting in “Server”`.
  - **Not linked:** o3, linked to nothing, had no class or chip of either kind.
  - **Reply unseen and Live refresh:** with the graph shown and no clicks, the Docs chat answered "Reply with the single word ok.". Tern's tab alert `finished` and o4's `ob-att-replied` showed in the same 0.2 s poll, 1.7 s after the prompt. o2 and o4 had `replied` chips with tooltip `omp replied in “Docs”`, and the pane read `idle`, alert true, not focused.
    - Harness note: without window activity the harness runs no plugin timers, and the first mark (o1) showed only 5 s after the state change. This run kept `/tmp/tobj/bin/pump` going, as earlier changes did.
  - **Needs you wins:** with o2 linked to Docs (replied) and Server (waiting), o2 showed only `ob-att-wait` and `needs you` for “Server”.
  - **Selected and marked:** o1 selected had `ob-sel ob-att-wait`. The shot shows the accent ring outside the amber ring, with the `needs you` chip (`t3_marks`).
  - **Viewing clears a reply:** focusing pane 6 set its alert false. After the graph opened again, o4 had no mark, while o2 and o1 kept `needs you`.
  - **Viewing keeps a question:** focusing pane 4 set its alert false, but its state stayed `waiting_input`, which confirms the design's inference. After a fresh open, o1 still showed `needs you` for “Server”.
  - **Light and dark themes:** shots `t3_light` and `t3_dark`, with o3 at P1 for comparison. `edgecheck.py` passed on both.
    - Sampled rings: needs-you amber `(154,115,38)`, hue 40°, in light and `(255,179,71)`, hue 35°, in dark; replied green `(88,132,88)`, hue 120°, and `(0,255,136)`, hue 152°.
    - The P1 badge's orange is `(247,107,21)`, hue 23°, and reads clearly apart from the amber in both, so no fallback was needed.
    - Not re-checked here, and untouched by this change: no objective was P0 in these shots, and the one unlinked tab was also the origin tab.
  - **Done and review nodes:** omp in tab 3's shell asked a question. Done o5 got `ob-att-wait` and `needs you` in the Done group, and in review mode its 96 px review node kept both (`t3_review`), with the tooltip naming tab 3's label `omp`.
  - **Log:** renders took at most 7.2 ms; no errors. All three chats were closed, the serve stopped, and `~/.omp/agent/sessions/--private-tmp-tobj-*` was removed.

## 4. Release 0.16.0

- [x] 4.1 Version `0.16.0` in `plugin.toml`. Verify an isolated `tern plugin install` of the repo folder prints `installed objectives 0.16.0`. Tick this box, then commit, push `main` and tag `v0.16.0` (annotated, message "objectives 0.16.0").

  Result: the install into `/tmp/tobj-inst160/config` printed `installed objectives 0.16.0 → /tmp/tobj-inst160/config/plugins/objectives`.
- [ ] 4.2 **(live)** After the push has finished, run `tern plugin install github.com/JakobMusik/tern-objectives --force` from a shell with no harness variables.

  Verify `tern plugin list` shows `objectives 0.16.0 … ready`, with `tabnav 0.1.0` and `omp-narration 0.1.0` untouched.
- [ ] 4.3 **(live)** With the user:
  - a long title wraps onto up to three lines, and its lines stay on the node;
  - a click on a title opens Rename, and a click beside it selects;
  - an objective linked to a tab whose omp chat asks a question shows "needs you", and one whose chat replied while you were elsewhere shows "replied" until you view that tab.

  Record the result here.

## Workflow follow-up

- Archive the change (`openspec archive attention-marks-and-titles --yes`), run `openspec validate --specs --strict`, commit and push.
