# Tasks

Checks run in the headless harness at `/tmp/tobj` unless marked **(live)**.
- **Harness setup:** start the serve as a named service (`/tmp/tobj/bin/serve`, ready on "serving"), then `ctl plugins fixtures`. After each edit, run `/tmp/tobj/bin/sync` and `ctl plugins fixtures` again, then reopen the graph if it closed (`ctl tree '.ob-root'` tells). Never source `/tmp/tobj/bin/env.sh` in a persistent shell.
- **Reading:** `ctl key` to press a chord, `ctl tree` for the graph and the settings page (`.ob-srow`), the helper's `keys` op for the keymap on given chords, and `ctl state` or a shot for an open field or a toast.
- **Keybinds:** the harness's are in `/tmp/tobj/config/settings.json`. Copy it aside before a check that writes it, and put it back afterwards.
- **After the checks:** stop the harness service.

## 1. The rename key

- [ ] 1.1 The default (design D1, D3): `alt+shift+r` in `Keys.COMMANDS` (`lib/keys.luau`); the comments in `window.luau` and `lib/app.luau`; README's commands table and typing note.

  Verify with no keybinds of the plugin's in the harness's `settings.json`:
  - the helper's `keys` op lists `plugin.objectives.rename` on `alt+shift+r` and nothing of the plugin's on `alt+r`, and the serve log has no "plugin bind left out" line for `alt+shift+r`;
  - objectives-graph "Rename key": "Rename by key" and "Nothing selected" with `ctl key alt+shift+r`, "Option+R left to the pane" with `ctl key alt+r`;
  - plugin-package "Palette commands": "Commands listed" shows ⌥⇧R for rename;
  - plugin-settings "Shortcut rows": "Defaults" reads ⌥⇧R; then "Rename moved to ⌥⇧R before this version", with `settings.json` holding the user's two entries (`"alt+shift+r": "plugin.objectives.rename"`, `"alt+r": []`);
  - plugin-settings "Removing and resetting a shortcut": "Remove the rename key", then Reset gives ⌥⇧R back;
  - plugin-package "README": `grep` finds ⌥⇧R in the table and the note, and no ⌥R or Option+R left. Before writing "‰", check that Option+Shift+R types it on the US layout (`UCKeyTranslate` through a throwaway Swift script, or the Keyboard Viewer); if it doesn't, the note names the right character.

## 2. Release 0.21.0

- [ ] 2.1 Version `0.21.0` in `plugin.toml`. Verify that an isolated `tern plugin install` of the repo folder prints `installed objectives 0.21.0`. Tick this box, then commit, push `main` and tag `v0.21.0` (annotated, message "objectives 0.21.0").
- [ ] 2.2 **(live)** After the push has finished, run `tern plugin install github.com/JakobMusik/tern-objectives --force` from a shell with no harness variables.

  Verify `tern plugin list` shows `objectives 0.21.0 … ready`, with the other plugins untouched. Read the live `settings.json` keybinds afterwards: unchanged.
- [ ] 2.3 **(live)** With the user:
  - ⌥⇧R renames the selected objective, with the left and with the right Option key;
  - Configure shows ⌥⇧R for Rename selected objective, with no Reset;
  - Option+R in a shell types as it does without the plugin.

  Record the result here.

## Workflow follow-up

- Archive the change (`openspec archive rename-key-shift-option-r --yes`), run `openspec validate --specs --strict`, commit and push.
