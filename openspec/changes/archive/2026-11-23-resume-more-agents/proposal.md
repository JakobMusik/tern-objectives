# Proposal

## Why

Resume brings back only omp chats. On 2026-11-22 the user asked to add Claude Code, Codex and Antigravity (`agy`), if possible. Today a closed tab that held one of their chats shows no Resume. Its row reads "agent", and while the chat runs, a Codex or Antigravity chat is wrongly named "omp".

A spike on 2026-11-22 (design, source record) found:
- **All three can be resumed** from a session id. They resume both as Tern's own chat (ACP) and in the agent's own interface, whichever mode made the chat.
- **Each chat can be matched to its pane exactly**, the way omp chats are, except Codex in its own interface. There, one shared `codex app-server` holds every thread, and nothing ties a Codex window to its thread.

On 2026-11-22 the user chose:
- **Claude and Codex follow Tern's settings.** If Tern opens the typed command as its own chat, Resume opens the chat as Tern's chat; otherwise it opens in the agent's own interface. The settings are *Open agent commands as ACP chats* (`agents.auto_acp`) and the agents that keep their own interface (`agents.keep_tui`).
- **Antigravity resumes in its own interface only** (`agy --conversation <id>`). Tern doesn't officially open `agy` as its chat.
- **No Resume for Codex in its own interface.**
- **Live chats are named by their agent**, and every agent's chat gets the attention marks.

## What Changes

1. **Saving more chats.** Besides omp chats, the plugin saves, under each chat's pane:
   - **Claude Code** chats, as Tern's chat or in Claude's own interface: the transcript of the session the chat is in now, once it exists. That is after the first message, and the session changes after `/clear`.
   - **Codex** chats that Tern opens as its own chat: the chat's rollout file.
   - **Antigravity** chats, as Tern's chat or in its own interface: the chat's conversation file.

   A pane is saved only when exactly one chat runs in it and its session is certain; otherwise nothing new is saved, as for omp.
2. **More times to save.** Chats in an agent's own interface give Tern no turn events. So the plugin also saves:
   - shortly after a shell starts a command that runs `claude` or `agy`;
   - every 30 seconds while such a chat runs.

   It also still saves at turns, at plugin start, when the graph opens, and before the graph closes tabs.
3. **Resume runs each chat's own command** in the new tab: `omp --resume <file>`, `claude --resume <id>`, `codex resume <id>` or `agy --conversation <id>`. Tern's shell then opens `claude` and `codex` as Tern's chat or in their own interface, by Tern's settings at that moment.
4. **Names and marks:**
   - A live chat typed at a prompt is named by its agent: "claude", "codex" or "agy".
   - A closed tab's row names its saved chat's agent.
   - "needs you", "replied" and "working" now come from every agent chat in Tern's own chat, not only omp's.
   - Chats in an agent's own interface run as plain shells, so Tern reports no state for them and they get no marks.
5. **Wording:** the Resume tooltip, the "nothing to resume" toast and the close tooltips say "chats", not "omp chats".
6. **README:** "Finish cleanly", "See what needs you" and "Jump anywhere" name the agents.
7. **Release 0.33.0**, a minor release.

Out of scope:
- **Codex in its own interface:** no Resume, by the user's choice (see Why). Its row reads "shell", as today.
- **Opening Antigravity as Tern's chat on Resume.**
- **Copilot and Tern's other ACP agents.**
- **Chats that never had a message,** or whose file was deleted or moved: there is nothing to resume.
- **Chats on another machine,** as for omp.
- **Several chats in one pane,** and a pane where a chat started another chat as a tool: nothing new is saved for it.
- **The "you:" line in a row's details:** it stays omp's, since only omp's transcript is read.
- **States and marks for chats in an agent's own interface.**

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `agent-resume`:
  - new requirements "Saved Claude chats", "Saved Codex chats", "Saved Antigravity chats", "When other chats are saved" and "Saved entries are checked";
  - "Resuming a closed tab" runs each agent's command;
  - "Saved chats follow their tabs" and "Resume button on a closed tab" cover every saved chat;
  - "Only omp chats are kept" is removed, replaced by "Saved entries are checked".
- `pane-details`: "Pane type" names Claude Code, Codex and Antigravity chats, live and closed.
- `objectives-graph`: "Attention marks", "Attention marks clear" and "Tab attention marks" cover every agent chat in Tern's own chat.

## Impact

- **`lib/agents.luau`:** the process scan also finds `claude`, `codex` and `agy` processes, and the environment values that locate Claude's records. Pairing covers agent panes and shells running a command. It reads Claude's session record for each `claude` process, and it adds the 30-second save and the save after a command starts.
- **`lib/store.luau`:**
  - `AgentSession` keeps its shape; `agent` is now "omp", "claude", "codex" or "agy";
  - each agent's file shape is checked, and the session id is read from the file name;
  - a snapshot stores a shell running a saved chat as an agent row.
- **`lib/app.luau`:** Resume types each agent's command, and a capture saves before it refreshes the snapshots.
- **`lib/details.luau`:** agent names and attention for every agent.
- **`lib/view.luau`:** the Resume tooltip and the close tooltips.
- **`window.luau`:** a save after a `command_started` that runs `claude` or `agy`.
- **`README.md`**; **`plugin.toml`** version 0.33.0.
- **Dependencies:** none new. `/bin/sh`, `pgrep`, `ps` and `lsof` ship with macOS. Claude's session records are read with `tern.fs.read`.
