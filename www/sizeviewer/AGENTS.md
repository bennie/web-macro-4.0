# Current State

## Project
- Directory: `/home/phil/work/web-macro-4.0/www/sizeviewer`
- Main files:
  - `index.html`: manual lineup mode
  - `grow-shrink.html`: single-subject grow/shrink mode
- Shared script:
  - `shared/sizeviewer-shared.js`
- Shared avatar data:
  - `avatar-images/avatars.json`
- Reference assets:
  - `reference-images/`
- Avatar assets:
  - `avatar-images/`

## Shared Data and Logic
- Both pages load avatars from `avatar-images/avatars.json`.
- Both pages use shared helpers from `shared/sizeviewer-shared.js` for:
  - measurement constants
  - unit formatting
  - scale rendering
  - scale max sync logic
  - shared reference defaults
  - chooser message rendering
  - avatar/reference loading
  - normalized mousewheel handling
- Character loading is asynchronous on startup.
- `Select Character` starts disabled until avatar JSON loads.
- If avatar JSON fails to load, the chooser shows an error message instead of appearing blank.

## Shared Avatars
- Current shared avatars are:
  - `Jennifur Rae (Stage 1)` through `Jennifur Rae (Stage 7)`
  - `Cassie`
  - `Bennie Zoot`
  - `Arilin`
  - `Alistor`

## Manual Lineup (`index.html`)

### Purpose
- Manual lineup mode places up to `3` figures at once for side-by-side comparison.

### Layout
- Left fixed vertical scale with translucent white background.
- Top status bar.
- Bottom footer status bar.
- Upper-right control panel.
- Center intro panel that disappears once any figure is placed.
- Ghosted MacroPhile logo below the header bar.
- Placed figures may visually overlap the header bar area.

### Header/Footer
- Top bar shows:
  - `Scale height`
  - metric/imperial toggle button
  - `Slots: Up to 3 figures`
  - `Mode` pulldown
- The `Mode` pulldown navigates between:
  - `Manual lineup` -> `index.html`
  - `Grow/Shrink` -> `grow-shrink.html`
- Bottom bar shows dynamic labels under placed images based on each image’s rendered position.

### Controls
- First row:
  - `Select Character`
  - `Select Reference`
  - `or`
  - `Upload Image`
- Second row:
  - `Reset`
- The earlier `Grow/Shrink Mode` control-panel link was removed once the header mode selector was added.

### Placement Behavior
- Accepts up to `3` total figures from any combination of:
  - character selection
  - reference selection
  - image upload
- Figures appear left-to-right in insertion order.
- If a fourth figure is added, the oldest is discarded.
- Each figure is scaled from its own real height in meters against the shared viewport scale.
- Figures are bottom-aligned to the ground line.
- Image dimensions are recalculated from available viewport height so they preserve aspect ratio during resize and wheel zoom.

### Intro Panel
- Intro title is `Sizeviewer`.
- Intro text says:
  - `Select a character, reference image or upload your own. It will place the image in the viewer to compare. You can place up to three images.`
  - `Mouse-wheel will also resize the scale.`
- HTML document title is `Macrophile | SizeViewer`.

### Choosers
- Character chooser:
  - scrollable `3`-column grid
  - sorted from smallest to largest by `heightMeters`
- Reference chooser:
  - sorted from largest to smallest by `heightMeters`
  - choosing a reference places it into the same shared lineup

### Scale and Units
- Internal sizing is meter-native.
- Starts with a `4 meter` viewport scale.
- Starts in imperial display mode.
- Metric toggle updates:
  - left scale labels
  - chooser labels
  - footer labels
  - top-bar `Scale height`
- Mouse wheel changes the viewport scale directly:
  - wheel up zooms in by decreasing the scale height
  - wheel down zooms out by increasing the scale height
  - wheel is ignored while modals are open
  - wheel is ignored when no figures are placed
  - wheel is ignored over the control panel

## Grow/Shrink (`grow-shrink.html`)

### Purpose
- Grow/Shrink mode manages a single subject and a variable number of comparison references.

### Terminology
- The selected character or uploaded image is the `subject`.
- Comparison figures are `reference images`.

### Layout
- Uses the same top and bottom status-bar structure as manual lineup.
- Uses the same centered intro-panel style as manual lineup.
- HTML document title is `Macrophile | Grow/Shrink`.
- Visible intro title is `Grow/Shrink`.

### Header/Footer
- Top bar shows:
  - `Scale height`
  - metric/imperial toggle button
  - `Reference images` with `-` and `+` controls
  - `Mode` pulldown
- The `Reference images` count ranges from `1` to `10`.
- The `Mode` pulldown navigates between:
  - `Manual lineup` -> `index.html`
  - `Grow/Shrink` -> `grow-shrink.html`
- Bottom bar shows dynamic labels under the subject and displayed references.

### Controls
- First row:
  - `Select character`
  - `or`
  - `Add image`
- Separate control:
  - `Choose Reference Images`
- Size controls:
  - `Bigger`
  - `Smaller`
  - `Reset`
- Slider:
  - `Grow or Shrink by:`
  - range `1` to `100`
  - default `10`
- The old reference-count slider in the control panel was removed; reference count is adjusted only from the header bar.

### Intro Panel
- Intro text says:
  - `Select a character or upload an image to view and shit its size.`

### Reference Behavior
- No reference images are displayed until a subject has been placed.
- Reference chooser metadata is sorted from largest to smallest.
- Nearest displayed references are filtered so only enabled references can appear.
- References larger than `3x` the current viewport scale are excluded.

### Resize Sequencing
- Normal grow/shrink flow:
  - subject resizes first
  - scale sync happens after the subject resize animation
  - references refresh after a short delay
- Current subject animation duration is `750ms`.
- Reference refresh delay is `100ms`.
- Special oversize growth flow:
  - if the next subject height would exceed the current scale, the scale resets first
  - the scale reset animates for `500ms`
  - then there is a `100ms` pause
  - then the subject grows for `750ms`
  - then references refresh after the usual `100ms` delay
- While a staged grow/shrink sequence is running:
  - size buttons are disabled
  - height input is disabled
  - mousewheel resize is ignored

### Scale and Units
- Internal sizing is meter-native.
- Starts with a `4 meter` viewport scale.
- Starts in imperial display mode.
- Mousewheel resizing uses the same grow/shrink step functions as the buttons, subject to the staged timing rules above.

## Reference System
- Reference metadata is loaded from `reference-images/*.json` where present.
- Metadata prefers `heightMeters` and falls back to legacy foot-based `height`.
- Reference categories currently in use include:
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
- `avatar-images/Cassie.png` is a trimmed-alpha PNG derived from Dropbox `Cassie.png`.
- `avatar-images/Arilin.png` is a trimmed-alpha PNG.
- `avatar-images/jennifur-rae-*.png` are avatar-only assets, not reference images.

## Tooling
- Repo-root lint command for Sizeviewer:
  - `npm run lint:sizeviewer`
- Repo-local pre-commit hook runs that linter automatically.

## Notes
- When updating avatars, edit `avatar-images/avatars.json` instead of duplicating avatar metadata inline.
- When updating shared scale/unit/catalog behavior, edit `shared/sizeviewer-shared.js` where possible.
- When changing grow/shrink sequencing, check `grow-shrink.html` directly because not all behavior is shared.
