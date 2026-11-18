# Objectives for Tern

A [Tern](https://docs.stencil.so/tern) plugin for keeping track of what you are working on across sessions, and for remembering what you finished. It keeps one list of objectives and links each one to the tabs where its work happens, shown as a graph: objectives on the left, tabs on the right, a line for every link. Click a tab to see which objectives it serves, or its **Go to tab** button to jump straight to it, in any session. Finished objectives come back for review on a spaced-repetition schedule, so you revisit what you did before you forget it.

![The objectives graph, opened from the Guides tab: open objectives on the left by priority, P0 first, each with a grip to move it, a priority, due date and tags, two of them with titles wrapped onto two lines; "Fix login bug" ringed in amber with a "needs you" chip, and "Write release notes" in green with "replied"; "Read about rate limiting", which links Guides, tinted, with a thick line to Guides while the other lines fade, and its link icon highlighted at the right of its title; below them the open Done group, its row ending in its own sort button reading "Priority", its objectives by priority and marked "review due" or "review in 4d", where "Restyle the docs site", which also links Guides, shows its highlighted link icon beside its trash icon; the header has a Search button and a sort button reading "Priority" after All and This session, "Review (2)", a gear button for Configure and "＋ New objective"; tabs grouped by session on the right, with a line for each link, each tab ending in a "Go to tab" button under its pane rows: "Release notes" ringed in green with "replied", its open chat row showing "you:" and "omp:", and "Server" ringed in amber with "needs you" for its omp chat waiting for input](docs/graph.png)

## Features

- **Link tabs to objectives.** Select an objective, open or done, and click **＋ Link** or **× Unlink** on a tab, or right-click a tab and pick one. Quicker still, point at an objective and click its link icon to link the selected tab, or, with no tab selected, the tab you opened the graph from; the icon stays highlighted while they are linked, and clicking it again unlinks them. Links change only when you change them.
- **See what needs you.** An objective turns amber, with a **needs you** chip, when an omp chat in one of its tabs asks you something, and green, with **replied**, when one finished a reply you haven't seen yet. While one is at work, it shows a **working** chip, with no colour around it. Each tab is marked the same way for the omp chats in its panes, whether an objective links it or not.
- **Review what you finished.** Marking an objective done puts it on a spaced-repetition schedule. When it's due, **Review (n)** brings it back to rate **Hard**, **Good** or **Easy**, which sets when you see it next.
- **Jump anywhere.** Click **Go to tab** at the foot of a tab, or the **→** at the end of a pane's row, to go there. Click a pane row to see what it is doing: an omp agent's last message and reply, a shell's last or running command, a file's path.
- **Organize.** Give objectives priorities P0–P3 and put them in your own order; the sort button in the header switches the list between priority, your order and newest first, and the open Done group has a sort button of its own. Add due dates, tags and a side note; filter by tag or by the current session. The selected objective shows its buttons right under it: **Note**, **Due**, **Tags** and **Delete** (with Undo).
- **Finish cleanly.** Mark an objective done, then close its tabs in one go, from its **Close n tabs** button or the notice that marking done shows; or close every tab that only done objectives link with **Close n done tabs** in the header. Both ask first, right where you clicked, and while they ask, each tab they would close shows a red ring and **Closes**, and the question's tooltip names them all. Point at a tab to show its trash icon, which closes that one tab after asking right there. Closed tabs stay in the graph, and **Resume** brings their omp chats back. Not done after all? Click a done objective's box to reopen it: **Keep review** carries its review schedule on when it's done again, **Reset review** starts it over. It goes last in your order (last of its priority, sorted by priority), with its links.

## Reviewing done objectives

Marking an objective done schedules its first review for the next day, on the SM-2-OSR schedule of the [obsidian-spaced-repetition](https://github.com/st3v3nmw/obsidian-spaced-repetition) plugin.

1. Open the **Done** group: each done objective's chip says when it comes back, **review due** or **review in 4d**.
2. Click **Review (n)** in the header. The left column lists the n objectives that are due; select one to see the tabs it was linked to.
3. Rate each one **Hard**, **Good** or **Easy**. Every button shows the days until it comes back: Hard soon, Easy furthest out. A rated objective leaves the list, and review mode ends when the list is empty.

Review mode stays on when you close the graph: the next time you open it in the same window, it lists what is due then. Click the active **Review (n)** to leave it. **＋ New objective** and ⌥N leave it too, so the new objective shows in the list. Restarting Tern forgets it.

![Review mode: two done objectives due for review, each with Hard, Good and Easy buttons showing the days until its next review (Hard · 1d, Good · 3d, Easy · 4d for one, Hard · 2d, Good · 10d, Easy · 14d for the other); the selected one shows its Note and Tags buttons and has a green line to the tab it was linked to, listed under "Linked to" at the top of the right column, where every tab ends in a row with "Go to tab" on the left and "× Unlink" or "＋ Link" on the right; the other links Guides, the tab the graph was opened from, so its link icon is highlighted beside its trash icon; the header has the Search button and the sort button reading "Priority" after All and This session](docs/review.png)

## Install

```sh
tern plugin install github.com/JakobMusik/tern-objectives
```

It needs nothing on `PATH` but `git`, which `tern plugin install` already uses. Sessions on other machines (attached over SSH) work too, with nothing installed there.

## Use

| Command | Key | What it does |
|---|---|---|
| Objectives: Open graph | ⌃⌘O | Show or hide the graph. |
| Objectives: Rename selected objective | ⌥⇧R | Rename the objective selected in the graph. Clicking a title in the graph renames it too. |
| Objectives: New objective | ⌥N | Create an objective in the graph, opening the graph first if it isn't shown. Same as **＋ New objective**. |
| Objectives: Search… | ⌃⌥F | Search the objectives, opening the graph first if it isn't shown. Same as the graph's **Search** button. |
| Objectives: Link this tab… | | Link the current tab to an objective, or unlink it. |
| Objectives: New objective for this tab… | | Create an objective already linked to the current tab. |
| Objectives: Configure | | Open the graph's settings: shortcuts, how new objectives start, and how the list is sorted. The ⚙ button in the graph's header does the same. |

Close the graph with ⌃⌘O, its ×, a click outside it, or Esc after clicking its title bar.

Open objectives are listed by priority, P0 first, and in the order you give them within each priority; due dates don't reorder them. The sort button in the header, after **Search**, shows how the list is sorted: **Priority**, **Newest** (by creation time, newest first) or **Your order**. Each click moves to the next. The Done group is sorted on its own: while it is open, the sort button at the right of its **Done (n)** row shows how, and each click moves to the next of **Recently done**, **Priority** (the most recently done first within each priority), **Newest** (by creation time) and **Next review** (the soonest review first, so the ones due come first). Clicking a badge changes the priority at once but moves nothing until your next click elsewhere, so you can step from P3 to P0 in place. Your order is kept whichever way the list is sorted. New objectives go on top, unless Configure puts them at the bottom (of their priority, sorted by priority; newest first, they come first anyway). One you make with **＋ New objective** or ⌥N is listed first in any case, marked **New**, while it stays selected, so its buttons and the tabs' **＋ Link** bars are at hand; select something else, or click empty space, and it moves to its place. To move one, click its grip (the six dots at its left), then click the upper or lower half of the objective it should go above or below; sorted by priority, only objectives of its priority take it, and sorted newest first, there are no grips. Cancel in the header, or a click anywhere else, puts it back.

Click an objective to select it: its lines stand out, every tab offers **＋ Link** or **× Unlink**, and a row of buttons appears under it. Click its title to rename it. Click a tab's header to select the tab: its lines stand out and every objective linked to it is tinted where it is, done ones too while the Done group is open, and the objectives' link icons link or unlink that tab. An objective and a tab can be selected together, so with an objective selected, click one of its tabs to see which other objectives lead to it too. Click either again to clear it, or empty space to clear both. Each time you open the graph, nothing is selected. While nothing is selected, the lines of the tab you opened the graph from stand out instead, and the open objectives they lead to are tinted.

To find objectives, click **Search** (the magnifier in the header) or press ⌃⌥F, and type a few words: the graph then lists only the objectives, open and done, whose title, side note or tags hold every one of them, ignoring the case of the letters A to Z; `#web` finds the tag. A chip in the header shows the search: click it to change the search, or its **×** to end it. The scope and tag filters still apply, the tabs stay listed, and **Review (n)** counts only what matches. Starting a search clears a selected objective, though not a selected tab, and an objective you create or select while searching stays listed while it is selected. Each time you open the graph, there is no search.

⌥⇧R, ⌥N and ⌃⌥F work in every pane, with either Option key, so Option+Shift+R no longer types "‰", Option+N no longer starts "˜", and Control+Option+F no longer reaches the pane, anywhere in Tern. Change or remove them in Configure.

### Configure

**Objectives: Configure**, or the ⚙ button in the graph's header, shows the settings in the graph; **Back to graph** returns.

- **Shortcuts:** each command's keys, with **Change**, **Remove** and, once changed, **Reset**. Type a new shortcut the way Tern's keybinds spell it, such as `ctrl+alt+n`. A shortcut something else already uses, or one without ⌃, ⌥ or ⌘, is refused, so Configure never takes a key from Tern or another plugin.
- **New objectives:** the priority they start at (P3 unless you change it) and whether they go on top or at the bottom of your order.
- **Order:** **Sort by**: **Priority** (the default), **Your order** or **Newest first**, the same choice as the sort button in the graph's header. **Sort Done by**: **Recently done**, **Priority**, **Newest first** or **Next review**, the same choice as the Done group's sort button; it starts out as **Sort by** was, with **Your order** as **Recently done**.

## Data and removal

Everything lives in one file, `<Tern config>/plugin-data/objectives/kv.json` (on macOS, `~/Library/Application Support/Tern/plugin-data/objectives/kv.json`). The one exception is the shortcuts you change in Configure: Tern saves those in its own keybinds, in `settings.json`, where its Settings › Keyboard shows them too. The plugin writes nowhere else.

```sh
tern plugin remove objectives
```

Removing the plugin keeps that file; delete the `plugin-data/objectives` folder to drop your objectives too.

## License

MIT © 2026 nyclanker
