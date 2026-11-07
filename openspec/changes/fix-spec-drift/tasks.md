# Tasks

Checks run in the headless harness at `/tmp/tobj` unless marked **(live)**.
- **Harness setup:** start the serve as a named service (`/tmp/tobj/bin/serve`, ready on "serving"), then `ctl plugins fixtures`. After each edit, run `/tmp/tobj/bin/sync` and `ctl plugins fixtures` again, then reopen the graph if it closed (`ctl tree '.ob-root'` tells). Right after a reload, force a fresh render with a click on "All" before reading the graph. Plugin timers fire only with window activity (`/tmp/tobj/bin/pump`). `pump` opens tabs behind the graph and can dock it into a split, so reopen it as a glimpse before measuring. Never source `/tmp/tobj/bin/env.sh` in a persistent shell.
- **Reading:** `ctl tree SEL` for texts, classes and rects; `/tmp/tobj/bin/order2` for the right column's order; `/tmp/tobj/bin/kv` for the store; `ctl shot NAME` for a PNG and layout JSON.
- **Data:** demo names follow the specs: sessions web, api and docs; tabs App build, Components, Server, Benchmarks and Guides.
- **After the checks:** stop the harness service, and delete `~/.omp/agent/sessions/--private-tmp-tobj-*` if a chat was started.

## 1. Code fixes

- [x] 1.1 Stale tag filter (D1) in `build`.

  Verify:
  - "Tag filter": "Filter by tag".
  - "Filtered tag removed": with "#api" active, untick "api" on its last holder. The chip is gone, every objective is listed (`ctl tree '.ob-obj'` count), and the kv dump's `view.tag` is absent.
  - Also from another path: delete the last holder while the filter is active.
  - "Empty state": "Nothing matches" under "This session" with no objective linked in the session.

  Result (harness; o1 "Fix login bug" #api, o2 "Write release notes" #web, o3 "Speed up search" with no tags, no links; view filtered on "api"):
  - **Before:** only o1 listed; chips `#api` (active) and `#web`; kv `view.tag` "api".
  - **Untick:** ⋯ → Tags → `#api` on o1 left o1 with no tags. The `#api` chip is gone, o1, o2 and o3 are listed, and kv `view.tag` is absent.
  - **Delete:** same start; ⋯ → Delete → `Delete “Fix login bug”` left o2 and o3 listed, the `#web` chip only, and no `view.tag`.
  - **Filter by tag:** `#web` listed only o2 with the chip active; a second click listed both again.
  - **Nothing matches:** "This session", where no objective links a tab, showed the single hint "No objectives match this filter." (shot `f11_nothing`).
- [x] 1.2 "you: …" only for omp agents (D2).

  Verify "Agent last user message":
  - "omp exchange": an omp chat in a harness tab answering "Explain caching"; its open row shows "you: Explain caching".
  - "Another agent": a non-omp agent row shows its reply line and no "you:" line on the first render after the graph opens. If no other agent can run in the harness, use a helper op that renders a copy of `lib/details.luau` with a non-omp agent entry, and say so in the result.

  Result (harness):
  - **omp exchange:** omp chat in pane 5 (`/tmp/tobj/w/ompA`) sent "Explain caching. Reply in one short sentence."; its open row reads `you:Explain caching. Reply in one short sentence.` above `omp:Caching keeps copies of frequently used …` (shot `f12_omp_row`).
  - **Another agent:** no other agent can run here. `claude` typed at a prompt in a test tab started, but Tern listed no agent for it (only omp's pane 5), since Claude needs Tern's `auto_acp`. I closed that pane. The helper op `details_test` ran a copy of `lib/*.luau` against a fake `cx.agents` holding a codex agent block (pane 101) and an omp chat (pane 102):
    - the codex row reads `codex · idle` with only `codex: Hello from codex`, on the first render and after the ticks;
    - the omp row has `you: …` first, then `you: Explain caching`, above `omp: …`;
    - transcript reads: `[102]`, the omp pane only.
- [x] 1.3 One open-objective sort (D3).

  Verify: two open objectives with equal priority, due date and `created` (set in `kv.json`). "Link this tab…" lists them in the same order as the graph (`ctl state` picker rows against `ctl tree '.ob-obj'`), both ways round after swapping their ids.

  Result (harness): "Alpha task" and "Beta task", both P2 with no due date and the same `created`.
  - With ids o4 and o5: the graph lists Alpha, Beta, and so does "Link this tab…" (picker rows read by stepping through `ctl state`).
  - With the ids swapped (Alpha o5, Beta o4): both list Beta, Alpha.
  - Renders took at most 7.5 ms, with no errors in the log.

## 2. Specs match the code

- [x] 2.1 Run each new or changed scenario of the deltas, unless 1.x already covered it.
  - objectives-graph: "Closed tab's line"; "Linking removes the fade" still holds on live tabs; "Filtered out"; "The graph's own tab"; "Every shown tab linked"; "Two sessions' closed tabs"; "Closed tab linked to an open objective" (shot).
  - tab-links: "Parked focus" (a session whose only pane is parked); "Menu heading"; "Resume moves a done objective's link".
  - objective-store: "Made for a tab".
  - objective-review: "Picker from review mode".
  - agent-resume: "Found by name in another case".
  - plugin-package: "Rename hidden without a selection" (`ctl palette objectives`).

  Verify: each scenario's THEN holds, with the reading named in it. Record every result. If one fails, stop and decide with the user whether the spec or the code changes.

  Result (harness; every THEN held, so no spec or code change was needed):
  - **Resume moves a done objective's link** and **Found by name in another case:**
    - setup: done X ("Write release notes") was linked to omp chat tab 6 (pane 5, saved), recorded as "work · tab 2"; the tab was then closed, session "work" closed, and session "Work" created;
    - from session "home", X selected: tab 6 showed under "Closed tabs" with Resume;
    - result: the chat opened as tab 110 in "Work", its tab 2, and Tern showed "Work"; the kv dump has X done, linked to `[110]`.
  - **Linking removes the fade:** live App build (117) went from `ob-tab-unlinked` to the card class after a "Link to" menu choice, and its label's darkest pixel is RGB 59,59,59 before and after (shots `f21_fade_before`, `f21_fade_after`). The graph needs a 1400 px tall window, or that node sits under the glimpse's footer.
  - **Filtered out:** Y ("Fix login bug" #api) linked to App build drew one edge layer; with "#web" hiding Y there were none, and clearing the filter brought it back.
  - **Closed tab's line** and **Two sessions' closed tabs:**
    - setup: X linked to Components ("web · tab 2"), Server ("api · tab 1") and Notes ("api · tab 3"), then all three closed;
    - the "Closed tabs" group reads Server, Notes, Components;
    - Components' node reads "closed · web · tab 2".
  - **Closed tab linked to an open objective:** shot `f21_ghosts` (crop) shows Components with a faint dashed border, no fill, half-strength text and a struck-through label. The live tab next to it has a solid fill and full-strength text.
  - **Every shown tab linked:** X linked to Benchmarks, the api session's only live tab. Under "This session": `{Linked to “Write release notes”} [api] Benchmarks {Closed tabs} Server Notes`, with no `.ob-divider`. Under "All" the divider is back.
  - **Menu heading:** with two open objectives, App build's menu reads `Link to` (`mi-sec`), the two objectives' rows, a separator, then Copy.
  - **The graph's own tab:** done o4 linked only to new tab D (129), and the graph was opened from D. "Close linked tabs · 1 open tab" was confirmed ("Close 1 tab"). D is gone, the graph came back over tab 124 beside a terminal, and o4 still links `[129]`.
  - **Parked focus:** session "parked", whose only pane (135) was parked, has no tabs. "Link this tab…" and "New objective for this tab…" each showed the error toast "The focused pane is not in a tab", and the objectives in `kv.json` were unchanged.
  - **Made for a tab:** "New objective for this tab…" from App build's shell, with "Ship the dashboard", stored o20, P2, open, linked to `[117]` only.
  - **Picker from review mode:** "Review (2)" listed o5 and o6. o5's ⋯ menu dismissed with Esc left the graph in review mode with o5 and o6, the button still active. The harness picker did not close the glimpse, so the reopen path itself was not exercised here.
  - **Rename hidden without a selection:** read from the palette's `div.cmdk` rows:
    - with o1 selected, all four commands, rename with ⌥R;
    - with the graph shown and nothing selected, and with no graph, rename is absent and the other three are listed.
  - **Log:** renders took at most 7.5 ms, with no errors.
- [x] 2.2 Purposes and config (D4): edit the objectives-graph and objective-store Purposes in the main specs, and the specs rule in `openspec/config.yaml`.

  Verify: `openspec validate --specs --strict` passes, and `openspec instructions specs --change fix-spec-drift --json` shows the new rule.

  Result:
  - **objectives-graph Purpose:** "…manages objectives mostly by clicking, with a rename key and typed fields where text is needed…".
  - **objective-store Purpose:** adds "their review schedules", "saved omp chats" and the view settings.
  - **`openspec/config.yaml`:** the specs rule now adds "plugin-package's repository and install scenarios are observed in the repository, on GitHub, or with an isolated install".
  - **Checks:** `openspec validate --specs --strict` 8 passed; `openspec instructions specs` lists the new rule; the change validates strictly.
- [x] 2.3 README (D4): the box bullet's Resume exception, the tabs bullet's ghost look, and the Prune known limit.

  Verify by reading each passage against the matching requirement: "Done objectives' links are fixed", "Ghost tabs look different" with "Unlinked tabs look different", and "Pruning closed tabs".

  Result:
  - **The box bullet:** "their links can't change (Resume aside: a reopened tab takes them over)".
  - **The tabs bullet:** live unlinked tabs are grey and dashed. Ghosts are faint, dashed, with a struck-through label and "closed ·" or "other window ·" before their place, and both groups are ordered by session name, then old position.
  - **The Review (n) limit:** "done objectives with no links, or linked only to other sessions' or windows' tabs"; "pruned" is gone.
  - **Filter bullet:** it also says a tag filter goes away by itself once no objective holds the tag (task 1.1).
  - Each passage agrees with "Done objectives' links are fixed", "Ghost tabs look different" and "Unlinked tabs look different", "Order of closed and other-window tabs", "Pruning closed tabs" and "Tag filter".

## 3. Release 0.14.1

- [x] 3.1 Version `0.14.1` in `plugin.toml`. Verify an isolated `tern plugin install` of the repo folder prints `installed objectives 0.14.1`. Tick this box, then commit, push `main` and tag `v0.14.1` (annotated, message "objectives 0.14.1").

  Result: the install into `/tmp/tobj-inst141/config` printed `installed objectives 0.14.1 → /tmp/tobj-inst141/config/plugins/objectives`.
- [ ] 3.2 **(live)** After the push has finished, run `tern plugin install github.com/JakobMusik/tern-objectives --force` from a shell with no harness variables.

  Verify `tern plugin list` shows `objectives 0.14.1 … ready`, with `tabnav 0.1.0` and `omp-narration 0.1.0` untouched.
- [ ] 3.3 **(live)** With the user:
  - a tag filter whose tag is removed from its last objective clears itself;
  - the "Link this tab" picker and the graph list objectives in the same order.

  Record the result here.

## Workflow follow-up

- Archive the change (`openspec archive fix-spec-drift --yes`), run `openspec validate --specs --strict`, commit and push.
