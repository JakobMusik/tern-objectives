# Tasks

Checks run in the headless harness at `/tmp/tobj` unless marked **(live)**.
- **Harness:**
  - **Scripts:** `/tmp/tobj/bin/{env.sh,serve,ctl,sync,op}`, rebuilt on 2026-11-22. `env.sh` sets `STENCIL_FIXTURE_ROOT=/tmp/tobj/crates/tern`, so the fixtures are `/tmp/tobj/crates/plugins/fixtures`.
  - **Helper plugin `tobjh`:** its ops are `sessions`, `new_tab`, `split`, `tab_of`, `run`, `agents`, `panes`, `ask`, `close`, `focus`, `setting_set` and `setting_get`, and it logs window events to its kv key `events`. Add ops as a check needs them.
  - **Running:** start the serve as a named service (`/tmp/tobj/bin/serve`, ready on "serving"), then run `ctl plugins fixtures`. After each edit, run `/tmp/tobj/bin/sync` and `ctl plugins fixtures` again.
  - **Never** source `env.sh` in a persistent shell, and never run `tern serve --help`, which serves.
- **Agent settings:**
  - `/tmp/tobj/config/settings.json` holds `agents.auto_acp` true, and the custom agent `antigravity` running the user's bridge with its preferences file at `/tmp/tobj/agy-prefs.sqlite`. Each check sets `agents.keep_tui` there, since `tern acp` reads the file when it starts (design S3).
  - The serve also gets `setting_set agents.auto_acp true`, so its shells wrap the agent commands.
- **Agent shells:** harness shells start with a temporary home (design S19). In every shell that runs an agent:
  - first run `export HOME=/Users/macintosh PATH=/Users/macintosh/.local/bin:$PATH; unset XDG_CACHE_HOME XDG_CONFIG_HOME XDG_DATA_HOME XDG_STATE_HOME`;
  - then type the agent's command as a line of its own.

  Messages go in with `op ask` for Tern's chats, and with `ctl type` plus `ctl key enter` into a focused pane for an agent's own interface. Each chat gets one short message.
- **Reading:**
  - kv dumps of `/tmp/tobj/config/plugin-data/objectives/kv.json` (key `agents`, and `tabs` for snapshots);
  - `ctl tree` for nodes, rows and tooltips;
  - `ctl shot NAME` for a PNG and layout JSON;
  - `ps`/`lsof` with `/tmp/tobj/w/ptree.sh PANE` for what a pane runs;
  - the serve log, `/tmp/tobj/logs/tern-serve.log`, for render times, "chat capture" lines and warnings.
- **Claude replies** fail with the user's account error (design S20). The turn still ends and the transcript is still written.
- **After the checks:**
  - stop the service;
  - remove only Claude and omp test transcripts created by these checks, not other transcripts sharing a parent directory;
  - check that `readlink ~/.local/bin/claude` points into `~/.local/share/claude/versions/`;
  - leave the Codex and Antigravity test chats, as design "Risks" says.

## 1. Saving the chats of more agents

- [x] 1.1 Finding and storing the chats (design D1, D2, D3):
  - **`tern.d.luau`:** regenerate it with `tern plugin types .` (Tern 0.9.30).
  - **`lib/agents.luau`:**
    - the script's `pgrep` pattern, its `ps -wwE` tokens (`HOME=`, `CLAUDE_CONFIG_DIR=`) and its `lsof` filter (`/conversations/<uuid>.db`, `/brain/<uuid>`);
    - `Proc` gains `agent`, `home` and `claude_dir`;
    - candidate panes: agent blocks, and running terminals in local sessions;
    - pairing by D2, Claude's record read with `tern.fs.read(path, 65536)`, and the file rules of D1.
  - **`lib/store.luau`:**
    - `Store.chat_file_ok(agent, file)` replaces `is_chat_file`;
    - add `Store.chat_id(entry)`;
    - `valid_session` accepts the four agents.

  Verify, with kv dumps:
  - agent-resume "Saved Claude chats", every scenario. "First message saves the chat" runs with `keep_tui` [], the others with `keep_tui` ["claude"];
  - "Saved Codex chats", both scenarios (`keep_tui` [] and ["codex"]);
  - "Saved Antigravity chats", every scenario;
  - "Saved entries are checked", both scenarios, with the entries written into `kv.json` by hand;
  - "Saved omp chats", "First message saves the chat" again: omp is unchanged.

  For each saved entry, also check that `Store.chat_id` gives the id the processes show (`ptree.sh`).

  Result (harness, 2026-11-22, Tern 0.9.30):
  - **Setup:** each agent ran in its own tab, in a folder under `/tmp/tobj/w/`. "Saved" times count from when polling saw the chat idle. Claude's replies were the account error (design S20), which ends the turn and writes the transcript.
  - **Harness timers:** the headless serve fires plugin timers only on window activity. The pump opens and closes a tab with `reveal {focus = false}`; `reveal false` raised "error converting Lua boolean to table".
  - **Saved Claude chats:**
    - *First message saves the chat* (`keep_tui` []): before the message, the kv dump held nothing for pane 21. 0.4 s after the turn, it held agent "claude", cwd `/private/tmp/tobj/w/clD` (Claude's record names the folder by its real path), and `~/.claude/projects/-private-tmp-tobj-w-clD/e7b8c796-….jsonl`. That is the `sessionId` in `~/.claude/sessions/56617.json`, the record of that pane's `claude`.
    - *In Claude's own interface* (`keep_tui` ["claude"], pane 32, a terminal running `claude`): with no graph opened, the 30-second capture ("…, watching") saved `…-clE/c2479dc5-….jsonl`. That is the sessionId of record 56921, whose `entrypoint` is "cli".
    - *A new session after /clear*: after `/clear` and a second message, a graph open replaced the entry within 0.8 s with `559ef61c-….jsonl`, the record's new sessionId.
    - *No message, nothing saved:* checked in the first scenario.
  - **Saved Codex chats:**
    - *First message saves the chat* (pane 129): 0.4 s after the turn the entry read agent "codex", cwd `/tmp/tobj/w/cxA`, `~/.codex/sessions/2026/11/22/rollout-…-01a203dd-b026-….jsonl`, the file `codex app-server` 58264 holds open.
    - *Codex's own interface saves nothing* (`keep_tui` ["codex"], pane 134): Codex recorded the message in thread `01a203de-…` (originator `codex-tui`). 2.2 s after a graph open, the kv dump held nothing for the pane. A Codex chat in Tern's chat with no message (pane 145) saved nothing either.
  - **Saved Antigravity chats:**
    - *As Tern's chat* (`tern acp antigravity`, pane 157): 0.4 s after the turn, `~/.gemini/antigravity-cli/conversations/937744e1-….db`, the file `agy acp` 67166 holds open.
    - *In its own interface* (`command agy`, pane 162): the 30-second capture saved `a3a69285-….db`, with no graph opened. The first message had been typed before agy was ready and never sent, so it was sent again.
    - *A new conversation after /clear:* after `/clear` and a second message, a graph open replaced it within 0.5 s with `260b1a2b-….db`.
  - **Saved entries are checked:** both scenarios were written into `kv.json` under closed tabs linked to Y:
    - "Legacy": a Claude entry holding a bare id;
    - "Odd": a Codex entry whose existing rollout file has no thread id.

    Neither ghost showed `.ob-resume`, and both rows read "agent". After Y's badge was clicked (P1 to P0), the kv dump held neither entry.
  - **Ids:** each saved file is named by the id its process shows: Claude's record `sessionId`, the rollout file held by the chat's `codex app-server`, and the conversation file held by `agy`. Task 2.1 checks the ids Resume types from them (`Store.chat_id`).
  - **omp first-turn timing:** polling `lsof` every 0.1 s in the initial implementation found the file 4.4 s after sending the message; the pane had already gone idle at 2.4 s. The ordinary turn-end scan could miss the file. The single comparison run on 0.32.0 saved in 2.8 s; that alone does not establish the failure rate on 0.32.0. D4 and the final check under 2.2 address this timing without changing the three-second requirement.
  - **Request queue:** a request made while a capture waits or runs now queues one more, instead of being dropped (design D4).
  - **Side effect of the 0.32.0 run:** that code's next write dropped every non-omp entry, the rollback design "Migration Plan" describes. Later captures saved them again, except pane 162: its agy, idle after `/clear`, holds two conversation folders and no conversation file. Design "Risks" names this.
  - **Captures:** 210–290 ms each in the serve log, with no warning.
- [x] 1.2 When chats are saved, and their rows (design D4, D5):
  - **`window.luau`:** a `command_started` handler calls `Agents.request()` when a word of the line runs `claude` or `agy`.
  - **`lib/agents.luau`:** the 30-second timer, armed after a capture that paired a chat in its own interface; and save before refreshing the snapshots.
  - **`lib/store.luau`:** `snapshot` stores a running terminal row with a saved "claude" or "agy" chat as "agent". `TabFacts` rows carry `running`.

  Verify:
  - agent-resume "When other chats are saved", "Saved before the tab closes": the kv dump holds the chat and the closed tab's snapshot row with kind "agent", and the graph shows "Resume";
  - the serve log shows a "chat capture" line at the command's start, then one about every 30 s while `command agy` runs, and none 30 s after it quits;
  - "Saved chats follow their tabs", "Unlinked with its tab", again, with a Claude chat in its own interface;
  - render times in the serve log stay within the 20 ms target.

  `TabFacts` rows carry the live pane's `info`, whose `running` `snapshot` reads.

  Result (harness, 2026-11-22):
  - **Saved before the tab closes:** a linked tab (Y) ran `command agy` in `/tmp/tobj/w/agC`. One message was sent, and agy then held `conversations/8178cd55-….db`. 23 s later the 30-second capture saved that file under pane 656, and the snapshot stored the row as `kind "agent"`. The tab was then closed with the graph never opened. On opening the graph, the closed tab read "command agy · Resume · closed · Default · tab 3", and its row "agy".

    A first run of this check typed the message before agy was ready, so it was never sent. With no conversation, nothing was saved, and the closed tab showed no Resume and a "shell" row. That is right, as nothing could be resumed.
  - **Capture times:** the capture after `command agy` started ran on the next window activity, as harness timers do, and was logged with ", watching". Later captures came about 30 s apart (23.1 s after sending, then 34.6 s after an earlier start). Before `command agy`, with no chat in its own interface, 33 s brought one capture with no ", watching".
  - **Unlinked with its tab:** Y linked tab 33, whose shell ran Claude in its own interface (pane 32), and its snapshot row was stored as `kind "agent"`. With the tab closed, its ghost showed "Resume" and the row "claude". After selecting Y and clicking "× Unlink" on the ghost, the kv dump held neither the tab's snapshot nor pane 32's saved chat, and Y linked only tab 3.
  - **Render times:** the harness window had grown to 21 tabs, and its renders reached 22.7 ms, as the window grew. On that window, eight opens and closes rendered at most 3.9 ms with 0.32.0's code (from `git archive HEAD`) and 4.5 ms with this change. The first open after a reload rendered 8.8 ms once; a rerun gave 4.0 ms. Captures took 208–302 ms off the UI thread.

## 2. Resume, names and marks

- [x] 2.1 Resume each agent's chat (design D6, D8):
  - **`lib/app.luau`:** `resume` types the command for each entry's agent; the toast says "chat".
  - **`lib/view.luau`:** the Resume tooltip and the close tooltips say "chats".

  Verify:
  - agent-resume "Resume commands", every scenario, with a shot of each new tab showing the earlier message, and `ptree.sh` for the command it ran. For "Claude comes back by Tern's settings", run it once with `keep_tui` ["claude"] and once with [];
  - "Resuming a closed tab", "Links move to the new tab", with a Codex chat;
  - "Resume button on a closed tab", "A chat in its own interface" and "Chat file gone" (with an Antigravity conversation file moved away);
  - "Where a chat resumes", "Back in its own session", with a Claude chat;
  - `ctl tree '.ob-resume'` shows the tooltip "Reopen this tab's chats in a new tab".

  Result (harness, 2026-11-22/23):
  - **Harness:** the shell Resume opens reads the harness's temporary `.zshrc`, so `HOME`, `PATH` (`~/.local/bin`, omp's bin) and the unset `XDG_*` went there. Before that, the first Resume typed `codex resume <id>` into a shell where `codex` wasn't on `PATH`.
  - **Codex comes back as Tern's chat** (`keep_tui` []): after "Reply with exactly: resume-two", the closed tab showed Resume and a "codex" row. Resume opened a tab whose process was `tern acp --typed=codex resume 01a203f4-fdef-…`, the id in the saved rollout's name. The chat was an agent block (program "codex", idle, last reply "resume-two"), and shot `t21_codex_acp` shows the message and the reply.
  - **Codex keeps its own interface:** saved as Tern's chat, then `keep_tui` ["codex"] before Resume. The new pane was a terminal running `codex resume 01a203f5-bf00-…`. Shot `t21_codex_own` shows Codex's own interface with "Reply with exactly: own-ui" and the reply "own-ui".
  - **Claude comes back by Tern's settings:** both runs typed `claude --resume <id>` in `/private/tmp/tobj/w/clD`.
    - With `keep_tui` ["claude"], the pane was a terminal running `claude --resume ee78b972-…`. Shot `t21_claude_own` shows Claude's own interface with the earlier message "Reply with exactly: ['claude']" and the account error as its reply.
    - With `keep_tui` [], the pane was an agent block (program "claude"), started as `tern acp --typed=claude --resume 5fd8d8d5-…`. Shot `t21_claude_acp` shows Tern's chat with "Reply with exactly: acp" and the same error.
  - **Antigravity comes back in its own interface:** saved as Tern's chat (`conversations/3fd47580-….db`). Resume opened a terminal running `agy --conversation 3fd47580-…`. After agy's folder-trust prompt, shot `t21_agy_own2` shows "Reply with exactly: agy-back" and the reply "agy-back".
  - **Links move to the new tab** (Codex): X and Y both linked closed tab 5. After Resume, the kv dump showed both linked to the new tab 21, the closed tab's snapshot gone, and the saved rollout moved to the new pane 20.
  - **Resume button:**
    - *A chat in its own interface:* in task 1.2, Claude's own interface (tab 33) and Antigravity's (`command agy`) both showed Resume, with rows "claude" and "agy".
    - *Chat file gone:* a closed tab whose saved Antigravity conversation was moved away (with its `-wal` and `-shm`) showed no Resume, then showed it again once the files were moved back. The row still read "agy", the saved entry's agent ("Pane type").
    - *Tooltip:* `.ob-resume` read "Reopen this tab's chats in a new tab".
  - **Back in its own session** (Claude): session "work" held three tabs, and the Claude chat in its third was saved (`799f34e3-….jsonl`), linked to X and closed. The harness then switched to "Default" and clicked Resume. Tern showed "work", and its tabs went from [177, 181] to [177, 181, 216]: the chat came back as its third tab, where it was, as `tern acp --typed=claude --resume 799f34e3-…`. Default's tabs were unchanged.

    An earlier run hung: that `claude` stayed "working" and never wrote a session record, so nothing was saved. It didn't recur. A later click went off-screen, below the 800-px window, until the old test tabs were closed.
- [x] 2.2 Names and marks (design D7):
  - **`lib/details.luau`:** `agent_name` uses the program and the saved chat; `attention` marks every agent block.

  Verify:
  - pane-details "Pane type", every scenario;
  - objectives-graph "Attention marks": "A Codex chat marks too" and "An agent's own interface doesn't mark", read with `ctl tree` and a shot;
  - "Attention marks clear": "Focusing a Codex pane clears its reply";
  - "Tab attention marks": "A Codex chat's reply";
  - "Attention marks", "Chat working", again with an omp chat.

  Result (isolated Tern 0.9.30):
  - The mixed tab read `shell`, `file` and `omp · idle`. Its closed rows read `shell`, `file` and `omp`. The live agent rows read `claude · idle`, `codex · idle` and `agy · idle`, including bare `agy` through the actual zsh shortcut. A closed Claude pane with no message read `agent`, its shell sibling read `shell`, and the tab offered no Resume.
  - Codex showed `working` on both its tab and X, then a green `replied` chip on both. The tooltips named the tab and pane, not omp. Focusing the replying pane cleared its alert and both chips. The omp control showed `working` on its own tab and Y. Evidence: `r33-codex-working`, `r33-codex-replied`, `r33-omp-working`.
  - A linked tab holding both Codex and Antigravity closed with the correct ghost names. One Resume click restored both conversations, in order: `codex resume …` in an ACP block, `agy --conversation …` in a terminal. X and Y both linked the replacement; the old snapshot was gone. The native agy row read `agy` without state. Its reply `native-only-33` did not mark the tab or X; after agy quit and `sleep` ran in the same pane, both its live and snapshot row were shells. Evidence: `r33-native-no-marks`, `r33-agy-native-reply`.
  - **First-turn timing correction:** each scan belongs to a specific command in its pane. A finished omp turn that still lacks an open file gets one late sample; a later command cannot inherit either that sample or the captured native file. For fresh omp pane 226 there was no entry before the turn; the saved timestamp, at one-second resolution, was within approximately 1.1 s of the observed `agent_finished` event. No file-order heuristic is used.
  - The acceptance run from `r33-mixed-rows` through the native-shell check logged 89 renders, maximum 12.6 ms, with no Objectives warnings or errors.

- [x] 2.3 README (design D8): "See what needs you", "Jump anywhere" and "Finish cleanly" name the agents, plus the limits note. Verify by reading the four places in `README.md`.

  Result: verified the Features text and “Resuming chats” in Use. The README distinguishes ACP states from native terminals, omp's last-user-message detail from other agents' replies, which UI Resume opens, and the native Codex capture limit.

## 3. Release 0.33.0

- [x] 3.1 Version `0.33.0` in `plugin.toml`. Verify that an isolated `tern plugin install` of the repo folder prints `installed objectives 0.33.0`. Tick this box, then commit, push `main` and tag `v0.33.0` (annotated, message "objectives 0.33.0").

  Result: the isolated local-folder install printed `installed objectives 0.33.0 → /tmp/tobj-inst330.HOWTEK/config/plugins/objectives`. No daemon ran against that configuration.
- [x] 3.2 **(live)** After the push has finished, run `tern plugin install github.com/JakobMusik/tern-objectives --force` from a shell with no harness variables.

  Verify `tern plugin list` shows `objectives 0.33.0 … ready`, with the other plugins untouched.

  Result: the signed tag `v0.33.0` points to `340f71a` on GitHub. The live install reported `installed objectives 0.33.0 (340f71a)` and `tern plugin list` reported `window ready`. The five other plugin listings were identical before and after: `external-editor 0.1.0`, `omp-narration 0.1.0`, `open-below 0.2.0`, `reply-selection 0.1.0`, `tabnav 0.1.0`. The isolated server was stopped, its 22 identified Claude/omp test transcripts removed, and the Claude executable link verified. Codex and agy test chats were left in their agents' own histories.
- [x] 3.3 **(live)** With the user:
  - a linked tab with a Codex chat, as Tern's chat, that had a message: close it, then Resume. It comes back as Tern's chat, or in Codex's own interface if Codex is set to keep it;
  - the same for Claude, in either mode;
  - an Antigravity chat, opened with `agy`: close its tab, then Resume. It comes back in Antigravity's own interface;
  - the closed rows read "codex", "claude" and "agy";
  - a Codex chat's reply marks its objective and tab "replied".

  Record the result here.

  Result (user, 0.33.0): "it's working", in reply to the live checks listed above. The user reported nothing more specific, so no single check is recorded on its own.

## Workflow follow-up

- Archive the change (`openspec archive resume-more-agents --yes`), run `openspec validate --specs --strict`, commit and push.
