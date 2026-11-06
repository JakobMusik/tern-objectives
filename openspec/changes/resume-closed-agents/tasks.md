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

- [ ] 2.1 Add `State.agents` to `lib/store.luau`: filled by `normalize`, with entries dropped by `drop_orphans` and `prune` (design D3).

  Verify: a kv dump from 0.8.x loads with an empty `agents`. After a delete, an unlink and a prune, no entry is left for a pane in no snapshot.
- [ ] 2.2 Add `lib/agents.luau`: request, capture and matching (design D2), with the request called from the `agent_state` handler in `window.luau`. Log each capture's time.

  Verify, by kv dump:
  - "First turn saves the session": the entry appears within 3 s of a message, holding the id from the process's argv;
  - "Two chats in one folder": two chats in one folder, each sent a message, leave no entry for either;
  - "No turn, no session": a chat opened and closed without a message leaves no entry;
  - "Pruned with its tab": after the chat's linked tab closes and "Prune closed tabs" is confirmed, neither its snapshot nor its entry is left;
  - the logged capture times. Record them in design.md's risks.

## 3. Naming Claude chats

- [ ] 3.1 Name Claude chats in `lib/details.luau` (design D1). Closed rows with a saved session read "claude".

  Verify, in shots (`ctl tree '.ob-rtype'`):
  - "Claude chat typed in a shell": the live chat's row reads "claude · idle";
  - "Closed Claude chat": after its linked tab closes, the row reads "claude";
  - "Mixed tab": an omp row still reads "omp · idle".

## 4. Resume

- [ ] 4.1 Resume button in `lib/view.luau` and `styles.css` (design D4).

  Verify:
  - "Button on a closed chat tab": a shot with a closed chat tab and a closed shell-only tab, both linked;
  - its rectangle in the layout JSON is at least 28 × 22;
  - `/tmp/tobj/bin/dragsel` across it shows no highlight;
  - "Header click still toasts": `ctl click` on the closed tab's label toasts "That tab is closed".
- [ ] 4.2 Resume action in `lib/app.luau`, plus `Store.adopt` (design D5, D6).

  Verify:
  - "One chat comes back": `ctl click '.ob-resume'` on a closed tab with a chat and a shell. Then `op agents` shows a chat running `claude --resume <id>` in the saved folder, a shot shows its earlier message, and the new tab has no shell pane;
  - "Links move to the new tab": the kv dump has X and Y linked to the new tab id, the old id is in no objective, and its snapshot is gone. A reopened graph's shot shows the new tab linked, with no ghost.
- [ ] 4.3 README: "Using the graph" describes Resume. "Known limits" adds:
  - Claude chats only;
  - two chats in one folder;
  - a chat needs one message before it can be resumed;
  - this Mac only;
  - other panes aren't recreated.

  Verify by reading the README.

## 5. Release 0.9.0

- [ ] 5.1 Version `0.9.0` in `plugin.toml`. Verify an isolated `tern plugin install` of the repo folder prints `installed objectives 0.9.0`, then commit, push `main` and tag `v0.9.0`.
- [ ] 5.2 **(live)** `tern plugin install github.com/JakobMusik/tern-objectives --force`, from a shell with no harness variables. Verify `tern plugin list` shows `objectives 0.9.0 … ready`, with `tabnav 0.1.0` untouched.
- [ ] 5.3 **(live)** With the user:
  - a Claude chat in a linked tab, sent one message, then its tab closed: the closed tab shows Resume, and its row reads "claude";
  - Resume brings the chat back in a new tab that takes the objective's link;
  - a live chat's row reads "claude · <state>".

  Record the result here.

## Workflow follow-up

- Archive the change (`openspec archive resume-closed-agents --yes`), run `openspec validate --specs --strict`, commit and push.
- Delete the harness's Claude session files and stop the harness services.
