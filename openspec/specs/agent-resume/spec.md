# agent-resume Specification

## Purpose
Lets a closed tab's omp chats come back from the graph: the plugin saves each chat's file under its pane while it runs, and a closed tab's Resume button reopens those chats in a new tab that takes over the closed tab's links.

## Requirements

### Requirement: Saved sessions follow their tabs
A saved session SHALL be removed once its pane is neither live in the window nor a row of a stored tab snapshot, for example after "Prune closed tabs" removes the closed tab that held it.

#### Scenario: Pruned with its tab
- **WHEN** a linked tab holding an omp chat with a saved chat file is closed, and the user confirms "Prune closed tabs"
- **THEN** the kv dump holds neither the tab's snapshot nor the pane's saved chat

### Requirement: Resume button
A closed tab node SHALL show a "Resume" button on its header when at least one of its pane rows has a saved omp chat whose file still exists, and none otherwise. Tabs held by another window SHALL NOT show it. Its hit area SHALL be at least 28 × 22 px, and dragging across it SHALL NOT select its text. Clicking the rest of the header SHALL still only say the tab is closed.

#### Scenario: Button on a closed chat tab
- **WHEN** a linked tab holding an omp chat with a saved chat file, and a linked tab holding only a shell, are both closed
- **THEN** the first closed tab's header shows "Resume" and the second's doesn't

#### Scenario: Header click still toasts
- **WHEN** the user clicks the closed tab's label, beside its Resume button
- **THEN** focus is unchanged and a toast says the tab is closed

#### Scenario: Chat file gone
- **WHEN** a closed tab's only saved omp chat file is moved away, and the graph draws again
- **THEN** that tab's header shows no "Resume"

### Requirement: Resuming a closed tab
Clicking "Resume" SHALL close the graph, open a new tab in the current session in the first saved chat's folder, and run `omp --resume <file>` there. Each further saved chat of that tab SHALL run the same way in a split to the right, in row order. Every objective linking the closed tab SHALL then link the new tab instead, and the closed tab's snapshot SHALL be removed. Panes without a saved chat SHALL NOT be recreated.

#### Scenario: One chat comes back
- **WHEN** a linked tab holding one omp chat with a saved chat file F and one shell is closed, and the user clicks its "Resume"
- **THEN** a new tab shows an omp chat started with `omp --resume F` that holds the earlier messages, and it has no shell pane

#### Scenario: Links move to the new tab
- **WHEN** that closed tab was linked to objectives X and Y, and the user clicks its "Resume" and opens the graph again
- **THEN** the kv dump shows X and Y linked to the new tab and not the closed one, the closed tab's snapshot is gone, and the graph shows the new tab linked under the current session with no ghost left

### Requirement: Saved omp chats
For each omp chat in a pane of this window on this machine, the plugin SHALL save, under that pane's id in its store: the agent "omp", the chat's file and its folder. The file SHALL be the omp session file the chat's process holds open, else the session file its command line resumes or restores. A chat with neither SHALL save nothing. A different file found later for the same pane SHALL replace the saved one.

#### Scenario: First message saves the chat
- **WHEN** the user types `omp` in a shell in folder F and sends the chat one message, and the reply ends
- **THEN** within 3 seconds of the reply ending, the kv dump holds, under that pane's id, agent "omp", folder F and the path of the `.jsonl` session file the chat's omp process holds open

#### Scenario: Two chats in one folder
- **WHEN** two omp chats run in folder F, in different panes, and each is sent one message
- **THEN** the kv dump holds a saved chat under each pane's id, and the two files differ, each being the one that pane's omp process holds open

#### Scenario: Chat started from a file
- **WHEN** a shell runs `omp --resume <file>` for an existing session file, no message is sent, and the user opens the graph
- **THEN** within 3 seconds the kv dump holds that file under the pane's id

#### Scenario: No message, nothing saved
- **WHEN** the user types `omp` in a shell, sends nothing, and opens the graph
- **THEN** the kv dump holds no saved chat for that pane

### Requirement: When omp chats are saved
The plugin SHALL save omp chats within 3 seconds after any omp chat's turn starts or ends, after the plugin starts, and after the graph opens, whether or not the graph is shown at that moment.

#### Scenario: Saved at plugin start
- **WHEN** an omp chat that has had a message runs, its saved chat is removed from `kv.json`, and the plugin is reloaded
- **THEN** within 3 seconds the kv dump holds that chat's file under its pane's id again

### Requirement: Only omp chats are kept
Saved entries that are not omp chats, such as Claude sessions saved by versions 0.9.0 to 0.10.0, SHALL NOT show Resume or name a row, and SHALL be gone from the store after its next write.

#### Scenario: Claude session from 0.10.0
- **WHEN** `kv.json` holds a saved Claude session under pane P of a closed linked tab, and the user opens the graph and then changes any objective
- **THEN** the closed tab shows no Resume, P's row starts with "agent", and the kv dump afterwards holds no saved entry under P
