# Objectives for Tern

A [Tern](https://tern.stencil.so) plugin that keeps one global list of objectives and links each one to the tabs where its work happens. It opens as a clickable graph: objectives on the left, tabs on the right, and a line for every link. Clicking a tab or a pane jumps straight to it, in any session.

## Install

```sh
tern plugin install github.com/JakobMusik/tern-objectives
```

The plugin is window-half only (`window.luau`, no host half) and needs nothing on `PATH` besides the `git` that `tern plugin install` uses to fetch it.

## Data

Everything the plugin stores lives in one file in Tern's plugin data folder:

```
<Tern config>/plugin-data/objectives/kv.json
```

On macOS that is `~/Library/Application Support/Tern/plugin-data/objectives/kv.json`. The plugin writes nothing into your project folders, your home folder or its own package folder.

## Remove

```sh
tern plugin remove objectives
```

Removing the plugin leaves `plugin-data/objectives/kv.json` in place; delete that folder by hand to drop your objectives too.

## License

MIT © 2026 nyclanker
