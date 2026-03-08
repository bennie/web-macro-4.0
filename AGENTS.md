# AGENTS.md

This file defines working rules for agents editing this repository.

## Scope
- Applies to the entire repository rooted here.

## Project Layout
- `index.html`: Main page.
- `stories.html`: Stories page.
- `style/main.css`: Shared stylesheet for both pages.
- `images/logo.svg`: Production logo (vector paths).
- `images/logo-textmode.svg`: Reference logo (editable text version).

## Conventions
- Keep HTML references consistent:
  - Stylesheet path: `style/main.css`
  - Logo path: `images/logo.svg`
- Prefer editing `images/logo-textmode.svg` for logo text/layout experiments.
- Keep `images/logo.svg` as the stable rendered output for cross-platform consistency.

## Logo Workflow
1. Make visual/logo text changes in `images/logo-textmode.svg`.
2. Convert text to paths for production output in `images/logo.svg`.
3. Preserve transparent background and current tight crop unless asked otherwise.

## Change Log
- `2026-03-08`: Reference logo file renamed from `images/logo-test.svg` to `images/logo-textmode.svg`.

## Editing Guidelines
- Make minimal, targeted changes.
- Do not introduce new unused assets.
- Do not rename key files or directories unless explicitly requested.
- Preserve accessibility attributes like `alt`, `title`, and `desc` when modifying logos or markup.

## Verification
- After edits, verify:
  - `index.html` and `stories.html` still load `style/main.css`.
  - Both pages still reference `images/logo.svg`.
  - No broken relative paths were introduced.
