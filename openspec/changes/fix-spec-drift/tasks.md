# Tasks

Checks run in the headless harness at `/tmp/tobj` unless marked **(live)**.
- **Harness setup:** start the serve as a named service (`/tmp/tobj/bin/serve`, ready on "serving"), then `ctl plugins fixtures`. After each edit, run `/tmp/tobj/bin/sync` and `ctl plugins fixtures` again, then reopen the graph if it closed (`ctl tree '.ob-root'` tells). Right after a reload, force a fresh render with a click on "All" before reading the graph. Plugin timers fire only with window activity (`/tmp/tobj/bin/pump`). `pump` opens tabs behind the graph and can dock it into a split, so reopen it as a glimpse before measuring. Never source `/tmp/tobj/bin/env.sh` in a persistent shell.
- **Reading:** `ctl tree SEL` for texts, classes and rects; `/tmp/tobj/bin/order2` for the right column's order; `/tmp/tobj/bin/kv` for the store; `ctl shot NAME` for a PNG and layout JSON.
- **Data:** demo names follow the specs: sessions web, api and docs; tabs App build, Components, Server, Benchmarks and Guides.
- **After the checks:** stop the harness service, and delete `~/.omp/agent/sessions/--private-tmp-tobj-*` if a chat was started.

## 1. Code fixes

- [ ] 1.1 Stale tag filter (D1) in `build`.

  Verify:
  - "Tag filter": "Filter by tag".
  - "Filtered tag removed": with "#api" active, untick "api" on its last holder. The chip is gone, every objective is listed (`ctl tree '.ob-obj'` count), and the kv dump's `view.tag` is absent.
  - Also from another path: delete the last holder while the filter is active.
  - "Empty state": "Nothing matches" under "This session" with no objective linked in the session.
- [ ] 1.2 "you: …" only for omp agents (D2).

  Verify "Agent last user message":
  - "omp exchange": an omp chat in a harness tab answering "Explain caching"; its open row shows "you: Explain caching".
  - "Another agent": a non-omp agent row shows its reply line and no "you:" line on the first render after the graph opens. If no other agent can run in the harness, use a helper op that renders a copy of `lib/details.luau` with a non-omp agent entry, and say so in the result.
- [ ] 1.3 One open-objective sort (D3).

  Verify: two open objectives with equal priority, due date and `created` (set in `kv.json`). "Link this tab…" lists them in the same order as the graph (`ctl state` picker rows against `ctl tree '.ob-obj'`), both ways round after swapping their ids.

## 2. Specs match the code

- [ ] 2.1 Run each new or changed scenario of the deltas, unless 1.x already covered it.
  - objectives-graph: "Closed tab's line"; "Linking removes the fade" still holds on live tabs; "Filtered out"; "The graph's own tab"; "Every shown tab linked"; "Two sessions' closed tabs"; "Closed tab linked to an open objective" (shot).
  - tab-links: "Parked focus" (a session whose only pane is parked); "Menu heading"; "Resume moves a done objective's link".
  - objective-store: "Made for a tab".
  - objective-review: "Picker from review mode".
  - agent-resume: "Found by name in another case".
  - plugin-package: "Rename hidden without a selection" (`ctl palette objectives`).

  Verify: each scenario's THEN holds, with the reading named in it. Record every result. If one fails, stop and decide with the user whether the spec or the code changes.
- [ ] 2.2 Purposes and config (D4): edit the objectives-graph and objective-store Purposes in the main specs, and the specs rule in `openspec/config.yaml`.

  Verify: `openspec validate --specs --strict` passes, and `openspec instructions specs --change fix-spec-drift --json` shows the new rule.
- [ ] 2.3 README (D4): the box bullet's Resume exception, the tabs bullet's ghost look, and the Prune known limit.

  Verify by reading each passage against the matching requirement: "Done objectives' links are fixed", "Ghost tabs look different" with "Unlinked tabs look different", and "Pruning closed tabs".

## 3. Release 0.14.1

- [ ] 3.1 Version `0.14.1` in `plugin.toml`. Verify an isolated `tern plugin install` of the repo folder prints `installed objectives 0.14.1`. Tick this box, then commit, push `main` and tag `v0.14.1` (annotated, message "objectives 0.14.1").
- [ ] 3.2 **(live)** After the push has finished, run `tern plugin install github.com/JakobMusik/tern-objectives --force` from a shell with no harness variables.

  Verify `tern plugin list` shows `objectives 0.14.1 … ready`, with `tabnav 0.1.0` and `omp-narration 0.1.0` untouched.
- [ ] 3.3 **(live)** With the user:
  - a tag filter whose tag is removed from its last objective clears itself;
  - the "Link this tab" picker and the graph list objectives in the same order.

  Record the result here.

## Workflow follow-up

- Archive the change (`openspec archive fix-spec-drift --yes`), run `openspec validate --specs --strict`, commit and push.
