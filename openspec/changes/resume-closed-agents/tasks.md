# Tasks

Checks run in the headless harness at `/tmp/tobj` unless marked **(live)**.
- **Harness setup for Claude chats** (design, source record):
  - `agents.auto_acp` is on in the running serve: helper op `setting_set` with `{"key":"agents.auto_acp","value":true}`, before the chat's shell starts;
  - the chats run in folders under `/tmp/tobj/w/`;
  - each check sends one short message, such as "Reply with exactly: ok";
  - the test Tern's clock moves only on `ctl wait`, so advance it while a turn runs.
- **Helper ops** (`/tmp/tobj/bin/op`): `agents`, `panes`, `run`, `close`, `new_tab`, `tab_type`, `procs` (async, its result in the helper's kv), `events` (the `agent_state` log), `setting_set` and `read`.
- **Kv dump** reads `/tmp/tobj/config/plugin-data/objectives/kv.json`.
- **After the checks**, delete `~/.claude/projects/-private-tmp-tobj-*` and `/tmp/tobj/config/settings.json`.

## 1. Spike

- [x] 1.1 Check D1 and D2's assumptions on a shell-typed Claude chat, with the 0.8.x plugin.

  Verify, and record in design.md's source record:
  - its pane row's type in a shot of the graph (expected "omp · idle", proposal item 3);
  - that `agent_state` arrives with `new = "working"` when a message is sent. Log it in the fixtures copy;
  - that `cx.procs:list` then returns its `claude` process with the session id.

  If any differs, stop and update the artifacts before group 2.

  Result (harness, 2026-11-06, chat in `/tmp/tobj/w/chatA`, pane 8):
  - the row read "omp · idle";
  - one message ("Reply with exactly: ok") fired one `agent_state`, idle → working;
  - `cx.procs:list` returned its `claude` process with `--session-id=82ec7f14-…` and folder `/private/tmp/tobj/w/chatA`.

  Two things differed from the setup notes:
  - the chat opened as an ACP chat only after `cx.settings:set("agents.auto_acp", true)`, because the running serve hadn't read the `settings.json` written after it started;
  - another, non-Tern `claude` process used the two-argument form `--resume <id>`, so the parser takes both forms.

  Both are recorded in design.md's source record.
- [x] 1.2 Typing timing (design D5): close the chat's tab, then in one helper op open a new shell tab in its folder and `cx:run` `claude --resume <id>` with no wait.

  Verify, with a shot after advancing the clock, that the chat comes back with its earlier message. If it doesn't, try waiting for the pane's `at_prompt` and record which works in D5.

  Result:
  - typing at once works: the agent ran `claude --resume 82ec7f14-…`, and shot `r_resume_now` showed the earlier message and reply;
  - the first attempt typed nothing, because `cx.layout:new_tab` returns the new pane's id, not the tab's, and in the same call `layout`, `tabs` and `panes` don't list it. `cx.session:tab_of(pane)` does give its tab.

  D5 and D6 were updated: the returned id is the pane, `tab_of` gives the tab, a 250 ms timer writes the new tab's snapshot, and each resumed chat's session moves to its new pane.

## 2. Saving sessions

- [x] 2.1 Add `State.agents` to `lib/store.luau`: filled by `normalize`, with entries dropped by `drop_orphans` and `prune` (design D3).

  Verify: a kv dump from 0.8.x loads with an empty `agents`. After a delete, an unlink and a prune, no entry is left for a pane in no snapshot.

  Result:
  - the 0.8.x store (`kv.pre-explore.json`) loaded, and its first write held `"agents": {}`;
  - one change from D3: the store doesn't know which panes are live, so `drop_orphans` leaves the map alone. Instead `Store.save_sessions` drops sessions whose pane is neither live nor in a snapshot, at every render (`win.live`, every pane `cx.session:panes()` lists) and every capture. `prune` drops its tabs' sessions itself;
  - two closed chat tabs that had never been linked lost their sessions at the next render (`["25","63","9"]` → `["9"]`);
  - unlinking chatB's closed tab from o1 removed its snapshot and session 89;
  - deleting o33 removed chatD's snapshot and session 92;
  - pruning removed chatA's snapshot and session 9 (`"agents": []`).
- [x] 2.2 Add `lib/agents.luau`: request, capture and matching (design D2), with the request called from the `agent_state` handler in `window.luau`. Log each capture's time.

  Verify, by kv dump:
  - "First turn saves the session": the entry appears within 3 s of a message, holding the id from the process's argv;
  - "Two chats in one folder": two chats in one folder, each sent a message, leave no entry for either;
  - "No turn, no session": a chat opened and closed without a message leaves no entry;
  - "Pruned with its tab": after the chat's linked tab closes and "Prune closed tabs" is confirmed, neither its snapshot nor its entry is left;
  - the logged capture times. Record them in design.md's risks.

  Result:
  - "First turn saves the session": after a 25 s pause, pane 9's entry held `74fd9b19-…`, the id in its process's `--session-id`, 2.3 s after the message;
  - "No turn, no session": chatA's turn, with an idle chat in chatC and two in chatB, saved only pane 9 (log: "4 chat(s), 1 paired"). Closing the chatC chat left no entry;
  - "Two chats in one folder": both chatB chats were sent a message, and neither got an entry. Once one was closed, the other's next turn saved it;
  - "Pruned with its tab": see 2.1;
  - capture times were 1190–1389 ms (design, risks).

  Found and fixed on the way, each recorded in design D2 and its source record:
  - the first capture saved a closed chat's id. `cx.procs:list` returns the sampler's latest finished sample, which can be minutes old, so a capture now lists again until the sample number moves on;
  - a short turn fired no `working` event while the harness clock stood still, so `agent_finished` ("done" or "failed") also triggers a capture;
  - another chat's turn would have saved an idle chat's id, so only chats that have had a turn are saved.

  Harness note: the headless serve runs plugin timers only while the window has activity, not on `ctl wait` alone. A 0 ms timer set from a helper command never fired until a tab opened. `/tmp/tobj/bin/pump N` opens and closes a scratch tab N times, 0.6 s apart, to keep timers running during these checks.

## 3. Naming Claude chats

- [x] 3.1 Name Claude chats in `lib/details.luau` (design D1). Closed rows with a saved session read "claude".

  Verify, in shots (`ctl tree '.ob-rtype'`):
  - "Claude chat typed in a shell": the live chat's row reads "claude · idle";
  - "Closed Claude chat": after its linked tab closes, the row reads "claude";
  - "Mixed tab": an omp row still reads "omp · idle".

  Result:
  - "Claude chat typed in a shell": pane 116 read "claude · idle";
  - "Closed Claude chat": once its turn had saved `e747b7a1-…` and its tab was closed, its row under "closed · Default · tab 2" read "claude";
  - "Mixed tab": an omp typed in a shell (`command` null, `program` "omp") read "omp · idle".

  `Details.begin` now takes the store's saved sessions, and `details.luau` uses `Agents.base_name` and `Agents.is_claude` in place of its own `base_name`.

## 4. Resume

- [x] 4.1 Resume button in `lib/view.luau` and `styles.css` (design D4).

  Verify:
  - "Button on a closed chat tab": a shot with a closed chat tab and a closed shell-only tab, both linked;
  - its rectangle in the layout JSON is at least 28 × 22;
  - `/tmp/tobj/bin/dragsel` across it shows no highlight;
  - "Header click still toasts": `ctl click` on the closed tab's label toasts "That tab is closed".

  Result:
  - "Button on a closed chat tab": shot `r_resume_btn2`. Closed tab 117, holding the saved chat 116, shows "Resume"; closed tab 139, holding only a shell, shows none. Both are linked to o2;
  - its rectangle is 58 × 22;
  - a drag from the label across the button: 0.00 change on the button (`hl.py`), and nothing opened;
  - "Header click still toasts": a click on tab 117's label showed the toast "That tab is closed" (shot `r_toast`), and focus stayed on the graph;
  - the first shot (`r_resume_btn`) showed the button greyed out like the rest of the closed tab, so the fade moved onto the node's parts (design D4, "Strength").
- [x] 4.2 Resume action in `lib/app.luau`, plus `Store.adopt` (design D5, D6).

  Verify:
  - "One chat comes back": `ctl click '.ob-resume'` on a closed tab with a chat and a shell. Then `op agents` shows a chat running `claude --resume <id>` in the saved folder, a shot shows its earlier message, and the new tab has no shell pane;
  - "Links move to the new tab": the kv dump has X and Y linked to the new tab id, the old id is in no objective, and its snapshot is gone. A reopened graph's shot shows the new tab linked, with no ghost.

  Result (harness restarted after the omp crashes; checks clicked a forced redraw first, since a closed pane redraws the graph only through a timer):
  - "One chat comes back": closed tab 5, with chat 4 (session `bbb06fa6-…`) and a shell, linked to o2 and o1. Resume closed the graph and focused pane 34 in new tab 35, running `claude --resume bbb06fa6-…` in chatA. Tab 35 held only that pane. Shot `r_resumed` showed "Reply with exactly: resume-me" and "resume-me";
  - "Links move to the new tab": o1 became `[35]` and o2 `[117,139,35]`, tab 5 was in no objective, its snapshot was gone, and the session moved to pane 34. After two more rounds (66, then 75), shot `r_links_moved` showed tab 75 live under Default, linked to o1 and o2, with no ghost of 66. The only ghosts were the unrelated closed tabs 117 and 139;
  - two chats: closed tab 82, holding chats in chatB (`c3de0d85-…`) and chatD (`45462eaf-…`) side by side and linked to o3, came back as tab 109. Pane 108 resumed chatB's chat, its right split 110 resumed chatD's, and shot `r_split_resumed` showed both earlier exchanges. o3 became `[109]`;
  - resumed again before a turn: tab 66 was closed right after its resume and still showed "claude" and Resume, since the resume timer stores the new panes as agents.

  Found and fixed on the way (design D3, D4, D6):
  - a session left from before the harness restart named pane 6, which was now a shell. Only rows stored as agents count now;
  - the new tab's snapshot was first written while its pane was still a shell (`kind` "terminal"), and snapshots used to be refreshed only when the graph drew. Captures now refresh linked tabs' snapshots, and the resume timer stores resumed panes as agents;
  - the sweep keeps sessions saved in the last 10 s, so a render before the new tab is listed can't drop them.
- [x] 4.3 README: "Using the graph" describes Resume. "Known limits" adds:
  - Claude chats only;
  - two chats in one folder;
  - a chat needs one message before it can be resumed;
  - this Mac only;
  - other panes aren't recreated.

  Verify by reading the README.

  Result:
  - "Using the graph" has a Resume bullet: it opens a tab in the current session, runs `claude --resume` in each chat's folder with one split per further chat, the new tab takes the closed tab's links, and other panes aren't recreated;
  - "Known limits" names `agents.auto_acp` and Claude only, one message and one chat per folder (and nothing for tabs closed before 0.9.0), and this Mac only;
  - the closed-rows limit now says a noted Claude chat reads `claude`.

## 5. Release 0.9.0

- [x] 5.1 Version `0.9.0` in `plugin.toml`. Verify an isolated `tern plugin install` of the repo folder prints `installed objectives 0.9.0`, then commit, push `main` and tag `v0.9.0`.

  Result: the isolated install (`/tmp/tobj-rel`) printed `installed objectives 0.9.0`, and `tern plugin list` showed `objectives 0.9.0 … 0 blocks, 0 lenses, window ready`.
- [ ] 5.2 **(live)** `tern plugin install github.com/JakobMusik/tern-objectives --force`, from a shell with no harness variables. Verify `tern plugin list` shows `objectives 0.9.0 … ready`, with `tabnav 0.1.0` untouched.
- [ ] 5.3 **(live)** With the user:
  - a Claude chat in a linked tab, sent one message, then its tab closed: the closed tab shows Resume, and its row reads "claude";
  - Resume brings the chat back in a new tab that takes the objective's link;
  - a live chat's row reads "claude · <state>".

  Record the result here.

## Workflow follow-up

- Archive the change (`openspec archive resume-closed-agents --yes`), run `openspec validate --specs --strict`, commit and push.
- Delete the harness's Claude session files and stop the harness services.
