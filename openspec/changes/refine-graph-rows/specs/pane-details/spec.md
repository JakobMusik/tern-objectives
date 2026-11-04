# Spec Delta

## REMOVED Requirements

### Requirement: Expandable pane rows
**Reason**: Rows now start folded and the graph remembers opened rows, so the requirement and its "Open by default" scenario no longer hold; "Folded pane rows" replaces it.
**Migration**: Rows folded under 0.4.0 start folded anyway; the stored list of folded rows is dropped on the next write, and rows the user opens are remembered from then on.

## MODIFIED Requirements

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

## ADDED Requirements

### Requirement: Folded pane rows
Each pane row in a live tab SHALL start folded, with a ▸ toggle. Clicking ▸ SHALL show the row's details under it and turn the toggle into ▾; clicking ▾ SHALL fold them again. Clicking the toggle SHALL NOT jump to the pane. Opened rows SHALL be remembered between opens of the graph.

#### Scenario: Folded by default
- **WHEN** the graph opens on a tab with two panes whose rows were never opened
- **THEN** neither row shows details, and each has a ▸ toggle

#### Scenario: Expand and collapse
- **WHEN** the user clicks ▸ on a pane row and then clicks ▾
- **THEN** the details are there after the first click and gone after the second, and focus stays on the graph

#### Scenario: Opened rows remembered
- **WHEN** the user opens a row's details, closes the graph and opens it again
- **THEN** that row still shows its details, and the kv dump lists its pane as opened

### Requirement: Pane type
Each pane row SHALL start with its pane's type: the agent's name for an agent, "shell" for a terminal, "note" for a note, "file" for any other file, "browser" for a browser, and the pane's kind for any other pane. A row in a closed or elsewhere tab SHALL show the type its stored kind gives.

#### Scenario: Mixed tab
- **WHEN** a tab holds a shell, a file pane and an idle omp agent
- **THEN** their rows start with "shell", "file" and "omp · idle"

#### Scenario: Closed tab
- **WHEN** a linked tab holding a shell is closed and shown under "Closed tabs"
- **THEN** its row still starts with "shell"
