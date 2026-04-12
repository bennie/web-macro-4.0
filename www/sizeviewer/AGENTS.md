# Current State

## Project
- Directory: `/home/phil/work/web-macro-4.0/www/sizeviewer`
- Main files:
  - `index.html`: manual lineup mode
  - `grow-shrink.html`: original single-figure grow/shrink mode
- Shared script:
  - `shared/sizeviewer-shared.js`
- Shared avatar data:
  - `avatar-images/avatars.json`
- Reference assets:
  - `reference-images/`
- Avatar assets:
  - `avatar-images/`

## Page Split
- `index.html` is no longer the old auto-sizing single-character app.
- `index.html` is now a manual lineup viewer that can place up to `3` figures at once.
- `grow-shrink.html` contains the original auto-mode experience with the richer size-adjustment workflow.
- `index.html` links to `grow-shrink.html` through a `Grow/Shrink Mode` control.

## Shared Avatar Catalog
- Both `index.html` and `grow-shrink.html` load selectable characters from `avatar-images/avatars.json`.
- Both pages also load shared measurement, formatting, scale, reference, and wheel helpers from `shared/sizeviewer-shared.js`.
- Character loading is asynchronous on startup.
- `Select Character` starts disabled until the avatar JSON loads.
- If the JSON load fails, the chooser shows a fallback error message instead of appearing blank.
- Current shared avatars are:
  - `Jennifur Rae (Stage 1)` through `Jennifur Rae (Stage 7)`
  - `Cassie`
  - `Bennie Zoot`
  - `Arilin`
  - `Alistor`

## Manual Lineup App (`index.html`)

### Layout
- Left fixed vertical scale with translucent white backing.
- Top header status bar.
- Bottom footer status bar.
- Upper-right control panel.
- Center intro panel that disappears once any figure is placed.
- Ghosted MacroPhile logo below the header bar.
- Placed figures are allowed to visually overlap the header bar area.

### Header/Footer
- Top bar shows:
  - `Scale height`
  - a metric/imperial toggle button
  - `Slots: Up to 3 figures`
  - `Mode: Manual lineup`
- Bottom bar is used for labels under the placed images.
- Footer labels are positioned dynamically from each image's actual rendered location, not fixed slots.

### Controls
- First row:
  - `Select Character`
  - `Select Reference`
  - `OR`
  - `Upload Image`
- Second row:
  - `Reset`
  - `Grow/Shrink Mode`
- `Reset` clears all placed figures, restores the intro panel, and resets the scale to the startup default.

### Placement Behavior
- The lineup accepts up to `3` total figures from any combination of:
  - character selection
  - reference selection
  - image upload
- Figures appear left-to-right in insertion order.
- If a fourth figure is added, the oldest placed figure is discarded.
- Each figure is scaled from its own real height in meters against the shared viewport scale.
- Figures are bottom-aligned to the ground line.
- Image dimensions are recalculated from available viewport height so they preserve aspect ratio during resize and wheel zoom.

### Intro Panel
- Intro title is `Sizeviewer`.
- Intro text currently says:
  - `Select a character, reference image or upload your own. It will place the image in the viewer to compare. You can place up to three images.`
  - `Mouse-wheel will also resize the scale.`
- The HTML document title is `Macrophile | SizeViewer`.

### Character Chooser
- Uses a `3`-column scrolling grid.
- Sorted from smallest to largest by `heightMeters`.

### Reference Chooser
- Enabled in manual lineup mode.
- Uses a `3`-column scrolling grid.
- Sorted from largest to smallest by `heightMeters`.
- Choosing a reference places it into the same shared lineup used by characters and uploads.

### Upload Flow
- `Upload Image` opens a modal.
- User can:
  - pick a local image
  - preview it
  - enter the intended height in the current unit system
- Closing via `Place` places the uploaded image into the shared lineup.

### Scale/Units
- Internal sizing is meter-native.
- Manual lineup starts with an imperial default display and a header toggle of `Use metric` / `Use imperial`.
- The metric toggle updates:
  - scale labels
  - chooser labels
  - footer labels
  - header `Scale height`
- Mouse wheel changes the viewport scale directly:
  - wheel up zooms in by decreasing the scale height
  - wheel down zooms out by increasing the scale height
  - wheel is ignored while modals are open
  - wheel is ignored when no figures are placed
  - wheel is ignored over the control panel

## Auto Mode (`grow-shrink.html`)
- Still contains the original sizeviewer behavior:
  - single active main figure
  - upload flow
  - size-changing controls
  - nearest reference image comparison
  - metric/imperial toggle
  - wheel-based size changes
- It now uses the same top and bottom status bar structure as the manual-lineup page.
- The visible page heading is `Grow/Shrink`.
- The intro text is displayed inside the same centered intro-panel style used by the main Sizeviewer page.
- The intro panel hides once an image is placed.
- The HTML document title is `Macrophile | Grow/Shrink`.
- It now also loads avatars from the shared `avatar-images/avatars.json`.

### Grow/Shrink Header/Footer
- Top bar shows:
  - `Scale height`
  - a metric/imperial toggle button
  - `Slots: 1 figure`
  - `Mode: Grow/Shrink`
- Bottom bar contains the current `Status / Height` readout.

## Reference System
- Reference metadata is still sourced from `reference-images/` JSON files where available.
- Metadata prefers `heightMeters` and falls back to legacy foot-based `height` values.
- Reference categories in use include:
  - `creature`
  - `Kaiju`
  - `building`
  - `mountain`
  - `planet`
  - `object`
  - `cell`
  - `atom`

## Assets
- `avatar-images/Bennie-Zoot.png` is the trimmed-alpha Bennie source derived from Dropbox `ZootSuitBennie_01-alpha.png`.
- `avatar-images/Cassie.png` is a trimmed alpha PNG derived from Dropbox `Cassie.png`.
- `avatar-images/Arilin.png` is a trimmed alpha PNG.
- `avatar-images/jennifur-rae-*.png` are avatar-only assets, not reference images.

## Linting
- The repo-root ESLint setup still lints `sizeviewer` through:
  - `npm run lint:sizeviewer`
- The repo-local pre-commit hook runs that linter automatically.

## Notes
- When updating avatars, prefer editing `avatar-images/avatars.json` instead of duplicating avatar metadata inline in either HTML file.
- When updating shared scale/unit/catalog behavior, prefer editing `shared/sizeviewer-shared.js` instead of duplicating changes across both pages.
- When changing manual-lineup behavior, check both `index.html` and `grow-shrink.html` before assuming logic is shared.
