# Tasks

Checks run in the headless harness at `/tmp/tobj` unless marked **(live)**.
- **Demo:** the harness store from `/tmp/tobj/kv.pre-explore.json`: o1–o8 and o33, with o7 done.
- **Shots:** `ctl shot NAME` writes a PNG and its layout JSON. "No highlight" means a crop of the heading shows no selection fill, compared with a shot taken before the double-click or drag.

No design.md: one CSS rule, no decision left open.

## 1. Headings

- [ ] 1.1 Add `user-select: none` to `.ob-group` and `.ob-session` in `styles.css`.

  Verify, after `/tmp/tobj/bin/sync` and `ctl plugins fixtures`, with o3 and o5 marked done and the Done group open:
  - `ctl dblclick '.ob-donegrp .ob-gtext'`: the heading's crop shows no highlight ("Double-click on the Done header");
  - `ctl dblclick` on a session heading's name: no highlight ("Double-click on a session heading");
  - `/tmp/tobj/bin/dragsel` across "Done (n)", a session heading and "Closed tabs": no highlight;
  - the three drag checks of "Controls don't select text" still show no highlight;
  - `ctl dblclick` on o1's title: the word is highlighted ("Titles stay selectable").

## 2. Release 0.8.3

- [ ] 2.1 Version `0.8.3` in `plugin.toml`. Verify an isolated `tern plugin install` of the repo folder prints `installed objectives 0.8.3`, then commit, push `main` and tag `v0.8.3`.
- [ ] 2.2 **(live)** `tern plugin install github.com/JakobMusik/tern-objectives --force`, from a shell with no harness variables. Verify `tern plugin list` shows `objectives 0.8.3 … ready`, with `tabnav 0.1.0` untouched.
- [ ] 2.3 **(live)** With the user: double-clicking "Done (n)" or a session name highlights nothing, and titles still select. Record the result here.

## Workflow follow-up

- Archive the change (`openspec archive unselectable-group-headers --yes`), run `openspec validate --specs --strict`, commit and push.
- Stop the harness services.
