# Design

## Context

See proposal.md for the request. The current code (custom-order-and-direct-controls D7):

- **Defaults** live in `Keys.COMMANDS` (`lib/keys.luau:11–18`): rename is `alt+r`. `window.luau` registers each command with `keys = Keys.default_keys(id)`.
- **Keys in effect** (`Keys.in_effect`, `lib/keys.luau:187–214`): the user's keybinds entries that name a plugin command, plus each command's default chord unless a user entry claims that chord. Configure's rows read this, and a row offers Reset unless its keys are exactly the default (`View.build_settings`, `lib/view.luau:1052–1054`).
- **Configure's edits** (`Keys.edited`, `lib/keys.luau:247–288`): Change writes `new: <action>` and, when the default differs, `default: []`. Remove writes `default: []`. Reset drops an `[]` on the default.
- **The user's keybinds** (read-only, 2026-11-09, `~/Library/Application Support/Tern/settings.json`) hold `"alt+shift+r": "plugin.objectives.rename"` and `"alt+r": []`: a Change to `alt+shift+r` made in Configure.
- **Comments** name ⌥R in `window.luau:41–44` and `:56`, and in `lib/app.luau:769`.

### Source record

| Claim | Evidence |
|---|---|
| A user entry on a chord stops the plugin's default chord being added again, so `alt+shift+r: rename` with default `alt+shift+r` reads as one key | `Keys.in_effect`: `claimed[canon]` (`lib/keys.luau:190–208`) |
| A row at its default shows no Reset | `View.build_settings` (`lib/view.luau:1052–1060`) |
| Configure accepted `alt+shift+r` for the user, so no other action ran on it in their keymap then | `change_keys` refuses a shortcut that `Keys.in_use` finds in `cx.actions:keys()` (`lib/app.luau:364–370`), and their keybinds hold it |
| Tern leaves out a plugin's default key that its preset already binds, with a WARN line | `/tmp/tobj/logs/tern-serve.log`: `plugin bind left out: the preset binds these keys keys="r"` (2026-11-06) |
| The harness can read the keymap for given chords | helper op `keys` (`cx.actions:keys()`), used in custom-order-and-direct-controls task 5.2 |

## Goals / Non-Goals

**Goals:**
- One default changes; Configure, the palette and the key handler follow from `Keys.COMMANDS`.

**Non-Goals:**
- Rewriting the user's keybinds on upgrade.
- Changing how Change, Remove and Reset edit the keybinds.

## Decisions

### D1. The default chord
`Keys.COMMANDS` gives rename `default = "alt+shift+r"`: lowercase, modifiers in the order `Keys.canon` writes (⌃⌥⇧⌘), so the default compares equal to the user's existing entry and to what Configure writes. `Keys.display` shows it as ⌥⇧R. Nothing else in the code names the chord: `window.luau` takes it through `Keys.default_keys`, and Reset and the "Back to …" tooltip through `c.default`.

Alternative: spell it `shift+alt+r`, as the user typed it. Rejected: `Keys.canon` would still compare it equal, but every other chord the plugin writes uses Apple's order, and ⌥⇧R is how macOS menus show it.

### D2. No keybinds migration
The plugin doesn't touch `settings.json` at start. For the user's keybinds (Context), the new default is claimed by their own entry, so the result is exactly ⌥⇧R with no Reset, and `alt+r: []` keeps ⌥R free as the new default does. For anyone else:
- **Default keys:** rename moves to ⌥⇧R, and ⌥R reaches the pane again.
- **Changed to another key, or removed, before 0.21.0:** their `[]` sits on `alt+r`, so the new default `alt+shift+r` runs rename too. Configure shows the extra key and offers Reset, and one Change, Remove or Reset there writes a fresh `[]` on the new default.

Rejected: rewriting an `alt+r: []` into `alt+shift+r: []` at start. The plugin can't tell its own `[]` from one the user wrote, and it writes the user's keybinds only when they act in Configure (plugin-settings, "Changing a shortcut").

### D3. README and comments
- **Table:** the rename row's key reads ⌥⇧R.
- **Typing note:** "⌥⇧R and ⌥N work in every pane, with either Option key, so Option+Shift+R no longer types "‰" and Option+N no longer starts "˜" anywhere in Tern." Task 1.1 checks that ⌥⇧R gives "‰" on the US layout before writing it.
- **Comments** in `window.luau` and `lib/app.luau` say ⌥⇧R. The design-history note "⌥R, as the user asked" becomes "⌥⇧R, as the user asked (rename-key-shift-option-r)".

### D4. Release
0.21.0, a minor release: behaviour changes.

## Risks / Trade-offs

- [Tern's preset or another plugin binds ⌥⇧R] → the user's own entry already works on it (Context), and task 1.1 checks the harness keymap and the serve log for a "left out" line. If Tern leaves it out, stop and ask.
- [Someone with an earlier Change or Remove gets ⌥⇧R as well] → D2: visible in Configure, fixed in one click. The proposal lists it as out of scope.
- ["With either Option key" for ⌥⇧R] → the harness sends key names, not physical keys. Tern reads modifiers the same way for ⌥R, but task 2.3 asks the user to try the right Option key as well.

## Migration Plan

None: nothing is stored, and keybinds stay as the user left them. To roll back, reinstall 0.20.0.
