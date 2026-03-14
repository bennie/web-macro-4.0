# Current State

## Project
- Directory: `/home/phil/work/sizeviewer`
- Application file: `index.html`
- Reference assets: `reference-images/`
- Avatar assets: `avatar-images/`

## Implemented UI
- Left-side vertical scale fixed to viewport:
  - Bottom is `0`
  - Top is dynamic based on current height behavior
  - Scale label can be `inches`, `feet`, or `miles`
  - Scale renders with no more than `20` divisions
- Scenic green/black gradient viewport background via `--bg`.
- HTML title: `Sizeviewer`.
- Main heading: `Sizeviewer`.
- Top-right control panel includes:
  - `Add image`
  - `Bigger`
  - `Smaller`
  - `Reset`
- Control panel is always on top (`z-index: 1000`).
- Lower-left two-line status display:
  - `Status:`
  - `Height: ...`
- Watermark logo fixed near the top-left of the content area.

## Image Upload Flow
- `Add image` opens a centered modal dialog.
- Dialog contains:
  - `Choose image`
  - hidden image file input (`accept="image/*"`)
  - `Height` numeric input (default `20`) with `feet` unit label
  - preview area
  - `Ok` button
- Dialog closes by `Ok` or overlay click.
- On close with a selected image:
  - Image is placed center-bottom of viewport
  - Image height is mapped to current scale
  - Transparent PNGs render without an added frame/background/border

## Size Controls
- `Bigger`, `Smaller`, and `Reset` start disabled.
- They become enabled after an image is placed.
- `Bigger`: increases current height by `10%`.
- `Smaller`: decreases current height by `10%`.
- `Reset`: restores to initial dialog default (`20`).
- All size changes immediately update placed image and references.

## Scale and Unit Logic
- Scale max grows to `ceil(height * 1.1)` when height exceeds current scale max.
- Scale max shrinks to `ceil(height * 1.1)` when height drops below `40%` of current scale max.
- Unit mode by current height:
  - `< 5` feet: scale labels shown in `inches` (`feet * 12`)
  - `5` to `2500` feet: scale labels shown in `feet`
  - `> 2500` feet: scale labels shown in `miles` (`feet / 5280`)
- Tick spacing uses a `1/2/5 x 10^n` strategy to keep divisions <= `20`.

## Status Formatting
- Displayed height is rounded for status text.
- Feet in status use comma formatting when large.
- In miles mode:
  - default: `Height: X miles (Y feet)`
  - above `100,000` feet: miles only (`Height: X miles`)

## Reference Images (Lower Right)
- Displays the two nearest references in lower-right based on current placed-image height.
- Reference images are bottom-aligned and scale-mapped to the same dynamic scale.
- Heights are loaded from matching JSON files in `reference-images/` when available.

## Additional Reference Assets
- `reference-images/empire-state.png`
- `reference-images/empire-state.json` (`height: 1454`)
- `reference-images/great-pyramid.png` updated to a transparent-outline/light-grey fill version
- `reference-images/nancy-50ft-woman.png` updated to a transparent cutout
- `reference-images/nancy-50ft-woman.json` now names `Nancy Archer (50ft Woman)`
- `reference-images/king-kong-skull-island-2017.png`
- `reference-images/king-kong-skull-island-2017.json` (`height: 104`)
- `avatar-images/Bennie-Zoot.png` with transparent background and light-grey fill

## Repo Hygiene
- `.gitignore` ignores:
  - `.numba-cache/`
  - `.u2net/`
  - `.venv-rembg/`

## Notes
- No commit was created during this session.
