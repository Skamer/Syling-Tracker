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
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                              Constructors                               --
  -----------------------------------------------------------------------------
  __Template__ {
    Timer = Timer,
    TimerBar = ProgressBar,
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
      self.DungeonTextureFileID = data.textureFileID

      local objectives = self:GetChild("Objectives")
      objectives:UpdateView(data.objectives, metadata)

      local affixes = self:GetChild("TopDungeonInfo"):GetChild("Affixes")
      affixes:UpdateFromData(data.affixes)

      local timer = self:GetChild("TimerInfo"):GetChild("Timer")
      timer.StartTime = data.startTime
      timer.Duration = data.timeLimit
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
  -----------------------------------------------------------------------------
  --                              Constructors                               --
  -----------------------------------------------------------------------------
  __Template__{
    TopDungeonInfo = Frame,
    TimerInfo = KeystoneTimer,
    Objectives = ObjectiveListView,
    {
      TopDungeonInfo = {
        Level       = FontString,
        Affixes = KeystoneAffixes,
        DungeonName = FontString,
        DungeonIcon = Texture,
      },
    }
  }
  function __ctor(self) end
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
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
    height = 25,
    Timer = {
      setAllPoints = true
    }
  },

  [KeystoneAffixes] = {
    height = 24,
    width = 72,

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

  [KeystoneContentView] = {
    backdrop = { 
      bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
    },
    backdropColor = { r = 35/255, g = 40/255, b = 46/255, a = 0.73},

    TopDungeonInfo = {
      backdrop = {
        bgFile = [[Interface\Buttons\WHITE8X8]],
        edgeFile  = [[Interface\Buttons\WHITE8X8]],
        edgeSize  = 1
      },
      backdropColor       = { r = 0, g = 0, b = 0, a = 0.65}, -- 87
      backdropBorderColor = { r = 35/255, g = 40/255, b = 46/255, a = 0.73},
      height = 48,

      location = {
        Anchor("TOP", 0, 0, "Header", "BOTTOM"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      },

      DungeonIcon = {
        fileID = FromUIProperty("DungeonTextureFileID"),
        texCoords = { left = 0.04,  right = 0.64, top = 0.02, bottom = 0.70 } ,
        vertexColor = { r = 1, g = 1, b = 1, a = 0.5 },
        height = 44,
        location = {
          Anchor("LEFT", 1, 0),
          Anchor("RIGHT", -1, 0)
        }

      },

      Level = {
        text = "Level 20",
        justifyV = "TOP",
        justifyH = "LEFT",
        location = {
          Anchor("TOPLEFT", 5, -5),
          -- Anchor("BOTTOMLEFT", 0, 0)
        }
      },
      Affixes = {
        location = {
          Anchor("TOPLEFT", 0, -5, "Level", "BOTTOMLEFT"),
        }
      },
      
      DungeonName = {
        -- text = "Académie d'Algeth'ar",
        text = FromUIProperty("DungeonName"),
        fontObject = Game18Font,
        textColor = { r = 1, g = 0.914, b = 0.682},
        justifyV = "MIDDLE",
        justifyH = "CENTER",

        location = {
          Anchor("LEFT", 70, 0),
          Anchor("TOP"),
          Anchor("BOTTOM"),
          Anchor("RIGHT")
        }
      }
    },

    TimerInfo = {
      location = {
        Anchor("TOP", 0, 0, "TopDungeonInfo", "BOTTOM"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      }
    },


    Objectives = {
      autoAdjustHeight = true,
      height = 32,
      -- backdrop = { 
      --   bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
      -- },
      -- backdropColor = { r = 35/255, g = 40/255, b = 46/255, a = 0.73},

      location = {
        Anchor("TOP", 0, 0, "TimerInfo", "BOTTOM"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      }
    }
  }
})