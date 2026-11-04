# Spec Delta

## Purpose

Shows objectives and tabs as a clickable two-column graph, with lines for links. The user manages objectives entirely by clicking, and sees at a glance which tabs serve which objective.

## ADDED Requirements

### Requirement: Opening the graph
"Objectives: Open graph" SHALL be a palette command bound to ⌃⌘O by default. It SHALL show the graph as a glimpse over the current tab. Running it again SHALL show the graph again rather than stacking another one: the window SHALL hold at most one graph at a time.

#### Scenario: Open twice
- **WHEN** the user runs "Objectives: Open graph" twice
- **THEN** the graph is shown and the window holds exactly one canvas owned by `objectives`

### Requirement: Two-column layout
The graph SHALL show objectives in a left column, tabs in a right column, and link lines between them. A header SHALL sit above both columns.

#### Scenario: Columns shown
- **WHEN** the graph opens with two objectives and three tabs
- **THEN** a screenshot shows two objective nodes on the left, three tab nodes on the right, and the header above them

### Requirement: Empty state
With no objectives, the left column SHALL show a hint pointing at "＋ New objective".

#### Scenario: First open
- **WHEN** the graph opens with an empty store
- **THEN** the left column shows the hint, and the right column still lists the window's tabs

### Requirement: Objective ordering
Open objectives SHALL be ordered:
1. by priority, P0 first;
2. then by due date, earliest first, with no date last;
3. then by created time, oldest first.

#### Scenario: Mixed priorities and dates
- **WHEN** the store holds P2 due tomorrow, P2 with no due date, P0 with no due date, and P2 due today
- **THEN** the order is P0, P2 due today, P2 due tomorrow, P2 with no date

### Requirement: Objective node content
Each objective node SHALL show, on fixed single lines:
- a done box, a priority badge, the title and a ⋯ button;
- below them, the side note (dimmed), a due chip and tag chips.

Text that doesn't fit SHALL end in "…". Hovering the node SHALL show the full title, the full note and the created and done times.

#### Scenario: Long note
- **WHEN** an objective has a 200-character side note
- **THEN** its node stays the same height, the note is cut with "…", and the node's tooltip holds the whole note

### Requirement: Priority badge
Clicking the priority badge SHALL step the priority P0 → P1 → P2 → P3 → P0. Badge colours SHALL be: P0 red, P1 orange, P2 blue, P3 grey.

#### Scenario: Cycle wraps
- **WHEN** the user clicks the badge of a P3 objective
- **THEN** the objective becomes P0 and its badge turns red

### Requirement: Done group
Clicking the done box SHALL toggle done. Done objectives SHALL leave the open list and gather in a "Done (n)" group at the bottom of the left column:
- the group is collapsed by default and opens or closes on click;
- inside it, the most recently done objective comes first;
- done objectives draw no lines.

#### Scenario: Marking done
- **WHEN** the user clicks the done box of a linked open objective
- **THEN** it moves into the Done group, the count goes up by one, and its lines are gone

#### Scenario: Reopening
- **WHEN** the user opens the Done group and clicks a done objective's box
- **THEN** it returns to the open list in its sort position, and its lines are drawn again

### Requirement: Objective menu
The ⋯ button SHALL open a picker with Rename, Side note, Due date, Tags and Delete.
- Rename and Side note SHALL open a one-line field pre-filled with the current value.
- Dismissing any picker or field SHALL change nothing.

#### Scenario: Rename
- **WHEN** the user picks Rename and enters "Fix login timeout"
- **THEN** the node shows "Fix login timeout"

#### Scenario: Dismissed field
- **WHEN** the user opens Side note and dismisses the field
- **THEN** the objective is unchanged

### Requirement: Due date picker and chip
The Due date picker SHALL offer:
- Today, Tomorrow, Friday (the next Friday after today), Next Monday and In 1 week;
- "Pick date…", which takes `YYYY-MM-DD`;
- Clear.

The due chip SHALL read "overdue Nd", "due today", "due tomorrow" or "due in Nd". It SHALL be amber when today or tomorrow, red when overdue, and muted otherwise.

#### Scenario: Overdue
- **WHEN** an open objective's due date is two days before today
- **THEN** its chip reads "overdue 2d" in red

#### Scenario: Due tomorrow
- **WHEN** the user picks "Tomorrow"
- **THEN** the chip reads "due tomorrow" in amber

### Requirement: Tag picker
The Tags picker SHALL list every existing tag, with a check on the objective's own, plus "New tag…". Choosing a tag SHALL add or remove it. "New tag…" SHALL ask for a name and add it. Tags SHALL show on the node as "#tag" chips.

#### Scenario: Add a new tag
- **WHEN** the user picks "New tag…" and enters "web"
- **THEN** the node shows a "#web" chip, and "web" is offered in the tag filter

### Requirement: Tab column
The right column SHALL group tabs under session headings. Sessions SHALL come in Tern's session order, with the current one marked, and tabs in tab order within each session. Linked closed tabs SHALL gather in a final "Closed tabs" group, and linked elsewhere tabs in an "Other windows" group.

#### Scenario: Three sessions
- **WHEN** the window holds sessions "alpha" (2 tabs), "beta" (1 tab, current) and "gamma" (1 tab)
- **THEN** the right column shows three headings in Tern's order, "beta" is marked current, and each lists its tabs in order

### Requirement: Tab node content
Each tab node SHALL show:
- its label: the tab's name if the user set one, else the title of its first pane;
- a dimmed line "<session> · tab <n>";
- one row per pane in the tab, floating panes included.

Parked panes and the graph's own pane SHALL NOT be listed.

#### Scenario: Split tab with a float
- **WHEN** an unnamed tab holds two tiled panes and one floating pane
- **THEN** its label is the first tiled pane's title, and it lists three pane rows

### Requirement: Unlinked tabs look different
A tab with no link to an open objective SHALL be drawn faded, with a dashed border.

#### Scenario: Linking removes the fade
- **WHEN** the user links a faded tab to an objective
- **THEN** the tab node is drawn at full strength with a solid border

### Requirement: Link lines
For each link between an open objective and a tab shown in the right column, a line SHALL join the two nodes:
- coloured by the objective's priority;
- drawn dashed when the tab is closed or elsewhere;
- ending at the nodes' edges, at any graph width from 360 to 1600 pixels.

#### Scenario: Alignment at two widths
- **WHEN** the graph is captured at 1400 and 460 pixels wide
- **THEN** in both captures, each line's ends sit within 2 pixels of the vertical centres of its objective node and tab header

### Requirement: Selection
Clicking an objective's title SHALL select it:
- its lines are drawn thicker;
- all other lines fade to about a quarter of their strength;
- link buttons appear on the tab nodes.

Clicking the selected objective again, or empty graph space, SHALL clear the selection.

#### Scenario: Select and clear
- **WHEN** the user clicks an objective's title and then clicks empty graph space
- **THEN** the first screenshot shows its lines emphasised and ＋/× buttons on the tabs, and the second shows neither

### Requirement: Scope filter
The header SHALL offer [All | This session].
- **All:** every objective and every tab.
- **This session:** only objectives linked to at least one tab of the current session, plus the selected objective, and only the current session's tabs, including its closed linked tabs.

#### Scenario: This session
- **WHEN** objective X is linked only to a tab of session "web", objective Y is linked only to a tab of "misc", and the current session is "web" with scope "This session"
- **THEN** the graph shows X and not Y, and only the tabs of "web"

### Requirement: Tag filter
The header SHALL show a chip for each existing tag. Clicking a chip SHALL show only objectives holding that tag; clicking it again SHALL clear the filter. At most one tag filter SHALL be active at a time.

#### Scenario: Filter by tag
- **WHEN** the user clicks the "#api" chip
- **THEN** only objectives tagged "api" are listed, and the chip is drawn active

### Requirement: New objective button
"＋ New objective" in the header SHALL ask for a title, create the objective at P2 with no links, and select it.

#### Scenario: Create and select
- **WHEN** the user clicks "＋ New objective" and enters "Write slides"
- **THEN** "Write slides" appears selected, and every tab node shows a ＋ button

### Requirement: Prune button visibility
The header SHALL show "Prune closed tabs" only while at least one linked tab is closed.

#### Scenario: Button appears
- **WHEN** a linked tab is closed while the graph is shown
- **THEN** "Prune closed tabs" appears in the header

### Requirement: Live refresh
While the graph is shown, it SHALL redraw by itself within one second of any of these:
- a tab or pane opening, closing or moving;
- a title change;
- the current session changing;
- an agent's state changing;
- a command finishing.

#### Scenario: New tab appears
- **WHEN** a new tab is opened while the graph is shown
- **THEN** the tab appears in the right column without the graph being reopened

### Requirement: Light and dark themes
Lines, badges, chips and faded nodes SHALL stay distinguishable in both Tern's light and dark appearances.

#### Scenario: Both appearances
- **WHEN** the graph is captured in the light appearance and in the dark appearance
- **THEN** both captures show every line, badge colour and the faded-tab style
