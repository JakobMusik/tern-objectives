# Design

## Context

See proposal.md for the request and what was settled with the user. The current code:

- **Order:** `View.sort_open` (`lib/view.luau:65–83`) sorts by priority, due date, created and id. It is used:
  - by the left column (line 397);
  - by the tab menu (line 553);
  - by "Link this tab", through `sorted_open` (`lib/app.luau:237–246`).

  A held order (`held`, `lib/app.luau:18–20`, 784–789 and 845–857; `lib/view.luau:398–413`) keeps the column still through badge clicks. `state.objectives` is an array. `Store.create` appends to it (`lib/store.luau:258–282`). `Store.restore` puts a record back at `saved.index` (lines 490–515), which is how Undo keeps an objective's place.
- **⋯ menu:**
  - `menu()` (`lib/app.luau:510–564`) is a `cx:pick` of Rename, Side note, Due date, Tags, Close linked tabs and Delete.
  - Delete (lines 388–402) and Close linked tabs (`confirm_close`, lines 473–508) each open a second `cx:pick` to confirm, and so does Prune (lines 570–590).
  - The fields and value pickers (`side_note`, `due_date`, `tags`, `rename`) end in `finish()`, which shows the graph again (lines 194–203).
- **Closing tabs:**
  - `closable` (`lib/app.luau:412–433`) counts a done objective's live tabs that no open objective links.
  - `close_tabs` (lines 437–469) saves the omp chats first (`Agents.save_now`), counts again, closes the graph when it sits in one of the tabs, then closes every pane.
- **Links of done objectives:**
  - `Store.toggle_link` refuses a done objective (`lib/store.luau:525–528`), and `link_of` draws no bar while a done objective is selected (`lib/view.luau:540–545`). Both are the archived linked-section D3 rule.
  - "Link this tab…" has a toast for a pick that turned out done (`lib/app.luau:280–282`).
- **Prune:**
  - the header button (`lib/view.luau:840–846`) is drawn from `Built.prunable` (line 341, gathered at lines 635–647);
  - `prune()` (`lib/app.luau:570–590`) asks with a picker, then calls `Store.prune` (`lib/store.luau:581–617`).
- **Remove:**
  - `Store.remove` (lines 454–486) removes at once and returns what Undo needs, but refuses an open objective (lines 459–461).
  - `Store.delete` (lines 435–449) has no Undo.
- **Nodes:**
  - `objective_node` (`lib/view.luau:126–215`) draws line 1 (done box, badge, title lines, trash on done nodes, ⋯ at line 196) and line 2, plus review mode's rating row `ob-l3` (lines 201–213).
  - `Layout.px` (`lib/layout.luau:8–29`) fixes every height. `obj_height` adds `review_h` (30 px: an 8 px gap and 22 px buttons) and 18 px for each extra title line, and the same constants give the edges their ends.
- **Commands:** `window.luau` registers open (⌃⌘O), rename (⌥R), link_tab and new_for_tab. The ⌥R key shows how a plugin key behaves (archived rename-and-linked-tabs-first, D6): it runs in every pane whatever `available` says, and the user's keybinds override it.

### Source record

The SDK's line numbers below refer to a text extraction of the SDK book: `https://docs.stencil.so/tern/print.html`, fetched 2026-11-09 and saved as `/tmp/ternsdk/book.txt`.

| Claim | Evidence |
|---|---|
| A canvas delivers only `action` events (clicks with an action name) to its owner, and takes no keys, inputs or editors | SDK "Canvas cx" (L36685–36692); `tern.d.luau` L1443, L1496–1516 |
| Any node's pointer actions are `click`, `dblclick` and `menu`, with no drag | SDK "Props every node takes" (L7957) |
| Tern's only reorderable list, the `prefs` page's ordered `multi` row, reports a reorder as a `change` event, which a canvas never delivers | SDK `prefs` (L19495, L19524); "Canvas cx" (L36689) |
| Chords are `+`-joined `ctrl`, `alt`/`opt`, `shift`, `cmd`/`super` and one key, or a physical key such as `ctrl+key_a`. There is no left or right Option | SDK "Chords" (L40537–40539) |
| ⌥↑ and ⌥↓ are Tern defaults (`editor.move_lines_*`, `markdown.move_block_*`), and a plugin bind on keys the defaults bind is left out | SDK built-in actions (L39566, L39670); "Keymap layering" (L4909) |
| `alt+n` is not in Tern's default action table, nor in the user's `keybinds` | SDK built-in actions (no ⌥N); live `settings.json`, read only, 2026-11-09 |
| The user layer replaces every binding of its keys, Tern's and plugins' alike, and `[]` removes a plugin's chord without replacing it | SDK "Keymap layering" (L4917–4919) |
| `cx.settings` reads and writes keybinds. `set("keybinds", t)` replaces the whole override map. A headless session applies changes but doesn't save them | `tern.d.luau` L940–963; SDK "Settings cx" (L37168, L37171) |
| `cx.actions:keys()` gives the effective chord → action ids. It spells each chord as its source does: Tern's defaults as `shift+cmd+r`, a keybinds entry exactly as written (`ctrl+alt+l` stays `ctrl+alt+l`, and `alt+ctrl+l` finds nothing). An entry of `[]` shows as an empty list | `tern.d.luau` L879–880; spike, task 1.1 |
| `cx.settings:set("keybinds", t)` with `[]` made by `tern.json.array({})` is read back as written and takes effect at once. A chord that doesn't parse raises (`` `alt+`: names no key ``) and changes nothing. `cmd+t` set there takes ⌘T from `new_tab` | spike, task 1.1 |
| Any keybinds write, `set` or `bind`, rebuilds the window's keymap without every plugin's binds, ours and other plugins' alike, until a plugin reload. A run-time `tern.command` call, even one registering an existing command again, or a run-time `tern.bind`, brings every plugin's binds back | spike, task 1.1 |
| In the harness, `key Alt+n` runs a command bound to `alt+n`, and to `alt+key_n` too, with a canvas or a shell focused, and the shell gets no character. The harness doesn't model a real keyboard's dead-key composition | spike, task 1.1 |
| Drop zones absolutely positioned over a node's halves take the click, over the node's own inner controls too, and their `:hover` bar draws | spike, task 1.1 (shot `ds_hover_bot`) |
| `:hover`, `position: absolute` and `cursor: grab` work in plugin CSS | SDK "Supported CSS" (L22460); `:hover` on the jump button since 0.6 (refine-graph-rows, R7); the edge layers are absolutely positioned (add-objectives-plugin, D4) |
| The harness can rest the pointer with `move X Y` or `hover <selector>`, press `key <combo>`, and click with real hit-testing | SDK harness commands (L29654–29668, L29692); `openspec/config.yaml` |

## Goals / Non-Goals

**Goals:**
- One stored order, shared by windows, that only the user changes.
- Every command the ⋯ picker offered becomes one click on the selected node. No confirmation picker is left.
- Shortcuts are changed through Tern's own keybinds, so Tern's Keyboard page and Configure always agree.
- Links change only through the user's clicks on link bars, or Resume's handover, for open and done objectives alike.

**Non-Goals:**
- Changing the Done group's order, review mode's order, or how review or Resume work.
- A plugin-side keymap: the plugin keeps declaring its default chords, and only the user layer changes.

## Decisions

### D1. The order is the array's order
- **Order:** the custom order is the order of the open objectives in `state.objectives`. Done records keep their slots, but nothing reads their position except Undo, through `saved.index`. Marking done doesn't move a record, so Undo puts it back in place.
- **Migration:** the state gains `ordered: boolean?`. While it isn't true, `normalize` reorders the open records with today's comparator, which moves from `View.sort_open` into the store as the legacy order. It fills only the open records' slots, then sets `ordered = true`. Every read before the first write derives the same order, so two windows can't disagree, and the first write stores it (a render's snapshot refresh writes soon after an open).
- **Readers:** `View.build`, the tab menu and "Link this tab" take the open records in array order. `View.sort_open` goes.
- **The held order goes:** `held`, `resort` and the hold branch in `View.build` are removed, since badge clicks can't move a node any more. The `later` flag stays for the verbs that draw later.
- **`Store.move(id, target, where)`:** inside `mutate`, it fails when either record is missing or done, or when `id == target`. Otherwise it removes `id` and inserts it before or after `target`'s new index. Hidden objectives keep their places relative to the rest.
- **`Store.create`:** takes the priority and place from the settings (D8): "top" inserts at index 1, "bottom" appends.

Alternatives:
- A `rank` number on each record. Rejected: it would need renumbering or gaps, and the array already is an order that Undo respects.
- A separate list of ids. Rejected: it can drift from the records when another window adds or removes one.

### D2. Pick and drop
- **State:** `moving: string?`, a module local of `lib/app.luau` beside `selected`. It is never stored, and a fresh open clears it.
- **Grip:** `span.ob-grip` holding Tern's `grip` icon comes first on line 1 of open nodes outside review mode, with `click = "lift=<id>"`. Its hit area is 22 × 18 px, like the done box, with `cursor: grab` and `user-select: none`. Line 1 loses ⋯'s 22 px and gains the grip's, so a title's room is unchanged.
- **Lifted look:**
  - The node gets `ob-lifted`: an inset accent bar on its left and an accent border.
  - The header shows `Moving “<title>”` and Cancel (`unlift=`) where the Undo notice goes. The click that lifted dropped any Undo notice, as every other click does.
- **Drop zones:** while `moving` is set, every other shown open node gets two children, `div.ob-drop.ob-drop-top` and `div.ob-drop.ob-drop-bot`.
  - Each is absolutely positioned over one half of the node, above its content, with `click = "drop=<target>:before"` or `":after"`.
  - `:hover` draws a 3 px accent bar along that edge.
  - They change no height, so `Layout` and the edges don't change.
- **Clicks (`M.action`):**
  - `lift` sets `moving`, or clears it for the same id.
  - `drop` runs `Store.move(moving, target, where)`, shows the "no longer exists" toast when it fails, and clears `moving`.
  - Any other act clears `moving` first, beside `drop_undo`. `bg` returns early only when it has nothing to clear.

Alternatives:
- Tern's `mark = "pick"` prop (SDK L7955). Rejected: it draws the lifted bar, but the insertion lines still need the zones' `:hover`, so one CSS class does both.
- Drop slots between nodes. Rejected: they change heights while moving, so lines and targets would shift under the pointer.
- ▲/▼ buttons and keys were set aside with the user, and ⌥↑/⌥↓ are taken by Tern.

### D3. The action bar
- **Placement:** the selected node gets `div.ob-acts` as its last line. In review mode it comes after `ob-l3`.
  - **Open objective:** Note (`note=<id>`), Due (`due=<id>`), Tags (`tags=<id>`) and Delete (`del=<id>`).
  - **Done objective:** Note and Tags, plus "Close n tabs" (`close=<id>`) when n > 0.
- **The count:** n comes from `closable(state, win, o)`, which moves from `lib/app.luau:412–433` into `lib/view.luau` as a pure helper. The view and app share it.
- **Buttons:** `span.ob-act` (flex `1 1 0`, `min-width: 0`, 22 px tall) each hold an icon and a label. The label is cut with "…" when the column is narrow. The icons, all from the 208 Tern ships (SDK "Icon names", L11324), are `note`, `clock`, `tag`, `trash` and `x-circle`.
- **Layout:** `px.acts_h = 30`. `obj_height(review, lines, acts)` and `Layout.add_obj(...)` add it, and `Layout.css` generates the `.ob-obj.ob-acts-on` heights for one to three title lines, with and without `.ob-review`. Edges are drawn from the same numbers, so they follow.
- **Clicks:**
  - `note`, `due` and `tags` call the existing `side_note`, `due_date` and `tags` flows, with `later = true`.
  - `del` calls `Store.remove`, which now accepts open records too, then `offer_undo("Removed “<title>”")`, and clears the selection.
  - `close` starts D4's question.
- **Removed:** `menu()`, the ⋯ span, its CSS and `Store.delete`. Rename stays a title click or ⌥R.

Alternative: icons on every node, always or on hover. The user picked the bar. The bar also keeps nodes 48 px tall when not selected.

### D4. Questions asked in place
- **State:** `confirm: { kind: "close", id: string, where: "bar" | "notice" } | { kind: "done_tabs" } | nil`, a module local of `lib/app.luau`.
- **Drawing:**
  - **Bar:** "Close n tabs?", then "· k stay open" when an open objective keeps k linked tabs (the full sentence in the tooltip), then Close (`cfm=`) and Cancel (`cfx=`).
  - **Notice:** `Close n tabs of “X”? · Close · Cancel`, in place of `Marked done … · Undo · Close n tabs`.
  - **Header:** "Close n done tabs" (D11) becomes `Close n done tabs? · Close · Cancel`.
- **Clicks:**
  - `close` (bar) and `closetabs` (notice) set `confirm`. `closetabs` keeps the Undo notice, as it does today.
  - `closedone` sets `confirm` too.
  - `cfm` runs `close_tabs` (which counts again, as close-linked-tabs D5 does) or D11's close. The notice's Close also drops the notice.
  - `cfx` clears `confirm`. Any other act clears it first.
- **Removed:** the confirmation picker in `confirm_close`, and Prune as a whole: `prune()`, `Store.prune`, `Built.prunable`, the header button and its CSS. Links now change only through link bars and Resume.
- **Timer:** the Undo notice keeps its 10 s timer. A notice that expires mid-question takes the question with it, and the close stays one click away in the selected objective's bar.

Alternative: closing without asking, with no undo. Rejected: closing ends programs, and only omp chats come back with Resume.

### D5. ⌥N
- **Command:** `window.luau` registers `{ id = "new", title = "Objectives: New objective", icon = "plus", group = "Objectives", keys = { "alt+n" }, run = App.new_key }`.
- **`App.new_key(cx)`:** it sets the page to "graph" (D6). When `Surface.here(cx)` is nil it calls `M.open(cx)`, a fresh open with a new origin. Then it calls `new_objective(cx, nil, nil, "", true)`, so `finish` brings the graph back with the new objective selected.
- **Spelling:** `alt+n`, the form ⌥R uses. Either Option key sends it (source record). Tern decides on the chord before text input, as ⌥R showed: Option+R typed no "®". Option+N, though, is a dead key on US layouts, and that is untested (risk). The fallback is `alt+key_n`, the physical key.

### D6. Settings page in the graph
- **State:** `page: "graph" | "settings"`, a module local of `lib/app.luau`. A fresh open sets "graph", and `finish` keeps it.
- **Opening it:**
  - `window.luau` registers `{ id = "configure", title = "Objectives: Configure", icon = "gear", group = "Objectives", run = App.configure }`. `App.configure` sets "settings", then renders the graph here, or opens it.
  - The graph's header gets an icon-only button with Tern's `gear` icon (`page=settings`, title "Configure").
- **Building it:** `View.build` hands over to `View.build_settings(state, keys)` while the page is "settings". It draws:
  - a header with "Settings" and "Back to graph" (`page=graph`);
  - a "Shortcuts" section: one row per command, with its name, its keys in effect, and Change (`kchg=<id>`), Remove (`krm=<id>`) and, when not at the default, Reset (`krst=<id>`);
  - a "New objectives" section: "Start at" P0–P3 (`setprio=<n>`) and "Place" Top | Bottom (`setplace=top|bottom`), as segmented buttons like All | This session;
  - a dim line saying shortcuts are saved in Tern's keybinds.

  It has no edges and an empty edge sheet.
- **Rendering:** while the page shows, renders skip the window model and Details, so the 750 ms poll costs nothing extra.
- ⌃⌘O closes the page like the graph.

### D7. Shortcuts through Tern's keybinds (`lib/keys.luau`)
- **Commands:**
  - `open`: default `ctrl+cmd+o`;
  - `rename`: default `alt+r`;
  - `new`: default `alt+n`;
  - `link_tab`, `new_for_tab` and `configure`: no default.

  Each runs the action `plugin.objectives.<id>`. `window.luau` takes each default from this table, so there is one source.
- **Keys in effect:** `cx.actions:keys()`, inverted for each action.
- **Display:** modifiers as ⌃⌥⇧⌘ in Apple's order, then the key, a letter in upper case. Sequences are joined by a space.
- **Parse:**
  - The text is lowercased and trimmed, split on `>` into chords, and each chord on `+`.
  - Every part but the last must be a modifier (`ctrl`, `alt`/`opt`, `shift`, `cmd`/`super`), and the last must be a key.
  - The chord is canonicalized: modifiers in one fixed order. Every chord `cx.actions:keys()` lists is canonicalized the same way before comparing, since it keeps each source's own spelling.
  - It is refused when a chord lacks `ctrl`, `alt` and `cmd`, unless its key is f1–f20.
- **Conflict:** the canonical chord's actions in `cx.actions:keys()`, minus this command's own, must be empty. Otherwise the toast names the first one, by its palette label when `cx.actions:describe` knows it, else its id.
- **Write:** a copy of `cx.settings:keybinds()` is edited, then written with `cx.settings:set("keybinds", kb)` inside `pcall`, empty lists made with `tern.json.array({})`. A raise means Tern refused the chord: the toast says it isn't a shortcut, and nothing changed.
  - **First, every change:** this action leaves every entry. A string entry naming it is deleted. A list entry loses it, and is deleted if that leaves it empty. Other entries, the user's own `[]` included, stay.
  - **Change:** `kb[new] = action`. When the command has a default that differs, `kb[default] = []`.
  - **Remove:** `kb[default] = []` when there is a default.
  - **Reset:** delete `kb[default]` if it is an empty list.
- **Plugin keys come back:** every keybinds write drops all plugins' binds from the keymap (source record). Right after the write, `window.luau`'s registration runs again: it re-registers the plugin's commands, which rebuilds the keymap with every plugin's binds. `Keys.write` takes it as a callback, so `lib/keys.luau` doesn't require `window.luau`.
- **Verify:** `cx.actions:keys()` is read again and must show the intended result. If it doesn't, the previous map goes back, the commands are registered again, and an error toast says the change didn't take.
- **Why the conflict check matters:** the user layer replaces Tern's own bindings (source record), so binding `cmd+t` there would take ⌘T from "New tab". The check is what stops Configure from doing that.

Alternative: keep the shortcuts in `kv.json` and register the commands' `keys` from them at load. Rejected:
- the commands' keys would still sit in the plugin layer, under the user layer, so Tern's own Keyboard page and any user entry would override them;
- Tern's Keyboard page would disagree with Configure;
- every keybinds write still drops the plugin layer (source record), so it would need the same re-registration anyway.

### D8. New-objective defaults
- **Storage:** `state.settings = { start_priority = 0..3, new_place = "top" | "bottom" }`. `normalize` fills 3 and "top" and replaces invalid values.
- **Writing:** `Store.set_settings(fn)` writes through `mutate`, like `set_view`.
- **Using them:** `Store.create` reads them (D1), so "＋ New objective", ⌥N and "New objective for this tab…" all follow them.

### D9. README, screenshots, version
- **README:**
  - the commands table gains New objective (⌥N) and Configure;
  - "Use" covers the grip, the action bar, Configure, link bars on done objectives and "Close n done tabs";
  - the keys note says shortcuts change in Configure, or in Tern's keybinds;
  - the data section says changed shortcuts are saved in Tern's settings.
- **Screenshots:** `docs/graph.png` and `docs/review.png` are retaken from the harness with the same content as now, with grips and no ⋯, and the drafts are shown to the user first.
- **Version:** 0.17.0.

### D10. Link bars for done objectives
- **Store:** `Store.toggle_link` drops its done check. It returns "linked", "unlinked", or nil when the objective is gone. "Link this tab…" loses its "done" toast, so a pick that another window marked done in the meantime simply toggles the link.
- **View:** `link_of` returns a bar for any selected objective, open or done, in review mode too. `Layout.add_tab` already adds `link_h` whenever a bar is drawn, so the tab heights and the edges follow without change.
- **Unchanged:**
  - the tab menu (`menu_objs`) and the "Link this tab…" picker still list open objectives only, as settled;
  - `Store.mark_done`, `restore`, `rate` and `close_tabs` don't touch links;
  - Resume's handover (`Store.adopt`) stays as it is.
- **Unlinking a closed tab** that nothing else links drops its snapshot (`drop_orphans`, line 532). The next render's `save_sessions` drops that tab's saved chats once they are older than its 10 s grace (`lib/store.luau:621–623`). That is the cleanup Prune used to do, now done one link at a time by the user.

Alternative: a separate "Unlink" button in the done objective's action bar. Rejected: the bars already say per tab what a click does, and an open objective's links work the same way.

### D11. "Close n done tabs"
- **Count:** `View.build` gathers `done_tabs`, the live tabs it places in the right column (all its sections, so the All / This session filter applies) that at least one done objective links and no open objective links. It returns them in `Built` beside `closed`.
- **Header:** a quiet button, "Close n done tabs" ("tab" when n = 1), with `click = "closedone="` and a tooltip naming what it closes. It is drawn only while n > 0, and in D4's question form while `confirm.kind == "done_tabs"`.
- **Close:** `close_tabs` is split, so one function closes a list of tabs that a caller-supplied counter gives it:
  1. save the omp chats with `Agents.save_now`; if that fails, say so and close nothing;
  2. count again with the counter, so tabs that changed in the meantime drop out: `closable(state, win, o)` for one objective's "Close n tabs", or a fresh `build`'s `done_tabs` for this button;
  3. close the graph first when it sits in one of them;
  4. close every pane of each;
  5. toast "Closed n tabs";
  6. call `finish`, which brings the graph back.

  No link changes on either path.
- **Not in review mode's way:** the button stays in the header in both modes, since it acts on tabs, not on the listed objectives.

Alternative: count every live tab of the window, whatever the filter. Rejected with the user: it could close tabs the graph isn't showing.

## Risks / Trade-offs

- **[⌥N is a dead key]** On a US layout, Option+N starts a "˜" composition. If Tern composes before matching the chord, ⌥N won't run the command. → Task 1.1 presses `key Alt+n` in the harness. The live check (task 6.3) is the real test. If it fails, a patch switches to `alt+key_n`.
- **[Drop zones must win the click]** Settled by task 1.1: the zones take both halves' clicks, over inner controls too.
- **[Writing keybinds]** Settled for this window by task 1.1: `[]` entries work, an unparsable chord raises, and the plugin layer comes back after a run-time registration. Still untested: whether a write in one window drops the plugin layer in the user's other Tern windows, which run their own VMs and won't re-register. → The live check (task 6.3) changes a shortcut with two windows open and presses a plugin key in the other one. If its keys are gone, a follow-up has each window re-register when it sees the keybinds change, for example on `focus`.
- **[Headless settings aren't saved]** The harness can't show persistence. → Persistence is checked live, by reading the user's `settings.json` after a change made with the user.
- **[Selecting moves the nodes below]** The bar adds 30 px under the selected node, so the nodes below it, and their lines, shift down. → Accepted. Selection already adds link bars to tab nodes, and the bar disappears with the selection.
- **[Narrow graphs]** At 460 px, four buttons share about 150 px. → Labels give way to icons, with each button's tooltip naming it. Task 3.1 takes a 460 px shot.
- **[Delete without asking]** → Undo for 10 s, the same as the done trash icon since 0.10.
- **[Closed tabs pile up without Prune]** A closed tab linked to an open objective stays under "Closed tabs", with its snapshot and saved chats, until it is resumed or unlinked. → Accepted with the user: links change only by the user's own clicks. Each ghost takes one click to unlink, and the data per tab is small.
- **[A done objective's links can now change]** A click on a stale bar, or a pick in "Link this tab…" while another window marks the objective done, changes a done objective's link. → Intended: the same click on an open objective would. Review keeps whatever links the user left.
- **[Closing several tabs at once]** "Close n done tabs" can close tabs in several sessions. → It asks first with the count, saves the omp chats so Resume can bring them back, and counts only the tabs the graph shows.
- **[⌥N in every pane]** Option+N no longer starts "˜" in any pane in Tern. → The README says so, and Configure can move or remove the key.
- **[An expired notice ends its question]** → The bar still offers "Close n tabs" on the done objective.
- **[Rollback]** 0.16.0 ignores `ordered` and `settings`, sorts by priority again, and refuses link changes on done objectives again. Keybinds made in Configure for `plugin.objectives.new` or `.configure` would do nothing under 0.16.0, and Tern says so when they're pressed. → Documented in the release notes. Reset in Configure before rolling back.

## Migration Plan

- **Stored state:** it gains `ordered` and `settings`. The first open after the update stores today's automatic order as the custom order, and the defaults P3 and top.
- **Keybinds:** they change only when the user changes a shortcut in Configure.
- **Release:** 0.17.0. To roll back, install `v0.16.0`.
