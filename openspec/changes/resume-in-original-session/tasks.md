# Tasks

Checks run in the headless harness at `/tmp/tobj` unless marked **(live)**.
- **Harness setup:** start the serve as a named service (`/tmp/tobj/bin/serve`, ready on "serving"), then `ctl plugins fixtures`; after each edit, `/tmp/tobj/bin/sync` and `ctl plugins fixtures` again. Plugin timers fire only with window activity: use `/tmp/tobj/bin/pump`.
- **Sessions:** helper ops `new_session`, `switch`, `rename_session` and `close_session`, plus a `sessions` op (to add) returning `cx.session:sessions()`, so a check reads each session's ordered tabs and which is current.
- **Chats:** omp chats in folders under `/tmp/tobj/w/`, one short message each, so each has a chat file.
- **After the checks**, delete `~/.omp/agent/sessions/--private-tmp-tobj-*` and stop the harness service.

## 1. Spike

- [x] 1.1 Check D3 and D4 with sessions "work" (three tabs) and "home", with a helper op that runs each way in one call.

  Verify, and record in design.md's source record:
  - A: from "home", `switch` to "work" then `new_tab`: which session holds the new tab (op `sessions`), and which is shown;
  - B: from "home", `new_tab` then `move_to_new_tab(pane, work)`: whether the pane lands in "work" and whether "home" keeps an empty tab;
  - `order_tab(tab, 2)` on the new tab, in the same call and from a 250 ms timer: which one moves it.

  Pick A if it works, else B, and update D3 and D4. If neither works, stop and update the artifacts.

  Result (harness, 2026-11-07; sessions "Default" 1, "work" 6 with tabs `[8,10,12]`, "home" 13, current):
  - A, from "home": `switch(6)` then `new_tab` in one call opened pane 18 in tab 19 of "work", and "work" became current. `order_tab(19, 2)` in the same call returned without error and "work" read `[8,19,10,12]`; "home" was unchanged;
  - B, from "home": `new_tab` gave pane 24 in tab 25, and `move_to_new_tab(24, 6)` returned 25: the whole tab moved to the end of "work" (`[…,12,25]`), "work" became current, and "home" kept no empty tab;
  - `order_tab` from a 250 ms timer also works: tab 29, opened by A, went to position 1.

  A is kept (design D3), with `order_tab` in the same call (D4).

## 2. Resume in the original session

- [x] 2.1 Implement D1 to D4 in `lib/app.luau` (`resume`): choose the session, check its host, open the tab there, order it, and toast on the fallback.

  Verify each scenario of "Where a chat resumes" with a linked omp chat tab in "work", closed, then Resume clicked from "home":
  - back in its own session: op `sessions` shows the new tab at position 2 of "work", "work" current, and no new tab in "home";
  - renamed: after `rename_session` "work" → "work-2", the new tab is in "work-2";
  - found by name: after closing "work" and creating a new "work", the new tab is in the new one;
  - fewer tabs: a tab that was tab 3 of a session now holding one tab comes back as its tab 2;
  - gone: with no session of that id or name, the new tab is the last of "home", and a shot shows the toast naming the session;
  - and, as before, the kv dump shows the links moved and the closed tab's snapshot gone.

  Result (harness; one omp chat, "w2", in `/tmp/tobj/w/extra`, first in tab 10 at position 2 of "work" (id 6, tabs `[8,10,12]`), linked to o1; every Resume clicked from "home" (id 13)):
  - back in its own session: "work" became `[8,87,12]` and current, the chat in tab 87; "home" stayed `[15]`; o1's 10 became 87, and 10's snapshot went;
  - renamed: with "work" renamed "work-2" (snapshot still "work", id 6), the chat came back as tab 107 of "work-2", `[8,107,12]`;
  - found by name: with session 6 closed and a new "work" (id 130, one tab) created, the chat came back in it as tab 140, `[132,140]`;
  - fewer tabs: with tab 140 moved to position 3 and snapshotted, then "work" cut to one tab, the chat came back as its tab 2, `[132,174]`;
  - gone: with "work" closed and no session of id 130 or name "work", the chat came back as the last tab of "home", `[15,202]`, and shot `s25_gone` shows the toast "Session “work” is gone: resumed here". o1's 174 became 202, 174's snapshot went, and pane 201 is saved with the same chat file.

## 3. README

- [x] 3.1 In "Using the graph", say Resume opens the tab in its own session at its old place and switches there, and in the current session when that session is gone. In "Known limits", replace "it refuses while the current session is on one" with the chosen session's machine.

  Verify by reading the sections against the delta spec.

  Result: "Using the graph" says Resume switches to the tab's session, even renamed, opens the tab at its old position, and when the session is gone opens it at the end of the current one with a message naming the session. "Known limits" now says it refuses when the session it would open in is on another machine, and adds that the old position is the one the plugin last saw (design, Risks). Both match "Where a chat resumes" and "Resuming a closed tab".

## 4. Release 0.11.1

- [ ] 4.1 Version `0.11.1` in `plugin.toml`. Verify an isolated `tern plugin install` of the repo folder prints `installed objectives 0.11.1`. Tick this box, then commit, push `main` and tag `v0.11.1` (annotated, message "objectives 0.11.1").
- [ ] 4.2 **(live)** After the push has finished, `tern plugin install github.com/JakobMusik/tern-objectives --force`, from a shell with no harness variables. Verify `tern plugin list` shows `objectives 0.11.1 … ready`, with `tabnav 0.1.0` untouched.
- [ ] 4.3 **(live)** With the user: Resume on a closed linked omp tab, clicked from another session, brings the chat back in its own session at its old position. Record the result here.

## Workflow follow-up

- Archive the change (`openspec archive resume-in-original-session --yes`), run `openspec validate --specs --strict`, commit and push.
- Next change: "Close linked tabs" for done objectives.
