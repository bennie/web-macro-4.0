# Sizeviewer Requirements

This document describes the current functional requirements for `www/sizeviewer` so the app can be reconstructed in Codex from scratch.

## Scope
- Build a single-page browser app in [`index.html`](/home/phil/work/web-macro-4.0/www/sizeviewer/index.html).
- Keep all logic client-side in plain HTML, CSS, and JavaScript.
- Use local asset folders:
  - `reference-images/`
  - `avatar-images/`

## Core Purpose
- The app displays one main figure anchored to the bottom of the viewport.
- The user can scale that figure up and down.
- The app compares the figure against reference objects shown at the lower right.
- The left side shows a vertical scale that updates with the current size range.

## Main Layout
- Full-viewport visual scene.
- Left edge:
  - fixed vertical scale
  - bottom labeled `0`
  - dynamic unit label at the top of the scale
- Top-right:
  - floating control panel
- Lower-left:
  - two-line status text
- Lower-right:
  - up to 3 reference images with labels
- Top-left:
  - watermark/logo

## Visual Style
- Title and heading are `Sizeviewer`.
- Background uses a scenic green/black gradient, not a flat color.
- Control panel is dark, semi-opaque, and always above content.
- Reference and avatar PNGs should render as-is without forced borders or frames.

## Control Panel
- Include these controls:
  - `Add image`
  - `Select character`
  - `Use metric` / `Use imperial` toggle
  - `Choose Reference Images`
  - `Bigger`
  - `Smaller`
  - `Reset`
- `Bigger`, `Smaller`, and `Reset` start disabled.
- Those three become enabled once a main image is placed.

## Main Image Placement
- Main image is always bottom-aligned to the viewport.
- Main image should be horizontally centered.
- Scaling is based on the image’s real-world height, not width.
- `Reset` restores the placed image’s original height.
- If the current image came from an avatar, `Reset` restores that avatar’s defined height.

## Add Image Flow
- `Add image` opens a modal dialog.
- Dialog contains:
  - button to choose an image file
  - hidden file input with `accept="image/*"`
  - numeric height input
  - live preview area
  - `Ok` button
- Default imported-image height is `2 meters`.
- Input unit label must follow the active measurement system.
- Closing the modal with a valid selected image places the image into the scene.
- Overlay click should also close the modal.

## Avatar Flow
- `Select character` opens a modal showing avatar choices.
- Current avatar catalog includes at least:
  - `Bennie-Zoot.png`
  - `Alistor.png`
- Clicking an avatar places it immediately.
- Avatar entries carry predefined real-world heights.

## Internal Measurement Model
- All internal state and calculations are meter-native.
- Any legacy foot-based reference data must be converted to meters at load time.
- The app must support both metric and imperial display systems without changing internal storage units.

## User Size Changes
- `Bigger` increases current height by `10%`.
- `Smaller` decreases current height by `10%`.
- Metric minimum character size is `1 nm`.
- Imperial minimum character size is also `1 nm`, converted through feet for the input/control path.

## Viewport Scale Behavior
- Default viewport maximum is `4 meters`.
- The viewport scale maximum grows when the main character exceeds the current scale.
- Growth target is approximately `height * 1.1`.
- For heights `>= 1 meter`, growth can round with `ceil(height * 1.1)`.
- For heights below `1 meter`, use a nice-step expansion instead of rounding everything up to `1`.
- The viewport scale shrinks when the main character drops below `35%` of the current scale height.
- The minimum viewport scale maximum is `1.5 nm`.
- If the main character height falls at or below the minimum-scale threshold, the viewport should automatically snap to that minimum viewport scale.

## Scale Rendering
- Scale should render no more than `20` divisions.
- Tick spacing uses a `1 / 2 / 5 x 10^n` nice-step strategy.
- Major tick labels should prefer even/clean values.
- Supported scale units:
  - metric side: `nm`, `um`, `mm`, `cm`, `m`, `km`
  - imperial side: `nm`, `um`, `mm`, `in`, `ft`, `mi`

## Measurement System Breakpoints
- Metric:
  - `< 0.000001 m` -> `nm`
  - `< 0.001 m` -> `um`
  - `< 0.1 m` -> `mm`
  - `< 1.1 m` -> `cm`
  - `< 2500 m` -> `m`
  - `>= 2500 m` -> `km`
- Imperial:
  - below `0.2 inches` -> use metric tiny units `mm`, `um`, `nm`
  - below `3 feet` -> `in`
  - below `2500 feet` -> `ft`
  - `>= 2500 feet` -> `mi`

## Status Formatting
- Lower-left status shows:
  - `Status:`
  - `Height: ...`
- Metric formatting:
  - use `nm`, `um`, `mm`, `cm`, `m`, or `kilometers` depending on current height
  - meter values below `4 meters` show `2` decimal places
  - values at `1000` and above use comma separators
  - kilometer values at `1000` and above show no decimal places
- Imperial formatting:
  - below `0.2 inches` switch to `mm`, `um`, or `nm`
  - below `12 inches` show fractional inches with up to `2` decimal places
  - from `12 inches` up to `3 feet` show inches only, rounded to whole inches
  - from `3 feet` up to `10 feet` show mixed feet/inches, for example `6 foot 6 inches`
  - from `10 feet` upward show feet, then miles at large values
  - values at `1000` and above use comma separators
  - mile values at `1000` and above show no decimal places
  - above `100,000 feet`, miles display without the feet parenthetical

## Reference Image System
- Show up to 3 nearest reference objects by absolute height difference.
- Reference objects are bottom-aligned and scaled against the same current viewport scale as the main image.
- Each reference has:
  - `name`
  - `fileBase`
  - `heightMeters`
  - optional `category`
- Metadata should load from matching JSON files in `reference-images/` when available.
- Prefer JSON `heightMeters`.
- If only legacy `height` exists, interpret it as feet and convert.
- Preserve JSON `category` when present.

## Reference Visibility Rules
- Only checked references from the chooser may appear in the lower-right comparison set.
- References larger than `3x` the current viewport scale must not be shown.
- Reference labels use the active measurement system.
- Labels include category when available, using the format:
  - `Name [category]: value`

## Reference Chooser
- `Choose Reference Images` opens a modal dialog.
- Modal shows every reference as an icon card with:
  - preview image
  - checkbox
  - name
  - category/size text
- Layout is a fixed `4`-column grid.
- The chooser modal is wider than the upload modal so 4 columns fit comfortably.
- Sort chooser entries from largest to smallest by `heightMeters`.
- Toggling a checkbox immediately updates which references are eligible for display.

## Default Selected Reference Set
- The default active set must include at least:
  - `Man`
  - `Woman`
  - `Kodiak Bear`
  - `Atom`
  - `Bacteria`
  - `Red Blood Cell`
  - `Pollen`
  - `Die`
  - `Egg`
  - `Basketball`
  - `King Kong (1933)`
  - `Nancy Archer (50ft Woman)`
  - `Godzilla (1954)`
  - `Godzilla Earth (2018)`
  - all `building` references
  - `Mount Everest`
  - `Pluto`
  - `Moon`
  - `Earth`
  - `Uranus`
  - `Jupiter`
  - `Sun`

## Reference Categories
- Current categories in use include:
  - `creature`
  - `Kaiju`
  - `building`
  - `mountain`
  - `planet`
  - `object`
  - `cell`
  - `atom`

## Important Reference Entries
- Buildings:
  - `Epcot Center`
  - `Great Pyramid`
  - `Washington Monument`
  - `Eiffel Tower`
  - `Sears Tower`
  - `CN Tower`
  - `Empire State Building`
- Mountains:
  - `Mount Rainier`
  - `Mount Everest`
- Planetary / astronomical:
  - `Mercury`
  - `Mars`
  - `Pluto`
  - `Moon`
  - `Earth`
  - `Jupiter`
  - `Uranus`
  - `Neptune`
  - `Sun`
- Small-scale references:
  - `Basketball` = `0.23876 m`
  - `Egg` = `0.056 m`
  - `Die` = `0.016 m`
  - `Pollen` = `0.0001 m`
  - `Red Blood Cell` = `0.000007 m`
  - `Bacteria` = `0.000001 m`
  - `Atom` = `0.0000000001 m`

## Asset Expectations
- Reference images should generally be tightly cropped PNGs with transparent outside regions.
- Bennie’s current avatar asset is a trimmed alpha PNG derived from `ZootSuitBennie_01-alpha.png`.
- Many reference images are prepared from Wikimedia or Dropbox source art and then cleaned into transparent PNGs.

## Implementation Notes
- Keep the app as a single-file HTML app unless there is a strong reason not to.
- Plain DOM APIs are sufficient; no framework is required.
- Keep the existing local JSON-per-reference pattern.
- Keep all calculations deterministic and synchronous on the client side.

## Verification
- `node --check` should pass when run against the inline script extracted from `index.html`.
- `npm run lint:sizeviewer` should pass from the repository root.
- The repo-local pre-commit hook should continue to run the linter.
