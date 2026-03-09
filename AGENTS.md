# AGENTS.md

This file defines working rules for agents editing this repository.

## Scope
- Applies to the entire repository rooted here.

## Project Layout
- `www/index.html`: Main page.
- `www/html/stories.html`: Stories page.
- `www/html/links.html`: Links directory page (JSON-driven).
- `www/data/links.json`: Link catalog data source.
- `www/style/main.css`: Shared stylesheet for site pages.
- `www/images/logo.svg`: Production logo (vector paths).
- `www/images/logo-textmode.svg`: Reference logo (editable text version).

## Conventions
- Keep HTML references consistent and relative to each HTML file:
  - `www/index.html`:
    - Stylesheet path: `style/main.css`
    - Logo path: `images/logo.svg`
  - `www/html/stories.html` and `www/html/links.html`:
    - Stylesheet path: `../style/main.css`
    - Logo path: `../images/logo.svg`
  - `www/html/links.html`:
    - Data path: `../data/links.json`
- Prefer editing `www/images/logo-textmode.svg` for logo text/layout experiments.
- Keep `www/images/logo.svg` as the stable rendered output for cross-platform consistency.

## Logo Workflow
1. Make visual/logo text changes in `www/images/logo-textmode.svg`.
2. Convert text to paths for production output in `www/images/logo.svg`.
3. Preserve transparent background and current tight crop unless asked otherwise.

## Change Log
- `2026-03-08`: Reference logo file renamed from `www/images/logo-test.svg` to `www/images/logo-textmode.svg`.
- `2026-03-08`: `www/stories.html` moved to `www/html/stories.html`; navigation and relative paths updated.
- `2026-03-08`: Added JSON-driven links page at `www/html/links.html` using `www/data/links.json`.

## Editing Guidelines
- Make minimal, targeted changes.
- Do not introduce new unused assets.
- Do not rename key files or directories unless explicitly requested.
- Preserve accessibility attributes like `alt`, `title`, and `desc` when modifying logos or markup.

## Verification
- After edits, verify:
  - `www/index.html` still loads `style/main.css`.
  - `www/html/stories.html` and `www/html/links.html` still load `../style/main.css`.
  - `www/html/links.html` still loads `../style/main.css` and fetches `../data/links.json`.
  - All pages still reference the logo using correct relative paths for their directory.
  - Clicking the logo takes users to `index.html` on every page.
  - The nav `Stories` item on `www/index.html` points to `html/stories.html`.
  - The nav `Links` item on `www/index.html` and `www/html/stories.html` points to `html/links.html` and `links.html` respectively.
  - For `Local Accounts` entries in `www/data/links.json`, `username` remains populated and renders as `username: <site title>` on `www/html/links.html`.
  - No broken relative paths were introduced.
