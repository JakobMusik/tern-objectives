# Tasks

Checks run in the headless harness at `/tmp/tobj` unless marked **(live)**.
- **Harness setup:** start the serve as a named service (`/tmp/tobj/bin/serve`, ready on "serving"), then `ctl plugins fixtures`; after each edit, `/tmp/tobj/bin/sync` and `ctl plugins fixtures` again. Plugin timers fire only with window activity: use `/tmp/tobj/bin/pump`.
- **Fixture:** the "Linked tabs section" scenario's window: sessions "web" (tabs "App build", "Components") and "api" (tabs "Server", "Benchmarks"), with objective X linked to "Components" and "Benchmarks" and the graph opened from "Server". Objectives are set up in `kv.json` and the plugin reloaded after (`ctl plugins fixtures`): links added to existing objectives, `done` set with a `done_at`.
- **Reading the graph:** `/tmp/tobj/bin/order` prints the right column's session headings and tab labels in order; `ctl tree '.ob-linkhead, .ob-divider, .ob-linkbar'` finds the heading, divider and bars; `/tmp/tobj/bin/kv` dumps the store. `ctl shot NAME` writes a PNG and its layout JSON, and `/tmp/tobj/bin/edgecheck.py` checks that line ends are within 2 px of node centres.
- **After the checks**, stop the harness service.

## 1. Linked section and divider

- [x] 1.1 The top section from the current links (D1): remove `pinned` and `select` from `lib/app.luau` and `pinned` from `View.Ui`; the section and its counts use `sel_tabs`.

  Verify each scenario of "Linked tabs section" with `order` and `ctl tree` after each click, and the kv dump after each link change:
  - linked tabs on top, and the linked closed tab under "Closed tabs" in the top section only;
  - "＋ Link" on "App build" moves it up under "web" before "Components", and "× Unlink" on "Benchmarks" moves it below the divider;
  - unlinking the last linked tab removes heading and divider; a new objective has neither until its first "＋ Link";
  - deselect restores the normal order, and selecting again gives the same section;
  - "This session" keeps only the current session's linked tabs;
  - a link made from a tab's right-click menu while X is selected moves the tab too.

  Result (harness; demo rebuilt as web 6 with "App build" 8 and "Components" 12, api 15 with "Server" 17 and "Benchmarks" 21; X = o2 "Write release notes" linked to 12 and 21 in a clean `kv.json`; graph opened from api's pane 16; orders from `/tmp/tobj/bin/order2`, which adds `{heading}` texts):
  - **Selected:** `{Linked to “Write release notes”} [api] Benchmarks [web] Components {Other tabs} [api] Server [web] App build`; bars `× Unlink` ×2, `＋ Link` ×2.
  - **"＋ Link" on App build:** `{Linked to …} [api] Benchmarks [web] App build Components {Other tabs} [api] Server` at once; its bar `× Unlink`; kv `[12, 21, 8]`.
  - **"× Unlink" on Benchmarks:** `{Linked to …} [web] App build Components {Other tabs} [api] Server Benchmarks`; its bar `＋ Link`; kv `[12, 8]`.
  - **Linked closed tab:** spare tab 39 "extra", linked by its bar and then closed: `… Components {Closed tabs} extra {Other tabs} [api] Server Benchmarks`.
  - **Deselect:** `[api] Server Benchmarks [web] App build Components {Closed tabs} extra`, no bars. **Selected again:** the same column as before deselecting.
  - **Last link removed:** with only App build left, its "× Unlink" gave the normal order with no heading or divider, four `＋ Link` bars, kv `[]`.
  - **Nothing linked / First link:** "Write slides" (o34), created with "＋ New objective" and selected: normal order, no heading; "＋ Link" on Components gave `{Linked to “Write slides”} [web] Components {Other tabs} [api] Server Benchmarks [web] App build`.
  - **This session:** X linked to Benchmarks and Components: `{Linked to …} [api] Benchmarks {Other tabs} [api] Server`; "All" again shows both sessions.
  - **Right-click menu:** with X selected, `menulink` on Server's header choosing "Write release notes" gave `{Linked to …} [api] Server Benchmarks [web] Components {Other tabs} [web] App build`; kv `[21, 12, 17]`.
  - **Log:** renders 1.5–2.1 ms, no errors.
- [x] 1.2 The divider (D2): `divider_h`, `Layout.add_divider`, the `.ob-divider` markup and its rules in `styles.css`.

  Verify "Other tabs divider":
  - shots in light and dark (`ctl appearance`), cropped to the divider, show the 3 px accent bar on both sides of the "Other tabs" pill, centred in the row;
  - the layout JSON gives the row 32 px;
  - `edgecheck.py` passes at 1400 and 460 px wide with X selected.

  If the bar or the pill doesn't draw as D2 says, stop and update D2 first.

  Result (harness, X selected, graph reopened from Server):
  - **Layout** (`ctl tree`): `.ob-divider` 32.0 px tall; both `.ob-drule` 3.0 px tall, 227.6 px wide each at window 1280; `.ob-dpill` "Other tabs" 18.0 px. Bar and pill centres both at y 575.7, the row's middle.
  - **Shots** `d12_light` and `d12_dark`, cropped: the bars and the outlined pill draw in the accent colour, a muted teal in the harness's light theme and bright blue in dark, with the pill between the two bars.
  - **`edgecheck.py`:** PASS at 1400 px (shot `e12_1400`) and 460 px (`e12_460`). With o1 also linked to App build, below the divider: PASS again (`e12b_1400`, `e12b_460`), 3 left and 4 right ends within 0.6 px, App build's at y 669.8 and 696.8.
  - `/tmp/tobj/bin/order2` now prints the pill as `{Other tabs}`.
- [x] 1.3 README: the "Click an objective" bullet says linked tabs move up and unlinked ones down at once, and describes the divider. Verify by reading the rendered bullet against "Linked tabs section".

  Result: the bullet now names the bold accent bar labelled **Other tabs**, says a linked tab moves up at once and an unlinked one down, and keeps the deselect sentence. Nothing in the README still says tabs stay put. The screenshot shows an unselected graph, so it stays.

## 2. Done objectives

- [ ] 2.1 Fixed links (D3): no link bar for a done objective; `Store.toggle_link` returns `"done"` unchanged; the `link=`, `lnk=` and `link_tab` handling of `"done"`.

  Verify:
  - "Selecting a done objective" and tab-links "Done objective selected": `ctl tree` finds no `.ob-linkbar` with a done objective selected, a `ctl click` where a bar was leaves its links unchanged in the kv dump, and a shot shows it selected;
  - with an open objective selected, the bars are still there ("Select and clear");
  - a helper op running a copy of `lib/store.luau` against the helper's store: `toggle_link` on a done objective returns `"done"` and leaves its tabs as they were, and on an open one still links and unlinks.
- [ ] 2.2 Done lines (D4): `Edge.done`, `Layout.done_color`, `obj_cy` for done nodes, and the edges of a selected done objective; review mode drops the listed objectives' edges.

  Verify each scenario of "Link lines", "Done objectives group" and review's "Closed tab in review":
  - a done X linked to a live tab and a closed tab, selected: a shot shows thick green lines to both, the closed one dashed, and open Y's line faded; `edgecheck.py` passes;
  - after a click on empty space, no green line, and Y's line at full strength;
  - review mode shows no line until a listed objective is selected, then its green line, with `edgecheck.py` passing at 1400 and 460 px wide;
  - marking an unselected linked objective done removes its lines;
  - a closed tab with a replied omp chat, in review: "Resume" and no line, then a dashed green line once its objective is selected, and no link bar.
- [ ] 2.3 README: the done bullet (lines only while selected, in green, no link bar), the Review bullet (lines appear for the selected one), and the closed-tabs bullet ("with its line" while selected). Verify by reading each bullet against "Link lines", "Done objectives' links are fixed" and "Review mode".

## 3. Release 0.13.0

- [ ] 3.1 Version `0.13.0` in `plugin.toml`. Verify an isolated `tern plugin install` of the repo folder prints `installed objectives 0.13.0`. Tick this box, then commit, push `main` and tag `v0.13.0` (annotated, message "objectives 0.13.0").
- [ ] 3.2 **(live)** After the push has finished, `tern plugin install github.com/JakobMusik/tern-objectives --force`, from a shell with no harness variables. Verify `tern plugin list` shows `objectives 0.13.0 … ready`, with `tabnav 0.1.0` and `omp-narration 0.1.0` untouched.
- [ ] 3.3 **(live)** With the user: linking and unlinking move tabs across the new divider at once; a done objective shows its green lines when selected and no link bars. Record the result here.

## Workflow follow-up

- Archive the change (`openspec archive linked-section-and-done-lines --yes`), run `openspec validate --specs --strict`, commit and push.
