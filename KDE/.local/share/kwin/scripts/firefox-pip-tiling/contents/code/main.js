const tileSizeFraction = 0.32; // fraction of screen width
const hideDuration = 2000; // milliseconds
const pipWindowTitles = ["Picture-in-Picture", "Bild-im-Bild"];

// =============================================================================

const active_pip_windows = [];

// =============================================================================

function cloneProperties(obj) {
  const clone = {};
  for (let key in obj) {
    clone[key] = obj[key];
  }
  return clone;
}

function removePipWindow(client) {
  const index = active_pip_windows.indexOf(client);
  if (index > -1) {
    active_pip_windows.splice(index, 1);
  }
}

function calculateTileGeometry(client) {
  const cHeight = client.frameGeometry.height;
  const cWidth = client.frameGeometry.width;
  const cAspectRatio = cWidth / cHeight;
  const screenGeometry = workspace.clientArea(KWin.FullscreenArea, client);
  const cWidthNew = Math.round(tileSizeFraction * screenGeometry.width);
  const cHeightNew = Math.round(cWidthNew / cAspectRatio);
  const posX = screenGeometry.width - cWidthNew;
  const posY = screenGeometry.height - cHeightNew;

  return { x: posX, y: posY, height: cHeightNew, width: cWidthNew };
}

// =============================================================================
// ============== Flatpak firefox pip windows cannot be minimized ==============
// =============================================================================
function movePipWindowsOffScreen() {
  active_pip_windows.forEach((window) => {
    window.originalGeometry = cloneProperties(window.frameGeometry);

    window.frameGeometry.x = -9999999;
    window.frameGeometry.y = -9999999;
  });
}

function restorePipWindowsPosition() {
  active_pip_windows.forEach((window) => {
    window.frameGeometry = cloneProperties(window.originalGeometry);
  });
}

function manuallyTilePipWindow() {
  active_pip_windows.forEach((window) => {
    window.frameGeometry = cloneProperties(window.targetGeometry);
  });
}

function tempMinimize() {
  const timer = new QTimer();
  timer.singleShot = true;
  timer.interval = hideDuration;
  timer.timeout.connect(restorePipWindowsPosition);

  movePipWindowsOffScreen();
  timer.start();
}
// =============================================================================
// =============================================================================
// =============================================================================

function autotilePipWindow(client) {
  if (!pipWindowTitles.some((title) => client.caption.includes(title))) {
    return;
  }
  active_pip_windows.push(client);

  client.originalGeometry = cloneProperties(client.frameGeometry);
  client.targetGeometry = calculateTileGeometry(client);

  client.frameGeometry = cloneProperties(client.targetGeometry);
  client.keepAbove = true;
  client.onAllDesktops = true;
}

registerShortcut(
  "FF-Pip-Tiling Hide Window",
  "Firefox Pip: Hide window temporarily",
  "Meta+<",
  tempMinimize
);
registerShortcut(
  "FF-Pip-Tiling Tile Window",
  "Firefox Pip: Move window into bottom right corner",
  "Meta+Alt+3",
  manuallyTilePipWindow
);

workspace.clientAdded.connect(autotilePipWindow);
workspace.clientRemoved.connect(removePipWindow);
