# Objectives for Tern

A [Tern](https://docs.stencil.so/tern) plugin that keeps one global list of objectives and links each one to the tabs where its work happens. It opens as a clickable graph: objectives on the left, tabs on the right, and a line for every link. Clicking a tab or a pane jumps straight to it, in any session.

![The objectives graph: seven objectives with priority badges, due dates and tags on the left; tabs grouped by session on the right, with the tab the graph was opened from outlined at the top; each pane row starts with its type and ends in an arrow button, folded except an omp agent's row, which shows "you:" and "omp:" lines cut in the middle; an unlinked tab drawn grey with a dashed border](docs/graph.png)

## Install

```sh
tern plugin install github.com/JakobMusik/tern-objectives
```

The plugin is one window script (`window.luau` and `lib/`): it keeps the objectives and draws the graph in Tern's built-in canvas popup. It needs nothing on `PATH` besides the `git` that `tern plugin install` uses to fetch it, and nothing on the machines your sessions run on: in a session on another machine (attached over SSH), the graph opens and works the same, filled from this machine.

## Commands

| Command | Key | What it does |
|---|---|---|
| Objectives: Open graph | ⌃⌘O | Shows the graph over the current tab; pressed again while it is shown, closes it. A click outside the graph or its × closes it too, and so does Esc after a click on its title bar. |
| Objectives: Link this tab… | | Picks an open objective to link to, or unlink from, the focused pane's tab. Linked objectives show a check. |
| Objectives: New objective for this tab… | | Asks for a title and creates a P2 objective already linked to the focused pane's tab. |

The key can be changed like any other: bind a chord to `plugin.objectives.open` in Tern's keybind settings.

## Using the graph

- **＋ New objective** asks for a title. The new objective is selected, so every tab shows a **＋ Link** bar to link it.
- **Click an objective** to select it: its lines get thicker, the others fade, and every tab gets a bar at its foot: **＋ Link**, or **× Unlink** where it is already linked. Click it again, or empty space, to clear the selection.
- **Right-click a tab** (its header or any pane row) for a **Link to** menu of every open objective, with a check on the linked ones. Choosing one links or unlinks it; nothing needs to be selected.
- The tab and pane you opened the graph from are outlined in the accent colour, and that tab's session comes first in the right column with the tab at its top, so you can see where you came from.
- **The box** marks an objective done; done objectives move to the **Done** group at the bottom and draw no lines. **P0–P3** cycles the priority (red, orange, blue, grey). **⋯** renames, sets a one-line side note, a due date or tags, or deletes it.
- **Click a tab header** to jump to that tab, or **a pane row's → button** to jump to that pane, in whatever session it lives. Each pane row starts with its type: an agent's name and state (`omp · working`), `shell`, `note`, `file`, `browser`, or the pane's kind. Rows start folded: **click a row's name** to open its details and click it again to fold them; the rows you open are remembered. The details show what the pane is doing: for an omp agent, `you:` with your last message and `omp:` with its last reply, each cut in the middle when it is too long so its beginning and its end both show; a terminal's last or running command; or a file's path.
- **All / This session** and the **#tag** chips filter the graph; the choice is remembered.
- Tabs with no link have a grey fill and a dashed border. A linked tab that closes stays as a ghost under **Closed tabs**, links kept, until **Prune closed tabs**; tabs held by another Tern window show under **Other windows**.

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

## License

MIT © 2026 nyclanker
