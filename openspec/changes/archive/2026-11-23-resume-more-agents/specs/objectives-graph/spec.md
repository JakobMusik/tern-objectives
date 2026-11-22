## MODIFIED Requirements

### Requirement: Attention marks
An objective node SHALL show the first mark that applies to the agent chats in the live tabs of this window that it links:
- **needs you:** one waits for the user's input. An amber ring, and a "needs you" chip first on its second line.
- **replied:** one finished a reply the user hasn't seen yet. A green ring and a "replied" chip.
- **working:** one is working. An accent-coloured "working" chip, and no ring.

Agents' own interfaces SHALL NOT mark it. The chip's tooltip SHALL name the tabs.

#### Scenario: Question waiting
- **WHEN** "Fix login bug" links tab "Server", and the omp chat there asks the user a question while the user is in another tab
- **THEN** the graph shows "Fix login bug" with an amber ring and a "needs you" chip whose tooltip names "Server"

#### Scenario: Reply unseen
- **WHEN** "Fix login bug" links tab "Server", and the omp chat there finishes a reply while the user is in another tab
- **THEN** the graph shows "Fix login bug" with a green ring and a "replied" chip

#### Scenario: Chat working
- **WHEN** "Fix login bug" links tab "Server", and the omp chat there is working on a turn
- **THEN** the graph shows "Fix login bug" with an accent-coloured "working" chip first on its second line, whose tooltip names "Server", and no ring

#### Scenario: Working turns into replied
- **WHEN** "Fix login bug" shows "working" for tab "Server", and the omp chat there finishes its reply while the user is in another tab
- **THEN** the "working" chip goes, and "Fix login bug" shows a green ring and a "replied" chip

#### Scenario: Needs you wins
- **WHEN** an objective links one tab whose omp chat waits for input and another whose omp chat has an unseen reply
- **THEN** its node shows the amber ring and the "needs you" chip only

#### Scenario: Needs you wins over working
- **WHEN** an objective links tab "Server", whose omp chat waits for input, and tab "Docs", whose omp chat is working
- **THEN** its node shows the amber ring and the "needs you" chip only, naming "Server"

#### Scenario: Replied wins over working
- **WHEN** an objective links tab "Server", whose omp chat has an unseen reply, and tab "Docs", whose omp chat is working
- **THEN** its node shows the green ring and the "replied" chip only, naming "Server"

#### Scenario: Two chats in one tab
- **WHEN** tab "Split", linked to "Fix login bug", holds two omp chats side by side, one waiting for input and the other with a reply the user hasn't seen
- **THEN** "Fix login bug" shows the amber ring and the "needs you" chip only, naming "Split" once

#### Scenario: Not linked
- **WHEN** the omp chat in tab "Server" waits for input, and "Write slides" doesn't link "Server"
- **THEN** "Write slides" has no ring and no chip of any kind

#### Scenario: A Codex chat marks too
- **WHEN** "Fix login bug" links tab "Server", whose Codex chat, opened as Tern's chat, is working on a turn, and then finishes its reply while the user is in another tab
- **THEN** "Fix login bug" first shows the "working" chip naming "Server", then the green ring and the "replied" chip

#### Scenario: An agent's own interface doesn't mark
- **WHEN** "Fix login bug" links tab "Server", whose shell runs Antigravity in its own interface, and it finishes a reply while the user is in another tab
- **THEN** "Fix login bug" has no ring and no chip

### Requirement: Attention marks clear
A "replied" mark SHALL go once the user has focused the chat's pane that replied, as Tern's own unseen-reply marker does. Looking at its tab while another pane there has focus SHALL NOT clear it. A "needs you" mark SHALL stay until the chat stops waiting for input, even after the user has focused it. Marks SHALL show on open, done and review nodes. A selected node SHALL show its selection ring and its mark together.

#### Scenario: Focusing the pane clears a reply
- **WHEN** "Fix login bug" shows "replied" for tab "Server", and the user focuses the omp pane there and opens the graph again
- **THEN** "Fix login bug" has no ring and no chip of either kind

#### Scenario: Another pane of the tab focused
- **WHEN** tab "Split", linked to "Fix login bug", holds two omp chats side by side, the right one finished a reply the user hasn't seen, and the user focuses the left one and opens the graph again
- **THEN** "Fix login bug" still shows "replied"

#### Scenario: Focusing keeps a question
- **WHEN** "Fix login bug" shows "needs you" for tab "Server", and the user focuses the omp pane there without answering and opens the graph again
- **THEN** "Fix login bug" still shows "needs you"

#### Scenario: Selected and marked
- **WHEN** "Fix login bug" shows "needs you" and the user selects it
- **THEN** the screenshot shows the accent selection ring and the amber ring together, and the "needs you" chip

#### Scenario: Focusing a Codex pane clears its reply
- **WHEN** "Fix login bug" shows "replied" for tab "Server", whose Codex chat replied, and the user focuses that pane and opens the graph again
- **THEN** "Fix login bug" has no ring and no chip

### Requirement: Tab attention marks
A live tab node SHALL show the first mark that applies to its panes' agent chats, as an objective node does: an amber ring and a "needs you" chip, a green ring and a "replied" chip, or a "working" chip and no ring. The chip SHALL come first on the node's second line, and its tooltip SHALL name the panes. Agents' own interfaces SHALL NOT mark it. Marks SHALL clear as on objective nodes. Closed and other-window tabs SHALL show none. The origin tab SHALL show its origin ring and its mark together.

#### Scenario: Question waiting
- **WHEN** the omp chat in tab "Server" asks the user a question while the user is in another tab
- **THEN** the "Server" node shows an amber ring and a "needs you" chip before "api · tab 1", whose tooltip names the omp pane's title

#### Scenario: Objective and tab together
- **WHEN** "Fix login bug" links tab "Server", and the omp chat there waits for input
- **THEN** both the "Fix login bug" node and the "Server" node show an amber ring and a "needs you" chip

#### Scenario: Reply unseen
- **WHEN** the omp chat in tab "Release notes" finishes a reply while the user is in another tab
- **THEN** the "Release notes" node shows a green ring and a "replied" chip

#### Scenario: Chat working
- **WHEN** the omp chat in tab "Server" is working on a turn
- **THEN** the "Server" node shows an accent-coloured "working" chip first on its second line, and no ring

#### Scenario: Needs you wins
- **WHEN** tab "Split" holds two omp chats side by side, one waiting for input and the other with a reply the user hasn't seen
- **THEN** the "Split" node shows the amber ring and the "needs you" chip only, and the chip's tooltip names the waiting pane only

#### Scenario: Unlinked tab
- **WHEN** no objective links tab "Server", and the omp chat there waits for input
- **THEN** the "Server" node keeps its grey fill and dashed border, drawn amber, and shows the "needs you" chip

#### Scenario: Focusing the pane clears a reply
- **WHEN** the "Release notes" node shows "replied", and the user focuses the omp pane that replied and opens the graph again
- **THEN** the "Release notes" node has no ring and no chip

#### Scenario: Origin tab marked
- **WHEN** the graph is opened from a shell pane in tab "Server", whose omp chat waits for input
- **THEN** the screenshot shows the "Server" node with the accent origin ring and the amber ring together, and the "needs you" chip

#### Scenario: Closed tab
- **WHEN** a linked tab whose omp chat waited for input is closed
- **THEN** its node under "Closed tabs" shows no ring and no chip

#### Scenario: A Codex chat's reply
- **WHEN** the Codex chat in tab "Release notes", opened as Tern's chat, finishes a reply while the user is in another tab
- **THEN** the "Release notes" node shows a green ring and a "replied" chip, whose tooltip names the Codex pane's title
