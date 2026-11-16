# Tasks

Checks run in the headless harness at `/tmp/tobj` unless marked **(live)**.
- **Harness:** `/tmp/tobj/bin/{env.sh,serve,ctl,sync,op,kv,pump}` and the helper plugin `tobjh` are in place from search-and-tab-marks.
  - Start the serve as a named service (`/tmp/tobj/bin/serve`, ready on "serving"), then run `ctl plugins fixtures`.
  - After each edit, run `/tmp/tobj/bin/sync` and `ctl plugins fixtures` again, then reopen the graph if it closed (`ctl tree '.ob-root'` tells).
  - Never source `/tmp/tobj/bin/env.sh` in a persistent shell, and never run `tern serve --help`, which serves.
- **Layout:** the README demo, rebuilt in a fresh serve as search-and-tab-marks task 3.1 built it:
  - session docs: Guides (a shell) and Release notes (an omp pane);
  - session web: App build (panes app and tests) and Components (a shell and `todo.md`);
  - session api: Server (a shell and an omp pane) and Benchmarks (a shell).
- **Store:** the demo store left in `/tmp/tobj/config/plugin-data/objectives/kv.json` (key `"state"`). Copy it to `/tmp/tobj/kv.demo-0250.json` before any check changes it, and remap its tab ids if the rebuilt layout's differ. Group 1 changes links and review dates freely; group 2 starts from the copy.
- **Reading:**
  - `ctl hover <selector>` (the element's centre) or `ctl move X Y` to rest the pointer, then `ctl shot NAME` for a PNG and layout JSON;
  - `ctl tree '.ob-obj'` for node classes, texts and tooltips;
  - `ctl click` for real hit-testing;
  - `ctl state` for focus and fields;
  - kv dumps of `kv.json`;
  - the helper's `focus`, `move_to_tab` and `close` ops to set, move and close the origin pane;
  - the serve log, `/tmp/tobj/logs/tern-serve.log`, for render times and warnings.
- **After the checks:** stop the harness service, and remove the chat folders the checks created under `~/.omp/agent/sessions/`.

## 1. The link button

- [x] 1.1 The button (design D1–D4):
  - in `lib/view.luau`, `quick_tab` in `View.build`, and the `qlink` argument of `objective_node`, passed by `add_node`;
  - its CSS in `styles.css`: the box, the hover reveal, the pointer look and the highlighted look;
  - README: one sentence in "Link tabs to objectives".

  Verify, with the graph opened from Guides's shell unless a scenario says otherwise:
  - tab-links "Link button on objective nodes", every scenario:
    - "Shown while pointing": `ctl hover` on "Speed up search", then a shot. In `ctl tree`, `.ob-qlink` is the last child of its `.ob-l1` with the tooltip `Link to “Guides”`. Any other node that doesn't link Guides has its `.ob-qlink` at opacity 0, read in the shot;
    - "Linked nodes keep it": `ctl move` to empty graph space, then a shot. `ob-qlink-on` is on exactly the two nodes;
    - "Review node": set "Set up CI"'s review due today, turn on review mode, `ctl hover` on its node, then a shot. `.ob-qlink` comes right before `.ob-trash`;
    - "Origin pane closes": open the graph from App build's tests pane, then close that pane with the helper's `close` op. Within 1.2 s, `ctl tree` holds no `.ob-qlink`;
    - "While moving": `ctl click` on the grip of "Speed up search", then `ctl hover` on "Read about rate limiting". `ctl tree` holds no `.ob-qlink`;
  - tab-links "Link button clicks", every scenario, each with `ctl click` on the button and a kv dump:
    - "Link from the node": also check no `ob-sel` in `ctl tree`, `ob-lit` on the node, a thick line to Guides in a shot, and `ctl state` focus unchanged;
    - "Unlink from the node";
    - "Selection kept": select "Fix login bug" first;
    - "Done objective", with the Done group open;
    - "Origin pane moved": open the graph from App build's tests pane, then move that pane into Server with `move_to_tab`. After 1.2 s, read the tooltip with `ctl tree`, then click;
    - "Ends the Undo notice": mark an objective done, then click a link button before 10 s pass;
  - objectives-graph "Selection": "Link button doesn't select", and "Select and clear" still holds;
  - objectives-graph "Larger hit areas": "Measured hit areas" from a shot's layout JSON, with the link buttons included, and "Review nodes";
  - "Objective node content": "Long note" still holds;
  - the narrower line (design risk): a 36-character one-line title at 460 px wide. Record whether its first line or creation time is cut with "…";
  - the look (design risk): crops of a plain button under the pointer and of a highlighted one on an `ob-lit` node, in light and dark (`ctl appearance`);
  - "Link lines" "Alignment at two widths": every line end within 2 px of its node and tab header centres at 1400 and 460 px wide, read from the layout JSON;
  - the README sentence, read back;
  - render times in the serve log stay within the 20 ms target, with no objectives warnings or errors.

  Result (harness, 2026-11-16, Tern 0.9.21):
  - **Harness:** a `/tmp` cleanup had emptied `/tmp/tobj/bin`, the helper's folder and the demo store. The scripts and the helper's `plugin.toml` and `window.luau` were written again from their last versions in this session's history, with `STENCIL_FIXTURE_ROOT=/tmp/tobj/crates/app`. Both plugins loaded with no errors; the log's only warning was the helper's own `esc_probe` on Escape.
  - **Layout and store:** the demo was rebuilt in a fresh serve in `/tmp/tobj/w/demo/guides`, with the same ids as before:
    - docs: Guides 3 (pane 2) and Release notes 5 (omp, pane 4);
    - web: App build 8 (panes 7 and 9) and Components 12 (pane 11 and `todo.md` in pane 20);
    - api: Server 15 (pane 14 and omp in pane 16) and Benchmarks 19 (pane 18).

    The store was written from search-and-tab-marks 3.1's data, with due dates from today, and saved as `/tmp/tobj/kv.demo-0250.json`.
  - **"Link button on objective nodes":**
    - **Shown while pointing:** with the pointer on "Speed up search", its `.ob-l1` read grip, box, badge, name, `ob-qlink`, with the tooltip `Link to “Guides”`. In shot `ql_hover`, its button had 204 ink pixels. Every other unlinked node's button had 0, and the two linked ones 186 and 155.
    - **Linked nodes keep it:** with the pointer on the header's empty space, `ob-qlink-on` was on "Read about rate limiting" and "Restyle the docs site" only, both titled `Unlink from “Guides”`. In shot `ql_rest`, only those two buttons had ink.
    - **Review node:** with "Set up CI" due today and review mode on, the pointer on its node gave name, `ob-qlink`, `ob-trash` at the end of its `.ob-l1`. The crop shows the link icon just left of the trash icon.
    - **Origin pane closes:** run on a two-pane tab "Scratch" added to web, rather than App build's tests pane, so the demo layout stayed whole. Opened from Scratch's second pane, the buttons read `Link to “Scratch”`. 0.08 s after the helper's `close`, `ctl tree` held no `.ob-qlink` and no `.ob-origin`, and the graph was still shown.
    - **While moving:** with "Speed up search" lifted and the pointer on "Read about rate limiting", `ctl tree` held 0 `.ob-qlink` and 4 `.ob-drop`. A click on empty space ended the move, and the 10 buttons came back.
  - **"Link button clicks":**
    - **Link from the node:** "Speed up search" went from `[19]` to `[19, 3]`. Afterwards nothing was selected, with no action bar or link bar. The node had `ob-lit` and the button `ob-qlink-on`, titled `Unlink from “Guides”`. The edge layers read `ob-e-all ob-e-dim` and `ob-e-sel`, the graph was still shown, and focus stayed on the graph's pane (48). Shot `ql_linked` shows a thick blue line from it to Guides.
    - **Unlink from the node:** a second click gave `[19]`, no `ob-lit`, and `Link to “Guides”`. The crop of shot `ql_unlinked` shows no line from it to Guides.
    - **Selection kept:** with "Fix login bug" selected, a click on the button of "Speed up search" gave `[19, 3]`. "Fix login bug" was still selected with its action bar, and the tabs still had their 6 link bars.
    - **Done objective:** "Set up CI" went from `[8]` to `[8, 3]` and stayed done. With the pointer away, its `ob-qlink-on` button showed (180 ink pixels).
    - **Origin pane moved:** opened from pane 9 in App build, the tooltip read `Link to “App build”`. After `move_to_tab` 9 → Server:
      - **First try, without activity:** after 1.2 s the graph had not redrawn, since the headless serve runs plugin timers only while the window is busy. The tooltip still named App build, and the click linked App build, the tab the button was drawn for (design D3). That link was removed by hand.
      - **Second try, with `pump 2` (1.5 s):** the origin ring was on Server, and the tooltip read `Link to “Server”`. The click gave `[19, 15]`, with no link to App build.
    - **Ends the Undo notice:** after marking "Update dependencies" done, the notice read `Marked done “Update dependencies” ·`. A click on the link button of "Speed up search" 0.3 s later left no `.ob-undo` and gave `[19, 3]`, and "Update dependencies" stayed done.
  - **"Selection":**
    - **Link button doesn't select:** after the click, nothing was selected, with no action bar or link bar.
    - **Select and clear:** opened from Scratch, which no objective links. A click on the second line of "Speed up search" selected it, with its action bar, 7 link bars and the layers `ob-e-all ob-e-dim` and `ob-e-sel`. A click on empty space left none of them, only `ob-e-all`.
  - **"Larger hit areas":**
    - **Measured hit areas:** shot `ql_hit`, with "Speed up search" selected:
      - 7 grips, 10 done boxes, 9 trash icons (tab nodes' included) and 10 link buttons, all 22 × 18;
      - 4 action bar buttons, all 22 tall;
      - 9 jump buttons, 28 × 22;
      - pane rows 22 tall;
      - the 7 unselected nodes with one-line titles, all 48 tall.
    - **Review nodes:** in review mode, 6 rating buttons, all 22 tall. Both listed nodes were 78 tall, and both link buttons 22 × 18.
  - **"Long note":** "Update dependencies" with a 200-character note stayed 48 px tall. The crop shows the note cut with "…" before the "due today" chip, and the node's tooltip holds the whole note.
  - **Narrower line** (design risk), "Draft the onboarding email sequences" (36 characters, one line):
    - **460 px window** (graph 379.5 px, node 116.8 px): beside the hidden button, the title showed nothing after the P1 badge. With the button gone (an objective lifted), it showed "Draf", clipped with no "…". Either way the title can't be read at this width.
    - **600 px window:** "Draft… 10" with the button, "Draft… 10-29 1" without.
    - **800 px window:** "Draft the … 10-29 14:05" with the button, "Draft the onbo… 10-29 14:05" without.
  - **Look** (design risk), crops in light and dark:
    - a plain button under the pointer is the accent on a light accent tint;
    - the highlighted button on the tinted "Read about rate limiting" is the accent on a stronger tint, and turns red under the pointer.

    In light mode the highlighted button is low contrast on the tint, but it can still be told apart; in dark mode it is clearly visible. D4 stands.
  - **"Alignment at two widths":** at 1400 (graph 1200 px) and 460 (graph 379.5 px), all 7 left and 6 right line ends sat within 0.55 px of their centres.
  - **README:** "Link tabs to objectives" now reads "Quicker still, point at an objective and click its link icon to link the tab you opened the graph from; the icon stays highlighted while they are linked, and clicking it again unlinks them."
  - **Log:** 75 renders, the longest 10.5 ms, none over 20 ms, and no objectives warnings or errors.

## 2. The README screenshots

- [x] 2.1 Take `docs/graph.png` and `docs/review.png` again (design D5), from the store saved in `/tmp/tobj/kv.demo-0250.json`:
  - **`graph.png`:**
    - Release notes' omp chat replies while Guides has focus, and Server's waits for input;
    - the same window size (`ctl resize 1045 928`) and crop (914 × 808);
    - opened from Guides, with nothing selected, the Done group open and the pointer off the graph.
  - **`review.png`:**
    - review mode with "Restyle the docs site" and "Profile slow search queries" due, and the latter selected;
    - opened from Guides, and cropped to the header, the two review nodes and the `Linked to` section, 1828 px wide.

  Update both alt texts to name the button. Show both drafts to the user before committing them.

  Verify:
  - plugin-package "README": "README contents" and "Graph screenshot first";
  - "Screenshots match this version": open nodes show grips, and no node in either image shows ⋯;
  - `graph.png`: "Read about rate limiting" shows the highlighted button, and no other open node shows one;
  - `review.png`: "Restyle the docs site" shows the highlighted button, and the header shows the Search button;
  - every line end in both shots sits within 2 px of its node and tab header centres, read from the layout JSON;
  - the user approved both drafts.

  Result (harness, 2026-11-16):
  - **Chats:** with Guides focused, Release notes' chat answered "In two short sentences, say what release notes for a web app should cover." (`idle` with its alert). Server's chat put a yes/no question about restarting the server before deploying, and waited (`waiting_input`). Both took 6 s.
  - **`graph.png`** (1828 × 1616):
    - `ctl resize 1045 928`, opened from pane 2 in Guides, the pointer at (3, 3), outside the graph. The glimpse was at the same box as before, 914.31 × 808.08, and was cropped there.
    - "Read about rate limiting" is tinted, with a thick line to Guides and the highlighted button. "Restyle the docs site" in the Done group shows it too. The other buttons had 0 ink pixels.
    - "Fix login bug" and Server are ringed amber with "needs you", and "Write release notes" and Release notes green with "replied".
    - All 7 open nodes have grips, and no node has ⋯.
    - The 22 px the button keeps cuts the second line of "Review pull requests for the onboarding and settings pages" to "onboarding and settings p…". The user was told this with the drafts.
    - All 7 left and 6 right line ends sit within 0.3 px of their centres, measured 3 px inside the gap.
  - **`review.png`** (1828 × 857, 4 px taller than before):
    - review mode, opened from Guides, with "Profile slow search queries" selected: its Note and Tags row, and Benchmarks under `Linked to` with "× Unlink";
    - "Restyle the docs site" shows the highlighted button beside its trash icon;
    - the header shows the Search button;
    - cropped from the glimpse's top to 8 px below the Guides node;
    - the one green line's ends sit within 0.3 px. The gap column's other marks were at y 873 and 904, in the footer below the crop.

    The ratings now read Hard · 2d, Good · 10d, Easy · 14d for "Restyle the docs site", where they read 9d for Good before. The rebuilt store's review data gives that.
  - **Alt texts:**
    - `graph.png`'s now names the highlighted icons on "Read about rate limiting" and "Restyle the docs site";
    - `review.png`'s names the highlighted icon, the Search button and Good · 10d.
  - **README checks:** the README has two images, `docs/graph.png` first (line 5), then `docs/review.png` (line 26). "README contents" still holds: the graph shot has the Done group open and Server marked "needs you", and the review shot has Hard, Good and Easy.
  - **Approval:** the user approved both drafts before they were committed.
  - **Cleanup:**
    - the serve was stopped with `ctl quit`;
    - the chat folders `--private-tmp-tobj-w-demo-notes--` and `--private-tmp-tobj-w-demo-serverchat--`, created today, were removed;
    - `--private-tmp-tobj-w-docs--` and `--private-tmp-tobj-w-server--`, from earlier runs, were left as they were.

## 3. Release 0.26.0

- [x] 3.1 Version `0.26.0` in `plugin.toml`. Verify that an isolated `tern plugin install` of the repo folder prints `installed objectives 0.26.0`. Tick this box, then commit, push `main` and tag `v0.26.0` (annotated, message "objectives 0.26.0").

  Result: the install into `/tmp/tobj-inst260/config` printed `installed objectives 0.26.0 → /tmp/tobj-inst260/config/plugins/objectives`.
- [ ] 3.2 **(live)** After the push has finished, run `tern plugin install github.com/JakobMusik/tern-objectives --force` from a shell with no harness variables.

  Verify `tern plugin list` shows `objectives 0.26.0 … ready`, with the other plugins untouched.
- [ ] 3.3 **(live)** With the user:
  - pointing at an objective in a graph opened from a tab shows a link icon at the right of its first line. A click links that tab: the node turns tinted with a thick line to the tab, and the icon stays, highlighted;
  - a click on the highlighted icon unlinks the tab;
  - in the open Done group, the icon links a done objective the same way.

  Record the result here.

## Workflow follow-up

- Archive the change (`openspec archive quick-link-button --yes`), run `openspec validate --specs --strict`, commit and push.
