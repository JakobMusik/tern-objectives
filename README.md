# Objectives for Tern

A [Tern](https://docs.stencil.so/tern) plugin for keeping track of what you are working on across sessions, and for remembering what you finished. It keeps one list of objectives and links each one to the tabs where its work happens, shown as a graph: objectives on the left, tabs on the right, a line for every link. Click a tab or pane to jump straight to it, in any session. Finished objectives come back for review on a spaced-repetition schedule, so you revisit what you did before you forget it.

![The objectives graph: open objectives on the left in your own order, each with a grip to move it, a priority, due date and tags, two of them with titles wrapped onto two lines; "Fix login bug" ringed in amber with a "needs you" chip, and "Write release notes" in green with "replied"; below them the open Done group, its objectives marked "review due" or "review in 4d"; the header has "Review (2)", a gear button for Configure and "＋ New objective"; tabs grouped by session on the right, with a line for each link, an omp chat waiting for input in the Server tab and an open chat row showing "you:" and "omp:"](docs/graph.png)

## Features

- **Link tabs to objectives.** Select an objective, open or done, and click **＋ Link** or **× Unlink** on a tab, or right-click a tab and pick one. Links change only when you change them.
- **See what needs you.** An objective turns amber, with a **needs you** chip, when an omp chat in one of its tabs asks you something, and green, with **replied**, when one finished a reply you haven't seen yet. While one is at work, it shows a **working** chip, with no colour around it.
- **Review what you finished.** Marking an objective done puts it on a spaced-repetition schedule. When it's due, **Review (n)** brings it back to rate **Hard**, **Good** or **Easy**, which sets when you see it next.
- **Jump anywhere.** Click a tab header or a pane's **→** to go there. Click a pane row to see what it is doing: an omp agent's last message and reply, a shell's last or running command, a file's path.
- **Organize.** Put objectives in your own order, and give them priorities P0–P3, due dates, tags and a side note; filter by tag or by the current session. The selected objective shows its buttons right under it: **Note**, **Due**, **Tags** and **Delete** (with Undo).
- **Finish cleanly.** Mark an objective done, then close its tabs in one go, from its **Close n tabs** button or the notice that marking done shows; or close every tab that only done objectives link with **Close n done tabs** in the header. Both ask first, right where you clicked. Closed tabs stay in the graph, and **Resume** brings their omp chats back. Not done after all? Click a done objective's box to reopen it: **Keep review** carries its review schedule on when it's done again, **Reset review** starts it over. It goes to the bottom of your list, with its links.

## Reviewing done objectives

Marking an objective done schedules its first review for the next day, on the SM-2-OSR schedule of the [obsidian-spaced-repetition](https://github.com/st3v3nmw/obsidian-spaced-repetition) plugin.

1. Open the **Done** group: each done objective's chip says when it comes back, **review due** or **review in 4d**.
2. Click **Review (n)** in the header. The left column lists the n objectives that are due; select one to see the tabs it was linked to.
3. Rate each one **Hard**, **Good** or **Easy**. Every button shows the days until it comes back: Hard soon, Easy furthest out. A rated objective leaves the list, and review mode ends when the list is empty.

Review mode stays on when you close the graph: the next time you open it in the same window, it lists what is due then. Click the active **Review (n)** to leave it. ⌥N leaves it too, so the new objective shows in the list. Restarting Tern forgets it.

![Review mode: two done objectives due for review, each with Hard, Good and Easy buttons showing the days until its next review (Hard · 1d, Good · 3d, Easy · 4d for one, Hard · 2d, Good · 9d, Easy · 14d for the other); the selected one shows its Note and Tags buttons and has a green line to the tab it was linked to, listed under "Linked to" at the top of the right column, where every tab offers "× Unlink" or "＋ Link"](docs/review.png)

## Install

```sh
tern plugin install github.com/JakobMusik/tern-objectives
```

It needs nothing on `PATH` but `git`, which `tern plugin install` already uses. Sessions on other machines (attached over SSH) work too, with nothing installed there.

## Use

| Command | Key | What it does |
|---|---|---|
| Objectives: Open graph | ⌃⌘O | Show or hide the graph. |
| Objectives: Rename selected objective | ⌥R | Rename the objective selected in the graph. Clicking a title in the graph renames it too. |
| Objectives: New objective | ⌥N | Create an objective in the graph, opening the graph first if it isn't shown. Same as **＋ New objective**. |
| Objectives: Link this tab… | | Link the current tab to an objective, or unlink it. |
| Objectives: New objective for this tab… | | Create an objective already linked to the current tab. |
| Objectives: Configure | | Open the graph's settings: shortcuts, and how new objectives start. The ⚙ button in the graph's header does the same. |

Close the graph with ⌃⌘O, its ×, a click outside it, or Esc after clicking its title bar.

Open objectives stay in the order you give them; priorities and due dates don't reorder them. New objectives go on top, unless Configure puts them at the bottom. To move one, click its grip (the six dots at its left), then click the upper or lower half of the objective it should go above or below. Cancel in the header, or a click anywhere else, puts it back.

Click an objective to select it: its lines stand out, every tab offers **＋ Link** or **× Unlink**, and a row of buttons appears under it. Click its title to rename it.

⌥R and ⌥N work in every pane, with either Option key, so Option+R no longer types "®" and Option+N no longer starts "˜" anywhere in Tern. Change or remove them in Configure.

### Configure

**Objectives: Configure**, or the ⚙ button in the graph's header, shows the settings in the graph; **Back to graph** returns.

- **Shortcuts:** each command's keys, with **Change**, **Remove** and, once changed, **Reset**. Type a new shortcut the way Tern's keybinds spell it, such as `ctrl+alt+n`. A shortcut something else already uses, or one without ⌃, ⌥ or ⌘, is refused, so Configure never takes a key from Tern or another plugin.
- **New objectives:** the priority they start at (P3 unless you change it) and whether they go on top or at the bottom of your order.

## Data and removal

Everything lives in one file, `<Tern config>/plugin-data/objectives/kv.json` (on macOS, `~/Library/Application Support/Tern/plugin-data/objectives/kv.json`). The one exception is the shortcuts you change in Configure: Tern saves those in its own keybinds, in `settings.json`, where its Settings › Keyboard shows them too. The plugin writes nowhere else.

```sh
tern plugin remove objectives
```

Removing the plugin keeps that file; delete the `plugin-data/objectives` folder to drop your objectives too.

## License

MIT © 2026 nyclanker
