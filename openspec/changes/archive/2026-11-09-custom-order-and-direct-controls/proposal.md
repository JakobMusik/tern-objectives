# Proposal

## Why

Asked by the user on 2026-11-09:
1. Left Option + N should create a new objective in the graph popup by default.
2. Most of the plugin's commands should be buttons in the graph that act directly. Today the ⋯ button opens a picker just to choose the command, which is awkward and slow, and closing linked tabs takes a second picker to confirm.
3. Objective nodes should be draggable, or movable in some other way, so the order reflects how relevant each objective is right now.
4. A "Configure" command should let users customize the shortcuts, among other settings.
5. "Prune closed tabs" removes links, and links should not be removed for you, so it goes. Done objectives get the "＋ Link" / "× Unlink" bars back. A new button closes the tabs that only done objectives link.

Settled with the user on 2026-11-09:
- **Order:** the user's order only. Priority and due date no longer sort.
- **Moving:** pick a node up by its grip, then click where it goes. A canvas can't be dragged (design, source record).
- **Buttons:** an action bar on the selected node replaces ⋯.
- **Configure:** shortcuts, plus the priority new objectives start at and whether they go to the top or the bottom.
- **Done tabs:** the new button counts only the tabs the graph shows, so it follows the All / This session filter.
- **Link choices:** a tab's "Link to" menu and the "Link this tab…" picker keep listing open objectives only. Done objectives are linked with the bars.

## What Changes

1. **Custom order.** Open objectives are listed in an order the user sets, stored with them and shared by every window.
   - The first open after the update keeps today's order (priority, then due date, then created).
   - From then on, priority, due date and badge clicks never move a node.
   - New objectives go to the top, or to the bottom if Configure says so.
   - "Link this tab…" and the tab menu use the same order.
   - The order held while changing priority is no longer needed, so it goes.
2. **Moving objectives.** Each open node gets a grip ⠿ at its left.
   - A click on the grip lifts the node, and the header says so, with Cancel.
   - While a node is lifted, pointing at another open node's upper or lower half shows an insertion line there, and a click drops the node at that line.
   - Cancel, a second click on the grip, or a click anywhere else puts it back where it was.
   - Done objectives and review mode keep their own order and get no grip.
3. **Action bar instead of ⋯.** The selected objective shows a row of buttons under it. In review mode the row comes below the rating buttons.
   - On an open objective: Note, Due, Tags and Delete.
   - On a done objective: Note, Tags and, when it has tabs to close, "Close n tabs".
   - Note, Due and Tags open the same field or picker as before, directly. Renaming stays a click on the title, or ⌥R.
   - **Delete** removes the objective at once and offers Undo ("Removed “X” · Undo"), like a done objective's trash icon. The confirmation picker goes.
   - **Close n tabs** asks inline. The bar turns into "Close n tabs?", with the tabs that stay open, plus Close and Cancel. The done notice's "Close n tabs" and the header's "Close n done tabs" (item 8) confirm the same way, in place, so no confirmation picker is left.
   - The ⋯ button and its picker are removed.
4. **⌥N: New objective.** A new command, "Objectives: New objective", on ⌥N (`alt+n`).
   - In the graph it does what "＋ New objective" does.
   - Anywhere else it opens the graph first, so the new node appears in the popup.
   - Tern's chords can't tell left Option from right, so either Option key works.
   - Like ⌥R, it runs in every pane, so Option+N no longer types the "˜" dead key in Tern.
5. **Configure.** A new command, "Objectives: Configure", and a ⚙ button in the graph's header open a settings page in the graph.
   - **Shortcuts:** each of the plugin's six commands with its key in effect, and Change, Remove and Reset.
     - A new shortcut is typed, for example `ctrl+alt+n`, because a canvas gets no keys.
     - A shortcut that something else already uses, or one without ⌃, ⌥ or ⌘, is refused.
     - Shortcuts are saved in Tern's own keybinds, so Settings › Keyboard shows them too.
   - **New objectives:** the starting priority, P0 to P3 (P3 by default), and whether they go to the top or the bottom (top by default). These are stored with the objectives.
   - "Back to graph" returns to the graph.
6. **README and screenshots.**
   - The commands table gains ⌥N and Configure.
   - "Use" explains moving, the action bar and Configure, that link bars work for done objectives too, and "Close n done tabs".
   - The data section says that changed shortcuts are saved in Tern's settings.
   - Both screenshots are taken again, because the nodes change (grip, no ⋯).
7. **No more Prune.** The header's "Prune closed tabs" and the cleanup behind it are removed.
   - A closed tab linked to an open objective stays under "Closed tabs" until the user resumes it or unlinks it with "× Unlink".
   - Its snapshot and saved omp chats stay until then.
8. **Done objectives' tabs.**
   - Selecting a done objective shows the link bars on every tab node, in review mode too, as for an open objective. Its links change only when the user clicks a bar, or when Resume hands them to the new tab.
   - A new header button, "Close n done tabs", closes the live tabs the graph shows that only done objectives link: at least one done objective links each, and no open objective does.
     - It shows only when n is above zero, and asks in place first.
     - It saves the omp chats in those tabs first, closes every pane of each, and changes no link, as "Close n tabs" does for one objective.
9. **Release 0.17.0**, a minor release because behaviour changes.

Out of scope:
- **A real drag with the pointer.** A canvas sends only clicks to the plugin, and Tern's reorderable list reports its changes as events a canvas never delivers (design, source record).
- **Moving by keyboard.** ⌥↑ and ⌥↓ are Tern's own keys for moving lines and blocks, so a plugin can't bind them.
- **Reordering done objectives or review mode's list.** They stay most recently done first and earliest due first.
- **Recording a shortcut by pressing it, or telling left Option from right.** A canvas gets no keys, and Tern's chords name no side.
- **Editing text inside the node.** Note, Due and Tags still use Tern's one-line field and pickers, since a canvas allows no inputs.
- **Other settings** (title width, the Undo time, colours), and a separate order per window or session.
- **Done objectives in a tab's "Link to" menu or the "Link this tab…" picker.** Those stay open objectives only, as settled.
- **Any other way of removing links in bulk.** Only the user's own clicks on a link bar, and Resume's handover, change links.

## Capabilities

### New Capabilities

- `plugin-settings`: the Configure command and settings page, shortcut changes saved through Tern's keybinds, and the defaults for new objectives.

### Modified Capabilities

- `objectives-graph`:
  - replaced: Objective ordering becomes Custom order, and Objective menu becomes Action bar;
  - modified: Graph returns after its pickers, Objective node content, Selection (link bars for a done objective too), New objective button, Larger hit areas, Rename key, Closing a done objective's tabs, Closing tabs from the done notice, Rename by clicking the title, and Controls and titles don't select text (no Prune);
  - new: Moving objectives, New objective key, Inline confirmation, Closing tabs of done objectives, and Direct controls don't select text;
  - removed: Order held while changing priority, and Prune button visibility.
- `objective-store`:
  - modified: Objective record (the configured starting priority and place), Private storage (shortcuts go to Tern's keybinds) and Missing priority;
  - removed: Pruning closed tabs;
  - new: Stored order;
  - replaced: Deleting an objective becomes Removing an objective.
- `objective-review`: Review mode, whose closed-tab scenario now expects link bars; Leaving review mode, whose picker scenario starts from the action bar; and Undo after done or remove, which gains a scenario for deleting an open objective.
- `tab-links`:
  - modified: Linking from the graph (any selected objective) and New objective for this tab command (the configured starting priority and place);
  - replaced: Done objectives' links are fixed becomes Links of done objectives.
- `agent-resume`: Saved sessions follow their tabs, whose example and scenario named Prune, becomes Saved chats follow their tabs.
- `plugin-package`:
  - modified: Palette commands (six commands, with ⌥N) and README (the ⌥N key);
  - new: README on the direct controls (moving, the action bar, Configure, the keybinds note, and screenshots of this version).

## Impact

- `window.luau`: the `new` and `configure` commands.
- `lib/store.luau`:
  - the stored order and its one-time migration;
  - `move`;
  - settings in the state;
  - `create` with the configured priority and place;
  - `remove` for open objectives, replacing `delete`;
  - `toggle_link` for done objectives;
  - `prune` removed.
- `lib/app.luau`:
  - the lift, drop, inline-confirm, action-bar and "Close n done tabs" clicks;
  - the settings page state;
  - ⌥N;
  - the ⋯ menu, the held order and Prune are removed.
- `lib/view.luau`:
  - the grip, drop zones, action bar, inline confirmations, settings page and ⚙ button;
  - link bars for a selected done objective;
  - the done-tabs count and its header button;
  - `sort_open` and the `prunable` list are removed.
- `lib/layout.luau`, `styles.css`: the action bar's height, the grip, the lifted look, the insertion lines and the settings page.
- `lib/keys.luau` (new): chord parsing, display and the keybinds edits.
- `README.md`, `docs/graph.png`, `docs/review.png`, `plugin.toml` (0.17.0).
- **The user's Tern `settings.json`:** only when the user changes a shortcut in Configure, through Tern's settings API.
