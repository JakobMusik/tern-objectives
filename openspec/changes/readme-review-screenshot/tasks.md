# Tasks

Design is skipped: the change adds an image and a spec line, with no technical decisions.

## 1. Review screenshot

- [x] 1.1 Add `docs/review.png` from the draft `/tmp/tobj/shots/serve/README_review_draft.png`, which the user saw with the proposal. If the draft is gone, or the user asked for changes, retake it in the harness: review mode with two due objectives, one selected so its line and linked tab show, cropped to the header, the two review nodes and the `Linked to` section.
  - Place it after the steps in the README's "Reviewing done objectives" section, with alt text naming the rating buttons and their day counts.
  - In `openspec/config.yaml`, change the apply guidance "only the README screenshot enters the repo" to "only the README's screenshots enter the repo".

  Verify:
  - GitHub's Markdown API (`gh api markdown`) renders the README with two images, `docs/graph.png` then `docs/review.png`;
  - "Graph screenshot first": in the README fetched from GitHub after the push, the first image is `docs/graph.png`;
  - both images are served from `main` (`curl` status 200, `image/png`);
  - `openspec validate --specs --strict` passes.

  Tick this box, then commit and push. No release: the plugin package doesn't change.

  Result:
  - `docs/review.png` is the user-approved draft, unchanged: 1838 × 753 px, 114,986 bytes. It sits after step 3 of "Reviewing done objectives", with alt text naming Hard · 1d / Good · 3d / Easy · 4d and Hard · 2d / Good · 9d / Easy · 14d.
  - `gh api markdown` on the README renders two images in order: `docs/graph.png`, then `docs/review.png`.
  - `openspec validate --specs --strict`: 8 passed. The change validates strictly.

## Workflow follow-up

- Archive the change (`openspec archive readme-review-screenshot --yes`), run `openspec validate --specs --strict`, commit and push.
