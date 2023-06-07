const TILE_SIZE_FRACTION = 0.32; // fraction of screen width
const HIDE_DURATION = 2000; // milliseconds
const PIP_WINDOW_TITLES = ["Picture-in-Picture", "Bild-im-Bild"];

// =============================================================================

const ACTIVE_PIP_WINDOWS = [];

// =============================================================================

function cloneProperties(obj) {
  const clone = {};
  for (let key in obj) {
    clone[key] = obj[key];
  }
  return clone;
}

function removePipWindow(client) {
  const index = ACTIVE_PIP_WINDOWS.indexOf(client);
  if (index > -1) {
    ACTIVE_PIP_WINDOWS.splice(index, 1);
  }
}

function calculateTileGeometry(client) {
  const cHeight = client.frameGeometry.height;
  const cWidth = client.frameGeometry.width;
  const cAspectRatio = cWidth / cHeight;
  const screenGeometry = workspace.clientArea(KWin.FullScreenArea, client);
  const cWidthNew = Math.round(TILE_SIZE_FRACTION * screenGeometry.width);
  const cHeightNew = Math.round(cWidthNew / cAspectRatio);
  const posX = screenGeometry.width - cWidthNew;
  const posY = screenGeometry.height - cHeightNew;

  return { x: posX, y: posY, height: cHeightNew, width: cWidthNew };
}

function tempMinimize() {
  const timer = new QTimer();
  timer.singleShot = true;
  timer.interval = HIDE_DURATION;
  timer.timeout.connect(() => {
    ACTIVE_PIP_WINDOWS.forEach((window) => {
      window.minimized = false;
    });
  });

  ACTIVE_PIP_WINDOWS.forEach((window) => {
    window.minimized = true;
  });

  timer.start();
}

function autotilePipWindow(client) {
  if (!PIP_WINDOW_TITLES.some((title) => client.caption.includes(title))) {
    return;
  }
  ACTIVE_PIP_WINDOWS.push(client);

  client.frameGeometry = calculateTileGeometry(client);
  client.keepAbove = true;
  client.onAllDesktops = true;
}

function manuallyTilePipWindow() {
  ACTIVE_PIP_WINDOWS.forEach((window) => {
    window.frameGeometry = calculateTileGeometry(window);
  });
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
