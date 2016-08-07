AtonementBarDB = {}

AtonementBarDB.defaultConfig = {
  profile = {
    showCooldowns = false,
    autohide = false,
    showCounter = true,
    showTimers = true,
    width = 200,
    height = 15,
    background = "Solid",
    backgroundColor = { r = 0, g = 0, b = 0, a = 0.6 },
    border = "Pixel Border",
    borderColor = { r = 0, g = 0, b = 0, a = 1 },
    highlightBorderColor = { r = 0.141176471, g = 0.356862745, b = 0.141176471 },
    statusbar = "Solid",
    font = nil,
    raidthresholds = {
      healthy = 9,
      warning = 5,
      danger = 2,
    },
    partythresholds = {
      healthy = 5,
      warning = 3,
      danger = 1,
    },
    healthycolor = { r = 0.29804, g = 0.68627451, b = 0.31372549 },
    warningcolor = { r = 1, g = 0.59607, b = 0 },
    dangercolor = { r = 0.9568, g = 0.26274, b = 0.21176 },
    xpos = -1,
    ypos = -1,
    orientation = "horizontal"
  }
}
