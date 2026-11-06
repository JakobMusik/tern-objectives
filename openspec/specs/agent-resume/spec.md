# agent-resume Specification

## Purpose
Lets a closed tab's Claude chats come back from the graph: the plugin saves each chat's session while it runs, and a closed tab's Resume button reopens those chats in a new tab that takes over the closed tab's links.

## Requirements

### Requirement: Saved Claude sessions
When a turn starts in a Claude chat on this machine, the plugin SHALL save, under the chat's pane id in its store: the agent "claude", the chat's session id and its folder. It SHALL do so within 3 seconds, whether or not the graph is shown. It SHALL save only when exactly one Claude chat and exactly one `claude` process with a session id share that folder. When the chat moves to another session, the next turn SHALL replace the saved id.

#### Scenario: First turn saves the session
- **WHEN** the user types `claude` in a shell in folder F, which opens a Claude chat, and sends it a message
- **THEN** within 3 seconds the kv dump holds, under that pane's id, agent "claude", folder F and the session id the chat's `claude` process was started with

#### Scenario: Two chats in one folder
- **WHEN** two Claude chats run in the same folder and each starts a turn
- **THEN** the kv dump holds no saved session for either pane

#### Scenario: No turn, no session
- **WHEN** a Claude chat is opened and closed without a message sent
- **THEN** the kv dump holds no saved session for its pane

### Requirement: Saved sessions follow their tabs
A saved session SHALL be removed once its pane is neither live in the window nor a row of a stored tab snapshot, for example after "Prune closed tabs" removes the closed tab that held it.

#### Scenario: Pruned with its tab
- **WHEN** a linked tab holding a Claude chat with a saved session is closed, and the user confirms "Prune closed tabs"
- **THEN** the kv dump holds neither the tab's snapshot nor the pane's saved session

### Requirement: Resume button
A closed tab node SHALL show a "Resume" button on its header when at least one of its pane rows has a saved session, and none otherwise. Tabs held by another window SHALL NOT show it. Its hit area SHALL be at least 28 × 22 px, and dragging across it SHALL NOT select its text. Clicking the rest of the header SHALL still only say the tab is closed.

#### Scenario: Button on a closed chat tab
- **WHEN** a linked tab holding a Claude chat with a saved session, and a linked tab holding only a shell, are both closed
- **THEN** the first closed tab's header shows "Resume" and the second's doesn't

#### Scenario: Header click still toasts
- **WHEN** the user clicks the closed tab's label, beside its Resume button
- **THEN** focus is unchanged and a toast says the tab is closed

### Requirement: Resuming a closed tab
Clicking "Resume" SHALL close the graph, open a new tab in the current session in the first saved chat's folder, and run `claude --resume <id>` there. Each further saved chat of that tab SHALL run the same way in a split to the right, in row order. Every objective linking the closed tab SHALL then link the new tab instead, and the closed tab's snapshot SHALL be removed. Panes without a saved session SHALL NOT be recreated.

#### Scenario: One chat comes back
- **WHEN** a linked tab holding one Claude chat with a saved session S and one shell is closed, and the user clicks its "Resume"
- **THEN** a new tab shows a Claude chat started with `claude --resume S` that holds the earlier messages, and it has no shell pane

#### Scenario: Links move to the new tab
- **WHEN** that closed tab was linked to objectives X and Y, and the user clicks its "Resume" and opens the graph again
- **THEN** the kv dump shows X and Y linked to the new tab and not the closed one, the closed tab's snapshot is gone, and the graph shows the new tab linked under the current session with no ghost left
