# Current State

## Project
- Directory: `/home/phil/work/web-macro-4.0/www/sizeviewer`
- Application file: `index.html`
- Reference assets: `reference-images/`
- Avatar assets: `avatar-images/`

## Implemented UI
- Left-side vertical scale fixed to viewport:
  - Bottom is `0`
  - Top is dynamic based on current height behavior
  - Default viewport scale max is `4` meters
  - Scale label can be `in`, `ft`, `mi`, `mm`, `cm`, `m`, or `km`
  - Scale renders with no more than `20` divisions
  - Major tick labels prefer clean "nice" steps rather than awkward fractional defaults
- Scenic green/black gradient viewport background via `--bg`.
- HTML title: `Sizeviewer`.
- Main heading: `Sizeviewer`.
- Top-right control panel includes:
  - `Add image`
  - `Use metric` / `Use imperial` toggle
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
  - `Height` numeric input
  - default imported-image height is `2` meters
  - input unit label swaps with the selected measurement system
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
- `Reset`: restores to the initial imported-image default (`2` meters).
- All size changes immediately update placed image and references.

## Scale and Unit Logic
- Internal state and calculations are meter-native.
- Scale max grows to `ceil(height * 1.1)` when height exceeds current scale max.
- Scale max shrinks to `ceil(height * 1.1)` when height drops below `10%` of current scale max.
- Imperial display modes by current height:
  - `< 5` feet: scale labels shown in `in`
  - `< 2500` feet: scale labels shown in `ft`
  - `>= 2500` feet: scale labels shown in `mi`
- Metric display modes by current height:
  - `< 0.1` meters: scale labels shown in `mm`
  - `< 1.1` meters: scale labels shown in `cm`
  - `< 2500` meters: scale labels shown in `m`
  - `>= 2500` meters: scale labels shown in `km`
- Tick spacing uses a `1/2/5 x 10^n` "nice step" strategy while keeping divisions <= `20`.

## Status Formatting
- Status text follows the active measurement system.
- Imperial status:
  - feet use comma formatting when large
  - miles mode shows `Height: X miles (Y feet)`
  - above `100,000` feet it shows miles only
- Metric status:
  - uses `mm`, `cm`, `m`, or `kilometers` depending on current height

## Reference Images (Lower Right)
- Displays the three nearest references in lower-right based on current placed-image height.
- Reference images are bottom-aligned and scale-mapped to the same dynamic scale.
- Heights are loaded from matching JSON files in `reference-images/` when available.
- JSON metadata now prefers `heightMeters` and falls back to legacy `height` values in feet.
- Reference captions follow the active measurement system.

## Additional Reference Assets
- `reference-images/earth.png` is a transparent crop derived from Wikimedia Earth imagery
- `reference-images/jupiter.png` is a transparent crop derived from Wikimedia Jupiter imagery
- `reference-images/king-kong-1933.png` is a transparent, tightly cropped black-outline/light-grey-fill replacement derived from Dropbox source art
- `reference-images/mars.png` is a transparent crop derived from Wikimedia Mars imagery
- `reference-images/mercury.png` is a transparent crop derived from Wikimedia Mercury imagery
- `reference-images/moon.png` is present with meter-based metadata
- `reference-images/neptune.png` is a transparent crop derived from Wikimedia Neptune imagery
- `reference-images/pluto.png` is a transparent crop derived from Wikimedia Pluto imagery
- `reference-images/empire-state.png`
- `reference-images/empire-state.json` (`height: 1454`)
- `reference-images/great-pyramid.png` updated to a transparent-outline/light-grey fill version
- `reference-images/nancy-50ft-woman.png` updated to a transparent cutout
- `reference-images/nancy-50ft-woman.json` now names `Nancy Archer (50ft Woman)`
- `reference-images/king-kong-skull-island-2017.png`
- `reference-images/king-kong-skull-island-2017.json` (`height: 104`)
- `reference-images/sun.png` currently uses the Wikimedia hydrogen-alpha Sun image with transparent outside pixels
- `reference-images/uranus.png` is a transparent crop derived from Wikimedia Uranus imagery
- `avatar-images/Bennie-Zoot.png` with transparent background and light-grey fill

## Current Large Body References
- `Mercury` (`4,879,400` meters)
- `Mars` (`6,779,000` meters)
- `Pluto` (`2,376,600` meters)
- `Moon` (`3,474,000` meters)
- `Earth` (`12,742,000` meters)
- `Jupiter` (`139,820,000` meters)
- `Uranus` (`50,724,000` meters)
- `Neptune` (`49,244,000` meters)
- `Sun` (`1,392,700,000` meters)

## Repo Hygiene
- `.gitignore` ignores:
  - `.numba-cache/`
  - `.u2net/`
  - `.venv-rembg/`

## Notes
- Recent work in this subtree includes meter/imperial support, updated figure assets, and a large set of planetary/astronomical reference additions.
