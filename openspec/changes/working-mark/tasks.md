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

- [ ] 1.1 The mark (design D1–D3): "working" in `Details.attention` (`lib/details.luau`); `RANK`, `call_of`, `mark_of`, the node class for "wait" and "replied" only, and the chip's text and tooltip in `lib/view.luau`; `.ob-attchip-working` in `styles.css`.

  Verify with `ctl tree`, `op agents` and shots:
  - objectives-graph "Attention marks": "Chat working" (the node has no `ob-att-*` class, its first line-2 chip reads "working" with tooltip `omp is working in “Server”`), "Working turns into replied", "Needs you wins over working" and "Replied wins over working";
  - unchanged: "Question waiting", "Reply unseen", "Needs you wins" and "Not linked";
  - "Attention marks clear", "Selected and marked", with a working chat: the selected node shows the accent selection ring with no inner ring, and the "working" chip;
  - a done node in the Done group linked to the working tab shows "working" first and its review chip after it, and a review node linked to it shows "working";
  - "Light and dark themes": shots under `ctl appearance light` and `ctl appearance dark`, cropped to a working node and a done node with "review due", show the chip's text readable on its tint in both, and the amber and green rings unchanged;
  - render times in `/tmp/tobj/logs/tern-serve.log`, with no objectives warnings or errors.
- [ ] 1.2 README (design D4): the "See what needs you" bullet names the **working** chip. Verify by reading the bullet.

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
