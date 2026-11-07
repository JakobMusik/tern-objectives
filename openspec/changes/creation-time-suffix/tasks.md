# Tasks

Checks run in the headless harness at `/tmp/tobj` unless marked **(live)**.
- **Harness setup:** start the serve as a named service (`/tmp/tobj/bin/serve`, ready on "serving"), then `ctl plugins fixtures`; after each edit, `/tmp/tobj/bin/sync` and `ctl plugins fixtures` again, then reopen the graph if it closed (`ctl tree '.ob-root'` tells). Plugin timers fire only with window activity: use `/tmp/tobj/bin/pump`. Never source `/tmp/tobj/bin/env.sh` in a persistent shell.
- **Reading:** `ctl tree SEL` gives texts and rects; the expected time is `created` from the kv dump (`/tmp/tobj/bin/kv`) formatted as `%m-%d %H:%M` in local time. `ctl shot NAME` writes a PNG and its layout JSON; `/tmp/tobj/bin/edgecheck.py` checks line ends.
- **After the checks**, stop the harness service.

## 1. The creation time

- [x] 1.1 `Dates.short` (D1) and the node's `.ob-created` span with its rules and the title's `min-width` (D2).

  Verify each scenario of "Creation time after the title":
  - two "Write slides" made with "＋ New objective" a minute or more apart: each `.ob-created` text equals its kv `created` formatted, and both kv titles are "Write slides";
  - a 120-character title at 1400 px: the title's rect ends before the time's, the title is cut, and the time's rect width equals its width on a short-titled node;
  - at 460 px: the title keeps at least 3em, and the time is cut only after it (rect widths);
  - Rename: the field opens with the plain title, and after "Write talk slides" the time is unchanged;
  - done and review nodes show the time; a shot in light and dark shows it dimmed after the title;
  - `edgecheck.py` still passes at 1400 px.

  If the widths don't share out as D2 says, stop and update D2 first.

  Result (harness; clean store with o1 "Fix login bug", o2 "Write release notes", o5 with a 120-character title, done o3 due for review; o1 linked to tab 3 for the lines; graph as a full-window glimpse, 1200 px wide at window 1400 and 380 px at 460):
  - **D2 changed twice** (design.md, D2): with the title growing, the time sat at the line's far end by ⋯. Then with the time `flex: 1 0.001 auto` and no box, at 460 px neither the time nor ⋯ showed. Shrink factors below 1 in total take only that fraction of the overflow, so the line overflowed. The title and time now share the clipping `.ob-name` box.
  - **Two with one title:** o10 and o11, both "Write slides" in the kv dump, made a minute apart, read `11-07 19:56` and `11-07 19:57`, each equal to its `created` formatted.
  - **Long title at 1400 px:** o5's title is 322.2 px wide and cut with "…", its time 6.0 px after it, 53.9 px wide with 53.0 px of ink; o1, given o5's `created` so the text matches, has 53.5 px of ink. Short titles are followed by their time 6.0 px after them, and ⋯ is inside every node.
  - **460 px:** the name box has about 15 px on open nodes, as the title had before this change: the title shows 2–3 letters ("Fix", "Dra", "Wr"), clipped without "…", and the time is clipped away. ⋯ is inside every open node. A done node, which also has the trash icon, has no room for the name, as before, and its ⋯ already overflowed the node by 6 px before this change.
  - **Rename:** ⋯ → Rename opened the field holding "Write slides"; after "Write talk slides", o10 still reads `11-07 19:56`.
  - **Done and review:** done o3 shows `11-02 19:56`, also as the only node in "Review (1)". Shots `c11_light` and `c11_dark` show the times dimmed after the titles.
  - **`edgecheck.py`:** PASS at 1400 (`c11d_1400`) and 460 px (`c11d_460b`).
- [x] 1.2 Link choices (D3): the tab menu's row labels and the "Link this tab" picker's row detail.

  Verify each scenario of "Creation time in link choices":
  - with the two "Write slides" open, the tab menu (`ctl tree 'div.pop button.mi'`) has two rows "Write slides · <time>", and choosing one links only that objective in the kv dump;
  - the picker's rows (`ctl state`, and a shot) read "Write slides" with dim `P2 · <time>`;
  - picking one shows the toast "Linked to Write slides" (shot).

  Result (harness; o10 renamed back to "Write slides" in `kv.json`, created 11-07 19:56, and o11 "Write slides", 19:57):
  - **Tab menu** on tab 3: rows `Fix login bug · 11-07 17:56`, `Write release notes · 11-05 18:56`, the long title `… · 11-07 17:56`, `Write slides · 11-07 19:56`, `Write slides · 11-07 19:57`, then Copy (shot `c12_menu`). `menulink` on `Write slides · 11-07 19:57` linked o11 to tab 3 and left o10 unlinked.
  - **Picker** from tab 3's shell: rows `Write slides` with `P2 · 11-07 19:56` and `P2 · 11-07 19:57` (`ctl state` while stepping down; the shot `c12_picker` shows the details dimmed after the titles, and the long title's row cut with "…").
  - **Toast:** choosing the 19:56 row linked o10 to tab 3, and the toast reads "Linked to Write slides" (shot `c12_toast`).
  - **Render:** the graph showed stale rows right after `ctl plugins fixtures` until a click on "All" re-rendered it, as in earlier changes; renders took at most 5.3 ms, with no errors.
- [x] 1.3 README: the objective node's description and the "Right-click a tab" and "Link this tab" passages mention the creation time after the title. Verify by reading them against both requirements.

  Result: the "＋ New objective" bullet says every node shows its title followed, dimmed, by its creation time as `11-07 14:32`; that a long title is cut before the time is; and that renaming leaves the time alone. The "Right-click a tab" bullet gives the row form `Write slides · 11-07 14:32`, and the "Link this tab" command row gives `P2 · 11-07 14:32`. The README screenshot still shows nodes without the time; this task didn't cover regenerating it.

## 2. Release 0.14.0

- [x] 2.1 Version `0.14.0` in `plugin.toml`. Verify an isolated `tern plugin install` of the repo folder prints `installed objectives 0.14.0`. Tick this box, then commit, push `main` and tag `v0.14.0` (annotated, message "objectives 0.14.0").

  Result: the install into `/tmp/tobj-inst14/config` printed `installed objectives 0.14.0 → /tmp/tobj-inst14/config/plugins/objectives`.
- [ ] 2.2 **(live)** After the push has finished, `tern plugin install github.com/JakobMusik/tern-objectives --force`, from a shell with no harness variables. Verify `tern plugin list` shows `objectives 0.14.0 … ready`, with `tabnav 0.1.0` and `omp-narration 0.1.0` untouched.
- [ ] 2.3 **(live)** With the user: objective nodes, the tab menu and the "Link this tab" picker show the creation time after the title. Record the result here.

## Workflow follow-up

- Archive the change (`openspec archive creation-time-suffix --yes`), run `openspec validate --specs --strict`, commit and push.
