-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                 "SylingTracker.Contents.KeystoneContentView"          ""
-- ========================================================================= --
export {
  FromUIProperty                      = Wow.FromUIProperty,
  GetFrameByType                      = Wow.GetFrameByType,
}

enum "KeystoneEnemyForcesFormatType" {
  "OnlyPercent",
  "OnlyAbsolute",
  "AbsoluteAndPercent",
  "Custom"
}

enum "KeystoneCurrentPullFormatType" {
  "OnlyFinalPercent",
  "OnlyFinalCount",
  "OnlyAdditivePercent",
  "OnlyAdditiveCount",
  "Custom"
}

__UIElement__()
class "KeystoneAffixe"(function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  __Observable__()
  property "AffixTexture" {
    type = Any
  }

  property "AffixName" {
    type = String
  }

  property "AffixDescription" {
    type = String
  }
  -----------------------------------------------------------------------------
  --                              Constructors                               --
  -----------------------------------------------------------------------------
  __Template__ {
    Icon = Texture
  }
  function __ctor(self) 
    self.OnEnter = function()
      GameTooltip:SetOwner(self, "ANCHOR_LEFT")
      GameTooltip:SetText(self.AffixName, 1, 1, 1, 1, true)
      GameTooltip:AddLine(self.AffixDescription, nil, nil, nil, true)
      GameTooltip:Show()
    end

    self.OnLeave = function() GameTooltip:Hide() end
  end
end)

__UIElement__()
class "KeystoneAffixes" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function UpdateFromData(self, affixesData)
    if affixesData then 
      self.AffixesCount = #affixesData 

      for i = 1, 4 do 
        local affixData = affixesData[i]
        local affix = self:GetChild("Affix"..i)
        if affixData then 
          affix.AffixName = affixData.name
          affix.AffixDescription = affixData.description
          affix.AffixTexture = affixData.texture
          affix:Show()
        else 
          affix:Hide()
        end
      end
    else
      for i = 1, 4 do 
        local affix = self:GetChild("Affix"..i)
        affix:Hide()
      end

      self.AffixesCount = nil 
    end
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  __Observable__()
  property "AffixesCount" {
    type = Number,
    default = 0,
  }
  -----------------------------------------------------------------------------
  --                              Constructors                               --
  -----------------------------------------------------------------------------
  __Template__ {
    Affix1 = KeystoneAffixe,
    Affix2 = KeystoneAffixe,
    Affix3 = KeystoneAffixe,
    Affix4 = KeystoneAffixe,
  }
  function __ctor(self) end
end)

__UIElement__()
class "KeystoneTimer" (function(_ENV)
  inherit "Timer"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnTimerBarSizeChangedHandler(self)
    self:GetParent():UpdateSubTimers()
  end

  local function OnDurationChangedHandler(self)
    self:UpdateSubTimers()
  end

  function UpdateSubTimers(self)
    local timerBar = self:GetChild("TimerBar")
    local maxWidth = math.floor(timerBar:GetWidth() + 0.5)

    if maxWidth == 0 then 
      return 
    end

    local twoChestLine = self:GetChild("TwoChestLine")
    twoChestLine:SetPoint("CENTER", timerBar, "RIGHT", -math.floor(Lerp(0, maxWidth, 0.2) + 0.5), 0)


    local threeChestLine = self:GetChild("ThreeChestLine")
    threeChestLine:SetPoint("CENTER", timerBar, "RIGHT", -math.floor(Lerp(0, maxWidth, 0.4) + 0.5), 0)
  end

  local function OnElapsedTimeChanged(self, new)
    local duration = self.Duration

    self.TwoChestElapsed = (new > duration * 0.8)
    self.ThreeChestElapsed = (new > duration * 0.6)
    self.TimerElapsed = (new > duration)
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  __Observable__()
  property "TwoChestElapsed" {
    type = Boolean,
    default = false 
  }

  __Observable__()
  property "ThreeChestElapsed" {
    type = Boolean,
    default = false 
  }

  __Observable__()
  property "TimerElapsed" {
    type = Boolean,
    default = false
  }
  -----------------------------------------------------------------------------
  --                              Constructors                               --
  -----------------------------------------------------------------------------
  __Template__ {
    TimerBar        = ProgressBar,
    TwoChestLine    = Texture,
    TwoChestTimer   = FontString,
    ThreeChestLine  = Texture,
    ThreeChestTimer = FontString
  }
  function __ctor(self) 
    local timerBar= self:GetChild("TimerBar")
    timerBar.OnSizeChanged = timerBar.OnSizeChanged + OnTimerBarSizeChangedHandler

    self.OnDurationChanged = self.OnDurationChanged + OnDurationChangedHandler
    self.OnElapsedTimeChanged = self.OnElapsedTimeChanged + OnElapsedTimeChanged
  end
end)

__UIElement__()
class "KeystoneEnemyForces" (function(_ENV)
  inherit "Frame"

  enum "EState" {
    Progress = 1,
    Completed = 2
  }
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  __Observable__()
  property "EnemyForcesState" {
    type    = EState,
    default = EState.Progress
  }

  __Observable__()
  property "EnemyForcesPendingQuantity" {
    type    = Number,
    default = 0
  }

  __Observable__()
  property "EnemyForcesQuantity" {
    type    = Number,
    default = 0
  }

  __Observable__()
  property "EnemyForcesTotalQuantity" {
    type    = Number,
    default = 0
  }

  property "FormatType" {
    type = KeystoneEnemyForcesFormatType,
    default = KeystoneEnemyForcesFormatType.OnlyPercent
  }

  property "CurrentPullFormatType" {
    type = KeystoneCurrentPullFormatType,
    default = KeystoneCurrentPullFormatType.OnlyAdditivePercent
  }
  
  property "CustomFormat" {
    type = String,
    handler = function(self, new)
      if new ~= nil or new ~= "" then
        local ok, result = Utils.GetFunctionFromString(new)
        if ok then 
          self.CustomFormatFunction = result 
        else
          self.CustomFormatFunction = nil
        end
      else 
        self.CustomFormatFunction = nil
      end 
    end
  }

  property "CustomFormatFunction" {
    type = Function
  }

  property "CustomPullFormat" {
    type = String,
    handler = function(self, new)
      if new ~= nil or new ~= "" then
        local ok, result = Utils.GetFunctionFromString(new)
        if ok then 
          self.CustomPullFormatFunction = result 
        else
          self.CustomPullFormatFunction = nil
        end
      else 
        self.CustomPullFormatFunction = nil
      end 
    end
  }

  property "CustomPullFormatFunction" {
    type = Function
  }
  -----------------------------------------------------------------------------
  --                              Constructors                               --
  -----------------------------------------------------------------------------
  __Template__ {
    Text      = FontString,
    Progress  = ProgressWithExtraBar
  }
  function __ctor(self) end
end)


__UIElement__()
class "KeystoneDeathCounter" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                              Constructors                               --
  -----------------------------------------------------------------------------
  __Template__ {
    Icon = Texture,
    Counter = FontString
  }
  function __ctor(self) end
end)


__UIElement__()
class "KeystoneContentView" (function(_ENV)
  inherit "ContentView"
  -----------------------------------------------------------------------------
  --                                Methods                                  --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data, metadata)
    super.OnViewUpdate(self, data, metadata)

    if data then 
      self.DungeonName = data.name
      self.KeystoneLevel = data.level
      self.KeystoneStarted = data.started
      self.DungeonTextureFileID = data.textureFileID
      self.KeystoneDuration = data.timeLimit
      self.KeystoneDeathCount = data.deathCount

      local objectives = self:GetChild("Content"):GetChild("Objectives")
      objectives:UpdateView(data.objectives, metadata)

      local affixes = self:GetChild("TopDungeonInfo"):GetChild("Affixes")
      affixes:UpdateFromData(data.affixes)

      local timer = self:GetChild("Content"):GetChild("TimerInfo")
      timer.StartTime = data.startTime
      timer.Duration = data.timeLimit

      local enemyForces = self:GetChild("Content"):GetChild("EnemyForces")
      enemyForces.EnemyForcesTotalQuantity = data.enemyForcesTotalQuantity
      enemyForces.EnemyForcesQuantity = data.enemyForcesQuantity
      enemyForces.EnemyForcesPendingQuantity = data.enemyForcesPendingQuantity
    else 
      self.DungeonName = nil 
      self.DungeonTextureFileID = nil
      self.KeystoneLevel = nil
      self.KeystoneStarted = nil
    end
  end

  function OnExpand(self)
    Style[self].TopDungeonInfo.visible = true
    Style[self].Objectives.visible = true
  end

  function OnCollapse(self)
    Style[self].TopDungeonInfo.visible = false
    Style[self].Objectives.visible = false
  end
  
  function OnRelease(self)
    self:GetChild("Content"):GetChild("TimerInfo"):Reset()
    
    self.DungeonName = nil 
    self.DungeonTextureFileID = nil
    self.KeystoneLevel = nil
    self.KeystoneStarted = nil
    self.KeystoneDuration = nil
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  __Observable__()
  property "DungeonTextureFileID" {
    type = Number
  }

  __Observable__()
  property "DungeonName" {
    type = String
  }

  __Observable__()
  property "KeystoneLevel" {
    type = Number,
    default = 0,
  }

  __Observable__()
  property "KeystoneStarted" {
    type = Boolean,
    default = false
  }

  __Observable__()
  property "KeystoneDuration" {
    type = Number,
    default = 0
  }

  __Observable__()
  property "KeystoneDeathCount" {
    type = Number,
    default = 0
  }
  -----------------------------------------------------------------------------
  --                              Constructors                               --
  -----------------------------------------------------------------------------
  __Template__{
    TopDungeonInfo  = Frame,
    Content         = Frame, 
    DeathCounter    = KeystoneDeathCounter,
    {
      Content = {
        TimerInfo   = KeystoneTimer,
        EnemyForces = KeystoneEnemyForces,
        Objectives  = ObjectiveListView,
      },
      TopDungeonInfo = {
        Level         = FontString,
        Affixes       = KeystoneAffixes,
        DungeonName   = FontString,
        DungeonIcon   = Texture,
      },
    }
  }
  function __ctor(self) end
end)
-------------------------------------------------------------------------------
--                              Observables                                  --
-------------------------------------------------------------------------------
function FromKeystoneStarted()
  return FromUIProperty("KeystoneStarted")
end

function FromKeystoneDuration()
  return FromUIProperty("KeystoneDuration")
end

function FromTimerDuration()
  return FromUIProperty("KeystoneDuration")
end

function FromTimerText()
  return GetFrameByType(KeystoneTimer, FromUIProperty("ElapsedTime"))
    :CombineLatest(FromKeystoneDuration())
    :Map(function(timer)
        local showRemainingTime = timer.ShowRemainingTime
        local duration          = timer.Duration
        local elapsedTime       = timer.ElapsedTime

        local clock = showRemainingTime
                      and SecondsToClock(max(0, duration - elapsedTime)) 
                      or SecondsToClock(elapsedTime) .. " / " .. SecondsToClock(duration)
        
        if elapsedTime > duration then 
          return Color.RED .. clock
        end 

        return clock
    end)
end

function FromTimerBarValue()
  return GetFrameByType(KeystoneTimer, FromUIProperty("ElapsedTime")):Map(function(timer)
      local duration          = timer.Duration
      local elapsedTime       = timer.ElapsedTime
      local showRemainingTime = timer.ShowRemainingTime

      if showRemainingTime then
        if duration > 0 then 
          return Lerp(0, 100, max(0, (duration - elapsedTime) / duration))
        else
          return 100
        end
      else
        if duration > 0 then  
          return Lerp(100, 0, max(0, (duration - elapsedTime) / duration))
        else
          return 0
        end
      end
  end)
end

function FromTimerBarStatusBarColor()
  return FromUIProperty("TimerElapsed"):Map(function(timerElapsed)
    return timerElapsed and Color(0.3, 0.3, 0.3, 0.9) or Color(0, 148/255, 1, 0.9)
  end)
end

function FromTwoChestTimerText()
  return GetFrameByType(KeystoneTimer, FromUIProperty("ElapsedTime")):Map(function(timer)
    return SecondsToClock(max(0, timer.Duration * 0.8 - timer.ElapsedTime))
  end)
end

function FromThreeChestTimerText()
  return GetFrameByType(KeystoneTimer, FromUIProperty("ElapsedTime")):Map(function(timer)
    return SecondsToClock(max(0, timer.Duration * 0.6 - timer.ElapsedTime))
  end)
end

function FromEnemyForcesProgressExtraValue()
  return GetFrameByType(KeystoneEnemyForces, FromUIProperty("EnemyForcesPendingQuantity"))
    :Map(function(enemyForces)
      return min(enemyForces.EnemyForcesPendingQuantity + enemyForces.EnemyForcesQuantity, enemyForces.EnemyForcesTotalQuantity)
    end)
end

function FromEnemyForcesTextColor()
  return GetFrameByType(KeystoneEnemyForces, FromUIProperty("EnemyForcesQuantity", "EnemyForcesTotalQuantity", "EnemyForcesPendingQuantity"))
    :Next()
    :Map(function(enemyForces)
      local current = enemyForces.EnemyForcesQuantity
      local total = enemyForces.EnemyForcesTotalQuantity
      local pending = enemyForces.EnemyForcesPendingQuantity

      if total > 0 and current >= total then 
        return Color.GREEN
      end

      return Color(0.9, 0.9, 0.9)
    end)
end

function FromEnemyForcesText()
  return GetFrameByType(KeystoneEnemyForces, FromUIProperty("EnemyForcesQuantity", "EnemyForcesTotalQuantity", "EnemyForcesPendingQuantity"))
    :Next()
    :Map(function(enemyForces)
      local enemyForcesTextFormatType = enemyForces.TextFormatType
      local pullTextFormatType        = enemyForces.PullTextFormatType
      local current                   = enemyForces.EnemyForcesQuantity
      local total                     = enemyForces.EnemyForcesTotalQuantity
      local pending                   = enemyForces.EnemyForcesPendingQuantity
      local formatType                = enemyForces.FormatType
      local currentPullFormatType     = enemyForces.CurrentPullFormatType


      if total == 0 then 
        return ""
      end

      -- Enemy Forces
      local enemyForcesText = ""
      if formatType == "OnlyPercent" then 
        enemyForcesText = format("%.2f%%", Utils.TruncateDecimal(current / total * 100, 2))
      elseif formatType == "OnlyAbsolute" then 
        enemyForcesText = format("%i / %i", current, total)
      elseif formatType == "AbsoluteAndPercent" then
        enemyForcesText = format("%i / %i - %.2f%%", current, total, Utils.TruncateDecimal(current / total * 100, 2))
      elseif formatType == "Custom" then 
        local customFormatFunction = enemyForces.CustomFormatFunction
        if customFormatFunction then
          enemyForcesText = customFormatFunction(current, total, pending)
        end 
      end

      -- Current Pull 
      if pending > 0 then 
        local pullText = ""
        if currentPullFormatType == "OnlyAdditivePercent" then
          pullText = format("( +%.2f%% )", Utils.TruncateDecimal(pending / total * 100, 2))
        elseif currentPullFormatType == "OnlyAdditiveCount" then 
          pullText = "( +"..pending .. " )"
        elseif currentPullFormatType == "OnlyFinalPercent" then 
          pullText = format("-> %.2f%%", Utils.TruncateDecimal((current + pending) / total * 100, 2))
        elseif currentPullFormatType == "OnlyFinalCount" then 
          pullText = "-> " .. current + pending
        elseif currentPullFormatType == "Custom" then 
          local customPullFormatFunction = enemyForces.CustomPullFormatFunction
          if customPullFormatFunction then 
            pullText = customPullFormatFunction(current, pull, pending)
          end
        end

        if current + pending >= total then 
          return enemyForcesText .. " " .. Color.GREEN .. pullText
        else
          return enemyForcesText .. " " .. pullText
        end
      end

      return enemyForcesText

    end)
end
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
API.UpdateBaseSkin({
  [KeystoneAffixe] = {
    height                            = 16,
    width                             = 16,

    Icon = {
      setAllPoints                    = true,
      fileID                          = FromUIProperty("AffixTexture"),
      texCoords                       = { left = 0.07,  right = 0.93, top = 0.07, bottom = 0.93 } ,
    }
  },

  [KeystoneTimer] = {
    autoAdjustHeight                  = true,
    started                           = FromUIProperty("KeystoneStarted"),
    duration                          = FromUIProperty("KeystoneDuration"),
    showRemainingTime                 = false,

    Text = {
      text                            = FromTimerText(),
      mediaFont                       = FontType("PT Sans Narrow Bold", 21),
    },

    TimerBar = {
      height                          = 10,
      frameStrata                     = "LOW",
      value                           = FromTimerBarValue(),
      statusBarColor                  = FromTimerBarStatusBarColor()
    },

    TwoChestLine = {
      height                          = 14,
      width                           = 2,
      drawLayer                       = "OVERLAY",
      subLevel                        = 2,
      texelSnappingBias               = 0,
      snapToPixelGrid                 = false,
      texelSnappingBias               = 0,
      color                           = FromUIProperty("TwoChestElapsed"):Map(function(elapsed) return elapsed and Color.RED or Color.GREEN end)
    },
    TwoChestTimer = {
      height                          = 25,
      visible                         = FromUIProperty("TwoChestElapsed"):Map(function(elapsed) return not elapsed end),
      text                            = FromTwoChestTimerText(),
      textColor                       = Color.GREEN,
      justifyV                        = "MIDDLE",
      justifyH                        = "CENTER",
    },

    ThreeChestLine = {
      height                          = 14,
      width                           = 2,
      drawLayer                       = "OVERLAY",
      subLevel                        = 2,
      texelSnappingBias               = 0,
      snapToPixelGrid                 = false,
      texelSnappingBias               = 0,
      color                           = FromUIProperty("ThreeChestElapsed"):Map(function(elapsed) return elapsed and Color.RED or Color.GREEN end)
    },

    ThreeChestTimer = {
      height                          = 25,
      visible                         = FromUIProperty("ThreeChestElapsed"):Map(function(elapsed) return not elapsed end),
      text                            = FromThreeChestTimerText(),
      textColor                       = Color.GREEN,
      justifyV                        = "MIDDLE",
      justifyH                        = "CENTER",
    }
  },

  [KeystoneAffixes] = {
    height = 16,
    width = 79,
  },

  [KeystoneEnemyForces] = {
    autoAdjustHeight                  = true,
    Text = {
      text                            = "Enemy Forces",
      mediaFont                       = FontType("PT Sans Narrow Bold", 13),
      textColor                       = FromEnemyForcesTextColor(),
    },

    Progress = {
      value                           = FromUIProperty("EnemyForcesQuantity"),
      minMaxValues                    = FromUIProperty("EnemyForcesTotalQuantity"):Map(function(total) return MinMax(0, total) end),
      extraValue                      = FromEnemyForcesProgressExtraValue(),

      Text = {
        text                          = FromEnemyForcesText()
      }
    }
  },

  [KeystoneDeathCounter] = {
    width                             = 40,
    height                            = 25,

    Icon = {
      atlas = AtlasType("poi-graveyard-neutral", true)
    },

    Counter = {
      justifyH                        = "RIGHT",
      justifyV                        = "MIDDLE",
    }
  },

  [KeystoneContentView] = {
    Header = {
      visible                         = false
    },

    DeathCounter = {
      visible = FromUIProperty("KeystoneDeathCount"):Map(function(count) return count > 0 end),
      Counter = {
        text = FromUIProperty("KeystoneDeathCount")
      }
    },

    TopDungeonInfo = {

      backdrop                        = { edgeFile  = [[Interface\Buttons\WHITE8X8]], edgeSize  = 1 },
      backdropBorderColor             = Color(35/255, 40/255, 46/255, 0.73),
      height                          = 48,

      DungeonIcon = {
        fileID                        = FromUIProperty("DungeonTextureFileID"),
        setAllPoints                  = true,
        drawLayer                     = "BACKGROUND",
      },

      Level = {
        text                          = FromUIProperty("KeystoneLevel"):Map(function(level)return CHALLENGE_MODE_POWER_LEVEL:format(level) end),
        justifyV                      = "TOP",
        justifyH                      = "LEFT",
      },
      
      DungeonName = {
        text                          = FromUIProperty("DungeonName"),
        fontObject                    = Game18Font,
        textColor                     = { r = 1, g = 0.914, b = 0.682},
        justifyV                      = "MIDDLE",
        justifyH                      = "CENTER",
      }
    },

    Content = {
      autoAdjustHeight                = true,
      paddingBottom                   = 5,

      backdrop = { 
        bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
        edgeFile  = [[Interface\Buttons\WHITE8X8]],
        edgeSize  = 1
      },

      backdropColor                   = Color(35/255, 40/255, 46/255, 0.73),
      backdropBorderColor             = Color(0, 0, 0, 0.4),

      Objectives = {
        autoAdjustHeight              = true,
        height                        = 32,
      },
      
      EnemyForces = {
        Progress = {
          ExtraBarTexture = {
            vertexColor               = { r = 1, g = 193/255, b = 25/255, a = 0.7}
          }
        },
      },
    }
  }
})

API.UpdateDefaultSkin({
  [KeystoneTimer] = {
    inherit = "base",

    Text = {
      location = {
        Anchor("TOPLEFT"),
        Anchor("TOPRIGHT")
      }      
    },

    TimerBar = {
      location = {
        Anchor("TOP", 0, -5, "Text", "BOTTOM"),
        Anchor("LEFT", 20, 0),
        Anchor("RIGHT", -20, 0)      
      }
    },

    TwoChestTimer = {
      location = {
        Anchor("TOP", 0, -2, "TwoChestLine", "BOTTOM")
      }      
    },

    ThreeChestTimer = {
      location = {
        Anchor("TOP", 0, -2, "ThreeChestLine", "BOTTOM")
      }      
    }
  },

  [KeystoneAffixes] = {
    inherit = "base",

    Affix1 = {
      location = {
        Anchor("LEFT")
      },
    },
    Affix2 = {
      location = {
        Anchor("LEFT", 5, 0, "Affix1", "RIGHT")
      },
    },

    Affix3 = {
      location = {
        Anchor("LEFT", 5, 0, "Affix2", "RIGHT")
      }
    },
    Affix4 = {
      location = {
        Anchor("LEFT", 5, 0, "Affix3", "RIGHT")
      }
    }
  },

  [KeystoneEnemyForces] = {
    inherit = "base",

    Text = {
      location = {
        Anchor("TOP"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      }
    },

    Progress = {
      location = {
        Anchor("TOP", 0, -5, "Text", "BOTTOM"),
        Anchor("LEFT"),
        Anchor("RIGHT")        
      }
    }
  },

  [KeystoneDeathCounter] = {
    inherit = "base",

    Icon = {
      location = {
        Anchor("RIGHT")
      }
    },

    Counter = {
      location = {
        Anchor("TOP"),
        Anchor("RIGHT", -2, 0, "Icon", "LEFT"),
        Anchor("LEFT"),
        Anchor("BOTTOM")
      }
    }
  },
  
  [KeystoneContentView] = {
    inherit = "base",

    TopDungeonInfo = {
      DungeonIcon = {
        location = {
          Anchor("LEFT", 1, 0),
          Anchor("RIGHT", -1, 0)
        }        
      },

      location = {
        Anchor("TOP"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      },

      Level = {
        location = {
          Anchor("TOPLEFT", 5, -5),        
        }
      },

      Affixes = {
        location = {
          Anchor("TOPLEFT", 0, -5, "Level", "BOTTOMLEFT"),
        }        
      },

      DungeonName = {
        location = {
          Anchor("LEFT", 79, 0),
          Anchor("TOP"),
          Anchor("BOTTOM"),
          Anchor("RIGHT", -45, 0)
        }        
      },

    },
    
    DeathCounter = {
      frameStrata = "HIGH",
      location = {
        Anchor("TOPRIGHT", -5, -24)
      }
    },

    Content = {
      TimerInfo = {
        location = {
          Anchor("TOP", 0, -5),
          Anchor("LEFT"),
          Anchor("RIGHT")
        }        
      },

      Objectives = {
        location = {
          Anchor("TOP", 0, -5, "TimerInfo", "BOTTOM"),
          Anchor("LEFT"),
          Anchor("RIGHT")
        }
      },

      EnemyForces = {
        location = {
          Anchor("TOP", 0, -5, "Objectives", "BOTTOM"),
          Anchor("LEFT", 20, 0),
          Anchor("RIGHT", -20, 0)
        }        
      },

      location = {
        Anchor("TOP", 0, -5, "TopDungeonInfo", "BOTTOM"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      }
    }
  }
})

API.RegisterSkinTag("keystone", 
  KeystoneEnemyForces,
  KeystoneAffixe, 
  KeystoneAffixes, 
  KeystoneTimer,
  KeystoneDeathCounter,
  KeystoneContentView
)