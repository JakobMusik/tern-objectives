## MODIFIED Requirements

### Requirement: Pane type
Each pane row SHALL start with its pane's type: the agent's name for an agent, "shell" for a terminal, "note" for a note, "file" for any other file, "browser" for a browser, and the pane's kind for any other pane. A Claude chat SHALL be named "claude", including one typed at a shell prompt. A row in a closed or elsewhere tab SHALL show the type its stored kind gives, or "omp" when the pane has a saved omp chat.

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
- **WHEN** a linked tab holding a Claude chat is closed and shown under "Closed tabs"
- **THEN** that row starts with "agent"

#### Scenario: Closed omp chat
- **WHEN** a linked tab holding an omp chat with a saved chat file is closed and shown under "Closed tabs"
- **THEN** that row starts with "omp"
