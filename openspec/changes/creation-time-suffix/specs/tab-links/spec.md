## ADDED Requirements

### Requirement: Creation time in link choices
Where the user picks an objective to link, each objective SHALL show its creation time as `MM-DD HH:MM` in local time: a tab menu row SHALL read `<title> · <time>`, and a "Link this tab" picker row SHALL show `P<priority> · <time>` as dim text after the title. Headings, toasts and confirmations SHALL keep the plain title.

#### Scenario: Same title in the tab menu
- **WHEN** two open objectives are both titled "Write slides", created at different minutes, and the user right-clicks a tab node
- **THEN** the menu has two rows, each "Write slides · " followed by that objective's creation time, and choosing one links only that objective in the kv dump

#### Scenario: Same title in the picker
- **WHEN** the user runs "Objectives: Link this tab…" with the same two objectives open
- **THEN** both rows read "Write slides", each with dim text `P2 · ` followed by its own creation time

#### Scenario: Plain title in a toast
- **WHEN** the user picks one of them in "Objectives: Link this tab…"
- **THEN** the toast reads "Linked to Write slides", without the time
