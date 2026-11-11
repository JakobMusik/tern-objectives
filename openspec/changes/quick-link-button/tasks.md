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

- [ ] 1.1 The button (design D1–D4):
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

## 2. The README screenshots

- [ ] 2.1 Take `docs/graph.png` and `docs/review.png` again (design D5), from the store saved in `/tmp/tobj/kv.demo-0250.json`:
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

## 3. Release 0.26.0

- [ ] 3.1 Version `0.26.0` in `plugin.toml`. Verify that an isolated `tern plugin install` of the repo folder prints `installed objectives 0.26.0`. Tick this box, then commit, push `main` and tag `v0.26.0` (annotated, message "objectives 0.26.0").
- [ ] 3.2 **(live)** After the push has finished, run `tern plugin install github.com/JakobMusik/tern-objectives --force` from a shell with no harness variables.

  Verify `tern plugin list` shows `objectives 0.26.0 … ready`, with the other plugins untouched.
- [ ] 3.3 **(live)** With the user:
  - pointing at an objective in a graph opened from a tab shows a link icon at the right of its first line. A click links that tab: the node turns tinted with a thick line to the tab, and the icon stays, highlighted;
  - a click on the highlighted icon unlinks the tab;
  - in the open Done group, the icon links a done objective the same way.

  Record the result here.

## Workflow follow-up

- Archive the change (`openspec archive quick-link-button --yes`), run `openspec validate --specs --strict`, commit and push.
