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

      for index, affixData in ipairs(affixesData) do
        local affix = self:GetChild("Affix"..index)
        affix.AffixName = affixData.name
        affix.AffixDescription = affixData.description
        affix.AffixTexture = affixData.texture
      end
    else
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
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "ShowSubTimers" {
    type    = Boolean,
    default = true
  }

  property "showSubTimersWithRemainingTime" {
    type    = Boolean,
    default = true
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
      self.DungeonTextureFileID = data.textureFileID

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
  -----------------------------------------------------------------------------
  --                              Constructors                               --
  -----------------------------------------------------------------------------
  __Template__{
    TopDungeonInfo  = Frame,
    Content         = Frame, 
    {
      Content = {
        TimerInfo   = KeystoneTimer,
        EnemyForces = KeystoneEnemyForces,
        Objectives  = ObjectiveListView,
      },
      TopDungeonInfo = {
        Level       = FontString,
        Affixes     = KeystoneAffixes,
        DungeonName = FontString,
        DungeonIcon = Texture
      },
    }
  }
  function __ctor(self)
  end
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
API.UpdateBaseSkin({
  [KeystoneAffixe] = {
    height = 16,
    width  = 16,

    Icon = {
      setAllPoints = true,
      fileID = FromUIProperty("AffixTexture"),
      texCoords = { left = 0.07,  right = 0.93, top = 0.07, bottom = 0.93 } ,
    }
  },

  [KeystoneTimer] = {
    autoAdjustHeight = true,

    Text = {
      text = GetFrameByType(KeystoneTimer, FromUIProperty("ElapsedTime")):Map(function(timer)
        local clock = timer.ShowRemainingTime 
                      and SecondsToClock(max(0, timer.Duration - timer.ElapsedTime)) 
                      or SecondsToClock(timer.ElapsedTime) .. " / " .. SecondsToClock(timer.Duration)
        
        if timer.ElapsedTime > timer.Duration then 
          return Color.RED .. clock 
        else
          return clock
        end
      end),
      mediaFont = FontType("PT Sans Narrow Bold", 21),
    },

    TimerBar = {
      height = 10,
      frameStrata = "LOW",
      value = GetFrameByType(KeystoneTimer, FromUIProperty("ElapsedTime")):Map(function(timer)
        if timer.ShowRemainingTime then
          return Lerp(0, 100, max(0, (timer.Duration - timer.ElapsedTime) / timer.Duration))
        else 
          return Lerp(100, 0, max(0, (timer.Duration - timer.ElapsedTime) / timer.Duration))
        end
      end),
      statusBarColor = GetFrameByType(KeystoneTimer, FromUIProperty("ElapsedTime")):Map(function(timer)
        if timer.ElapsedTime > timer.Duration then
          return Color(0.3, 0.3, 0.3, 0.9)
        end

        return { r = 0, g = 148/255, b = 1, a = 0.9 }
      end),    
    },

    TwoChestLine = {
      height = 14,
      width = 2,
      drawLayer           = "OVERLAY",
      subLevel            = 2,
      texelSnappingBias    = 0,
      snapToPixelGrid     = false,
      texelSnappingBias    = 0,
      color = GetFrameByType(KeystoneTimer, FromUIProperty("ElapsedTime")):Map(function(timer)
        if timer.ElapsedTime > timer.Duration * 0.8 then 
          return Color.RED 
        end 

        return Color.GREEN
      end),
    },
    TwoChestTimer = {
      visible = GetFrameByType(KeystoneTimer, FromUIProperty("ElapsedTime")):Map(function(timer)
        if timer.showSubTimersWithRemainingTime and timer.ElapsedTime > timer.Duration * 0.8 then 
          return false
        else 
          return true
        end
      end),
      text = GetFrameByType(KeystoneTimer, FromUIProperty("ElapsedTime")):Map(function(timer)
        if timer.showSubTimersWithRemainingTime then 
          return SecondsToClock(max(0, timer.Duration * 0.8 - timer.ElapsedTime))
        else 
          return SecondsToClock(timer.Duration * 0.8)
        end
      end),
      textColor = GetFrameByType(KeystoneTimer, FromUIProperty("ElapsedTime")):Map(function(timer)
        if timer.ElapsedTime > timer.Duration * 0.8 then 
          return Color.RED 
        end 

        return Color.GREEN
      end),
      height = 25,
      justifyV = "MIDDLE",
      justifyH = "CENTER",
    },

    ThreeChestLine = {
      height = 14,
      width = 2,
      drawLayer           = "OVERLAY",
      subLevel            = 2,
      texelSnappingBias    = 0,
      snapToPixelGrid     = false,
      texelSnappingBias    = 0,
      color = GetFrameByType(KeystoneTimer, FromUIProperty("ElapsedTime")):Map(function(timer)
        if timer.ElapsedTime > timer.Duration * 0.6 then 
          return Color.RED 
        end 

        return Color.GREEN
      end),
    },

    ThreeChestTimer = {
      visible = GetFrameByType(KeystoneTimer, FromUIProperty("ElapsedTime")):Map(function(timer)
        if timer.showSubTimersWithRemainingTime and timer.ElapsedTime > timer.Duration * 0.6 then 
          return false
        else 
          return true
        end
      end),

      text = GetFrameByType(KeystoneTimer, FromUIProperty("ElapsedTime")):Map(function(timer)
        if timer.showSubTimersWithRemainingTime then 
          return SecondsToClock(max(0, timer.Duration * 0.6 - timer.ElapsedTime))
        else 
          return SecondsToClock(timer.Duration * 0.6)
        end
      end),
      textColor = GetFrameByType(KeystoneTimer, FromUIProperty("ElapsedTime")):Map(function(timer)
        if timer.ElapsedTime > timer.Duration * 0.6 then 
          return Color.RED 
        end 

        return Color.GREEN
      end),
      height = 25,
      justifyV = "MIDDLE",
      justifyH = "CENTER",
    }
  },

  [KeystoneAffixes] = {
    height = 24,
    width = 72,
  },

  [KeystoneEnemyForces] = {
    autoAdjustHeight = true,
    Text = {
      text = "Enemy Forces",
      mediaFont = FontType("PT Sans Narrow Bold", 13),
      textColor = Color(0.9, 0.9, 0.9),
    },

    Progress = {
      value = GetFrameByType(KeystoneEnemyForces, FromUIProperty("EnemyForcesQuantity")):Map(function(enemyForces)
        return enemyForces.EnemyForcesQuantity
      end),

      minMaxValues = GetFrameByType(KeystoneEnemyForces, FromUIProperty("EnemyForcesTotalQuantity")):Map(function(enemyForces)
        return MinMax(0, enemyForces.EnemyForcesTotalQuantity)
      end),

      extraValue = GetFrameByType(KeystoneEnemyForces, FromUIProperty("EnemyForcesPendingQuantity")):Map(function(enemyForces)
        return min(enemyForces.EnemyForcesPendingQuantity + enemyForces.EnemyForcesQuantity, enemyForces.EnemyForcesTotalQuantity)
      end),

      Text = {
        text = GetFrameByType(KeystoneEnemyForces, FromUIProperty("EnemyForcesQuantity", "EnemyForcesTotalQuantity", "EnemyForcesPendingQuantity"))
              :Next()
              :Map(function(_, current, total, pending)
                if pending > 0 then 
                  return string.format("%i / %i ( %i )", current, total, pending)
                end 

                return string.format("%i / %i", current, total)
              end)
      }
    }
  },

  [KeystoneContentView] = {
    Header = {
      visible = false
    },

    TopDungeonInfo = {
      backdrop = {
        bgFile = [[Interface\Buttons\WHITE8X8]],
        edgeFile  = [[Interface\Buttons\WHITE8X8]],
        edgeSize  = 1
      },
      backdropColor       = { r = 0, g = 0, b = 0, a = 0.65}, -- 87
      backdropBorderColor = { r = 35/255, g = 40/255, b = 46/255, a = 0.73},
      height = 48,

      DungeonIcon = {
        fileID = FromUIProperty("DungeonTextureFileID"),
        texCoords = { left = 0.04,  right = 0.64, top = 0.02, bottom = 0.70 } ,
        vertexColor = { r = 1, g = 1, b = 1, a = 0.5 },
        height = 44,
      },

      Level = {
        text = FromUIProperty("KeystoneLevel"):Map(function(level)
          return CHALLENGE_MODE_POWER_LEVEL:format(level)
        end),
        justifyV = "TOP",
        justifyH = "LEFT",
      },
      
      DungeonName = {
        text = FromUIProperty("DungeonName"),
        fontObject = Game18Font,
        textColor = { r = 1, g = 0.914, b = 0.682},
        justifyV = "MIDDLE",
        justifyH = "CENTER",
      }
    },

    Content = {
      autoAdjustHeight = true,
      paddingBottom = 5,

      backdrop = { 
        bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
      },

      backdropColor = { r = 35/255, g = 40/255, b = 46/255, a = 0.73},

      Objectives = {
        autoAdjustHeight = true,
        height = 32,
      },
      
      EnemyForces = {
        Progress = {
          ExtraBarTexture = {
            vertexColor = { r = 1, g = 193/255, b = 25/255, a = 0.7}
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
          Anchor("LEFT", 70, 0),
          Anchor("TOP"),
          Anchor("BOTTOM"),
          Anchor("RIGHT")
        }        
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
  KeystoneContentView
)