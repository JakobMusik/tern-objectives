## MODIFIED Requirements

### Requirement: Attention marks
An objective node SHALL show the first mark that applies to the omp chats in the live tabs of this window that it links:
- **needs you:** one waits for the user's input. An amber ring, and a "needs you" chip first on its second line.
- **replied:** one finished a reply the user hasn't seen yet. A green ring and a "replied" chip.
- **working:** one is working. An accent-coloured "working" chip, and no ring.

Other agents SHALL NOT mark it. The chip's tooltip SHALL name the tabs.

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
