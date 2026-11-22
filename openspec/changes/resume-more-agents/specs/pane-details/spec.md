## MODIFIED Requirements

### Requirement: Pane type
Each pane row SHALL start with its pane's type: the agent's name for an agent, "shell" for a terminal, "note" for a note, "file" for any other file, "browser" for a browser, and the pane's kind for any other pane. Claude Code, Codex and Antigravity chats SHALL be named "claude", "codex" and "agy", including ones typed at a shell prompt. A row in a closed or elsewhere tab SHALL show the type its stored kind gives, or the agent of the pane's saved chat when it has one.

#### Scenario: Mixed tab
- **WHEN** a tab holds a shell, a file pane and an idle omp agent
- **THEN** their rows start with "shell", "file" and "omp · idle"

#### Scenario: Closed tab
- **WHEN** a linked tab holding a shell is closed and shown under "Closed tabs"
- **THEN** its row still starts with "shell"

#### Scenario: Claude chat typed in a shell
- **WHEN** the user types `claude` in a shell, which opens a Claude chat, and the chat is idle
- **THEN** its row starts with "claude · idle"

#### Scenario: Closed Claude chat
- **WHEN** a linked tab holding a Claude chat that was never sent a message is closed and shown under "Closed tabs"
- **THEN** that row starts with "agent"

#### Scenario: Closed omp chat
- **WHEN** a linked tab holding an omp chat with a saved chat file is closed and shown under "Closed tabs"
- **THEN** that row starts with "omp"

#### Scenario: Codex chat typed in a shell
- **WHEN** Tern opens typed agent commands as its own chats, and the user types `codex` in a shell and the chat is idle
- **THEN** its row starts with "codex · idle"

#### Scenario: Antigravity chat typed in a shell
- **WHEN** the user's `agy` shortcut opens Antigravity as Tern's chat, and the chat is idle
- **THEN** its row starts with "agy · idle"

#### Scenario: Closed Codex chat
- **WHEN** a linked tab holding a Codex chat with a saved rollout file is closed and shown under "Closed tabs"
- **THEN** that row starts with "codex"
