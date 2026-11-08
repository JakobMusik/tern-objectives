# Objectives for Tern

A [Tern](https://docs.stencil.so/tern) plugin for keeping track of what you are working on across sessions, and for remembering what you finished. It keeps one list of objectives and links each one to the tabs where its work happens, shown as a graph: objectives on the left, tabs on the right, a line for every link. Click a tab or pane to jump straight to it, in any session. Finished objectives come back for review on a spaced-repetition schedule, so you revisit what you did before you forget it.

![The objectives graph: objectives with priorities, due dates and tags on the left, two of them with titles wrapped onto two lines; "Fix login bug" ringed in amber with a "needs you" chip, and "Write release notes" in green with "replied"; below them the open Done group, its objectives marked "review due" or "review in 4d", and a "Review (2)" button in the header; tabs grouped by session on the right, with a line for each link, an omp chat waiting for input in the Server tab and an open chat row showing "you:" and "omp:"](docs/graph.png)

## Features

- **Link tabs to objectives.** Select an objective and click **＋ Link** on a tab, or right-click a tab and pick one.
- **See what needs you.** An objective turns amber, with a **needs you** chip, when an omp chat in one of its tabs asks you something, and green, with **replied**, when one finished a reply you haven't seen yet.
- **Review what you finished.** Marking an objective done puts it on a spaced-repetition schedule. When it's due, **Review (n)** brings it back to rate **Hard**, **Good** or **Easy**, which sets when you see it next.
- **Jump anywhere.** Click a tab header or a pane's **→** to go there. Click a pane row to see what it is doing: an omp agent's last message and reply, a shell's last or running command, a file's path.
- **Organize.** Priorities P0–P3, due dates, tags and a side note; filter by tag or by the current session.
- **Finish cleanly.** Mark an objective done, then close its tabs in one go. Closed tabs stay in the graph, and **Resume** brings their omp chats back.

## Reviewing done objectives

Marking an objective done schedules its first review for the next day, on the SM-2-OSR schedule of the [obsidian-spaced-repetition](https://github.com/st3v3nmw/obsidian-spaced-repetition) plugin.

1. Open the **Done** group: each done objective's chip says when it comes back, **review due** or **review in 4d**.
2. Click **Review (n)** in the header. The left column lists the n objectives that are due; select one to see the tabs it was linked to.
3. Rate each one **Hard**, **Good** or **Easy**. Every button shows the days until it comes back: Hard soon, Easy furthest out. A rated objective leaves the list, and review mode ends when the list is empty.

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
| Objectives: Link this tab… | | Link the current tab to an objective, or unlink it. |
| Objectives: New objective for this tab… | | Create an objective already linked to the current tab. |

Close the graph with ⌃⌘O, its ×, a click outside it, or Esc after clicking its title bar.

⌥R works in every pane, so Option+R no longer types "®". To change either key, bind `plugin.objectives.open` or `plugin.objectives.rename` in Tern's keybind settings.

## Data and removal

Everything lives in one file, `<Tern config>/plugin-data/objectives/kv.json` (on macOS, `~/Library/Application Support/Tern/plugin-data/objectives/kv.json`). The plugin writes nowhere else.

```sh
tern plugin remove objectives
```

Removing the plugin keeps that file; delete the `plugin-data/objectives` folder to drop your objectives too.

## License

MIT © 2026 nyclanker
