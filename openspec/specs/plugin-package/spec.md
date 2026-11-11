# plugin-package Specification

## Purpose
Defines how the plugin is packaged, published and installed, so that any Tern user can add it with a single `tern plugin install` command and knows what it does and where its data lives.

## Requirements

### Requirement: Manifest
The package root SHALL hold a `plugin.toml` with:
- schema 1;
- id `objectives`;
- name "Objectives";
- a version: `0.1.0` for the first release, then the patch number raised for each fix and the minor number for each release that changes behaviour;
- a description;
- a window entry and its style sheet;
- no host entry and no blocks.

Tern's install-time checks SHALL accept the package.

#### Scenario: Local install check
- **WHEN** `tern plugin install <repo folder>` runs against an isolated Tern config
- **THEN** it reports `installed objectives` with the manifest's version, and `tern plugin list` shows the plugin ready with 0 blocks and no problems

### Requirement: Palette commands
The plugin SHALL register seven palette commands in the group "Objectives", four with default keys:
- "Objectives: Open graph", ⌃⌘O;
- "Objectives: Rename selected objective", ⌥⇧R;
- "Objectives: New objective", ⌥N;
- "Objectives: Search…", ⌃⌥F;
- "Objectives: Link this tab…";
- "Objectives: New objective for this tab…";
- "Objectives: Configure".

The palette SHALL list the rename command only while an objective is selected in a graph shown over the current tab. Its key works either way.

#### Scenario: Commands listed
- **WHEN** an objective is selected in the graph shown over the current tab, and the palette is opened with the query "objectives"
- **THEN** the seven commands appear, "Open graph" with ⌃⌘O, "Rename selected objective" with ⌥⇧R, "New objective" with ⌥N and "Search…" with ⌃⌥F

#### Scenario: Rename hidden without the graph
- **WHEN** no graph is shown over the current tab, and the palette is opened with the query "objectives"
- **THEN** "Open graph", "New objective", "Search…", "Link this tab…", "New objective for this tab…" and "Configure" appear, and "Rename selected objective" doesn't

#### Scenario: Rename hidden without a selection
- **WHEN** the graph is shown over the current tab with nothing selected, and the palette is opened with the query "objectives"
- **THEN** "Rename selected objective" doesn't appear, and the other six commands do

### Requirement: Install from GitHub
The plugin SHALL install with `tern plugin install github.com/JakobMusik/tern-objectives` from the public repository's default branch, with no credentials and nothing extra needed on `PATH` besides git.

#### Scenario: Fresh install from GitHub
- **WHEN** that command runs against an isolated Tern config
- **THEN** the plugin is installed as `objectives` and loads ready

### Requirement: Repository metadata
The repository SHALL be public under `JakobMusik`. It SHALL carry an MIT license (© 2026 nyclanker) and the GitHub topic `tern-plugin`, and its first release SHALL be tagged `v0.1.0`.

#### Scenario: Published metadata
- **WHEN** the repository is viewed on GitHub
- **THEN** it is public, shows the MIT license and the `tern-plugin` topic, and has tag `v0.1.0`

### Requirement: README
The README SHALL give:
- the exact install command;
- that it needs only `git` on `PATH`, and nothing on the machines sessions run on;
- the seven commands with the ⌃⌘O, ⌥⇧R, ⌥N and ⌃⌥F keys;
- how to close the graph: ⌃⌘O, a click outside, its ×, or Esc after clicking its title bar;
- how searching and reviewing done objectives work;
- where its data lives and how to remove it;
- two screenshots: the graph with the Done group open and a marked tab, then review mode with its rating buttons.

#### Scenario: README contents
- **WHEN** a reader opens the README
- **THEN** it contains the install command, the commands with ⌃⌘O, ⌥⇧R, ⌥N and ⌃⌥F, the ways to close the graph, that nothing is installed on other machines, how to search, how to review done objectives, the data location under `plugin-data/objectives/`, a screenshot of the graph with the Done group open and a tab node marked "needs you", and after it a screenshot of review mode with Hard, Good and Easy buttons

#### Scenario: Graph screenshot first
- **WHEN** the README is read on GitHub
- **THEN** its first image is `docs/graph.png`, the graph screenshot

### Requirement: Package folder stays read-only at run time
The plugin SHALL never write into its own package folder, so that using it never triggers a plugin reload.

#### Scenario: Clean package after use
- **WHEN** the plugin has been used to create, link and delete objectives
- **THEN** the installed package folder holds exactly the files that were installed

### Requirement: README on the direct controls
The README SHALL explain how to move objectives with the grip, what the action bar offers, and how Configure changes shortcuts and the new-objective defaults. It SHALL say that changed shortcuts are saved in Tern's keybinds, not in the plugin's data folder. Its screenshots SHALL show this version's nodes.

#### Scenario: Direct controls explained
- **WHEN** a reader opens the README
- **THEN** it explains moving with the grip, the action bar's buttons, Configure, and that changed shortcuts live in Tern's keybinds

#### Scenario: Screenshots match this version
- **WHEN** a reader looks at both screenshots
- **THEN** the graph's open objectives show grips, and no node in either shows a ⋯ button
