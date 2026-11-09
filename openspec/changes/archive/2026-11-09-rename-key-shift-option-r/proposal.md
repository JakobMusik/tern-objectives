# Proposal

## Why

Asked by the user on 2026-11-09: the default key of "Objectives: Rename selected objective" should be Shift+Option+R instead of Option+R. Like every plugin key, ⌥R runs in every pane, so Option+R can't type "®" anywhere in Tern. The user has already moved rename to `alt+shift+r` in Configure, and their keybinds hold `alt+r: []` from that change.

## What Changes

1. **The rename command's default key becomes ⌥⇧R** (`alt+shift+r`, the spelling Configure writes, shown ⌥⇧R in Apple's modifier order). **BREAKING** for anyone using ⌥R to rename with the default keys.
2. **⌥R is no longer the plugin's.** With default keys, Option+R reaches the pane again. Option+Shift+R stops reaching the pane instead, in every pane.
3. **Keybinds already set stay as they are.** The plugin doesn't edit `settings.json` on upgrade:
   - the user's `alt+shift+r` entry for rename now matches the default, so Configure shows ⌥⇧R with no Reset;
   - their `alt+r: []`, left by that earlier change, stays in their keybinds. Nothing runs on ⌥R either way.
4. **README:** the commands table, and the note on which keys the plugin takes from typing.
5. **Release 0.21.0**, a minor release because behaviour changes.

Out of scope:
- The other defaults (⌃⌘O, ⌥N) and how Configure changes keys.
- Cleaning up keybinds left by earlier versions. Someone who changed rename to a key other than ⌥⇧R, or removed it, before 0.21.0 gets ⌥⇧R as well. Their earlier change put `[]` on ⌥R, the old default, not on ⌥⇧R. Configure then shows both keys and offers Reset, and its Change, Remove or Reset sets them as wanted (design, Risks).
- Retaking the screenshots: they don't show the rename key.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `objectives-graph`: "Rename key" (default ⌥⇧R; ⌥R is left to the pane) and "Rename by clicking the title" (names ⌥⇧R).
- `plugin-package`: "Palette commands" and "README" name ⌥⇧R.
- `plugin-settings`: "Shortcut rows" (the default row reads ⌥⇧R; an earlier change to `alt+shift+r` reads as the default), and "Removing and resetting a shortcut" (its rename scenario presses ⌥⇧R).

## Impact

- `lib/keys.luau`: the rename command's default chord.
- `window.luau`, `lib/app.luau`: comments naming ⌥R.
- `README.md`: the commands table and the typing note.
- `openspec/specs/*`: the deltas above.
- `plugin.toml`: version 0.21.0.
- The user's Tern `settings.json`: not written. Stored data: none.
