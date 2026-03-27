# Software Requirements Specification

## Product
- Product name: `Sizeviewer`
- Implementation target: single-page web application in `www/sizeviewer/index.html`
- Runtime model: client-side HTML, CSS, and JavaScript only

## Purpose
- Allow a user to place one main image into a scaled scene.
- Let the user resize that image across a very large range of sizes.
- Show the main image against comparable reference objects.
- Support both imperial and metric presentation while keeping the internal model meter-native.

## Files And Assets
- Main application file:
  - `www/sizeviewer/index.html`
- Reference image directory:
  - `www/sizeviewer/reference-images/`
- Avatar image directory:
  - `www/sizeviewer/avatar-images/`
- Reference metadata format:
  - one optional JSON file per reference image, stored beside the PNG

## User Interface

### Overall Layout
- The application shall render as a full-viewport scene.
- The application shall show a fixed vertical measurement scale on the left side.
- The application shall show a floating control panel in the upper-right.
- The application shall show a status readout in the lower-left.
- The application shall show up to three reference figures in the lower-right.
- The application shall show a watermark logo near the upper-left content area.

### Main Heading And Intro
- The page title shall be `Sizeviewer`.
- The main heading shall be `Sizeviewer`.
- The intro sentence shall read `Upload an image to view and shift its size.`
- That intro sentence shall disappear after a main image is placed, whether placement came from upload or avatar selection.

### Visual Style
- The scene background shall use a scenic green/black gradient.
- The control panel shall use a dark, semi-opaque style and remain above the scene.
- Main images, avatars, and reference images shall render without added decorative frames or borders.

## Control Panel Requirements
- The control panel shall include:
  - `Add image`
  - `Select character`
  - `Use metric` / `Use imperial`
  - `Choose Reference Images`
  - `Bigger`
  - `Smaller`
  - `Reset`
- `Bigger`, `Smaller`, and `Reset` shall start disabled.
- Those three controls shall become enabled after a main image is placed.

## Main Image Behavior
- The main image shall be bottom-aligned to the viewport.
- The main image shall be horizontally centered in the scene.
- The main image shall scale by real-world height.
- The image width shall remain automatic.
- `Reset` shall restore the originally placed height of the current main image.
- If the current image came from the avatar chooser, `Reset` shall restore that avatar’s defined height.

## Upload Flow
- Selecting `Add image` shall open an upload modal.
- The upload modal shall include:
  - a `Choose image` action
  - a hidden file input with `accept="image/*"`
  - a numeric height input
  - a unit label bound to the active measurement system
  - a preview area
  - an `Ok` button
- The default imported-image height shall be `2 meters`.
- Closing the upload modal with a selected image shall place that image in the scene.
- Clicking the overlay outside the upload modal shall also close it and place the image if one is ready.

## Avatar Flow
- Selecting `Select character` shall open a character chooser modal.
- The character chooser shall:
  - use a fixed 3-column grid
  - fit within the viewport
  - scroll vertically when content exceeds available height
  - sort avatars from smallest to largest by height
- Selecting an avatar shall place it immediately into the scene.
- Avatar entries shall each have a predefined `heightMeters` value.

## Avatar Catalog
- The current avatar set shall include at least:
  - `Jennifur Rae (Stage 1)` at `1.347216 m`
  - `Jennifur Rae (Stage 2)` at `2.7432 m`
  - `Bennie Zoot` at `3.5 m`
  - `Jennifur Rae (Stage 3)` at `8.2296 m`
  - `Arilin` at `24.384 m`
  - `Jennifur Rae (Stage 4)` at `32.9184 m`
  - `Jennifur Rae (Stage 5)` at `164.592 m`
  - `Jennifur Rae (Stage 6)` at `987.552 m`
  - `Alistor` at `1780 m`
  - `Jennifur Rae (Stage 7)` at `6912.864 m`

## Internal Measurement Model
- All internal calculations and stored heights shall use meters.
- Any legacy reference metadata field named `height` shall be interpreted as feet and converted to meters.
- Switching between metric and imperial shall only change presentation and input interpretation, not internal storage units.

## Size Adjustment Behavior
- `Bigger` shall increase current height by `10%`.
- `Smaller` shall decrease current height by `10%`.
- The metric minimum character size shall be `1 nm`.
- The imperial minimum character size shall also be `1 nm`, converted through feet for input and clamping.
- Mouse wheel support shall be available when a main image is placed.
- Mouse wheel behavior shall be:
  - wheel up increases size
  - wheel down decreases size
  - it shall use the same size-step logic as `Bigger` and `Smaller`
  - it shall be ignored while any modal is open
  - it shall be ignored when no main image is placed
  - it shall be ignored when the pointer is over the control panel
- Wheel input shall use accumulated deltas with a threshold rather than direct raw-delta scaling.

## Viewport Scale Requirements
- The default viewport scale maximum shall be `4 meters`.
- The viewport scale shall grow when the current image height exceeds the current scale maximum.
- The scale growth target shall be approximately `height * 1.1`.
- For heights at or above `1 meter`, scale growth may round using `ceil(height * 1.1)`.
- For heights below `1 meter`, scale expansion shall use a nice-step progression instead of rounding directly to `1`.
- The viewport scale shall shrink when the current image height drops below `35%` of the current scale maximum.
- The minimum viewport scale maximum shall be `1.5 nm`.
- If the current image height is at or below the minimum viewport-scale threshold, the scale shall snap to the minimum viewport scale maximum.

## Scale Rendering Requirements
- The vertical scale shall render no more than `20` tick divisions.
- Tick spacing shall use a `1 / 2 / 5 x 10^n` nice-step strategy.
- Major tick labels shall favor clean values.
- The scale shall support these display units:
  - metric: `nm`, `um`, `mm`, `cm`, `m`, `km`
  - imperial: `nm`, `um`, `mm`, `in`, `ft`, `mi`

## Unit Breakpoints

### Metric
- `< 0.000001 m` shall display as `nm`
- `< 0.001 m` shall display as `um`
- `< 0.1 m` shall display as `mm`
- `< 1.1 m` shall display as `cm`
- `< 2500 m` shall display as `m`
- `>= 2500 m` shall display as `km`

### Imperial
- below `0.2 inches` shall display using `mm`, `um`, or `nm`
- below `3 feet` shall display as `in`
- below `2500 feet` shall display as `ft`
- at or above `2500 feet` shall display as `mi`

## Status Readout Requirements
- The status readout shall appear in the lower-left.
- It shall contain:
  - `Status:`
  - `Height: ...`

### Metric Status Formatting
- Metric status shall use `nm`, `um`, `mm`, `cm`, `m`, or `kilometers` according to the active breakpoints.
- Meter values below `4 meters` shall show `2` decimal places.
- Values at `1000` and above shall use comma separators.
- Kilometer values at or above `1000` shall show no decimal places.

### Imperial Status Formatting
- Below `0.2 inches`, status shall switch to `mm`, `um`, or `nm`.
- Below `12 inches`, inches may show fractional values with up to `2` decimal places.
- From `12 inches` up to `3 feet`, values shall show inches only.
- From `3 feet` up to `10 feet`, values shall show mixed feet and inches.
- At larger sizes, values shall show feet, then miles.
- Values at `1000` and above shall use comma separators.
- Mile values at or above `1000` shall show no decimal places.
- Above `100,000 feet`, miles shall display without a feet parenthetical.

## Reference Image System
- The application shall support a reference catalog displayed in the lower-right comparison area.
- Up to three nearest references shall be shown, based on absolute height difference from the current main image.
- Reference figures shall be bottom-aligned and scaled against the same viewport scale as the main image.
- Each reference shall support:
  - `name`
  - `fileBase`
  - `heightMeters`
  - optional `category`
- Reference metadata shall load from `reference-images/<fileBase>.json` when present.
- Reference JSON shall prefer `heightMeters`.
- Reference JSON may also provide `name` and `category`.

## Reference Visibility Rules
- Only references selected in the chooser shall be eligible for display.
- References larger than `3x` the current viewport scale shall not be displayed.
- Reference labels shall follow the active measurement system.
- If a reference has a category, the label shall use the format:
  - `Name [category]: value`

## Reference Chooser
- Selecting `Choose Reference Images` shall open a reference chooser modal.
- The chooser shall show every reference as an icon card with:
  - preview image
  - checkbox
  - name
  - category and/or size text
- The chooser shall use a fixed 4-column grid.
- The chooser modal shall be wider than the character chooser modal.
- References in the chooser shall be sorted from largest to smallest by `heightMeters`.
- Toggling a checkbox shall immediately update which references are eligible for display.

## Default Selected Reference Set
- The default active reference set shall include at least:
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
- Supported categories shall include at least:
  - `creature`
  - `Kaiju`
  - `building`
  - `mountain`
  - `planet`
  - `object`
  - `cell`
  - `atom`

## Important Reference Inventory

### Buildings
- `Epcot Center`
- `Great Pyramid`
- `Washington Monument`
- `Eiffel Tower`
- `Sears Tower`
- `CN Tower`
- `Empire State Building`

### Mountains
- `Mount Rainier`
- `Mount Everest`

### Large Astronomical / Planetary References
- `Mercury` at `4,879,400 m`
- `Mars` at `6,779,000 m`
- `Pluto` at `2,376,600 m`
- `Moon` at `3,474,000 m`
- `Earth` at `12,742,000 m`
- `Jupiter` at `139,820,000 m`
- `Uranus` at `50,724,000 m`
- `Neptune` at `49,244,000 m`
- `Sun` at `1,392,700,000 m`

### Small References
- `Basketball` at `0.23876 m`
- `Egg` at `0.056 m`
- `Die` at `0.016 m`
- `Pollen` at `0.0001 m`
- `Red Blood Cell` at `0.000007 m`
- `Bacteria` at `0.000001 m`
- `Atom` at `0.0000000001 m`

## Asset Requirements
- Reference images should generally be tightly cropped PNGs with transparent outside regions.
- Avatar images should generally be tightly cropped PNGs with transparent outside regions.
- Bennie’s current avatar asset shall remain a trimmed alpha PNG derived from `ZootSuitBennie_01-alpha.png`.
- Arilin shall be represented by a trimmed alpha PNG derived from `Arilin_SizeViewer_Pose_01.png`.
- Jennifur Rae stage avatars shall be represented by trimmed alpha PNGs derived from the supplied Dropbox sizeviewer images.

## Implementation Constraints
- The product should remain a single-file app unless there is a strong reason to split it.
- Plain DOM APIs are sufficient; no front-end framework is required.
- Calculations should remain deterministic and entirely client-side.
- Existing JSON-per-reference metadata loading should be preserved.

## Verification Requirements
- The JavaScript extracted from the inline script shall pass `node --check`.
- The project shall pass `npm run lint:sizeviewer` from the repository root.
- The repo-local pre-commit hook shall continue to run the linter.
