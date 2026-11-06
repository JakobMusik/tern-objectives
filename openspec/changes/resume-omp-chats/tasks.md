# Tasks

Checks run in the headless harness at `/tmp/tobj` unless marked **(live)**.
- **Harness setup:**
  - start the serve as a named service (`/tmp/tobj/bin/serve`, ready on "serving"), then `ctl plugins fixtures`;
  - copy the repo into the fixtures with `/tmp/tobj/bin/sync` after each edit, and reload with `ctl plugins fixtures`;
  - omp chats run in folders under `/tmp/tobj/w/`, typed into harness shells; each check sends one short message, such as "Reply with exactly: ok";
  - the test Tern's clock moves only on `ctl wait`, and plugin timers fire only with window activity: use `/tmp/tobj/bin/pump`.
- **Helper ops** (`/tmp/tobj/bin/op`): `agents`, `panes`, `run`, `close`, `new_tab`, `tab_type`, `read`, and `proc_run` (its result in the helper's kv as `proc`).
- **Kv dump** reads `/tmp/tobj/config/plugin-data/objectives/kv.json`.
- **After the checks**, delete `~/.omp/agent/sessions/--private-tmp-tobj-*` (omp wraps folders outside home in `--`).

## 1. Spike

- [x] 1.1 Check D1 and D5's assumptions on a harness omp chat, with the 0.10.0 plugin.

  Type `omp` in a shell tab in `/tmp/tobj/w/ompA` and send one message. Verify, and record in design.md's source record:
  - `proc_run` of D1's script shows that chat's pid with `TERN_WINDOW_PANE` equal to its pane id, and its open `.jsonl` under `sessions/--private-tmp-tobj-w-ompA--/`;
  - `cx.agents:list()` (op `agents`) lists the pane;
  - after the tab is closed, `omp --resume '<file>'` typed at once into a new shell tab in the same folder shows the earlier message (shot), and op `agents` lists the new pane;
  - `proc_run` then shows the resumed process holding the same file.

  If any differs, stop and update the artifacts before group 2.

  Result (harness, 2026-11-07, script `/tmp/tobj/bin/ompscan.sh`, which D1 embeds):
  - Tern listed the shell-typed omp as an agent: pane 16, `program` "omp", state idle. One message ("Reply with exactly: ok") answered "ok" in 2.8 s;
  - the script ran in 198 ms with status 0. Pid 72648's command line read `omp`, its environment `TERN_WINDOW_PANE=16`, and it held `~/.omp/agent/sessions/--private-tmp-tobj-w-ompA--/2026-11-06T19-11-12-973Z_….jsonl` open;
  - after pane 16 was closed, `omp --resume '<file>'` typed at once into a new shell tab in the same folder showed the earlier message and reply (shot `s11_resumed`), and `agents` listed the new pane 54, `program` "omp";
  - before a message, the resumed pid 73544 held no file, and its command line named it (`omp --resume <file>`), which D1's fallback reads. After one message ("ok2") it held the same file, and no second file appeared in the folder.

  One thing differed from the setup notes: omp names the folder of a chat outside home `--private-tmp-tobj-w-ompA--`, not `-private-…`. The cleanup paths are fixed.

## 2. Saving omp chats

- [x] 2.1 Capture (design D1, D2): rewrite `lib/agents.luau` around the one-process script and its parser. Remove the Claude matching (`folder`, `session_of`, `is_session_id`, `pair`, the `cx.procs` sampling, `turned`), keep `is_claude` and `base_name`, and add `is_chat_file` (in `lib/store.luau`, which `normalize` needs and `agents.luau` already requires). Request a capture from the startup timer in `window.luau` and from `App.open`.

  Verify with kv dumps:
  - one message in an omp chat in `/tmp/tobj/w/ompA` saves agent "omp", folder `/tmp/tobj/w/ompA` and its open file, within 3 s of the reply ending (omp creates the file only then, design source record);
  - two chats in `/tmp/tobj/w/ompB`, one message each, save two different files, each matching its pid's open file in `proc_run`;
  - `omp --resume '<file>'` in a new shell, no message, then opening the graph, saves that file;
  - a chat with no message, then opening the graph, saves nothing;
  - deleting a saved entry from `kv.json` and reloading the plugin saves it again within 3 s.

  Result (harness, 2026-11-07):
  - pane 106 in `ompA` was saved with its open file, folder `/tmp/tobj/w/ompA`, after its reply. A longer first turn (pane 140, 46 s) showed omp creates the file only as the first reply ends: the turn-start capture found nothing, and the turn-end one saved it about 1 s after. The artifacts were updated for this (spec scenario, design source record, D2, risks);
  - panes 180 and 214 in `ompB` saved two different files, each the one its pid (77473, 78114) holds open in `proc_run`;
  - pane 254, running `omp --resume '<pane 140's file>'` with no message, had no entry until the graph opened, then that file;
  - pane 275, `omp` with no message: no entry after the graph opened, while that capture saved 5 others;
  - pane 214's entry, deleted from `kv.json`, was back 1.2 s after the plugin reloaded;
  - captures took 189 to 234 ms (log `chat capture`).
- [x] 2.2 Migration (design D3): `normalize` keeps only valid omp entries.

  Verify: write a Claude entry (`agent` "claude", a UUID `session`) into `kv.json` under a closed linked tab's agent pane, open the graph, then change a priority. The tab shows no Resume, its row starts with "agent" (`ctl tree '.ob-rtype'`), and the kv dump afterwards has no entry under that pane.

  Result (harness): tab 276 (pane 275, an omp agent row) was linked to o1, snapshotted and closed. With a Claude entry written under pane 275 and the plugin reloaded, the graph showed no `.ob-resume` in `.ob-t-276`, and its row's type read "agent". Opening the graph wrote nothing, so the entry stayed in the file; clicking o1's priority badge wrote the store, and the kv dump then held no entry under 275.

## 3. Resume and rows

- [x] 3.1 Button and rows (design D4): the button needs a valid entry whose file exists, and its tooltip names omp. Closed rows take their name from valid entries only.

  Verify: with an omp chat tab and a shell-only tab, both linked and closed, a shot shows "Resume" on the first only, and `ctl tree '.ob-rtype'` reads "omp" for the chat's row. After the chat file is moved aside and the graph redraws (`.ob-segb` click), the button is gone. Move the file back afterwards.

  Result (harness): tab 215 (pane 214, chat "b2" in `ompB`) and shell tab 333, linked to o1 and closed. `.ob-resume` count: 1 in `.ob-t-215`, 0 in `.ob-t-333`; its title "Reopen this tab's omp chats in a new tab"; row types `["omp","shell"]`. Shot `s31_resume` shows "Resume" on "b2", whose row reads "omp b2". With the chat file renamed aside and "All" clicked, the count in `.ob-t-215` was 0 (row still "omp"); with it back, 1.
- [x] 3.2 Resume action (design D5): type `omp --resume '<file>'`, quoted, in the new tab and its splits; toast when no chat is left.

  Verify:
  - clicking Resume on the closed omp chat tab opens a new tab whose omp chat shows the earlier message (shot), with no shell pane;
  - the kv dump shows the tab's objectives linked to the new tab, the old snapshot gone, and the new pane saved with the same file;
  - a closed tab with two omp chats comes back as two panes side by side, in row order (shot).

  Result (harness):
  - Resume on tab 215 opened tab 359, holding only pane 358, an omp chat in `ompB` whose shot (`s32_resumed`) shows the earlier "Reply with exactly: b2";
  - the kv dump: o1's tabs went from `[8,276,215,333]` to `[8,276,359,333]`; no snapshot for 215; pane 358 saved with 214's file; 214's entry gone;
  - tab 377, holding two chats split side by side (panes 376 "e1" and 380 "e2"), linked and closed, showed one Resume with rows `["omp","omp"]`. Resume opened tab 453: panes 452 and 454, side by side, "e1" left and "e2" right (shot `s32_two`), each saved with its old pane's file; o1's 377 became 453.

## 4. README

- [x] 4.1 Update "Using the graph" (Resume brings back omp chats) and "Known limits": omp only, Claude and Codex chats are not resumed (and Claude Resume from 0.9.0 to 0.10.0 is gone), a chat needs one message or a file it was started from, this Mac only, and an omp that holds no file and was switched with `/new` may reopen the earlier chat.

  Verify by reading the rendered sections against specs/agent-resume.

  Result: "Using the graph" says Resume brings back omp chats, noted at each turn, at plugin start and on opening the graph, and runs `omp --resume <chat file>`. "Known limits" adds: omp only, with the Claude Resume of 0.9.0 to 0.10.0 gone; a chat is noted once its first reply has ended or when it was started from a file; no Resume for a tab closed during the first reply or whose file moved; `/new` with no message reopens the earlier chat; the undocumented `TERN_PANE`; this Mac only. Every sentence matches a requirement of `specs/agent-resume` or a risk in design.md.

## 5. Release 0.11.0

- [x] 5.1 Version `0.11.0` in `plugin.toml`. Verify an isolated `tern plugin install` of the repo folder prints `installed objectives 0.11.0`, then commit, push `main` and tag `v0.11.0` (annotated, message "objectives 0.11.0").

  Result: the isolated install (`/tmp/tobj-rel`) printed `installed objectives 0.11.0`, and `tern plugin list` showed `objectives 0.11.0 … 0 blocks, 0 lenses, window ready`. The release commit `f686e07` went out without this box ticked (an edit lost to a race with the commit); it is ticked here instead, and the tag `v0.11.0` stays on `f686e07`.
- [x] 5.2 **(live)** After the push has finished, `tern plugin install github.com/JakobMusik/tern-objectives --force`, from a shell with no harness variables. Verify `tern plugin list` shows `objectives 0.11.0 … ready`, with `tabnav 0.1.0` untouched.

  Result: `installed objectives 0.11.0 → ~/Library/Application Support/Tern/plugins/objectives`; `tern plugin list` shows `objectives 0.11.0 … ready`, `omp-narration 0.1.0 … ready` and `tabnav 0.1.0 … ready`. Read-only afterwards: the live `kv.json` held 17 saved omp chats, among them pane `100000000001` of the linked tab "QA: Summarize the release checklist" with its `-Documents-Projects-demo/2026-10-29T08-14-15-789Z_….jsonl`. Every saved chat whose omp process was running matched the file that process holds or names (16 of 16).
- [ ] 5.3 **(live)** With the user: a linked tab with an omp chat, closed, shows Resume, and its row reads "omp"; Resume brings the chat back with its messages in a new tab that takes the objective's link. Record the result here.

## Workflow follow-up

- Archive the change (`openspec archive resume-omp-chats --yes`). Then edit the Purpose of `openspec/specs/agent-resume/spec.md`, which still says "Claude chats", run `openspec validate --specs --strict`, commit and push.
- Delete `~/.omp/agent/sessions/--private-tmp-tobj-*` and stop the harness service.
- Next change: "Close linked tabs" for done objectives, which captures omp chats just before closing.
