const tileSizeFraction = 0.32; // fraction of screen width
const hideDuration = 2000; // milliseconds
const hideShortcut = "Meta+<";
const pipWindowTitles = ["Picture-in-Picture", "Bild-im-Bild"];

// =============================================================================

let active_pip_windows = [];

// =============================================================================

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
    window.originalGeometry = {};
    for (let k in window.frameGeometry) {
      window.originalGeometry[k] = window.frameGeometry[k];
    }

    window.frameGeometry.x = -9999999;
    window.frameGeometry.y = -9999999;
  });
}

function restorePipWindowsPosition() {
  active_pip_windows.forEach((window) => {
    window.frameGeometry = window.originalGeometry;
  });
}

function tempMinimize() {
  let timer = new QTimer();
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
  client.frameGeometry = calculateTileGeometry(client);
  client.keepAbove = true;
  client.onAllDesktops = true;
}

registerShortcut(
  "HidePipWindowTemp",
  "Firefox pip: Hide window temporarily",
  hideShortcut,
  tempMinimize
);

workspace.clientAdded.connect(autotilePipWindow);
workspace.clientRemoved.connect(removePipWindow);
