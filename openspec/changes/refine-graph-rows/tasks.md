# Tasks

Checks run in the headless harness at `/tmp/tobj` unless marked **(live)**.
- **Demo:**
  - session "web": "App build" (panes "app", "notes") and "Components" ("ui", plus a `todo.md` file pane);
  - session "api": "Server" and "Benchmarks";
  - session "docs": "Guides" and an `extra` tab;
  - objectives o1–o8.
- **Kv dump** reads `/tmp/tobj/config/plugin-data/objectives/kv.json`.
- **Helper dump** is `/tmp/tobj/bin/graphs`.

## 1. Column order

- [x] 1.1 Origin's session and tab first (design R1).

  Verify, from the tree order of `.ob-session` and `.ob-tab` nodes:
  - opened from api's "Benchmarks", the column reads api (Benchmarks, Server), web, docs;
  - closed, then reopened from web's "Components", it reads web (Components, App build), api, docs;
  - after the origin pane closes (helper `close`) while shown, Tern's order returns within a second.

  Result (`/tmp/tobj/bin/order`):
  - from Benchmarks (pane 17): `[api] Benchmarks Server [web] App build Components [docs] Guides omp`;
  - from Components (pane 15): `[web] Components App build [api] Server Benchmarks [docs] …`;
  - origin split 31 in Components, then closed: 1.2 s later `[web] App build Components …`, with no origin mark left.

## 2. Tab node look

- [x] 2.1 Unlinked tabs: full-strength text, grey fill, dashed border; ghosts unchanged (design R2).

  Verify, in shots before and after linking an unlinked tab from the graph (kv dump shows the link): the node's fill changes from grey to the card colour, and its label's text colour is the same in both.

  Result: with o6 selected, the "＋ Link" bar on docs's `omp` tab (20) gave o6 `[9, 20]`. In shots `u21_before` and `u21_after`, the fill went from `(239,239,239)` to `(255,255,255)`, and the label's darkest pixel stayed `(59,59,59)`.
- [x] 2.2 Light and dark appearances.

  Verify: in shots of both appearances, the unlinked fill differs from linked cards, all badge colours show, and `edgecheck.py` passes.

  Result, shots `u22_light` and `u22_dark` with the unlinked tab "misc":
  - the first fill, 5 % ink over the page, sat 3 levels from the dark card. Moved to an ink layer over the card (design R2);
  - now unlinked `239` vs linked `255` in light, `(45,48,56)` vs `(29,32,40)` in dark;
  - all four badge colours and every line show in both;
  - `edgecheck.py` passes both (7 objective ends, 6 tab ends).

## 3. Pane rows

- [x] 3.1 Rows start folded, `view.expanded` replaces `view.collapsed`, and the toggle is 28 px wide with a 15 px glyph (design R3).

  Verify:
  - a fresh open shows no `.ob-detail`, only ▸;
  - a click on ▸ shows the details, and the kv dump's `view.expanded` lists the pane, with no `collapsed` key;
  - a click on ▾ folds it again;
  - a row opened, then the graph closed and reopened, is still open;
  - layout data shows every toggle at least 28 × 22, rows 22 and objective nodes 48; `edgecheck.py` passes with some rows open.

  Result:
  - the first open after the upgrade showed 9 `▸` and no details;
  - ▸ on row 15 opened it, and the kv dump read `expanded: {"15": true}` with `collapsed` gone; ▾ folded it, giving `expanded: {}`. Focus stayed on the canvas (pane 39);
  - rows 15 and 8, opened, then the graph closed and reopened: both still open (2 `▾`, 7 `▸`);
  - layout (shot `s31`): toggles 28 × 22, done box and ⋯ 22 × 18, nodes 48, rows 22; `edgecheck.py` passes.
- [x] 3.2 Pane type at each row's start, with the agent's state (design R4).

  Verify with `ctl tree`:
  - the "Components" rows start with "shell" and "file";
  - an `omp --no-session --model haiku --max-cost 0.05` pane starts with "omp · idle", and with "omp · working" mid-turn while folded;
  - a linked tab closed with the helper shows "shell" under "Closed tabs".

  Result (`ctl tree '.ob-row'`):
  - "Components" reads `shell ui`, `file todo.md`; the other terminals read `shell`;
  - the idle omp read `omp · idle`, and once prompted its folded row read `▸omp · working` within 0.4 s;
  - "misc", linked to o8 and then closed, shows `shell misc` under "Closed tabs". The closed omp tab shows `agent omp`: only the stored kind is left (design R4).
- [x] 3.3 Agent lines `you: …` and `omp: …` with a middle cut (design R5).

  Verify: after a haiku exchange whose prompt and reply are both over 200 characters, the open row's `ctl tree` shows "you: " and "omp: " lines. The shot shows each line's beginning, "…", and the message's end. If the `text` node doesn't cut in the canvas, stop and update design R5.

  Result, with a 320-character prompt and a 430-character reply (haiku, $0.01):
  - **Native cut, dropped.** Tern's `truncate = "middle"` cut the middle, but kept about four characters too many, so the node clipped its own end ("…particip"). This held after a resize refit and with `system-ui`. Design R5 was updated and the lines moved to a CSS split.
  - **CSS split.** `ctl tree` shows `you:` and `omp:` lines with the whole messages. Shots `s33_split_1100` and `s33_split_1500` show "you: BEGIN. Please answer in one plain paragraph o… ends with the word FINISH" and "omp: A cache is a small, fast storage layer that keep… measured latency.", with more of the beginning at 1500 px.
  - **Measured.** Every tail ends exactly at the line's content edge (1012.4 and 1293.6), and `edgecheck.py` passes at both widths with the row open.

## 4. Unselectable controls

- [ ] 4.1 `user-select: none` on chips, badges, header buttons and the toggle (design R6).

  Verify: `ctl down`/`move`/`up` drags:
  - from the header's empty space across "＋ New objective", the tag filter chips and "All" / "This session";
  - from an objective's side note across its due and tag chips, then up across its badge.

  Shots show no highlight on those controls, and the kv dump shows the priority unchanged.

## 5. Docs and release

- [ ] 5.1 README: rows start folded, each with its type; agent rows give "you:" and "<agent>:" lines cut in the middle; the origin's tab comes first; unlinked tabs are grey with a dashed border. Refresh `docs/graph.png` from a harness shot, and drop the known limit about selectable badges, chips and header buttons.

  Verify: `grep` finds the new points and no "selectable"; the screenshot shows folded rows with type labels.
- [ ] 5.2 Version `0.5.0`: an isolated install prints `installed objectives 0.5.0`; commit, push `main`, tag `v0.5.0`; `tern plugin install github.com/JakobMusik/tern-objectives --force` live.

  Verify: the tags API lists `v0.5.0`, and live `tern plugin list` shows `objectives 0.5.0` ready.
- [ ] 5.3 **(live)** With the user:
  - the graph opened from a later tab lists that tab's session and tab first;
  - unlinked tabs read at full strength;
  - rows start folded and the toggle is easy to hit;
  - a note's row starts with "note";
  - an omp row reads "omp · <state>", with "you:" / "omp:" lines cut in the middle;
  - dragging across chips, badges and header buttons selects nothing.

  Record the findings here.

## Workflow follow-up

- Run the verify workflow, then archive the change into `openspec/specs/` and commit.
- Stop the harness services.
