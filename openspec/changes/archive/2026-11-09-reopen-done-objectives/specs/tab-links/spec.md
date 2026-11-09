## MODIFIED Requirements

### Requirement: Links of done objectives
A done objective's links SHALL change the same way as an open objective's: through the link bars while it is selected, in the Done group or in review mode. Nothing else SHALL change them: marking done, Undo, rating, reopening and closing its tabs SHALL leave them as they are, and the only exception SHALL be Resume, which hands a closed tab's links to the tab it opens ("Resuming a closed tab").

#### Scenario: Unlink from a done objective
- **WHEN** done objective X links tabs A and B, and the user opens the Done group, selects X and clicks "× Unlink" on A
- **THEN** the kv dump shows X linked to B only, X is still done and selected, and A shows below the "Other tabs" divider with "＋ Link"

#### Scenario: Link a done objective
- **WHEN** the user then clicks "＋ Link" on tab C
- **THEN** the kv dump shows X linked to B and C, and a green line joins X to C

#### Scenario: Resume moves a done objective's link
- **WHEN** done objective X is linked to closed tab A, which held an omp chat that had replied, and the user selects X and clicks A's "Resume"
- **THEN** the kv dump shows X linked to the new tab instead of A, and X is still done

#### Scenario: Reopening keeps the links
- **WHEN** done objective X links live tab A and tab B, closed with "Close n tabs", and the user reopens X with "Reset review"
- **THEN** the kv dump shows X open and linked to A and B, and B shows under "Closed tabs" with a dashed line to X
