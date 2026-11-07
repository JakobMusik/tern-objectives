# Design

## Context

See proposal.md, "Why".

- **Creation time:** `Store.create` sets `created = os.time()` (`lib/store.luau:272`), and it is the only place objectives are made; Undo's `restore` puts the saved record back whole. The node's tooltip already prints it as `Created YYYY-MM-DD HH:MM` through `stamp` (`lib/view.luau:82–91`).
- **Title line:** `.ob-l1` is a flex row with a 6 px gap: the done box (22 px), the priority badge, `.ob-title` (`flex: 1 1 auto; min-width: 0`, cut with "…"), then on done nodes the trash icon, then ⋯ (22 px) (`lib/view.luau:138–160`, `styles.css:226–290`). At a 460 px window the left column is about 130 px wide, which leaves the title about 60 px.
- **Tab menu rows** are built by `menu_of` (`lib/view.luau:463`) as `{ id = "lnk=<objective>:<tab>", label = title, checked }`.
- **"Link this tab"** builds `PickItem`s with `label = title, detail = "P<priority>"` (`lib/app.luau:251–258`). The success toast uses the picked item's `label`.

### Source record

| Claim | Evidence |
|---|---|
| `os.date` formats a Unix time in local time | `lib/dates.luau:14`; the tooltip's `stamp` (`lib/view.luau:83`) |
| A picker row's `detail` is dim text after the label, and typing filters on the label | `tern.d.luau:1908–1911` |
| A canvas menu row's `detail` is only its tooltip, so visible text must be in `label` | SDK, [Building Views › Actions and events](https://docs.stencil.so/tern/guides/views.html): "detail (its tooltip here)" |
| Tern lays out `.ob-l1`'s flex row and cuts `.ob-title` with "…" | shipped since 0.1; "Objective node content" scenarios |

## Goals / Non-Goals

**Goals:**
- Same-titled objectives are distinguishable wherever one is chosen, with no change to stored data.

**Non-Goals:**
- A setting for the format.
- Showing the done time instead of the creation time on done objectives.

## Decisions

### D1. One formatter
`Dates.short(t: number?): string?` returns `os.date("%m-%d %H:%M", t)`, or nil when `t` isn't a number. A record without `created` then shows no time rather than the current one. The view and the picker both call it.

Alternative: store the formatted time in the title at creation. The user chose not to: Rename would expose it, and existing objectives would lack it.

### D2. The node
- After `.ob-title`, a `.ob-created` span with the short time, keyed `created`, before the trash icon and ⋯.
- `.ob-created`: 11 px, `color: var(--t3)`, `white-space: nowrap`, `overflow: hidden`, `text-overflow: clip`, `flex: 0 0.001 auto`, `min-width: 0`.
- `.ob-title` gets `min-width: 3em` in place of 0.
- In CSS flex, shrinking is shared in proportion to each item's shrink factor times its size, and an item stops at its `min-width`. With a factor of 0.001, the time gives up a fraction of a pixel while the title shrinks. Once the title is down to 3em, the time is the only item left to shrink. So a long title is cut first, and on a very narrow node the time is cut after it, with the title still showing a few letters.
- Node heights don't change, so the layout sheet and the lines are untouched. The span sits inside the node's click area, so a click on it selects the node like the title does.

Alternatives:
- `flex: none` on the time keeps it whole at every width, but at 460 px the title would shrink to nothing.
- The time at the start of the second line, before the note and chips: it would always fit, but it isn't a suffix of the name, which is what the user asked for.

### D3. Link choices
- `menu_of` labels each row `title .. " · " .. Dates.short(o.created)`, with no time when it's nil.
- `link_tab` sets each item's `detail` to `"P" .. priority .. " · " .. Dates.short(o.created)`.
- The label stays the plain title, so the toast keeps the plain title, and typing filters on titles.

## Risks / Trade-offs

- **[Tern's flex shrinking differs from CSS]** Nothing records how Tern's layout shares shrinking between items or honours `min-width` on a shrinking item. → Task 1.1 measures the title and time rects at 1400 and 460 px wide. If the time is cut while the title still has room, or the title disappears, stop and update D2.
- **[Same minute]** Two objectives with one title created within one minute still read alike. → The user's choice of format; the tooltip gives the full time, and the ids differ in the kv dump.
- **[Wider menu rows]** Each "Link to" row grows by 14 characters. → The tab menu's known limit, a row per open objective with no scrolling, is about height, not width.
- **[Clock and time zone]** The time is local at render time, so it shifts if the machine's time zone changes. → Accepted; the tooltip does the same.

## Migration Plan

Nothing stored changes, and every existing objective already has `created`. Release 0.14.0. To roll back, install `v0.13.0` again.
