## MODIFIED Requirements

### Requirement: Review schedule starts at done
Marking an objective done SHALL give it a review schedule: next review on the next calendar day, interval 1 day, ease 250% and review count 0. An objective reopened with its review kept SHALL instead carry its schedule on: interval, ease and review count unchanged, next review on its stored date, or the next day when that date is today or earlier. A done objective stored without a schedule SHALL be read as if it had been marked done on its done date, so its next review is the day after it.

#### Scenario: Marked done
- **WHEN** the user marks an open objective done on 2026-11-07
- **THEN** the kv dump shows its schedule: next review 2026-11-08, interval 1, ease 250, review count 0

#### Scenario: Done before this version
- **WHEN** `kv.json` holds an objective marked done on 2026-11-04 with no schedule, and the graph opens on 2026-11-07
- **THEN** the header shows "Review (1)", and the objective's node shows a "review due" chip

#### Scenario: Done again with its review kept
- **WHEN** on 2026-11-09 the user marks done an objective reopened with "Keep review", whose schedule reads next review 2026-11-20, interval 9.5, ease 270, review count 2
- **THEN** the kv dump shows next review 2026-11-20, interval 9.5, ease 270, review count 2

#### Scenario: Kept review already due
- **WHEN** on 2026-11-09 the user marks done an objective reopened with "Keep review", whose schedule reads next review 2026-11-05, interval 4, ease 250, review count 1
- **THEN** the kv dump shows next review 2026-11-10, interval 4, ease 250, review count 1

#### Scenario: Done again after a reset
- **WHEN** on 2026-11-09 the user marks done an objective reopened with "Reset review"
- **THEN** the kv dump shows next review 2026-11-10, interval 1, ease 250, review count 0
