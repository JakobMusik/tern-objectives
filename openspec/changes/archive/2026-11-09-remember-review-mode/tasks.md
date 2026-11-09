# Tasks

Checks run in the headless harness at `/tmp/tobj` unless marked **(live)**.
- **Harness setup:** start the serve as a named service (`/tmp/tobj/bin/serve`, ready on "serving"), then `ctl plugins fixtures`. After each edit, run `/tmp/tobj/bin/sync` and `ctl plugins fixtures` again, then reopen the graph if it closed (`ctl tree '.ob-root'` tells). Never source `/tmp/tobj/bin/env.sh` in a persistent shell.
- **Reading:**
  - `ctl tree '.ob-obj'` for the left column, and `ctl tree '.ob-revbtn'` for the Review button and its `ob-on` class;
  - `/tmp/tobj/bin/kv` for the store;
  - `ctl shot NAME` for a PNG and layout JSON.
- **Data:** a store with three open objectives ("Fix login bug", "Review pull requests", "Write slides") and done objectives, two of them due today. Restore it from a copy under `/tmp/tobj` before each scenario that rates or removes.
- **After the checks:** stop the harness service.

## 1. Remember review mode

- [x] 1.1 Keep the window's flag across opens (design D1, D2): `M.open` no longer clears `reviewing`. Update the comments on `reviewing` in `lib/app.luau`.

  Verify each objective-review "Leaving review mode" scenario, toggling the graph with `plugins run plugin.objectives.open` and reading `ctl tree`:
  - "Reopened in review mode": "Review (2)" has `ob-on` and only the two due objectives are listed;
  - "Left before closing";
  - "Nothing due at the next open": remove the due record from the harness `kv.json` by hand, then put it back;
  - "Forgotten on reload", with `ctl plugins fixtures`;
  - "Last one rated", "Button clicked again" and "Picker from review mode", unchanged.

  Also check that a fresh open in review mode still clears the Undo notice, and that the settings page's "Next open shows the graph" still holds: ⌃⌘O twice from the settings page shows the columns.

  Result (harness): the store had open o1 "Fix login bug", o2 "Review pull requests" and o3 "Write slides", plus done o4 (due 11-13), o5 (due 11-08) and o6 (due 11-09). Today was 2026-11-09, so two were due. The graph was toggled with `ctl key Ctrl+Cmd+o` (and `plugins run plugin.objectives.open` once).
  - **Reopened in review mode:** after "Review (2)", the column listed o5, o6. The first press closed the graph (no `.ob-root`), and the second showed it with "Review (2)" `ob-on` and o5, o6 only.
  - **Left before closing:** a click on the active "Review (2)" gave o1, o2, o3 and the Done group. After two presses, "Review (2)" had no `ob-on` and the column read the same.
  - **Nothing due at the next open:** with only o6 due, the graph was closed in review mode listing o6. o6's record was then deleted from the harness `kv.json` by hand. The next open showed no Review button and o1, o2, o3, o5, o4. Then it was closed, o6 was put back, and the open after that showed "Review (1)" without `ob-on`, plus the Done group.
  - **Forgotten on reload:** the graph was closed in review mode listing o5 and o6, and then `ctl plugins fixtures` ran. The next open showed "Review (2)" without `ob-on` and the Done group.
  - **Last one rated:** with only o6 due, Easy on o6 left o1, o2, o3 and the Done group, with no Review button. The kv dump held o6's next review on 11-13. A reopen showed the same.
  - **Button clicked again:** checked under "Left before closing".
  - **Picker from review mode:** with o5 selected in review mode, Tags opened the picker (`picker.mode` "pick"), and Esc closed it. The graph showed "Review (2)" `ob-on` with o5 (selected) and o6.
  - **Undo notice:** in review mode, the trash on o5 showed "Removed “Restyle the docs site” · Undo". After a close and an open, there was no `.ob-undo`, and the graph was in review mode with "Review (1)".
  - **Settings page:** from review mode, ⚙ showed the settings page (two `.ob-sh` headings). The first press closed it, and the second showed the columns in review mode ("Review (2)" `ob-on`, o5 and o6), with no `.ob-sh`.
  - **Seen on the way, a harness artifact:** at first it looked as if, after a field opened from the graph was dismissed with Esc, the first ⌃⌘O replaced the graph with a new one instead of closing it. In fact `/tmp/tobj/bin/pump`, run after the Esc, opens and closes scratch tabs. That focus change docks the glimpse into its tab as a split: the tab went from 1 pane to 2, titled "Objectives", even with no field opened. ⌃⌘O then replaces the docked graph, as "Replacing a docked graph" specifies. With plain waits instead of `pump`, the graph stayed a glimpse after Esc on the New objective field, after Enter on it, and after Esc on the Tags picker. Each time, the first ⌃⌘O closed it.
- [x] 1.2 ⌥N ends review mode (design D3) in `M.new_key`.

  Verify each objectives-graph "New objective key" scenario, using `ctl key Alt+n`, typing the title, and reading `ctl tree` and the kv dump:
  - "From review mode";
  - "From a shell after review mode", with focus in a shell pane;
  - "In the graph" and "From a shell", unchanged.

  Also check that a dismissed title field (Esc) leaves review mode ended.

  Result (harness, same store):
  - **From review mode:** with "Review (2)" `ob-on` listing o5 and o6, `key Alt+n` opened the title field (`picker.mode` "prompt"). Behind it, the graph already showed o1, o2, o3 and the Done group. After typing "Write slides" and Return, the column read o7 (selected), o1, o2, o3, then the Done group, and "Review (2)" had no `ob-on`. The kv dump held o7 "Write slides" at P3, first among the open records.
  - **From a shell after review mode:** the graph was closed in review mode, so focus was in shell pane 2. `key Alt+n`, "Write slides" and Return showed the graph with o7 (selected) first, then o1, o2, o3 and the Done group, with "Review (2)" not `ob-on`. Shots of the window before and after (`rrm_shell_before`, `rrm_shell_after`, graph closed) differ only in a 4 × 32 px strip, the caret. The prompt line reads `❯` with nothing typed.
  - **From a shell / In the graph:** with no review mode, ⌥N from the shell made o7 "Write slides", selected at the top. ⌥N in the graph then made o8 "Draft agenda", selected at the top above o7.
  - **Dismissed field:** in review mode, ⌥N then Esc left the column with the open objectives and the Done group, and "Review (2)" without `ob-on`.
  - **Settings page:** ⌥N on the settings page switched to the columns (no `.ob-sh`).
- [x] 1.3 README: in "Reviewing done objectives", one sentence saying review mode stays on when you close the graph and comes back at the next open in that window, until it ends or Tern restarts. Verify by reading the section.

  Also check the render times in `/tmp/tobj/logs/tern-serve.log`, with no errors.

  Result: the paragraph after step 3 reads: "Review mode stays on when you close the graph: the next time you open it in the same window, it lists what is due then. Click the active **Review (n)** to leave it. ⌥N leaves it too, so the new objective shows in the list. Restarting Tern forgets it." This run's log has 112 renders, the longest 5.5 ms, and no objectives errors or warnings.

## 2. Release 0.18.0

- [x] 2.1 Version `0.18.0` in `plugin.toml`. Verify that an isolated `tern plugin install` of the repo folder prints `installed objectives 0.18.0`. Tick this box, then commit, push `main` and tag `v0.18.0` (annotated, message "objectives 0.18.0").

  Result: the install into `/tmp/tobj-inst180/config` printed `installed objectives 0.18.0 → /tmp/tobj-inst180/config/plugins/objectives`.
- [x] 2.2 **(live)** After the push has finished, run `tern plugin install github.com/JakobMusik/tern-objectives --force` from a shell with no harness variables.

  Verify `tern plugin list` shows `objectives 0.18.0 … ready`, with `tabnav 0.1.0` and `omp-narration 0.1.0` untouched.

  Result: `installed objectives 0.18.0 → ~/Library/Application Support/Tern/plugins/objectives`. `tern plugin list` shows `objectives 0.18.0 … window ready`, beside `omp-narration 0.1.0 … ready` and `tabnav 0.1.0 … ready`. The tag `v0.18.0` (`3a177c2`) is signed and on GitHub.
- [x] 2.3 **(live)** With the user:
  - close the graph in review mode and open it again: it shows review mode;
  - ⌥N from review mode shows the new objective in the list;
  - with review mode remembered in one window, the graph in a second window that hasn't been in review mode opens without it.

  Record the result here.

  Result (user, 0.18.0): "it works", in reply to the three checks listed above. The user reported nothing more specific, so no single check, the second-window one included, is recorded on its own.

## Workflow follow-up

- Archive the change (`openspec archive remember-review-mode --yes`), run `openspec validate --specs --strict`, commit and push.
