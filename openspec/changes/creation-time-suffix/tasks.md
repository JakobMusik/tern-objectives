# Tasks

Checks run in the headless harness at `/tmp/tobj` unless marked **(live)**.
- **Harness setup:** start the serve as a named service (`/tmp/tobj/bin/serve`, ready on "serving"), then `ctl plugins fixtures`; after each edit, `/tmp/tobj/bin/sync` and `ctl plugins fixtures` again, then reopen the graph if it closed (`ctl tree '.ob-root'` tells). Plugin timers fire only with window activity: use `/tmp/tobj/bin/pump`. Never source `/tmp/tobj/bin/env.sh` in a persistent shell.
- **Reading:** `ctl tree SEL` gives texts and rects; the expected time is `created` from the kv dump (`/tmp/tobj/bin/kv`) formatted as `%m-%d %H:%M` in local time. `ctl shot NAME` writes a PNG and its layout JSON; `/tmp/tobj/bin/edgecheck.py` checks line ends.
- **After the checks**, stop the harness service.

## 1. The creation time

- [ ] 1.1 `Dates.short` (D1) and the node's `.ob-created` span with its rules and the title's `min-width` (D2).

  Verify each scenario of "Creation time after the title":
  - two "Write slides" made with "＋ New objective" a minute or more apart: each `.ob-created` text equals its kv `created` formatted, and both kv titles are "Write slides";
  - a 120-character title at 1400 px: the title's rect ends before the time's, the title is cut, and the time's rect width equals its width on a short-titled node;
  - at 460 px: the title keeps at least 3em, and the time is cut only after it (rect widths);
  - Rename: the field opens with the plain title, and after "Write talk slides" the time is unchanged;
  - done and review nodes show the time; a shot in light and dark shows it dimmed after the title;
  - `edgecheck.py` still passes at 1400 px.

  If the widths don't share out as D2 says, stop and update D2 first.
- [ ] 1.2 Link choices (D3): the tab menu's row labels and the "Link this tab" picker's row detail.

  Verify each scenario of "Creation time in link choices":
  - with the two "Write slides" open, the tab menu (`ctl tree 'div.pop button.mi'`) has two rows "Write slides · <time>", and choosing one links only that objective in the kv dump;
  - the picker's rows (`ctl state`, and a shot) read "Write slides" with dim `P2 · <time>`;
  - picking one shows the toast "Linked to Write slides" (shot).
- [ ] 1.3 README: the objective node's description and the "Right-click a tab" and "Link this tab" passages mention the creation time after the title. Verify by reading them against both requirements.

## 2. Release 0.14.0

- [ ] 2.1 Version `0.14.0` in `plugin.toml`. Verify an isolated `tern plugin install` of the repo folder prints `installed objectives 0.14.0`. Tick this box, then commit, push `main` and tag `v0.14.0` (annotated, message "objectives 0.14.0").
- [ ] 2.2 **(live)** After the push has finished, `tern plugin install github.com/JakobMusik/tern-objectives --force`, from a shell with no harness variables. Verify `tern plugin list` shows `objectives 0.14.0 … ready`, with `tabnav 0.1.0` and `omp-narration 0.1.0` untouched.
- [ ] 2.3 **(live)** With the user: objective nodes, the tab menu and the "Link this tab" picker show the creation time after the title. Record the result here.

## Workflow follow-up

- Archive the change (`openspec archive creation-time-suffix --yes`), run `openspec validate --specs --strict`, commit and push.
