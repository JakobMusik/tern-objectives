# Tasks

Checks run in the headless harness at `/tmp/tobj` unless marked **(live)**.
- **Demo:** the harness store from `/tmp/tobj/kv.pre-explore.json`: o1–o8 and o33, with o7 done.
- **Shots:** `ctl shot NAME` writes a PNG and its layout JSON. "No highlight" means a crop of the heading shows no selection fill, compared with a shot taken before the double-click or drag.

No design.md: one CSS rule, no decision left open.

## 1. Headings

- [x] 1.1 Add `user-select: none` to `.ob-group` and `.ob-session` in `styles.css`.

  Verify, after `/tmp/tobj/bin/sync` and `ctl plugins fixtures`, with o3 and o5 marked done and the Done group open:
  - `ctl dblclick '.ob-donegrp .ob-gtext'`: the heading's crop shows no highlight ("Double-click on the Done header");
  - `ctl dblclick` on a session heading's name: no highlight ("Double-click on a session heading");
  - `/tmp/tobj/bin/dragsel` across "Done (n)", a session heading and "Closed tabs": no highlight;
  - the three drag checks of "Controls don't select text" still show no highlight;
  - `ctl dblclick` on o1's title: the word is highlighted ("Titles stay selectable").

  Result (harness, 2026-11-06). `hl.py` gives each element's mean pixel change against the shot before; 0.00 is no change:
  - double-click on "Done (3)" with the group open: 0.00;
  - double-click on the "Default" session name: 0.00 on the heading and the name;
  - drags across "Done (3)", the session heading and "Closed tabs": 0.05, 0.00 and 0.00. The 0.05 is the caret: the drag's press and release toggled the group. Its crop shows no highlight;
  - `dragsel`/`seldiff.py`: Prune, New objective, the tag filters, All / This session, the due chip, the tag chip and the badge all 0.0. o1's side note (10.1) and title (4.0) still select;
  - double-click on o1's title highlighted "bug".

  `.ob-linkhead` and `.ob-divider` dropped their own `user-select` line, which `.ob-group` now covers.

## 2. Release 0.8.3

- [x] 2.1 Version `0.8.3` in `plugin.toml`. Verify an isolated `tern plugin install` of the repo folder prints `installed objectives 0.8.3`, then commit, push `main` and tag `v0.8.3`.

  Result: the isolated install (`/tmp/tobj-rel`) printed `installed objectives 0.8.3`, and `tern plugin list` showed `objectives 0.8.3 … 0 blocks, 0 lenses, window ready`.
- [x] 2.2 **(live)** `tern plugin install github.com/JakobMusik/tern-objectives --force`, from a shell with no harness variables. Verify `tern plugin list` shows `objectives 0.8.3 … ready`, with `tabnav 0.1.0` untouched.

  Result: `installed objectives 0.8.3 → ~/Library/Application Support/Tern/plugins/objectives`; `tern plugin list` shows `objectives 0.8.3 … ready` and `tabnav 0.1.0 … ready`. The tag is `v0.8.3` (`fe07847`), with the message "v0.8.3" instead of the usual "objectives 0.8.3"; it was left, since a published tag isn't moved.
- [x] 2.3 **(live)** With the user: double-clicking "Done (n)" or a session name highlights nothing, and titles still select. Record the result here.

  Result (user, checked on 0.10.0, which includes this change): confirmed.

## Workflow follow-up

- Archive the change (`openspec archive unselectable-group-headers --yes`), run `openspec validate --specs --strict`, commit and push.
- Stop the harness services.
