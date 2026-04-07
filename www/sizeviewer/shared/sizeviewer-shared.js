(function () {
  const FEET_TO_METERS = 0.3048;
  const INCHES_PER_FOOT = 12;
  const FEET_PER_MILE = 5280;
  const METERS_PER_KILOMETER = 1000;
  const METRIC_NM_MAX_METERS = 0.000001;
  const METRIC_UM_MAX_METERS = 0.001;
  const METRIC_MM_MAX_METERS = 0.1;
  const METRIC_CM_MAX_METERS = 1.1;
  const METRIC_KM_MIN_METERS = 2500;
  const IMPERIAL_MM_MAX_METERS = (0.2 / INCHES_PER_FOOT) * FEET_TO_METERS;

  const defaultReferences = [
    { name: 'Man', fileBase: 'man', heightMeters: 6 * FEET_TO_METERS, category: 'creature' },
    { name: 'Woman', fileBase: 'woman', heightMeters: 5 * FEET_TO_METERS, category: 'creature' },
    { name: 'Kodiak Bear', fileBase: 'bear', heightMeters: 9 * FEET_TO_METERS, category: 'creature' },
    { name: 'Atom', fileBase: 'atom', heightMeters: 0.0000000001, category: 'atom' },
    { name: 'Bacteria', fileBase: 'bacteria', heightMeters: 0.000001, category: 'cell' },
    { name: 'Red Blood Cell', fileBase: 'red-blood-cell', heightMeters: 0.000007, category: 'cell' },
    { name: 'Pollen', fileBase: 'pollen', heightMeters: 0.0001, category: 'cell' },
    { name: 'Die', fileBase: 'die', heightMeters: 0.016, category: 'object' },
    { name: 'Egg', fileBase: 'egg', heightMeters: 0.056, category: 'object' },
    { name: 'Basketball', fileBase: 'basketball', heightMeters: 0.23876, category: 'object' },
    { name: 'King Kong (1933)', fileBase: 'king-kong-1933', heightMeters: 24 * FEET_TO_METERS, category: 'Kaiju' },
    { name: 'Nancy Archer (50ft Woman)', fileBase: 'nancy-50ft-woman', heightMeters: 50 * FEET_TO_METERS, category: 'Kaiju' },
    { name: 'King Kong (Skull Island 2017)', fileBase: 'king-kong-skull-island-2017', heightMeters: 104 * FEET_TO_METERS, category: 'Kaiju' },
    { name: 'Godzilla (1954)', fileBase: 'godzilla-1954', heightMeters: 165 * FEET_TO_METERS, category: 'Kaiju' },
    { name: 'Godzilla Earth (2018)', fileBase: 'godzilla-earth-2018', heightMeters: 1043.3 * FEET_TO_METERS, category: 'Kaiju' },
    { name: 'Epcot Center', fileBase: 'epcot-center', heightMeters: 180 * FEET_TO_METERS, category: 'building' },
    { name: 'Great Pyramid', fileBase: 'great-pyramid', heightMeters: 456 * FEET_TO_METERS, category: 'building' },
    { name: 'Washington Monument', fileBase: 'washington-monument', heightMeters: 555 * FEET_TO_METERS, category: 'building' },
    { name: 'Eiffel Tower', fileBase: 'eiffel', heightMeters: 1083 * FEET_TO_METERS, category: 'building' },
    { name: 'Sears Tower', fileBase: 'sears-tower', heightMeters: 1451 * FEET_TO_METERS, category: 'building' },
    { name: 'CN Tower', fileBase: 'cn-tower', heightMeters: 1815 * FEET_TO_METERS, category: 'building' },
    { name: 'Empire State Building', fileBase: 'empire-state', heightMeters: 1454 * FEET_TO_METERS, category: 'building' },
    { name: 'Mount Rainier', fileBase: 'mount-rainier', heightMeters: 4392, category: 'mountain' },
    { name: 'Mount Everest', fileBase: 'mount-everest', heightMeters: 8848.86, category: 'mountain' },
    { name: 'Mercury', fileBase: 'mercury', heightMeters: 4879400, category: 'planet' },
    { name: 'Mars', fileBase: 'mars', heightMeters: 6779000, category: 'planet' },
    { name: 'Pluto', fileBase: 'pluto', heightMeters: 2376600, category: 'planet' },
    { name: 'Moon', fileBase: 'moon', heightMeters: 3474000, category: 'planet' },
    { name: 'Earth', fileBase: 'earth', heightMeters: 12742000, category: 'planet' },
    { name: 'Jupiter', fileBase: 'jupiter', heightMeters: 139820000, category: 'planet' },
    { name: 'Uranus', fileBase: 'uranus', heightMeters: 50724000, category: 'planet' },
    { name: 'Neptune', fileBase: 'neptune', heightMeters: 49244000, category: 'planet' },
    { name: 'Sun', fileBase: 'sun', heightMeters: 1392700000, category: 'planet' }
  ];

  // Formats scale tick labels without forcing decimals for whole numbers.
  const formatScaleNumber = (value) => {
    return Number.isInteger(value) ? String(value) : String(Number(value.toFixed(2)));
  };

  // Rounds a numeric value and adds commas once it reaches four digits.
  const formatRoundedValue = (value) => {
    const roundedValue = Math.round(value);
    return roundedValue >= 1000 ? roundedValue.toLocaleString('en-US') : String(roundedValue);
  };

  // Formats a display number with optional decimals and comma grouping for large values.
  const formatDisplayNumber = (value, digits = 2) => {
    if (value >= 1000) {
      return Math.round(value).toLocaleString('en-US');
    }

    const fixedValue = Number(value.toFixed(digits));
    return fixedValue >= 1000
      ? fixedValue.toLocaleString('en-US', {
          minimumFractionDigits: 0,
          maximumFractionDigits: digits
        })
      : String(fixedValue);
  };

  // Formats inch-only values, preserving fractional inches below one foot.
  const formatInchesValue = (inchesValue) => {
    if (inchesValue < 12) {
      return Number(inchesValue.toFixed(2)).toString();
    }

    return String(Math.round(inchesValue));
  };

  // Converts a feet value into mixed whole feet and whole inches text.
  const formatFeetAndInches = (feetValue) => {
    const totalInches = Math.round(feetValue * INCHES_PER_FOOT);
    const wholeFeet = Math.floor(totalInches / INCHES_PER_FOOT);
    const remainingInches = totalInches % INCHES_PER_FOOT;

    if (remainingInches === 0) {
      return wholeFeet + ' foot';
    }

    return wholeFeet + ' foot ' + remainingInches + ' inches';
  };

  // Parses a user-entered height and clamps it to the active system minimum.
  const getClampedDisplayHeightValue = (value, system) => {
    const parsedHeight = Number(value);
    return Number.isFinite(parsedHeight)
      ? Math.max(system.minInput, parsedHeight)
      : system.defaultInputValue;
  };

  // Picks a human-friendly step size using a 1/2/5 progression.
  const getNiceStep = (minimumStep) => {
    const power = 10 ** Math.floor(Math.log10(minimumStep));
    const stepBase = minimumStep / power;
    let normalizedStep = 10;

    if (stepBase <= 1) normalizedStep = 1;
    else if (stepBase <= 2) normalizedStep = 2;
    else if (stepBase <= 5) normalizedStep = 5;

    return normalizedStep * power;
  };

  // Expands the viewport scale slightly above a target height.
  const getExpandedScaleMax = (heightMeters) => {
    if (heightMeters >= 1) {
      return Math.ceil(heightMeters * 1.1);
    }

    return getNiceStep(heightMeters * 1.1);
  };

  // Tests whether a tick value lines up with a major-step boundary.
  const isStepMultiple = (value, step) => {
    const roundedRatio = Math.round(value / step);
    return Math.abs(value - (roundedRatio * step)) < 1e-9;
  };

  // Selects the active unit mode for a meter value within a measurement system.
  const getScaleModeForMeters = (valueMeters, system) => {
    return system.scaleModes.find((mode) => valueMeters < mode.maxMeters) || system.scaleModes[system.scaleModes.length - 1];
  };

  // Draws the left-side vertical scale for the current viewport range.
  const renderScale = ({ scaleEl, labelEl, maxMeters, minScaleMaxMeters, system }) => {
    scaleEl.querySelectorAll('.tick').forEach((tick) => tick.remove());

    const safeMax = Math.max(minScaleMaxMeters, maxMeters);
    const maxDivisions = 20;
    const majorStep = getNiceStep(safeMax / 4);
    const minorStep = Math.max(getNiceStep(majorStep / 2), safeMax / maxDivisions);
    const values = [];
    const scaleMode = getScaleModeForMeters(safeMax, system);

    labelEl.textContent = scaleMode.unit;

    for (let value = 0; value <= safeMax + Number.EPSILON; value += minorStep) {
      values.push(value);
    }
    if (Math.abs(values[values.length - 1] - safeMax) > Number.EPSILON) {
      values.push(safeMax);
    }

    values.forEach((value) => {
      const tick = document.createElement('div');
      const isMajor = isStepMultiple(value, majorStep) || value === safeMax;
      tick.className = 'tick' + (isMajor ? ' major' : ' minor');
      tick.style.bottom = (value / safeMax) * 100 + '%';
      if (isMajor) {
        tick.textContent = formatScaleNumber(scaleMode.convertFromMeters(value));
      }
      scaleEl.appendChild(tick);
    });
  };

  // Chooses the next scale maximum using the shared grow/shrink threshold rules.
  const syncScaleMax = ({ heightMeters, currentScaleMaxMeters, minScaleMaxMeters, shrinkThresholdRatio = 0.35 }) => {
    const expandedFromHeight = Math.max(minScaleMaxMeters, getExpandedScaleMax(heightMeters));
    const isAboveCurrentScale = heightMeters > currentScaleMaxMeters;
    const isBelowShrinkThreshold = heightMeters < (currentScaleMaxMeters * shrinkThresholdRatio);
    const isBelowMinimumScaleThreshold = heightMeters <= minScaleMaxMeters;

    if (isBelowMinimumScaleThreshold) {
      return minScaleMaxMeters;
    }

    if (isAboveCurrentScale || isBelowShrinkThreshold) {
      return expandedFromHeight;
    }

    return currentScaleMaxMeters;
  };

  // Replaces a chooser grid with a single status or error message panel.
  const setGridMessage = (container, className, message) => {
    container.innerHTML = '';
    const note = document.createElement('div');
    note.className = className;
    note.textContent = message;
    container.appendChild(note);
  };

  // Resolves the image path for a reference catalog entry.
  const getReferenceImagePath = (reference) => 'reference-images/' + reference.fileBase + '.png';

  // Loads and validates the shared avatar catalog JSON used by both pages.
  const loadAvatarCatalog = async () => {
    const response = await fetch('avatar-images/avatars.json');
    if (!response.ok) {
      throw new Error('Avatar catalog request failed.');
    }
    const loaded = await response.json();
    return loaded.filter((avatar) => {
      return avatar
        && typeof avatar.name === 'string'
        && typeof avatar.filePath === 'string'
        && Number.isFinite(Number(avatar.heightMeters))
        && Number(avatar.heightMeters) > 0;
    }).map((avatar) => ({
      name: avatar.name.trim(),
      filePath: avatar.filePath.trim(),
      heightMeters: Number(avatar.heightMeters)
    }));
  };

  // Loads optional per-reference JSON overrides for names, sizes, and categories.
  const loadReferenceCatalog = async (baseReferences = defaultReferences) => {
    const loaded = await Promise.all(baseReferences.map(async (reference) => {
      const response = await fetch('reference-images/' + reference.fileBase + '.json');
      if (!response.ok) return reference;
      const config = await response.json();
      const parsedHeightMeters = Number(config.heightMeters);
      const parsedLegacyHeightFeet = Number(config.height);
      return {
        ...reference,
        name: typeof config.name === 'string' && config.name.trim() ? config.name.trim() : reference.name,
        category: typeof config.category === 'string' && config.category.trim() ? config.category.trim() : reference.category,
        heightMeters: Number.isFinite(parsedHeightMeters) && parsedHeightMeters > 0
          ? parsedHeightMeters
          : Number.isFinite(parsedLegacyHeightFeet) && parsedLegacyHeightFeet > 0
            ? parsedLegacyHeightFeet * FEET_TO_METERS
            : reference.heightMeters
      };
    }));

    return loaded;
  };

  // Binds normalized wheel handling that triggers stepped callbacks for up/down input.
  const bindWheelStepHandler = ({ shouldHandle, onWheelUp, onWheelDown, isBlockedTarget }) => {
    let wheelAccumulator = 0;

    document.addEventListener('wheel', (event) => {
      if (!shouldHandle()) return;
      if (isBlockedTarget && isBlockedTarget(event.target)) return;

      let delta = event.deltaY;
      if (event.deltaMode === 1) delta *= 16;
      if (event.deltaMode === 2) delta *= window.innerHeight;

      wheelAccumulator += delta;
      const threshold = 80;

      while (wheelAccumulator <= -threshold) {
        onWheelUp();
        wheelAccumulator += threshold;
      }

      while (wheelAccumulator >= threshold) {
        onWheelDown();
        wheelAccumulator -= threshold;
      }

      if (Math.abs(delta) > 0) {
        event.preventDefault();
      }
    }, { passive: false });
  };

  window.SizeviewerShared = {
    FEET_TO_METERS,
    INCHES_PER_FOOT,
    FEET_PER_MILE,
    METERS_PER_KILOMETER,
    METRIC_NM_MAX_METERS,
    METRIC_UM_MAX_METERS,
    METRIC_MM_MAX_METERS,
    METRIC_CM_MAX_METERS,
    METRIC_KM_MIN_METERS,
    IMPERIAL_MM_MAX_METERS,
    defaultReferences,
    formatScaleNumber,
    formatRoundedValue,
    formatDisplayNumber,
    formatInchesValue,
    formatFeetAndInches,
    getClampedDisplayHeightValue,
    getNiceStep,
    getExpandedScaleMax,
    isStepMultiple,
    getScaleModeForMeters,
    renderScale,
    syncScaleMax,
    setGridMessage,
    getReferenceImagePath,
    loadAvatarCatalog,
    loadReferenceCatalog,
    bindWheelStepHandler
  };
}());
