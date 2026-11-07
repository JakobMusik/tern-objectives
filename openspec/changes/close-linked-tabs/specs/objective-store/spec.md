## MODIFIED Requirements

### Requirement: Pruning closed tabs
"Prune closed tabs" SHALL ask for confirmation, naming how many closed tabs it will touch: the shown closed tabs that an open objective links. On confirmation it SHALL remove those tabs' links to open objectives, and the snapshot and saved chats of each one that no done objective links. Links of done objectives, live tabs, and tabs held by another window SHALL be untouched.

#### Scenario: Prune after closing a tab
- **WHEN** a tab linked only to an open objective is closed and the user confirms "Prune closed tabs"
- **THEN** no objective links that tab, its snapshot is gone, and links to live tabs remain

#### Scenario: Done objective's link kept
- **WHEN** closed tab C is linked to open objective Y and to done objective X, and the user confirms "Prune closed tabs"
- **THEN** Y no longer links C, X still does, and C's snapshot is still in the kv dump
