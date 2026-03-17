# AGENTS.md

This file defines working rules for agents editing this repository.

## Scope
- Applies to the entire repository rooted here.

## Project Layout
- `www/index.html`: Main page.
- `www/html/stories.html`: Stories page.
- `www/html/links.html`: Links directory page (JSON-driven).
- `www/html/changes.html`: Change log page (JSON-driven).
- `www/html/legal.html`: Legal/AUP page.
- `www/data/links.json`: Link catalog data source.
- `www/data/changes.json`: Change log data source.
- `www/style/main.css`: Shared stylesheet for site pages.
- `www/macro-stat/index.cgi`: MacroStat CGI entrypoint.
- `www/templates/main-template.tmpl`: File-based HTML::Template used by MacroStat.
- `www/sizeviewer/`: Subtree project for interactive size comparison viewer.
- `lib/`: Perl modules used by MacroStat and legacy components.
- `www/images/logo.svg`: Production logo (vector paths).
- `www/images/logo-textmode.svg`: Reference logo (editable text version).
- `www/images/computer.png`: Transparent MacroStat illustration asset.

## Conventions
- Keep HTML references consistent and relative to each HTML file:
  - `www/index.html`:
    - Stylesheet path: `style/main.css`
    - Logo path: `images/logo.svg`
  - `www/html/stories.html`, `www/html/links.html`, `www/html/changes.html`, and `www/html/legal.html`:
    - Stylesheet path: `../style/main.css`
    - Logo path: `../images/logo.svg`
  - `www/html/links.html`:
    - Data path: `../data/links.json`
  - `www/html/changes.html`:
    - Data path: `../data/changes.json`
  - `www/macro-stat/index.cgi` (via template params):
    - `html_prefix`: `/`
    - `image_prefix`: `/images/`
- Site-wide nav links for these features should use absolute paths:
  - Sizeviewer: `/sizeviewer/`
  - MacroStat: `/macro-stat/`
- For MacroStat template changes, edit `www/templates/main-template.tmpl` instead of DB-backed template storage.
- Keep `www/images/computer.png` as the active MacroStat image asset (do not reintroduce `computer.gif` unless requested).
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
- `2026-03-08`: MacroStat integrated into the updated site design using file-based template `www/templates/main-template.tmpl` and Perl libs under `lib/`.
- `2026-03-08`: Added `www/sizeviewer/` as a git subtree and linked site navigation to `/sizeviewer/`.
- `2026-03-08`: Added JSON-driven change log page at `www/html/changes.html` using `www/data/changes.json`.

## Editing Guidelines
- Make minimal, targeted changes.
- Do not introduce new unused assets.
- Do not rename key files or directories unless explicitly requested.
- Preserve accessibility attributes like `alt`, `title`, and `desc` when modifying logos or markup.

## Verification
- After edits, verify:
  - `www/index.html` still loads `style/main.css`.
  - `www/html/stories.html`, `www/html/links.html`, `www/html/changes.html`, and `www/html/legal.html` still load `../style/main.css`.
  - `www/html/links.html` still loads `../style/main.css` and fetches `../data/links.json`.
  - `www/html/changes.html` still loads `../style/main.css` and fetches `../data/changes.json`.
  - All page footers still link `AUP` to `html/legal.html` (or `legal.html` from within `www/html/`).
  - All pages still reference the logo using correct relative paths for their directory.
  - Clicking the logo takes users to `index.html` on every page.
  - The nav `Stories` item on `www/index.html` points to `html/stories.html`.
  - The nav `Links` item on `www/index.html` and `www/html/stories.html` points to `html/links.html` and `links.html` respectively.
  - The nav `Sizeviewer` item on site pages points to `/sizeviewer/`.
  - The nav `MacroStat` item on site pages points to `/macro-stat/`.
  - `www/macro-stat/index.cgi` compiles (`perl -Ilib -c`) and renders through `www/templates/main-template.tmpl`.
  - For `Local Accounts` entries in `www/data/links.json`, `username` remains populated and renders as `username: <site title>` on `www/html/links.html`.
  - No broken relative paths were introduced.
