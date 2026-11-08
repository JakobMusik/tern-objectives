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

- [ ] 1.1 Title lines (D1): `Text.wrap`, the title rows in `View.build`, `Layout.add_obj` with a line count, and the `ob-n2`/`ob-n3` heights in the layout sheet and `styles.css`.

  Verify first the width choice: at the harness's 1280 px viewport, a node with a 36-character line and the time shows both whole (`ctl tree` text and a shot). If not, stop and change the width in design D1 and the "Title lines" requirement.

  Then each scenario, from `ctl tree` rects and texts and the shots:
  - "Title lines": "Short title", "Two lines" (with `edgecheck.py` on the shot), "More than three lines", and "Same breaks at any width" at 1400 and 900 px.
  - "Creation time after the title": "Long title" at 1400 px; "Done and review nodes" with a two-line title in the Done group and in review mode.
  - "Objective node content": "Long note".
  - "Larger hit areas": "Measured hit areas" and "Review nodes", with one-line and two-line titles present.
  - The log's render times, and no errors.

## 2. Click the title to rename

- [ ] 2.1 Rename by clicking the title (D2): `ren=` on each title line, act `ren` in `M.action`, `user-select: none` on `.ob-title`. README: in the commands table, "Rename" also by clicking a title.

  Verify, with `ctl click` on the title's rect and the Rename field read from `ctl state`:
  - "Rename by clicking the title": "Rename by click", "Selection unchanged", "Beside a short title", and "Second line of a title";
  - "Selection": "Select and clear" (a click beside the title) and "Selecting a done objective" (a click on the second line);
  - "Controls and titles don't select text": "Drag across a title" and "Drag across a node's badge and chips";
  - "Creation time after the title": "Rename keeps the time";
  - the title click in review mode opens the field, and ⌥R still renames the selected objective;
  - the tooltip risk: hovering a cut title shows the node's tooltip with the whole title (shot). If it shows none, give the title lines the node's tooltip, and say so here.

## 3. Attention marks

- [ ] 3.1 Attention marks (D3): `Details.attention`, the per-objective mark and chip in `View.build`, the rings and chips in `styles.css`, and alerts in the refresh signature. README: the Features line.

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

## 4. Release 0.16.0

- [ ] 4.1 Version `0.16.0` in `plugin.toml`. Verify an isolated `tern plugin install` of the repo folder prints `installed objectives 0.16.0`. Tick this box, then commit, push `main` and tag `v0.16.0` (annotated, message "objectives 0.16.0").
- [ ] 4.2 **(live)** After the push has finished, run `tern plugin install github.com/JakobMusik/tern-objectives --force` from a shell with no harness variables.

  Verify `tern plugin list` shows `objectives 0.16.0 … ready`, with `tabnav 0.1.0` and `omp-narration 0.1.0` untouched.
- [ ] 4.3 **(live)** With the user:
  - a long title wraps onto up to three lines, and its lines stay on the node;
  - a click on a title opens Rename, and a click beside it selects;
  - an objective linked to a tab whose omp chat asks a question shows "needs you", and one whose chat replied while you were elsewhere shows "replied" until you view that tab.

  Record the result here.

## Workflow follow-up

- Archive the change (`openspec archive attention-marks-and-titles --yes`), run `openspec validate --specs --strict`, commit and push.
