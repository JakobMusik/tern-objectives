# pane-details Specification

## Purpose
Lets the user see what each pane in a tab is doing without leaving the graph: an agent's state and latest exchange, a terminal's last command, or what any other pane shows.

## Requirements

### Requirement: Agent state
A pane row running an agent, either an agent block or omp typed at a shell prompt, SHALL show the agent's state after its type, as in "omp · working": working, waiting for input, idle or exited. The state SHALL show whether the row is folded or open.

#### Scenario: Working agent
- **WHEN** an omp agent in the pane is mid-turn and its row is folded
- **THEN** the row reads "omp · working"

### Requirement: Agent last reply
An open agent row SHALL show the agent's latest reply as one line "<agent>: <reply>", with line breaks turned into spaces. A reply too long for the line SHALL keep its beginning and its end, with "…" in place of the middle.

#### Scenario: Long reply
- **WHEN** the agent's last reply is 400 characters over several lines and its row is open
- **THEN** the line starts with "omp: " and the reply's first words, then shows "…", and ends with the reply's last words

### Requirement: Agent last user message
For omp agents, an open row SHALL also show the user's latest message as one line "you: <message>" above the reply line, following the same rule. Agents without a readable omp chat SHALL show the reply line only. Until the message has been read, the line SHALL read "you: …".

#### Scenario: omp exchange
- **WHEN** the user sent "Explain __shfl_down_sync" to an omp agent and opens its row
- **THEN** the details show "you: Explain __shfl_down_sync" above the "omp: " reply line

### Requirement: Terminal last command
An expanded row of a terminal pane SHALL show one of:
- its last finished command, with ✓ for exit status 0 or ✗ otherwise, the exit status and the duration;
- while a command runs, that command with ⟳ and the elapsed time, instead;
- "no command yet" when neither is known.

#### Scenario: Failed command
- **WHEN** the pane last ran `false`
- **THEN** the details read "✗ 1 · <duration>  false"

#### Scenario: Running command
- **WHEN** `sleep 30` is running in the pane
- **THEN** the details show "⟳", an elapsed time that goes up while the graph is shown, and "sleep 30"

### Requirement: Other pane kinds
An expanded row of any other pane SHALL show:
- a file pane's path;
- a browser pane's address;
- a plugin block's kind;
- for any remaining kind, its title.

#### Scenario: File pane
- **WHEN** a file pane showing `~/notes/todo.md` is expanded
- **THEN** the details show that path

### Requirement: Details stay current
While the graph is shown, expanded details SHALL update within one second of an agent's state or reply changing, or a command finishing.

#### Scenario: Command finishes while shown
- **WHEN** a command running in an expanded terminal row finishes while the graph is shown
- **THEN** the row switches from the running form to the finished form without the graph being reopened

### Requirement: Folded pane rows
Each pane row in a live tab SHALL start folded and SHALL show no arrow. A click anywhere on the row except its jump button SHALL show the row's details under it, and another such click SHALL fold them. That click SHALL NOT jump to the pane. Opened rows SHALL be remembered between opens of the graph.

#### Scenario: Folded by default
- **WHEN** the graph opens on a tab with two panes whose rows were never opened
- **THEN** neither row shows details, and neither shows a ▸ or ▾ arrow

#### Scenario: Expand and collapse
- **WHEN** the user clicks a pane row's name and then clicks it again
- **THEN** the details are there after the first click and gone after the second, focus stays on the graph, and the shown tab is unchanged

#### Scenario: Click beside the name
- **WHEN** the user clicks a folded pane row in the gap just left of its jump button, and then clicks the row's type
- **THEN** the details are there after the first click and gone after the second, and the shown session and tab are unchanged

#### Scenario: Opened rows remembered
- **WHEN** the user opens a row's details, closes the graph and opens it again
- **THEN** that row still shows its details, and the kv dump lists its pane as opened

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
