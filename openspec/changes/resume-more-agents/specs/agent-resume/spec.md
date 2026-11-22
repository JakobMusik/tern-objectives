## ADDED Requirements

### Requirement: Saved Claude chats
For each Claude Code chat in a pane of this window on this machine, as Tern's chat or in Claude's own interface, the plugin SHALL save, under that pane's id: the agent "claude", the transcript file of the session the chat is in now, and its folder. That session SHALL be the one Claude records for the only `claude` process whose environment names the pane. Nothing SHALL be saved until that transcript exists. A new session in the same pane SHALL replace the saved one.

#### Scenario: First message saves the chat
- **WHEN** Tern opens typed agent commands as its own chats, the user types `claude` in a shell in folder F and sends the chat one message, and the reply ends
- **THEN** within 3 seconds the kv dump holds, under that pane's id, agent "claude", folder F, and a file ending in `/<session id>.jsonl` that exists

#### Scenario: In Claude's own interface
- **WHEN** Claude is set to keep its own interface, the user types `claude` in a shell in folder F, sends one message, and waits 35 seconds without opening the graph
- **THEN** the kv dump holds, under that pane's id, agent "claude", folder F and that session's transcript file

#### Scenario: A new session after /clear
- **WHEN** in Claude's own interface the user sends one message, types `/clear`, sends another message, and opens the graph
- **THEN** within 3 seconds the kv dump holds, under that pane's id, the second session's transcript, not the first

#### Scenario: No message, nothing saved
- **WHEN** the user types `claude` in a shell, sends nothing, and opens the graph
- **THEN** the kv dump holds no saved chat for that pane

### Requirement: Saved Codex chats
For each Codex chat that Tern opens as its own chat in a pane of this window on this machine, the plugin SHALL save, under that pane's id: the agent "codex", the chat's rollout file and its folder. The rollout file SHALL be the only one held open by the Codex server that runs this chat alone and whose environment names the pane. Codex in its own interface SHALL save nothing.

#### Scenario: First message saves the chat
- **WHEN** Tern opens typed agent commands as its own chats, the user types `codex` in a shell in folder F and sends the chat one message, and the reply ends
- **THEN** within 3 seconds the kv dump holds, under that pane's id, agent "codex", folder F, and a `rollout-…-<thread id>.jsonl` file that exists

#### Scenario: Codex's own interface saves nothing
- **WHEN** Codex is set to keep its own interface, the user types `codex` in a shell, sends one message, and opens the graph
- **THEN** after 3 seconds the kv dump holds no saved chat for that pane

### Requirement: Saved Antigravity chats
For each Antigravity chat in a pane of this window on this machine, as Tern's chat or in its own interface, the plugin SHALL save, under that pane's id: the agent "agy", the chat's conversation file and its folder. The conversation SHALL be the only one held open by the only `agy` process whose environment names the pane. A process holding two conversations SHALL save nothing new.

#### Scenario: As Tern's chat
- **WHEN** a shell in folder F runs `tern acp antigravity` (the user's custom agent), the user sends the chat one message, and the reply ends
- **THEN** within 3 seconds the kv dump holds, under that pane's id, agent "agy", folder F, and a `conversations/<conversation id>.db` file that exists

#### Scenario: In its own interface
- **WHEN** the user types `command agy` in a shell in folder F, sends one message, and waits 35 seconds without opening the graph
- **THEN** the kv dump holds, under that pane's id, agent "agy", folder F and that conversation's file

#### Scenario: A new conversation after /clear
- **WHEN** in its own interface the user sends one message, types `/clear`, sends another message, and opens the graph
- **THEN** within 3 seconds the kv dump holds, under that pane's id, the second conversation's file, not the first

### Requirement: When other chats are saved
The plugin SHALL save Claude, Codex and Antigravity chats whenever it saves omp chats. It SHALL also save within 3 seconds after a shell in this window starts a command that runs `claude` or `agy`, and every 30 seconds while a Claude or Antigravity chat runs in its own interface in a pane of this window.

#### Scenario: Saved before the tab closes
- **WHEN** a linked tab's shell runs `command agy`, the user sends one message, waits 35 seconds and closes the tab without opening the graph
- **THEN** the graph, opened afterwards, shows the closed tab with "Resume", and its row starts with "agy"

### Requirement: Saved entries are checked
A saved entry SHALL show Resume and name a row only when its agent is "omp", "claude", "codex" or "agy" and its file has that agent's shape: an omp session file, a Claude transcript, a Codex rollout file or an Antigravity conversation file, the last three named by their session id. Other entries, such as the Claude session ids saved by versions 0.9.0 to 0.10.0, SHALL be gone from the store after its next write.

#### Scenario: Claude session from 0.10.0
- **WHEN** `kv.json` holds a saved Claude session under pane P of a closed linked tab, and the user opens the graph and then changes any objective
- **THEN** the closed tab shows no Resume, P's row starts with "agent", and the kv dump afterwards holds no saved entry under P

#### Scenario: A file of the wrong shape
- **WHEN** `kv.json` holds, under pane P of a closed linked tab, agent "codex" with an existing file whose name holds no thread id, and the user opens the graph and then changes any objective
- **THEN** the closed tab shows no Resume, and the kv dump afterwards holds no saved entry under P

### Requirement: Resume commands
Resume SHALL type, into each new shell, `omp --resume <file>` for an omp chat, `claude --resume <id>` for a Claude chat, `codex resume <id>` for a Codex chat, or `agy --conversation <id>` for an Antigravity chat, where `<id>` is the session id in the saved file's name. Tern's shell then opens Claude and Codex as Tern's chat or in their own interface, as Tern's settings say at that moment. Antigravity SHALL open in its own interface.

#### Scenario: Codex comes back as Tern's chat
- **WHEN** Tern opens typed agent commands as its own chats and Codex isn't set to keep its own interface, and a linked tab holding a Codex chat with a saved rollout file is closed and its "Resume" clicked
- **THEN** the new tab's pane ran `codex resume <thread id>`, is Tern's chat, and shows the earlier message

#### Scenario: Codex keeps its own interface
- **WHEN** Codex is set to keep its own interface, and a linked tab holding a Codex chat saved as Tern's chat is closed and its "Resume" clicked
- **THEN** the new tab runs Codex's own interface, started with `codex resume <thread id>`, showing the earlier message

#### Scenario: Claude comes back by Tern's settings
- **WHEN** a linked tab holding a Claude chat with a saved transcript is closed and its "Resume" clicked, once with Claude set to keep its own interface and once without
- **THEN** each new tab ran `claude --resume <session id>` in the chat's folder and shows the earlier message: in Claude's own interface the first time, as Tern's chat the second

#### Scenario: Antigravity comes back in its own interface
- **WHEN** a linked tab holding an Antigravity chat saved as Tern's chat is closed and its "Resume" clicked
- **THEN** the new tab runs Antigravity's own interface, started with `agy --conversation <conversation id>`, showing the earlier message

## MODIFIED Requirements

### Requirement: Resuming a closed tab
Clicking "Resume" SHALL close the graph, open a new tab in the first saved chat's folder, in the session "Where a chat resumes" names, and run that chat's command, as "Resume commands" gives it, there. Each further saved chat of that tab SHALL run the same way in a split to the right, in row order. Every objective linking the closed tab SHALL then link the new tab instead, and the closed tab's snapshot SHALL be removed. Panes without a saved chat SHALL NOT be recreated.

#### Scenario: One chat comes back
- **WHEN** a linked tab holding one omp chat with a saved chat file F and one shell is closed, and the user clicks its "Resume"
- **THEN** a new tab shows an omp chat started with `omp --resume F` that holds the earlier messages, and it has no shell pane

#### Scenario: Links move to the new tab
- **WHEN** that closed tab was linked to objectives X and Y, and the user clicks its "Resume" and opens the graph again
- **THEN** the kv dump shows X and Y linked to the new tab and not the closed one, the closed tab's snapshot is gone, and the graph shows the new tab linked under its session with no ghost left

### Requirement: Saved chats follow their tabs
A saved chat SHALL be removed once its pane is neither live in the window nor a row of a stored tab snapshot, for example after the user unlinks the last objective from the closed tab that held it, which drops the tab's snapshot.

#### Scenario: Unlinked with its tab
- **WHEN** a tab holding an omp chat with a saved chat file, linked only to open objective Y, is closed, and the user selects Y and clicks "× Unlink" on the closed tab
- **THEN** once the graph has redrawn, the kv dump holds neither the tab's snapshot nor the pane's saved chat

### Requirement: Resume button on a closed tab
A closed tab node SHALL show a "Resume" button on its header when at least one of its pane rows held a chat, as Tern's chat or in an agent's own interface, and has a saved chat whose file still exists, and none otherwise. Tabs held by another window SHALL NOT show it. Its hit area SHALL be at least 28 × 22 px, and dragging across it SHALL NOT select its text. Clicking the rest of the header SHALL select the tab, with no toast.

#### Scenario: Button on a closed chat tab
- **WHEN** a linked tab holding an omp chat with a saved chat file, and a linked tab holding only a shell, are both closed
- **THEN** the first closed tab's header shows "Resume" and the second's doesn't

#### Scenario: Header click selects
- **WHEN** the user clicks the closed tab's label, beside its Resume button
- **THEN** focus is unchanged, no toast shows, no new tab opens, and the closed tab is drawn selected with its "Resume" still showing

#### Scenario: Chat file gone
- **WHEN** a closed tab's only saved omp chat file is moved away, and the graph draws again
- **THEN** that tab's header shows no "Resume"

#### Scenario: A chat in its own interface
- **WHEN** a linked tab whose shell ran Claude in its own interface, with a saved transcript, is closed
- **THEN** its header shows "Resume", and its row starts with "claude"

## REMOVED Requirements

### Requirement: Only omp chats are kept
**Reason**: Claude, Codex and Antigravity chats are kept now, so "only omp" no longer holds.
**Migration**: "Saved entries are checked" takes its place. It still drops the Claude sessions saved by versions 0.9.0 to 0.10.0, with the same scenario.
