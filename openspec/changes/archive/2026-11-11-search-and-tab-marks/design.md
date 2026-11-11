# Design

## Context

See proposal.md, "Why".

- **Filters today:** `View.build` (`lib/view.luau`) runs every objective through `visible(o)` (lines 537–550): the tag filter first, then the scope filter, which keeps the selected objective. The open list, the Done group and review mode's list all come from what `visible` keeps:
  - `due_list` is built from `done_list`;
  - `Built.due` counts it, and a count of 0 ends review mode (`lib/app.luau`, `build`).

  Lines are drawn for `open_list` only. The tab menu and the "Link this tab…" picker list every open objective, "whatever the filters".
- **The header** (lines 977–995): the [All | This session] segment, the tag chips, a spacer, then the notices and buttons. It wraps (`.ob-head`, `flex-wrap: wrap`).
- **Typed text:** every text the graph takes comes through `cx:prompt`, at window level. `finish(cx2, true)` shows the graph again if the field closed it (`lib/app.luau` lines 238–250).
- **UI state lives in the VM** (`lib/app.luau` lines 17–85), one per window:
  - a fresh `M.open` resets `selected`, `moving`, `held`, `confirm` and `page`;
  - `M.open(cx, true)`, the reopen after a field, keeps them;
  - `M.new_key` (lines 275–285) is how a key acts on the graph: open it fresh when it isn't shown here, switch the settings page back, then ask.
- **Commands and keys:**
  - `Keys.COMMANDS` (`lib/keys.luau` lines 11–18) drives both the default chords that `window.luau` registers and the settings page's rows, in that order;
  - `Keys.in_effect` drops a default that a user keybind claims.
- **Attention today** (lines 613–651):
  - `Details.attention(row)` gives an omp row's call: `wait`, `replied` or `working`;
  - `call_of(tab)` keeps the strongest call per live tab, ranked by `RANK`;
  - `mark_of(o)` keeps the strongest over an objective's tabs, with the labels of the tabs that make it.

  Tab nodes take none of it. Their second header line is one `span.ob-line.ob-dim`, "<session> · tab <n>", inside the 38 px `.ob-thead`: 2 px of padding, then two 18 px lines (`lib/layout.luau`, `tab_head_h`).

### Source record

| Claim | Evidence |
|---|---|
| A canvas view can't hold an input node | `tern.d.luau:1443`, `CanvasSpec.view`: "input, editor and image kinds are not allowed" |
| `cx:prompt` takes `value` (selected), `placeholder`, `icon` and `action`, and resolves nil when dismissed | `tern.d.luau:1894–1896`, `1933–1943` |
| A command's default chords are `CommandDef.keys` | `tern.d.luau:1185–1200` |
| `search` and `x` are Tern icon names | SDK "Icon names", fetched 2026-11-11 from `https://docs.stencil.so/tern/print.html` (text extraction `/tmp/ternsdk/book.txt`, line 13675 for `search`) |
| Tern binds ⌥F (`canvas.fill_solid`) and ⌥⇧F (`canvas.fill_pattern`), and a plugin's default on a key Tern binds is left out | Spike in task 1.3: `op keys_all` read `alt+f → canvas.fill_solid`; a throwaway command with `keys = { "alt+f" }` logged `plugin bind left out: the preset binds these keys keys="alt+f"`, and `ctl key Alt+f` didn't run it. The SDK's keymap tables, searched for "alt+f", had missed this |
| ⌃⌥F is free in Tern's keymap | Same spike: `op keys` read nothing on `ctrl+alt+f` |
| A plugin key runs in every pane, with either Option key | custom-order-and-direct-controls D5 (⌥N); rename-key-shift-option-r (⌥⇧R) |

## Goals / Non-Goals

**Goals:**
- The search is one more filter in `visible`, so the column, the Done group, review mode, the Review count and the lines all follow it with no extra code.
- The tab marks and the objective marks share one computation per tab, so the two can't disagree.

**Non-Goals:**
- Sharing a search between windows, or storing it.
- Any change to node heights: the tab chip sits on an existing line.

## Decisions

### D1. Where the search lives
`local search: string?` in `lib/app.luau`, beside `selected`. It is never stored.
- **End:** a fresh `M.open` clears it with the selection (the user's choice).
- **Kept:** `M.open(cx, true)` keeps it, so a search survives its own field and every other field or picker.
- **Passed on:** `View.build` gets it as `ui_state.search`.

Each window's VM has its own, and a plugin reload forgets it.

*Alternative:* storing it in `state.view` like the tag filter. Rejected: the user asked for it to end when the graph is opened again, and a stored search would also reach other windows.

### D2. Matching
- **`Store.search_words(text)`:** lowercases the text and splits it on whitespace. It returns nil when no word is left.
- **`Store.matches(o, words)`:**
  - The text searched is lowercased: the title, then the side note, then `#<tag>` for each tag, joined by line breaks.
  - Every word must occur in it, found with `string.find(…, 1, true)`, a plain search, so `.`, `%` and `(` are just characters.
  - The `#` lets "#api" find the tag alone, while "api" finds the tag and any title or note holding it.

*Alternatives:*
- Any word instead of every word: rejected, since a longer query would then find more, not fewer.
- Lua patterns: rejected, since typed text would need escaping.

### D3. Filtering and the selection
`visible(o)` gains one check after the tag filter: with words, an objective that doesn't match is hidden unless it is the selected one. The scope filter makes the same exception.
- **The field's answer** (`ask_search`):
  - nil (dismissed) changes nothing;
  - text that trims to empty clears the search;
  - any other text sets it, trimmed with `Text.one_line`, and clears `selected`.

  It then calls `finish(cx2, true)`.
- **Why the selection clears:** so the exception never shows an objective selected before the search. It only keeps one selected during the search, such as a new objective, which `new_objective` selects, or one being renamed.

### D4. Header: button or chip
After the scope segment, and before the tag chips, since it filters as they do:
- **No search:** `span.ob-btn.ob-btn-quiet.ob-searchbtn`, with the `search` icon and the title "Search titles, notes and tags". Its click is `search=`.
- **A search:** `div.ob-searchchip`, an accent-filled pill like an active tag chip, holding two parts:
  - `span.ob-sq`: the icon and the text, cut with "…" past 220 px, and its tooltip holds the whole text. Its click is `search=`, which opens the field again.
  - `span.ob-sx`: the `x` icon, titled "End the search". Its click is `unsearch=`.

Both verbs go through `M.action`, so like any click they end a question, a move, a hold and the Undo notice. `search=` opens the field and draws later (`later = true`). `unsearch=` clears `search` and draws.

### D5. The key
- **`lib/keys.luau`:** `Keys.COMMANDS` gains `{ id = "search", label = "Search", default = "ctrl+alt+f" }` after "new", so the settings page lists Search after New objective. The user chose ⌃⌥F once the spike showed ⌥F can't be a plugin default (source record).
- **`window.luau`:** registers "Objectives: Search…" with `icon = "search"`, `keys = Keys.default_keys("search")` and `run = App.search_key`.
- **`App.search_key`:** follows `M.new_key`, without ending review mode, since the search applies there:
  - with no graph shown over the current tab, `M.open(cx)` opens it fresh, which also ends an old search;
  - with the settings page shown, it switches back to the graph and draws;
  - then it opens the field.

### D6. One mark per tab
`tab_mark(tab)` replaces `call_of`, and its results are kept per build:
- **For a tab of this window:** the strongest call over its rows, and the titles of the rows that make it, each title once. `wait` still wins over everything.
- **Otherwise:** nil, since closed and other-window tabs have no live rows.

`Mark` becomes `{ kind, names }`. `mark_of(o)` takes each tab's `kind` and names the tab by its label, as today. The tab node names the panes, by their titles.

### D7. The tab node's chip and ring
`tab_node` takes the tab's mark.
- **Second line:** the line becomes `div.ob-tl2`, an 18 px flex row holding the chip first, then the "<session> · tab <n>" span, which still ends in "…". The chip reuses `.ob-chip.ob-attchip.ob-attchip-<kind>`, with the text from `MARK_CHIP`. Its tooltip is `MARK_TIP` with the pane titles: "omp is waiting in “server-chat”". It has no click of its own, so a click there jumps to the tab like the rest of the header. The ghost fade's `.ob-thead > :not(.ob-th1)` rule matches the new row as it did the span.
- **Ring:** `wait` and `replied` add `ob-tatt-wait` or `ob-tatt-replied` to the node. They colour the border and add a 1 px inset ring of the same colour, as `ob-att-*` does on objective nodes. `working` adds no ring.
- **With other states:**
  - On an unlinked tab, the border keeps its dashes in the mark's colour.
  - On the origin tab, the accent ring stays outside: the border and a 1.5 px inset in the accent, then a 3 px inset in the mark's colour. This is the objective nodes' rule, a selection ring outside and the mark inside.
- **No new heights:** the chip is 16 px tall on an 18 px line, so `tab_head_h` and the edge ends don't move.

### D8. README and screenshot
- **README:**
  - a "Search" row in the commands table;
  - ⌃⌥F in the keys note, as for ⌥⇧R and ⌥N;
  - a paragraph on searching, after the paragraph on selecting;
  - "See what needs you" names tab nodes.
- **`docs/graph.png`:** taken again, as highlight-origin-tab-links task 3.1 took it: the same window size (`ctl resize 1045 928`) and crop (914 × 808), opened from Guides with the Done group open.
  - The harness, its demo layout and its `kv.readme-0220.json` were under `/tmp` and are gone. The store is rebuilt from the current image, which shows every title, priority, date chip, tag and visible note. The date chips are set by due dates relative to the day of the shot.
  - The omp chats are made as before (add-objectives-plugin D14, "Agent rows"): Server's chat asks a question and waits; Release notes' chat replies while another pane has focus.
  - The draft is shown to the user before it is committed.

## Risks / Trade-offs

- **[⌃⌥F in every pane]** ⌃⌥F no longer reaches any pane in Tern. → It was the user's choice; the README says so, and Configure can move or remove the key.
- **[Another plugin's ⌃⌥F]** A plugin could claim ⌃⌥F too. Read on 2026-11-11: the user's other plugins (external-editor, omp-narration, open-below, reply-selection, tabnav) register no default keys, and the user's `settings.json` holds no `ctrl+alt+f` entry. → The live check (task 4.3) still presses ⌃⌥F in a shell.
- **[Case folding]** Luau's `string.lower` folds only the letters A to Z, so "é" doesn't find "É". Checked in task 1.2: "Écrire la doc" was found by "Écrire" and "ÉCRIRE", not by "écrire". → The README says the search ignores the case of A to Z only; the proposal leaves other letters out of scope.
- **[Search hides the Done group's matches]** With the group folded, matches there show only in its count. → As under the tag filter; the proposal keeps the fold the user's.
- **[A search ending review mode]** A search with no due match empties review mode's list, and "Leaving review mode" ends review mode then. → This is the tag filter's behaviour today; ending the search shows the normal list.
- **[Rebuilt screenshot data]** The demo's chats are generated anew, so their titles and replies read differently. → As in highlight-origin-tab-links 3.1; the user approves the draft.

## Migration Plan

Nothing is stored, so there is nothing to migrate. Keybinds that a user wrote for other commands are untouched. A user keybind already on `ctrl+alt+f` claims the chord, so Search gets no key there (`Keys.in_effect`), and the settings row shows "none" with Reset.
