## ADDED Requirements

### Requirement: Done group sort method
The page's "Order" section SHALL offer "Sort Done by" after "Sort by": Recently done, Priority, Newest first or Next review, the same method as the Done group's sort button. A store without it SHALL read it from "Sort by", Your order as Recently done. The choice SHALL be stored with the objectives in the plugin's `kv.json`, apart from "Sort by", and SHALL hold in every window and after a reload. No method SHALL change the user's own order.

#### Scenario: Read from Your order
- **WHEN** `kv.json` was written by 0.28.2 with "Sort by" set to Your order, and the user opens the settings page
- **THEN** "Sort by" has Your order selected and "Sort Done by" has Recently done selected, and the open Done group's button reads "Recently done"

#### Scenario: Read from another method
- **WHEN** `kv.json` was written by 0.28.2 with "Sort by" set to Newest first, and the user opens the settings page
- **THEN** "Sort Done by" has Newest first selected

#### Scenario: Picked and saved
- **WHEN** "Sort by" is Priority and the user picks Next review for "Sort Done by"
- **THEN** Next review is selected, "Sort by" still has Priority selected, the open Done group's button reads "Next review", and the kv dump's settings hold both methods

#### Scenario: Survives a reload
- **WHEN** the user picks Newest first for "Sort Done by" and the plugin is reloaded
- **THEN** the settings page still shows Newest first for "Sort Done by", and the Done group lists the newest first
