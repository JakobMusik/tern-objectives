# Objectives for Tern

A [Tern](https://docs.stencil.so/tern) plugin that keeps one global list of objectives and links each one to the tabs where its work happens. It opens as a clickable graph: objectives on the left, tabs on the right, and a line for every link. Clicking a tab's header or a pane's → button jumps straight to it, in any session.

![The objectives graph: seven objectives on the left, each title followed by its creation date and time, with priority badges, due dates and tags; tabs grouped by session on the right, with the tab the graph was opened from outlined at the top; each pane row starts with its type and ends in an arrow button, folded except an omp agent's row, which shows "you:" and "omp:" lines cut in the middle; an unlinked tab drawn grey with a dashed border](docs/graph.png)

## Install

```sh
tern plugin install github.com/JakobMusik/tern-objectives
```

The plugin is one window script (`window.luau` and `lib/`): it keeps the objectives and draws the graph in Tern's built-in canvas popup. It needs nothing on `PATH` besides the `git` that `tern plugin install` uses to fetch it, and nothing on the machines your sessions run on: in a session on another machine (attached over SSH), the graph opens and works the same, filled from this machine.

## Commands

| Command | Key | What it does |
|---|---|---|
| Objectives: Open graph | ⌃⌘O | Shows the graph over the current tab; pressed again while it is shown, closes it. A click outside the graph or its × closes it too, and so does Esc after a click on its title bar. |
| Objectives: Rename selected objective | ⌥R | Opens the Rename field for the objective selected in the graph. With nothing selected, or the graph not shown, it says so and does nothing. |
| Objectives: Link this tab… | | Picks an open objective to link to, or unlink from, the focused pane's tab. Linked objectives show a check, and each row gives the objective's priority and when it was created, as `P2 · 11-07 14:32`. |
| Objectives: New objective for this tab… | | Asks for a title and creates a P2 objective already linked to the focused pane's tab. |

The keys can be changed like any other: bind a chord to `plugin.objectives.open` or `plugin.objectives.rename` in Tern's keybind settings. A plain R can't be the rename key, not even inside the graph only: Tern uses R in its own panes, the graph can't take keys of its own, and a plugin's key works in every pane.

## Using the graph

- **＋ New objective** asks for a title. Every objective's node shows its title followed, dimmed, by when it was created, as `11-07 14:32`, so objectives with the same title can be told apart; a long title is cut before the time is, and renaming leaves the time as it is. The new objective is selected, so every tab shows a **＋ Link** bar to link it.
- **Click an objective** to select it: its lines get thicker, the others fade, and, for an open objective, every tab gets a bar at its foot: **＋ Link**, or **× Unlink** where it is already linked. Its tabs move to the top of the right column under **Linked to “…”**, and a bold accent bar labelled **Other tabs** divides them from the rest; a session with tabs on both sides shows its heading twice. A tab you link moves up at once, and a tab you unlink moves down. The usual order comes back when you clear the selection: click the objective again, or empty space.
- **Right-click a tab** (its header or any pane row) for a **Link to** menu of every open objective, each with its creation time (`Write slides · 11-07 14:32`) and a check on the linked ones. Choosing one links or unlinks it; nothing needs to be selected.
- The tab you opened the graph from has an accent-coloured ring, and the pane you opened it from an accent bar at its row's left edge. That tab's session comes first in the right column with the tab at its top, so you can see where you came from.
- **The box** marks an objective done. Done is final: done objectives move to the **Done** group at the bottom, most recently done first, and their links can't change, so selecting one shows no **＋ Link** bars. A done objective draws its lines only while it is selected, in green. Its box does nothing more. For a mistake, the header shows **Marked done “…” · Undo** until your next click in the graph, or for 10 seconds. A done objective's **trash icon** removes it at once, with the same **Undo**. **P0–P3** cycles the priority (red, orange, blue, grey). With an objective selected, **⌥R** renames it. **⋯** renames, sets a one-line side note, a due date or tags, or deletes it after asking.
- **Close linked tabs** in a done objective's **⋯**, or **Close 2 tabs** in its **Marked done** notice, closes the tabs it links in this window, after asking. Tabs an open objective still links stay open, and the question says how many. The plugin first notes the omp chats in those tabs, so each closed tab can bring them back with **Resume**; every other program in them ends. Links are kept. Marking an objective done never closes anything by itself, and cancelling the question keeps the notice's **Undo**.
- **Review** done objectives on a spaced-repetition schedule, the SM-2-OSR schedule of the [obsidian-spaced-repetition](https://github.com/st3v3nmw/obsidian-spaced-repetition) plugin with its default settings. Marking an objective done schedules its first review for the next day, and a done node's chip reads **review due** or **review in 3d**. **Review (n)** in the header lists the n done objectives that are due, each with **Hard**, **Good** and **Easy** buttons showing the days until its next review; select one to see its lines. Hard halves the interval, Good stretches it by the objective's ease (250% at first), and Easy by a little more, raising the ease. A rated objective leaves the list; the mode ends when the list is empty, when you click **Review** again, or when the graph closes.
- **Click a tab header** to jump to that tab, or **a pane row's → button** to jump to that pane, in whatever session it lives. Each pane row starts with its type: an agent's name and state (`omp · working`), `shell`, `note`, `file`, `browser`, or the pane's kind. Rows start folded: **click anywhere on a row but its → button** to open its details, and click again to fold them; the rows you open are remembered. The details show what the pane is doing: for an omp agent, `you:` with your last message and `omp:` with its last reply, each cut in the middle when it is too long so its beginning and its end both show; a terminal's last or running command; or a file's path.
- **All / This session** and the **#tag** chips filter the graph; the choice is remembered.
- Tabs linked to no open objective have a grey fill and a dashed border. A linked tab that closes stays as a ghost under **Closed tabs**, links kept; tabs held by another Tern window show under **Other windows**. A closed tab that only done objectives link is kept out of the way: it shows, with **Resume**, while you select one of those objectives and in review mode, and its line shows while that objective is selected. **Prune closed tabs** removes the links of closed tabs to open objectives only, so done objectives keep their closed tabs for review; the trash icon or Delete removes those with the objective.
- **Resume** on a closed tab brings back its omp chats. While an omp chat runs in Tern, the plugin notes its chat file at each turn, when the plugin starts and when you open the graph. When the tab has closed, **Resume** switches to the session the tab was in, even if you renamed it, opens a new tab at the tab's old position there, and runs `omp --resume <chat file>` in the chat's folder, with one split per further chat. If that session is gone, the tab opens at the end of the current session, and a message names the missing session. The new tab takes over the closed tab's links, so its ghost goes away. Shells and other panes of the old tab are not recreated.

## Data

Everything the plugin keeps lives in one file in Tern's plugin data folder:

```
<Tern config>/plugin-data/objectives/kv.json
```

On macOS that is `~/Library/Application Support/Tern/plugin-data/objectives/kv.json`. The plugin writes nothing into your project folders, your home folder or its own package folder.

## Remove

```sh
tern plugin remove objectives
```

Removing the plugin leaves `plugin-data/objectives/kv.json` in place; delete that folder by hand to drop your objectives too.

## Known limits

- Side notes are one line of up to 200 characters. Tern's one-line field joins pasted lines without a space, so put a space or punctuation at the end of a line before pasting.
- The graph takes no keys, so Esc pressed inside it does nothing until you click its title bar. ⌃⌘O, a click outside and its × close it from anywhere.
- The tab's **Link to** menu has a row for every open objective and doesn't scroll. When there are more than fit the window's height (23 in an 800 px tall window), the rest fall below the window's edge and can't be picked; select the objective and use its **＋ Link** bar instead.
- A plugin reload, for example after an update, forgets where you opened the graph from and which objective was selected. A graph left open loses its accent marks and its origin-first order until you open it again.
- Rows in closed tabs and in other windows' tabs keep only the pane's stored kind, so an agent there reads `agent` instead of its name, and a note reads `file`. An omp chat whose chat file was noted reads `omp`.
- **Resume** works only for omp chats. Claude Code, Codex and other agents are not resumed; the Claude **Resume** of versions 0.9.0 to 0.10.0 is gone, along with the Claude conversations it had noted. Reopen those with `claude --resume` yourself.
- omp writes a chat's file when its first reply ends, so a chat is noted once it has had a reply, or when it was started from a chat file (`omp --resume` or Tern restoring it). A tab closed during its chat's first reply, or before the plugin saw the chat, gets no **Resume**, and neither does one whose chat file has since been moved or deleted.
- An omp chat switched to a new chat with `/new`, with no message sent since, still names its earlier chat file, so **Resume** reopens the earlier chat.
- The plugin finds a chat's pane through the `TERN_PANE` variable Tern gives its shells, which Tern doesn't document. If a later Tern drops it, chats aren't noted and **Resume** doesn't appear; nothing wrong is reopened.
- **Resume** reads processes on this Mac only, so it doesn't cover chats in sessions on another machine, and it refuses when the session it would open in is on one.
- A tab's old position is the one it had when the plugin last saw it: the last time the graph drew or an omp turn ran. If tabs were reordered after that and before the tab closed, the chat can come back a place or two off.
- Closing tabs can't be undone: Tern can't reopen a tab, and the programs in it end. Only omp chats come back, with **Resume**, and not one still in its first reply or in a session on another machine.
- ⌥R renames from anywhere in Tern, not only from the graph, because a plugin's key can't be limited to one pane. So Option+R no longer types "®", or sends Meta-R to a shell, in any pane; outside the graph it shows a hint instead. To keep Option+R for typing, bind `plugin.objectives.rename` to another chord.
- Reset on a plugin command's row in Tern's Keyboard settings removes its key instead of restoring it. Tern writes an empty entry for the chord, such as `"alt+r": []`, to `keybinds` in `settings.json`, and the row disappears. Delete that entry to get the default key and the row back.
- Review has no keys, since the graph takes none: rate with the mouse.
- A rating can't be undone. A mis-rated objective comes back at the date it was given.
- **Review (n)** counts what the filters show. Under **This session**, done objectives linked only to pruned or other sessions' tabs aren't counted; **All** shows every due one.

## License

MIT © 2026 nyclanker
