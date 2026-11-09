## REMOVED Requirements

### Requirement: Final done state
**Reason**: From 0.19.0 a done objective's box asks whether to reopen it (objectives-graph, "Reopening a done objective"), so done is no longer final. Its scenario "Done stays done" goes with it.
**Migration**: "Done and reopening" replaces it. Stored records are unchanged: a done objective stays done until the user reopens it.

## ADDED Requirements

### Requirement: Done and reopening
Marking an objective done SHALL record the done time and start or carry on its review schedule. A done objective SHALL become open again only through Undo right after it was marked done, or when the user reopens it. Reopening SHALL clear the done time, keep or drop the schedule as the user chose, and put the objective after every other objective in the stored order. Marking done, Undo and reopening SHALL NOT change its links.

#### Scenario: Done until reopened
- **WHEN** the user marks a linked objective done, waits for the Undo notice to go, then clicks its done box and Cancel
- **THEN** the record is still done with the same done time, and its tab links are identical throughout

#### Scenario: Reopened keeping its review
- **WHEN** done objective "Write slides", linked to two tabs and reviewed twice, is reopened with "Keep review" while "Fix login bug" and "Review pull requests" are open
- **THEN** the kv dump shows "Write slides" open, with no done time, the same schedule and the same two links, as the last record of the list

#### Scenario: Reopened resetting its review
- **WHEN** done objective "Write slides", linked to two tabs, is reopened with "Reset review"
- **THEN** the kv dump shows "Write slides" open, with no done time, no schedule and the same two links
