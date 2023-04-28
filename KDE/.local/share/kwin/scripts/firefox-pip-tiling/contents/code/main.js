const tileSizeFraction = 0.32; // fraction of screen width
const hideDuration = 2000; // milliseconds
const hideShortcut = "Meta+<";

function calcTileGeometry(client) {
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

function tempMinimize(client) {
  let timer = new QTimer();
  timer.singleShot = true;
  timer.interval = hideDuration;
  timer.timeout.connect(() => {
    client.minimized = false;
  });

  client.minimized = true;
  timer.start();
}

function autotilePipWindow(client) {
  if ("Picture-in-Picture" !== client.caption) {
    return;
  }
  client.frameGeometry = calcTileGeometry(client);
  client.keepAbove = true;
  client.onAllDesktops = true;

  registerShortcut(
    "HidePipWindowTemp",
    "Firefox pip: Hide window temporarily (set by script)",
    hideShortcut,
    () => {
      tempMinimize(client);
    }
  );
}

workspace.clientAdded.connect(autotilePipWindow);
