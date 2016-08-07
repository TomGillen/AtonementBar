local media = LibStub("LibSharedMedia-3.0")

AtonementBar = LibStub("AceAddon-3.0"):NewAddon("AtonementBar", "AceConsole-3.0", "AceEvent-3.0")

local getLocalSpellName = function(spellId)
  local name, rank, icon, castTime, minRange, maxRange = GetSpellInfo(spellId)
	return name
end

AtonementBar.spellIDs = {
  ["Atonement"] = { id = 194384, name = getLocalSpellName(194384) },
  ["Penance"] = { id = 47540, name = getLocalSpellName(47540) },
  ["Power Word: Shield"] = { id = 17, name = getLocalSpellName(17) },
  ["Mindbender"] = { id = 123040, name = getLocalSpellName(123040) },
  ["Halo"] = { id = 120517, name = getLocalSpellName(120517) },
  ["Schism"] = { id = 214621, name = getLocalSpellName(214621) },
  ["Rapture"] = { id = 47536, name = getLocalSpellName(47536) },
}

AtonementBar.trackedCooldowns = {
  47540,
  17,
  123040,
  120517,
  214621,
  47536
}

AtonementBar.cooldowns = { }

AtonementBar.texCoords = {0.07,0.93,0.07,0.93}

AtonementBar.frame = CreateFrame("frame", "AtonementBar", UIParent)
AtonementBar.frame:ClearAllPoints()
AtonementBar.frame:SetPoint("CENTER", UIParent)
AtonementBar.frame:SetMovable(true)
AtonementBar.frame:SetUserPlaced(true)
AtonementBar.frame:SetClampedToScreen(true)
AtonementBar.frame:Hide()

local options = {
  name = "AtonementBar",
  handler = AtonementBar,
  type = "group",
  args = {
    general = {
      name = "General",
      type = "group",
      args = {
        autohide = {
          name = "Show Only in Group",
          desc = "Show AtonementBar only when in a party or raid",
          type = "toggle",
          get = function(info) return AtonementBar.db.profile.autohide end,
          set = "SetAutohide"
        },
        showCounter = {
          name = "Show Atonement Count",
          desc = "Show a counter of the total number of active atonements",
          type = "toggle",
          get = function(info) return AtonementBar.db.profile.showCounter end,
          set = "SetShowCounter"
        },
        showTimers = {
          name = "Show Bar Timer Text",
          desc = "Show counters of the number of seconds remaining at each threshold",
          type = "toggle",
          get = function(info) return AtonementBar.db.profile.showTimers end,
          set = "SetShowTimers"
        },
        colors = {
          name = "Colors",
          type = "group",
          order = 1,
          args = {
            healthycolor = {
              name = "High Antonements Color",
              desc = "The color of the atonement bar when the number of atonements out is above the high threashold",
              type = "color",
              width = "full",
              order = 1,
              get = function(info)
                return AtonementBar.db.profile.healthycolor.r, AtonementBar.db.profile.healthycolor.g, AtonementBar.db.profile.healthycolor.b, 1
              end,
              set = "SetHealthyColor"
            },
            warningcolor = {
              name = "Medium Antonements Color",
              desc = "The color of the atonement bar when the number of atonements out is only above the medium threashold",
              type = "color",
              width = "full",
              order = 2,
              get = function(info)
                return AtonementBar.db.profile.warningcolor.r, AtonementBar.db.profile.warningcolor.g, AtonementBar.db.profile.warningcolor.b, 1
              end,
              set = "SetWarningColor"
            },
            dangercolor = {
              name = "Low Antonements Color",
              desc = "The color of the atonement bar when the number of atonements out is only above the low threashold",
              type = "color",
              width = "full",
              order = 3,
              get = function(info)
                return AtonementBar.db.profile.dangercolor.r, AtonementBar.db.profile.dangercolor.g, AtonementBar.db.profile.dangercolor.b, 1
              end,
              set = "SetDangerColor"
            }
          }
        },
        partythresholds = {
          name = "Party Atonement Thresholds",
          type = "group",
          order = 2,
          args = {
            healthy = {
              name = "High",
              desc = "The ideal number of atonements when high healing output is needed",
              type = "range",
              min = 0,
              softMax = 16,
              order = 1,
              width = "double",
              get = function(info) return AtonementBar.db.profile.partythresholds.healthy end,
              set = function(info, val) AtonementBar.db.profile.partythresholds.healthy = val end
            },
            warning = {
              name = "Medium",
              desc = "The number of atonements wanted outside of heavy damage",
              type = "range",
              min = 0,
              softMax = 16,
              order = 2,
              width = "double",
              get = function(info) return AtonementBar.db.profile.partythresholds.warning end,
              set = function(info, val) AtonementBar.db.profile.partythresholds.warning = val end
            },
            danger = {
              name = "Low",
              desc = "The minimum number of atonements that should ever be up",
              type = "range",
              min = 0,
              softMax = 16,
              order = 3,
              width = "double",
              get = function(info) return AtonementBar.db.profile.partythresholds.danger end,
              set = function(info, val) AtonementBar.db.profile.partythresholds.danger = val end
            }
          }
        },
        raidthresholds = {
          name = "Raid Atonement Thresholds",
          type = "group",
          order = 3,
          args = {
            healthy = {
              name = "High",
              desc = "The ideal number of atonements when high healing output is needed",
              type = "range",
              min = 0,
              softMax = 16,
              order = 1,
              width = "double",
              get = function(info) return AtonementBar.db.profile.raidthresholds.healthy end,
              set = function(info, val) AtonementBar.db.profile.raidthresholds.healthy = val end
            },
            warning = {
              name = "Medium",
              desc = "The number of atonements wanted outside of heavy damage",
              type = "range",
              min = 0,
              softMax = 16,
              order = 2,
              width = "double",
              get = function(info) return AtonementBar.db.profile.raidthresholds.warning end,
              set = function(info, val) AtonementBar.db.profile.raidthresholds.warning = val end
            },
            danger = {
              name = "Low",
              desc = "The minimum number of atonements that should ever be up",
              type = "range",
              min = 0,
              softMax = 16,
              order = 3,
              width = "double",
              get = function(info) return AtonementBar.db.profile.raidthresholds.danger end,
              set = function(info, val) AtonementBar.db.profile.raidthresholds.danger = val end
            }
          }
        }
      }
    },
    cooldowns = {
      name = "Cooldowns",
      type = "group",
      args = {
        enabled = {
          name = "Enabled",
          desc = "EXPERIMENTAL: Enables / disables cooldown display on the atonement bar",
          type = "toggle",
          set = "SetShowCooldowns",
          get = function(info) return AtonementBar.db.profile.showCooldowns end
        },
      }
    },
    frame = {
      name = "Frame",
      type = "group",
      args = {
        lock = {
          name = "Lock",
          desc = "Enables / disables frame lock, allowing AtonementBar to be dragged",
          type = "toggle",
          order = 1,
          get = function(info) return AtonementBar.db.profile.locked end,
          set = "SetFrameLock"
        },
        vertical = {
          name = "Vertical",
          desc = "Toggles between horizontal and vertical layouts",
          type = "toggle",
          width = "full",
          order = 2,
          get = function(info) return AtonementBar.db.profile.orientation ~= "horizontal" end,
          set = "SetVertical"
        },
        width = {
          name = "Width",
          desc = "The frame width",
          type = "range",
          softMin = 10,
          softMax = 300,
          order = 3,
          set = "SetFrameWidth",
          get = function(info) return AtonementBar.db.profile.width end
        },
        height = {
          name = "Height",
          desc = "The frame height",
          type = "range",
          softMin = 10,
          softMax = 300,
          order = 4,
          set = "SetFrameHeight",
          get = function(info) return AtonementBar.db.profile.height end
        }
      }
    }
  }
}


-- Config Setters

function AtonementBar:SetFrameLock(info, val)
  local self = AtonementBar
  self.db.profile.locked = val

  local frame = AtonementBar.frame

  if val then
    frame:EnableMouse(false)
  else
  	frame:EnableMouse(true)
  	frame:RegisterForDrag("LeftButton")
  	frame:SetScript("OnDragStart", frame.StartMoving)
  	frame:SetScript("OnDragStop", function()
      AtonementBar.db.profile.xpos = frame:GetLeft()
      AtonementBar.db.profile.ypos = frame:GetTop()
      frame:StopMovingOrSizing()
    end)
  end
end

function AtonementBar:SetAutohide(info, val)
  self.db.profile.autohide = val
  self:UpdateVisibility()
end

function AtonementBar:SetFrameWidth(info, width)
  self.db.profile.width = width
  self:SetupFrame()
end

function AtonementBar:SetFrameHeight(info, height)
  self.db.profile.height = height
  self:SetupFrame()
end

function AtonementBar:SetShowCooldowns(info, val)
  self.db.profile.showCooldowns = val

  if not val then
    for k,v in pairs(AtonementBar.cooldowns) do
      v.enabled = false
      v.flashing = false
      v.frame:Hide()
    end
  end
end

function AtonementBar:SetShowCounter(info, val)
  self.db.profile.showCounter = val
  self:SetupFrame()
end

function AtonementBar:SetShowTimers(info, val)
  self.db.profile.showTimers = val
  self:SetupFrame()
end

function AtonementBar:SetVertical(info, val)
  local changed = false
  if val then
    if self.db.profile.orientation == "horizontal" then
      self.db.profile.orientation = "vertical"
      changed = true
    end
  else
    if self.db.profile.orientation ~= "horizontal" then
      self.db.profile.orientation = "horizontal"
      changed = true
    end
  end

  if changed then
    local tmp = self.db.profile.width
    self.db.profile.width = self.db.profile.height
    self.db.profile.height = tmp
  end

  self:SetupFrame()
end

function AtonementBar:SetHealthyColor(info, r, g, b, a)
  self.db.profile.healthycolor = {
    r = r,
    g = g,
    b = b
  }

  self:SetupFrame()
end

function AtonementBar:SetWarningColor(info, r, g, b, a)
  self.db.profile.warningcolor = {
    r = r,
    g = g,
    b = b
  }

  self:SetupFrame()
end

function AtonementBar:SetDangerColor(info, r, g, b, a)
  self.db.profile.dangercolor = {
    r = r,
    g = g,
    b = b
  }

  self:SetupFrame()
end

-- Initialisation

local function IsDiscPriest()
  local class, classFileName = UnitClass("player")
  return classFileName == "PRIEST" and GetSpecialization() == 1
end

function AtonementBar:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("AtonementBarDB", AtonementBarDB.defaultConfig, true)
  LibStub("AceConfig-3.0"):RegisterOptionsTable("AtonementBar", options, {"ab", "atonement", "atonmentbar"})
  self.optionsGUI = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("AtonementBar", "AtonementBar")

  self:SetupFrame()

  self:SpecializationChanged()
  self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", self.SpecializationChanged)
  self:RegisterEvent("PLAYER_TALENT_UPDATE", self.GetAtonementDuration)

  if not self.db.profile.locked then
    print("AtonementBar is unlocked and can be dragged. Use /ag lock to toggle frame lock.")
  end
end

function AtonementBar:OnEnable()
  self.frame:SetScript("OnUpdate", self.Update)
end

function AtonementBar:OnDisable()
  self.frame:SetScript("OnUpdate", nil)
end

function AtonementBar:UpdateVisability()
  if self.isDiscipline then
    self.frame:Show()
  else
    self.frame:Hide()
  end
end

function AtonementBar:SpecializationChanged()
  AtonementBar.isDiscipline = IsDiscPriest()
  AtonementBar:UpdateVisability()
  AtonementBar:GetAtonementDuration()
end

function AtonementBar:SetupFrame()
  local conf = self.db.profile

  local backdrop = {
	    bgFile = media:Fetch("background", conf.background, false),
      edgeFile = media:Fetch("border", conf.border, false),
      edgeSize = 1,
      tile = true,
      tileSize = 16,
      insets = { left = 1, right = 1, top = 1, bottom = 1 }
	}

  local statusBarTexture = media:Fetch("statusbar", conf.statusbar, false)

  local frame = self.frame or CreateFrame("frame", "AtonementBar", UIParent)

  if not frame:IsUserPlaced() or not frame:GetLeft() then
    frame:ClearAllPoints()

    if conf.xpos ~= -1 or conf.ypos ~= -1 then
      frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", conf.xpos, conf.ypos)
    else
      frame:SetPoint("CENTER", UIParent)
    end
  end

  frame:SetSize(conf.width,conf.height)

  -- Atonement timer bars
  frame.bars = frame.bars or CreateFrame("frame", nil, frame)

	frame.bars:SetBackdrop(backdrop)
  frame.bars:SetBackdropColor(conf.backgroundColor.r, conf.backgroundColor.g, conf.backgroundColor.b, conf.backgroundColor.a)
  frame.bars:SetBackdropBorderColor(conf.borderColor.r, conf.borderColor.g, conf.borderColor.b, conf.borderColor.a)

  frame.barscontainer = frame.barscontainer or CreateFrame("frame", nil, frame.bars)
  frame.barscontainer:SetPoint("TOPLEFT", frame.bars, "TOPLEFT", 1, -1)
  frame.barscontainer:SetPoint("BOTTOMRIGHT", frame.bars, "BOTTOMRIGHT", -1, 1)

  frame.healthy = frame.healthy or frame.barscontainer:CreateTexture()
  frame.healthy:SetTexture(statusBarTexture)
  frame.healthy:SetVertexColor(conf.healthycolor.r, conf.healthycolor.g, conf.healthycolor.b, 0.7)
  frame.healthy.text = frame.healthy.text or frame.barscontainer:CreateFontString()
  frame.healthy.text:SetFont(media:Fetch("font", conf.font, false), 12, "OUTLINE")

  frame.warning = frame.warning or frame.barscontainer:CreateTexture()
  frame.warning:SetTexture(statusBarTexture)
  frame.warning:SetVertexColor(conf.warningcolor.r, conf.warningcolor.g, conf.warningcolor.b, 0.7)
  frame.warning.text = frame.healthy.text or frame.barscontainer:CreateFontString()
  frame.warning.text:SetFont(media:Fetch("font", conf.font, false), 12, "OUTLINE")

  frame.danger = frame.danger or frame.barscontainer:CreateTexture()
  frame.danger:SetTexture(statusBarTexture)
  frame.danger:SetVertexColor(conf.dangercolor.r, conf.dangercolor.g, conf.dangercolor.b, 0.7)
  frame.danger.text = frame.healthy.text or frame.barscontainer:CreateFontString()
  frame.danger.text:SetFont(media:Fetch("font", conf.font, false), 12, "OUTLINE")

  frame.bars:ClearAllPoints();
  frame.healthy:ClearAllPoints();
  frame.warning:ClearAllPoints();
  frame.danger:ClearAllPoints();
  frame.healthy.text:ClearAllPoints();
  frame.warning.text:ClearAllPoints();
  frame.danger.text:ClearAllPoints();

  if conf.orientation == "horizontal" then
    local barOffset = 0
    if conf.showCounter then
      barOffset = conf.height - 1
    end

    frame.bars:SetPoint("TOPLEFT", frame, "TOPLEFT", barOffset, 0)
    frame.bars:SetPoint("BOTTOMRIGHT", frame)

    frame.healthy:SetPoint("TOPLEFT", frame.barscontainer, "TOPLEFT")
    frame.healthy:SetPoint("BOTTOMLEFT", frame.barscontainer, "BOTTOMLEFT")
    frame.healthy.text:SetPoint("LEFT", frame.healthy, "RIGHT")

    frame.warning:SetPoint("TOPLEFT", frame.healthy, "TOPRIGHT")
    frame.warning:SetPoint("BOTTOMLEFT", frame.healthy, "BOTTOMRIGHT")
    frame.warning.text:SetPoint("LEFT", frame.warning, "RIGHT")

    frame.danger:SetPoint("TOPLEFT", frame.warning, "TOPRIGHT")
    frame.danger:SetPoint("BOTTOMLEFT", frame.warning, "BOTTOMRIGHT")
    frame.danger.text:SetPoint("LEFT", frame.danger, "RIGHT")
  else
    local barOffset = 0
    if conf.showCounter then
      barOffset =  -(conf.width - 1)
    end

    frame.bars:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, barOffset)
    frame.bars:SetPoint("BOTTOMRIGHT", frame)

    frame.healthy:SetPoint("TOPLEFT", frame.barscontainer, "TOPLEFT")
    frame.healthy:SetPoint("TOPRIGHT", frame.barscontainer, "TOPRIGHT")
    frame.healthy.text:SetPoint("TOP", frame.healthy, "BOTTOM")

    frame.warning:SetPoint("TOPLEFT", frame.healthy, "BOTTOMLEFT")
    frame.warning:SetPoint("TOPRIGHT", frame.healthy, "BOTTOMRIGHT")
    frame.warning.text:SetPoint("TOP", frame.warning, "BOTTOM")

    frame.danger:SetPoint("TOPLEFT", frame.warning, "BOTTOMLEFT")
    frame.danger:SetPoint("TOPRIGHT", frame.warning, "BOTTOMRIGHT")
    frame.danger.text:SetPoint("TOP", frame.danger, "BOTTOM")
  end

  -- Atonement counter
  frame.counter = frame.counter or CreateFrame("frame", nil, frame)
  frame.counterText = frame.counterText or frame.counter:CreateFontString()

  if conf.showCounter then
  	frame.counter:SetBackdrop(backdrop)
    frame.counter:SetBackdropColor(conf.backgroundColor.r, conf.backgroundColor.g, conf.backgroundColor.b, conf.backgroundColor.a)
    frame.counter:SetBackdropBorderColor(conf.borderColor.r, conf.borderColor.g, conf.borderColor.b, conf.borderColor.a)

    if conf.orientation == "horizontal" then
      frame.counter:ClearAllPoints();
      frame.counter:SetPoint("TOPLEFT", frame)
      frame.counter:SetPoint("BOTTOMLEFT", frame)
      frame.counter:SetWidth(conf.height)
    else
      frame.counter:ClearAllPoints();
      frame.counter:SetPoint("TOPLEFT", frame)
      frame.counter:SetPoint("TOPRIGHT", frame)
      frame.counter:SetHeight(conf.width)
    end

    frame.counterText:SetPoint("CENTER", frame.counter, "CENTER")
    frame.counterText:SetFont(media:Fetch("font", conf.font, false), 12, "OUTLINE")

    frame.counter:Show()
    frame.counterText:Show()
  else
    frame.counter:Hide()
    frame.counterText:Hide()
  end

  frame:Show()

  self:SetFrameLock(nil, self.db.profile.locked)
end

function AtonementBar:GetAtonementDuration()
  local talentID, name, texture, selected, available = GetTalentInfo(5, 1, 1)
  if selected then
    AtonementBar.atonementDuration = 17
  else
    AtonementBar.atonementDuration = 15
  end
end

local cooldownFade = function(remaining, threshold, fadeTime)
  return math.max(0, math.min(1, (threshold - remaining) / fadeTime))
end

function AtonementBar:UpdateVisibility()
  if self.db.profile.autohide and (not IsInGroup() or IsInRaid()) then
    self.frame:Hide()
  else
    self.frame:Show()
  end
end

function AtonementBar:Update()
  local self = AtonementBar
  local conf = self.db.profile

  if not self.isDiscipline then
    return
  end

  self:FindAtonementBuffs()
  self:UpdateVisibility()

  -- update Atonement timer bars
  local count = #self.durations
  local maxDuration = self.atonementDuration

  local thresholds = conf.raidthresholds
  if not IsInRaid() then
    thresholds = conf.partythresholds
  end

  local healthyDuration = 0
  if #self.durations >= thresholds.healthy then
    healthyDuration = math.max(0, math.min(maxDuration, self.durations[thresholds.healthy]))
  end

  local warningDuration = 0
  if #self.durations >= thresholds.warning then
    warningDuration = math.max(0, math.min(maxDuration, self.durations[thresholds.warning] - healthyDuration))
  end

  local dangerDuration = 0
  if #self.durations >= thresholds.danger then
    dangerDuration = math.max(0, math.min(maxDuration, self.durations[thresholds.danger] - (warningDuration + healthyDuration)))
  end

  local barSize = self.frame.barscontainer:GetWidth()
  if conf.orientation ~= "horizontal" then
    barSize = self.frame.barscontainer:GetHeight()
  end

  local fifteenPixelsDuration = (20 / barSize) * maxDuration
  local textDisplayThreshold = maxDuration - fifteenPixelsDuration

  if healthyDuration > 0 and (warningDuration - healthyDuration) > fifteenPixelsDuration and conf.showTimers then
    self.frame.healthy.text:SetText(math.ceil(healthyDuration))
    self.frame.healthy.text:SetAlpha(cooldownFade(healthyDuration, textDisplayThreshold, 0.5))
    self.frame.healthy.text:Show()
  else
    self.frame.healthy.text:Hide()
  end

  if warningDuration > 0 and (dangerDuration - warningDuration) > fifteenPixelsDuration and conf.showTimers then
    self.frame.warning.text:SetText(math.ceil(warningDuration))
    self.frame.warning.text:SetAlpha(cooldownFade(warningDuration, textDisplayThreshold, 0.5))
    self.frame.warning.text:Show()
  else
    self.frame.warning.text:Hide()
  end

  if dangerDuration > 0 and conf.showTimers then
    self.frame.danger.text:SetText(math.ceil(dangerDuration))
    self.frame.danger.text:SetAlpha(cooldownFade(dangerDuration, textDisplayThreshold, 0.5))
    self.frame.danger.text:Show()
  else
    self.frame.danger.text:Hide()
  end

  local frameWidthUnit = barSize / maxDuration
  if conf.orientation == "horizontal" then
    self.frame.healthy:SetPoint("RIGHT", self.frame.barscontainer, "LEFT", healthyDuration * frameWidthUnit, 0)
    self.frame.warning:SetPoint("RIGHT", self.frame.healthy, "RIGHT", warningDuration * frameWidthUnit, 0)
    self.frame.danger:SetPoint("RIGHT", self.frame.warning, "RIGHT", dangerDuration * frameWidthUnit, 0)
  else
    self.frame.healthy:SetPoint("BOTTOM", self.frame.barscontainer, "TOP", 0, -(healthyDuration * frameWidthUnit))
    self.frame.warning:SetPoint("BOTTOM", self.frame.healthy, "BOTTOM", 0, -(warningDuration * frameWidthUnit))
    self.frame.danger:SetPoint("BOTTOM", self.frame.warning, "BOTTOM", 0, -(dangerDuration * frameWidthUnit))
  end

  -- update cooldowns
  if conf.showCooldowns then
    for i = 1, #self.trackedCooldowns, 1 do
      local spellId = self.trackedCooldowns[i]
      self:CheckSpellCooldown(spellId)
      self:DrawSpellCooldown(spellId)
    end
  end

  -- update Atonement counter
  if conf.showCounter then
    self.frame.counterText:SetText(#AtonementBar.durations)

    local color = (healthyDuration > 0 and conf.healthycolor) or (warningDuration > 0 and conf.warningcolor) or (dangerDuration > 0 and conf.dangercolor) or {r=1,g=1,b=1}
    self.frame.counterText:SetTextColor(color.r, color.g, color.b, 1)
  end
end

function AtonementBar:FindAtonementBuffs()
  local spell = self.spellIDs["Atonement"].name
  local atonements = self.durations or { }

  -- clear old durations
  for i = 1, #atonements, 1 do
		table.remove( atonements, 1 )
	end

  -- find atonement buff on local player
  local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitBuff("player", spell, nil, "PLAYER")

  if expirationTime then
    atonements[#atonements + 1] = expirationTime - GetTime()
  end

  -- find atonement buffs on group members
  local players = GetNumGroupMembers()

  local type = "party"
  if IsInRaid() then
    type = "raid"
  end

  if players then
    for i = 1, players, 1 do
      local unitId = type .. i
      local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitBuff(unitId, spell, nil, "PLAYER")

      if expirationTime then
        atonements[#atonements + 1] = expirationTime - GetTime()
      end
    end
  end

  table.sort(atonements, function(a, b) return a > b end)

  self.durations = atonements
end

local createSpellCooldown = function(spellId)
  local name, rank, icon, castingTime, minRange, maxRange, spellID = GetSpellInfo(spellId)
  local self = AtonementBar

  local barsize = self.frame.barscontainer:GetHeight()
  if self.db.profile.orientation ~= "horizontal" then
    barsize = self.frame.barscontainer:GetWidth()
  end

  local spell = {
    enabled = false,
    start = 0,
    duration = 0,
  }

  spell.frame = CreateFrame("Frame", nil, self.frame.barscontainer)

  spell.texture = spell.frame:CreateTexture()
  spell.texture:SetTexture(icon)
  spell.texture:SetTexCoord(unpack(self.texCoords))
  spell.texture:SetAllPoints()

  spell.cooldown = CreateFrame("Cooldown", nil, spell.frame, "CooldownFrameTemplate")
  spell.cooldown:SetAllPoints()

  spell.cooldownText = spell.frame:CreateFontString()
  spell.cooldownText:SetPoint("CENTER", spell.frame, "CENTER")
  spell.cooldownText:SetFont(media:Fetch("font", self.db.profile.font, false), 10, "OUTLINE")

  spell.frame:Hide()
  return spell
end

function AtonementBar:CheckSpellCooldown(spellId)
  local spell = self.cooldowns[spellId] or createSpellCooldown(spellId)

  local start, duration, enable = GetSpellCooldown(spellId)
  local cooldownRemaining = (start + duration) - GetTime()

  spell.start = start
  spell.duration = duration

  if duration ~= 0 then
    -- cooldown started, and not the general cooldown
    if not spell.enabled and cooldownRemaining > 1.5 then
      spell.enabled = true
      spell.flashing = false
    end
  else
    -- cooldown inactive
    if spell.enabled then
      -- cooldown completed last frame
      spell.enabled = false
      spell.flashing = true
      spell.completed = GetTime()
    else
      if spell.flashing and (GetTime() - spell.completed) > 0.3 then
        spell.flashing = false
      end
    end
  end

  self.cooldowns[spellId] = spell
end

function AtonementBar:DrawSpellCooldown(spellId)
  local spell = self.cooldowns[spellId]
  local maxDuration = self.atonementDuration

  if spell then
    local cooldownRemaining = (spell.start + spell.duration) - GetTime()

    if spell.enabled and cooldownRemaining < maxDuration then
      local alpha = math.min(cooldownFade(cooldownRemaining, spell.duration, 0.5), cooldownFade(cooldownRemaining, maxDuration - 2, 1))

      local barsize = self.frame.barscontainer:GetHeight()
      if self.db.profile.orientation ~= "horizontal" then
        barsize = self.frame.barscontainer:GetWidth()
      end

      spell.size = barsize - 2

      spell.frame:SetAlpha(alpha)
      spell.frame:ClearAllPoints()
      spell.frame:SetSize(spell.size, spell.size)
      spell.cooldown:SetCooldown(spell.start, spell.duration)
      spell.cooldownText:SetText(math.ceil(cooldownRemaining))

      if self.db.profile.orientation == "horizontal" then
        local position = self.frame.barscontainer:GetWidth() * (cooldownRemaining / maxDuration)
        spell.frame:SetPoint("LEFT", self.frame.barscontainer, "LEFT", position, 0)
      else
        local position = self.frame.barscontainer:GetHeight() * (cooldownRemaining / maxDuration)
        spell.frame:SetPoint("TOP", self.frame.barscontainer, "TOP", 0, -position)
      end

      spell.frame:Show()
    else
      if spell.flashing then
        local flashProgress = math.max(0, math.min(1, (GetTime() - spell.completed) / 0.3))
        local size = spell.size * (1 + flashProgress)

        spell.frame:SetAlpha(1 - flashProgress)
        spell.frame:SetSize(size, size)
        spell.frame:ClearAllPoints()

        if self.db.profile.orientation == "horizontal" then
          spell.frame:SetPoint("CENTER", self.frame.barscontainer, "LEFT", spell.size * 0.5, 0)
        else
          spell.frame:SetPoint("CENTER", self.frame.barscontainer, "TOP", 0, -(spell.size * 0.5))
        end

        spell.cooldown:SetCooldown(spell.start, spell.duration)
        spell.cooldownText:SetText("")
      else
        spell.frame:Hide()
      end
    end
  end
end
