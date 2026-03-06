# Current State

## Project
- Directory: `/vagrant/js`
- Primary file: `index.html`
- Reference assets: `/vagrant/js/reference-images`

## Implemented UI
- Left-side vertical scale fixed to viewport:
  - Bottom is `0`
  - Top is dynamic based on current height behavior
  - Scale label can be `inches`, `feet`, or `miles`
  - Scale renders with no more than `20` divisions
- Dark grey viewport background (`#3f3f46`).
- Main heading: `Sizeviewer Demo`.
- Top-right control panel buttons:
  - `Add image`
  - `Bigger`
  - `Smaller`
  - `Reset`
- Lower-left two-line status display:
  - `Status:`
  - `Height: ...`
- Right-side reference image:
  - `reference-images/man.png`
  - Bottom-right anchored
  - Height mapped against the same scale as the main image

## Control Button Behavior
- `Bigger`, `Smaller`, and `Reset` start disabled.
- They are enabled only after an image is added/placed.
- `Bigger`: increases by `10%` of current value.
- `Smaller`: decreases by `10%` of current value.
- `Reset`: restores to initial dialog height default (`20`).
- All changes immediately resize the placed image.

## Image Upload Flow
- `Add image` opens a centered modal dialog.
- Dialog contains:
  - `Choose image`
  - hidden image file input (`accept="image/*"`)
  - `Height` numeric input (default `20`) followed by `feet`
  - preview area
  - `Ok` button
- Dialog closes by `Ok` or overlay click.
- On close with a selected image:
  - Image is placed center-bottom of main viewport
  - Height is applied relative to current scale

## Scale and Unit Logic
- If height exceeds current scale max, scale max becomes `ceil(height * 1.1)`.
- If height drops below `10%` of current scale max, scale max resets to `ceil(height * 1.1)`.
- Unit mode by current height:
  - `< 5` feet: scale labels display `inches` (`feet * 12`)
  - `5` to `2500` feet: scale labels display `feet`
  - `> 2500` feet: scale labels display `miles` (`feet / 5280`)
- Tick spacing uses a `1/2/5 x 10^n` strategy to keep total divisions <= `20`.

## Status Formatting
- Status height value is rounded for display.
- Feet values in status use comma formatting when large.
- In miles mode (`> 2500` feet):
  - default: `Height: X miles (Y feet)`
  - above `100,000` feet: show miles only (`Height: X miles`)

## Reference Image Data
- `reference-images/man.json` contains `{ "height": 6 }`.
- `reference-images/woman.json` contains `{ "height": 5 }`.
- App currently loads `man.json` and applies `man.png` height using the same `scaleMax` mapping.

## Implementation Notes
- Selected image is read using `FileReader` data URL.
- Height input is sanitized to minimum `1`.
- No commit has been created in this session.
