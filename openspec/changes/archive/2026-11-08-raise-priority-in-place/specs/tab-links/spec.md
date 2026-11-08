## MODIFIED Requirements

### Requirement: New objective for this tab command
"Objectives: New objective for this tab…" SHALL ask for a title, then create an objective at P3 already linked to the focused pane's tab.

#### Scenario: Create linked
- **WHEN** the user runs the command in tab "API Learning" and enters "Add caching layer"
- **THEN** a new P3 objective "Add caching layer" exists, linked to that tab

### Requirement: Creation time in link choices
Where the user picks an objective to link, each objective SHALL show its creation time as `MM-DD HH:MM` in local time: a tab menu row SHALL read `<title> · <time>`, and a "Link this tab" picker row SHALL show `P<priority> · <time>` as dim text after the title. Headings, toasts and confirmations SHALL keep the plain title.

#### Scenario: Same title in the tab menu
- **WHEN** two open objectives are both titled "Write slides", created at different minutes, and the user right-clicks a tab node
- **THEN** the menu has two rows, each "Write slides · " followed by that objective's creation time, and choosing one links only that objective in the kv dump

#### Scenario: Same title in the picker
- **WHEN** the user runs "Objectives: Link this tab…" with the same two objectives open, both still at the P3 they were made with
- **THEN** both rows read "Write slides", each with dim text `P3 · ` followed by its own creation time

#### Scenario: Plain title in a toast
- **WHEN** the user picks one of them in "Objectives: Link this tab…"
- **THEN** the toast reads "Linked to Write slides", without the time
