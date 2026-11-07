## MODIFIED Requirements

### Requirement: Agent last user message
For omp agents, an open row SHALL also show the user's latest message as one line "you: <message>" above the reply line, following the same rule. Until that message has been read, the line SHALL read "you: …". Agents without a readable omp chat SHALL show the reply line only, never a "you:" line.

#### Scenario: omp exchange
- **WHEN** the user sent "Explain caching" to an omp agent and opens its row
- **THEN** the details show "you: Explain caching" above the "omp: " reply line

#### Scenario: Another agent
- **WHEN** an agent other than omp has replied and the user opens its row
- **THEN** the details show its reply line and no "you:" line, from the first render on
