# Proposal

## Why

Asked by the user on 2026-11-08: spaced-repetition review is one of the plugin's main features, but the README barely showed it. Its one screenshot had the Done group collapsed, and the rating buttons appeared nowhere.

Already done without a spec change (`b806cdf`):
- the README names review in its intro and features, and has a "Reviewing done objectives" section;
- `docs/graph.png` shows the graph with the Done group open: "review due" and "review in 4d" chips and a "Review (2)" button.

The user also asked for a second, clearer screenshot of review mode. The README requirement in plugin-package says "one screenshot of the graph", so the second one needs this change.

## What Changes

1. **A second README screenshot, `docs/review.png`:** review mode with two due objectives and their Hard, Good and Easy buttons, one of them selected so its line and linked tab show. It goes in the "Reviewing done objectives" section.
2. **The README requirement** asks for both screenshots, the graph first. Plugin listings take a README's first image as its screenshot, so the graph stays first.
3. **`openspec/config.yaml`:** the apply guidance "only the README screenshot enters the repo" becomes "only the README's screenshots enter the repo".

Out of scope:
- Any plugin code or release: this is README content only.
- How plugin listings show the plugin: they keep using the first image, `docs/graph.png`.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `plugin-package`: README is modified, to ask for the graph screenshot with the Done group open and, after it, the review-mode screenshot.

## Impact

- `README.md`, `docs/review.png`.
- `openspec/config.yaml`: one apply guidance line.
- `openspec/specs/plugin-package/spec.md`: through the delta.
