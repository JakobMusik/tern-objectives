# pane-details Specification

## Purpose
Lets the user see what each pane in a tab is doing without leaving the graph: an agent's state and latest exchange, a terminal's last command, or what any other pane shows.

## Requirements

### Requirement: Expandable pane rows
Each pane row in a live tab SHALL show its details area under the row by default, with a ▾ toggle. Clicking ▾ SHALL fold the details away and turn the toggle into ▸; clicking ▸ SHALL open them again. Clicking the toggle SHALL NOT jump to the pane. Folded rows SHALL be remembered between opens of the graph.

#### Scenario: Open by default
- **WHEN** the graph opens on a tab with two panes whose rows were never folded
- **THEN** both rows show their details under them, each with a ▾ toggle

#### Scenario: Expand and collapse
- **WHEN** the user clicks ▾ on a pane row and then clicks ▸
- **THEN** the details are gone after the first click and back after the second, and focus stays on the graph

### Requirement: Agent state
An expanded row of a pane running an agent, either an agent block or omp typed at a shell prompt, SHALL show the agent's state: working, waiting for input, idle or exited.

#### Scenario: Working agent
- **WHEN** an omp agent in the pane is mid-turn and its row is expanded
- **THEN** the details show the state "working"

### Requirement: Agent last reply
An expanded agent row SHALL show the agent's latest reply as one line labelled "omp". The reply SHALL be cut to its first 160 characters, with line breaks turned into spaces and "…" added when it was cut.

#### Scenario: Long reply
- **WHEN** the agent's last reply is 400 characters over several lines
- **THEN** the "omp" line shows its first 160 characters on one line, ending in "…"

### Requirement: Agent last user message
For omp agents, an expanded row SHALL also show the user's latest message, as one line labelled "you", following the same 160-character rule. Agents without a readable omp chat SHALL show the reply line only. Until the message has been read, the "you" line SHALL show a placeholder.

#### Scenario: omp exchange
- **WHEN** the user sent "Explain __shfl_down_sync" to an omp agent and its row is expanded
- **THEN** the details show a "you" line starting "Explain __shfl_down_sync" above the "omp" reply line

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
