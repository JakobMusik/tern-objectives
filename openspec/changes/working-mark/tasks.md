# Tasks

Checks run in the headless harness at `/tmp/tobj` unless marked **(live)**.
- **Harness setup:** start the serve as a named service (`/tmp/tobj/bin/serve`, ready on "serving"), then `ctl plugins fixtures`. After each edit, run `/tmp/tobj/bin/sync` and `ctl plugins fixtures` again, then reopen the graph if it closed (`ctl tree '.ob-root'` tells). Never source `/tmp/tobj/bin/env.sh` in a persistent shell. The headless serve runs plugin timers only while the window has activity, so keep it busy with `/tmp/tobj/bin/pump N` while a turn runs (resume-closed-agents, task 2.2).
- **Chats:** omp chats in tabs "Server" and "Docs" (and two side by side in "Split" if the layout still has it), driven through the helper's `run` op from another focused tab:
  - **working:** "Run `sleep 90` in bash, then reply with exactly: done";
  - **waiting for input:** ask it to put a yes/no question to the user with its ask tool;
  - **unseen reply:** a short turn ("Reply with exactly: ok") that ends while another tab has focus.
- **Reading:** `ctl tree '.ob-obj'` for nodes and their classes, `ctl tree '.ob-attchip'` for chips and tooltips, `/tmp/tobj/bin/op agents` for each chat's state, and `ctl shot NAME` for a PNG and layout JSON.
- **After the checks:** stop the harness service.

## 1. The working mark

- [x] 1.1 The mark (design D1–D3): "working" in `Details.attention` (`lib/details.luau`); `RANK`, `call_of`, `mark_of`, the node class for "wait" and "replied" only, and the chip's text and tooltip in `lib/view.luau`; `.ob-attchip-working` in `styles.css`.

  Verify with `ctl tree`, `op agents` and shots:
  - objectives-graph "Attention marks": "Chat working" (the node has no `ob-att-*` class, its first line-2 chip reads "working" with tooltip `omp is working in “Server”`), "Working turns into replied", "Needs you wins over working" and "Replied wins over working";
  - unchanged: "Question waiting", "Reply unseen", "Needs you wins" and "Not linked";
  - "Attention marks clear", "Selected and marked", with a working chat: the selected node shows the accent selection ring with no inner ring, and the "working" chip;
  - a done node in the Done group linked to the working tab shows "working" first and its review chip after it, and a review node linked to it shows "working";
  - "Light and dark themes": shots under `ctl appearance light` and `ctl appearance dark`, cropped to a working node and a done node with "review due", show the chip's text readable on its tint in both, and the amber and green rings unchanged;
  - render times in `/tmp/tobj/logs/tern-serve.log`, with no objectives warnings or errors.

  Result (harness, today 2026-11-09). omp chats ran in tab 5 "Server" (pane 4) and tab 7 "Docs" (pane 6), messaged through the helper's `ask` op while tab 3 kept focus. The store (`/tmp/tobj/kv.wm.json`) held open o1 "Fix login bug" → Server, o2 "Ship docs" → Docs, o3 "Review pull requests" → Server and Docs, o4 "Write slides" with no links, and done o5 "Profile slow queries" → Docs, due for review today. Docs ran "sleep 150" for one long turn.
  - **Chat working** (the working chat was in Docs, not Server): with Docs `working` and Server `idle`, o2, o3 and o5 had no `ob-att-*` class, and their first line-2 chip read "working" with tooltip `omp is working in “Docs”`. o1 and o4 had no chip.
  - **Done and review nodes:** o5 in "Done (1)" read "working", then "review due". After "Review (1)", its review node (`ob-review`) read the same above Hard · 1d, Good · 3d and Easy · 4d (shot `wm_review`).
  - **Reply unseen / Replied wins over working:** a short turn in Server ended `idle` with its alert set, while Docs still worked. o1 and o3 got `ob-att-replied` and "replied" (`omp replied in “Server”`), o3 naming Server only. o2 and o5 still read "working".
  - **Question waiting / Needs you wins over working:** asked for a yes/no question, Server went `working`, then `waiting_input`. o1 and o3 got `ob-att-wait` and "needs you" (`omp is waiting in “Server”`), o3 naming Server only.
  - **Working turns into replied / Needs you wins / Not linked:** Docs' turn ended after 2m34s, `idle` with its alert set. With no click, the graph redrew: o2 and o5 got `ob-att-replied` and "replied" (`omp replied in “Docs”`). o3, with Server waiting and Docs replied, showed only "needs you" for Server. o4 had no chip and no ring throughout.
  - **Selected and marked:** o2 selected while working had the accent ring alone: from outside in, at its left edge, 2 device pixels of accent (90, 128, 128), then the node's white. Its "working" chip showed above its action bar (shot `wm_sel_light`).
  - **Light and dark:** the working chip is bold accent text on the accent tint: a grey-teal in the harness's light theme and blue in dark, readable in both. "review due" beside it is the same colours in normal weight (shots `wm_working`, `wm_dark`). The amber and green rings and chips look as before in both (`/tmp/tobj/shots/wm_rings_both.png`).
  - **Harness note:** the first click on "Review (1)" came while the graph sat docked after `pump` runs. Afterwards `ctl tree` found no graph. ⌃⌘O opened it as a glimpse, and the review checks ran there.
  - **Log:** since the serve started, 31 renders, the longest 5.8 ms, and no objectives warnings or errors.
- [x] 1.2 README (design D4): the "See what needs you" bullet names the **working** chip. Verify by reading the bullet.

  Result: the bullet now ends "While one is at work, it shows a **working** chip, with no colour around it."

## 2. Release 0.20.0

- [ ] 2.1 Version `0.20.0` in `plugin.toml`. Verify that an isolated `tern plugin install` of the repo folder prints `installed objectives 0.20.0`. Tick this box, then commit, push `main` and tag `v0.20.0` (annotated, message "objectives 0.20.0").
- [ ] 2.2 **(live)** After the push has finished, run `tern plugin install github.com/JakobMusik/tern-objectives --force` from a shell with no harness variables.

  Verify `tern plugin list` shows `objectives 0.20.0 … ready`, with the other plugins untouched.
- [ ] 2.3 **(live)** With the user:
  - an objective linked to a tab whose omp chat is working shows a "working" chip and no ring;
  - when that chat finishes while the user is elsewhere, the chip turns into the green "replied" mark;
  - one linked chat waiting for input and another working shows "needs you" only.

  Record the result here.

## Workflow follow-up

- Archive the change (`openspec archive working-mark --yes`), run `openspec validate --specs --strict`, commit and push.
