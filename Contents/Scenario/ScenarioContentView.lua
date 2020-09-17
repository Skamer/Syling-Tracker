-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Scorpio              "SylingTracker.Scenario.ContentView"                    ""
-- ========================================================================= --
namespace                           "SLT"
-- ========================================================================= --
-- Iterator helper for ignoring the children are used for backdrop, and avoiding
-- they are taken as account for their parent height
IterateFrameChildren  = Utils.IterateFrameChildren
-- ========================================================================= --
ValidateFlags         = System.Toolset.validateflags
ResetStyles           = Utils.ResetStyles
-- ========================================================================= --
class "ScenarioContentHeader" (function(_ENV)
  inherit "ContentHeader"

  __Template__ {
    Name = SLTFontString
  }
  function __ctor(self) end 
end)

__Recyclable__ "SylingTracker_ScenarioContentView%d"
class "ScenarioContentView" (function(_ENV)
  inherit "ContentView"

  __Flags__()
  enum "Flags" {
    NONE                  = 0,
    HAS_OBJECTIVES        = 1,
    HAS_BONUS_OBJECTIVES  = 2,
  }
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data)
    local scenarioData = data.scenario 
    if not scenarioData then 
      return 
    end 

    local name = scenarioData.name 
    if name then 
      local nameFrame = self:GetChild("Header"):GetChild("ScenarioName")
      Style[nameFrame].text = name 
    end

    -- Stage Part
    local contentFrame = self:GetChild("Content")
    local stageFrame = contentFrame:GetChild("Stage")

    local currentStage, numStages = scenarioData.currentStage, scenarioData.numStages
    if currentStage and numStages then 
      local stageCounter = stageFrame:GetChild("Counter")
      Style[stageCounter].text = string.format("%i/%i", currentStage, numStages)
    end 

    local stageName = scenarioData.stageName
    if stageName then 
      local stageNameFrame = stageFrame:GetChild("Name")
      Style[stageNameFrame].text = stageName
    end


    -- Determine the flags 
    local flags = Flags.NONE 
    if scenarioData.objectives then 
      flags = flags + Flags.HAS_OBJECTIVES
    end

    if scenarioData.bonusObjectives then 
      flags = flags + Flags.HAS_BONUS_OBJECTIVES
    end

    if flags ~= self.Flags then 
      ResetStyles(self)
      -- REVIEW: Probably need adding the header

      -- Is the scenario has objectives
      if ValidateFlags(Flags.HAS_OBJECTIVES, flags) then 
        self:AcquireObjectives()
      else
        self:ReleaseObjectives()
      end
      
      -- Is the scenario has bonus objectives
      if ValidateFlags(Flags.HAS_BONUS_OBJECTIVES, flags) then 
        objectivesView = self:AcquireBonusObjectives()
      else
        self:ReleaseBonusObjectives()
      end



      -- Styling stuff
      if flags ~= Flags.NONE then 
        local styles = self.FlagsStyles and self.FlagsStyles[flags]
        if styles then 
          Style[self] = styles
        end 
      end
    end

    -- Update the conditional children if exists 
    if scenarioData.objectives then 
      local objectivesView = self:AcquireObjectives()
      objectivesView:UpdateView(scenarioData.objectives)
    end

    if scenarioData.bonusObjectives then
      local bonusObjectivesView = self:AcquireBonusObjectives()
      bonusObjectivesView:UpdateView(scenarioData.bonusObjectives)
    end

    -- Don't forget to set the new flag for avoiding "Flashy" behaviors
    self.Flags = flags
  end

  -- function OnAdjustHeight(self, useAnimation)
  --   local height = 0
  --   local maxOuterBottom 

  --   for childName, child in self:GetChilds() do
  --     local outerBottom = child:GetBottom() 
  --     if outerBottom then 
  --       if not maxOuterBottom or maxOuterBottom > outerBottom then 
  --         maxOuterBottom = outerBottom
  --       end 
  --     end 
  --   end
    
  --   if maxOuterBottom then 
  --     local computeHeight = self:GetTop() - maxOuterBottom + self.PaddingBottom
  --     if useAnimation then 
  --       self:SetAnimatedHeight(computeHeight)
  --     else 
  --       self:SetHeight(computeHeight)
  --     end
  --   end
  -- end

  function AcquireObjectives(self)
    local content = self:GetChild("Content")
    local objectives = content:GetChild("Objectives")
    if not objectives then 
      objectives = self.ObjectivesClass.Acquire()

      -- We need to keep the old name when we'll release it
      self.__previousObjectivesName = objectives:GetName()

      objectives:SetParent(content)
      objectives:SetName("Objectives")

      objectives.OnSizeChanged = objectives.OnSizeChanged + self.OnObjectivesSizeChanged
    
      -- self:AdjustContentHeight()
      self:AdjustHeight(true)
    end

    return objectives 
  end

  function ReleaseObjectives(self)
    local content = self:GetChild("Content")
    local objectives = content:GetChild("Objectives")
    if objectives then 
      -- Give its old name (generated by the recycle system)
      objectives:SetName(self.__previousObjectivesName)
      self.__previousObjectivesName = nil 

      -- Unregister the events
      objectives.OnSizeChanged = objectives.OnSizeChanged - self.OnObjectivesSizeChanged

      -- It's better to release after events have been un registered for avoiding
      -- useless calls
      objectives:Release()

      -- self:AdjustContentHeight()
      self:AdjustHeight(true)
    end
  end

  function AcquireBonusObjectives(self)
    local bonusObjectives = self.__bonusObjectives
    if not bonusObjectives then
      local content = self:GetChild("Content")

      bonusObjectives = self.BonusObjectivesClass.Acquire()
      local bonusObjectivesText = SLTFontString.Acquire()
      local bonusObjectivesIcon = IconBadge.Acquire()

      self.__bonusObjectives = bonusObjectives
      self.__bonusObjectivesText = bonusObjectivesText
      self.__bonusObjectivesIcon = bonusObjectivesIcon 

      -- We need to keep the old name when we'll release it 
      self.__previousBonusObjectivesName = bonusObjectives:GetName()
      self.__previousBonusObjectivesTextName = bonusObjectivesText:GetName()
      self.__previousBonusObjectivesIconName = bonusObjectivesIcon:GetName()

      bonusObjectives:SetParent(content)
      bonusObjectivesText:SetParent(content)
      bonusObjectivesIcon:SetParent(content)

      bonusObjectives:SetName("BonusObjectives")
      bonusObjectivesText:SetName("BonusObjectivesText")
      bonusObjectivesIcon:SetName("BonusObjectivesIcon")


      bonusObjectives.OnSizeChanged = bonusObjectives.OnSizeChanged + self.OnObjectivesSizeChanged

      -- self:AdjustContentHeight()
      self:AdjustHeight(true)
    end

    return bonusObjectives
  end

  function ReleaseBonusObjectives(self)
    local bonusObjectives = self.__bonusObjectives
    if bonusObjectives then
      local bonusObjectivesText = self.__bonusObjectivesText
      local bonusObjectivesIcon = self.__bonusObjectivesIcon

      self.__bonusObjectives = nil
      self.__bonusObjectivesIcon = nil 
      self.__bonusObjectivesText = nil 

      -- Give its old name (generated by the recycle system) 
      bonusObjectives:SetName(self.__previousBonusObjectivesName)
      bonusObjectivesText:SetName(self.__previousBonusObjectivesTextName)
      bonusObjectivesIcon:SetName(self.__previousBonusObjectivesIconName)

      self.__previousBonusObjectivesName = nil
      self.__previousBonusObjectivesTextName = nil 
      self.__previousBonusObjectivesIconName = nil

      -- Unregister the events
      bonusObjectives.OnSizeChanged = bonusObjectives.OnSizeChanged - self.OnObjectivesSizeChanged

      -- It's better to release after events have been un registered for avoiding
      -- useless calls
      bonusObjectives:Release()
      bonusObjectivesText:Release()
      BonusObjectivesIcon:Release()

      -- self:AdjustContentHeight()
      self:AdjustHeight(true)
    end 
  end

  function OnRelease(self)
    -- First, release the children
    self:ReleaseObjectives()

    self:ClearAllPoints()
    self:SetParent()
    self:Hide()

    -- "CancelAdjustHeight" and "CancelAnimatingHeight" wiil cancel the pending
    -- computing stuff for height, so they not prevent "SetHeight" here doing 
    -- its stuff.
    self:CancelAdjustHeight()
    self:CancelAnimatingHeight()
    self:SetHeight(1)

    -- Reset the class properties
    self.Flags  = nil

    -- Will Remove all custom styles properties, so the  next time the object will
    -- be used, this one will be in a clean state
    ResetStyles(self)
  end

  function OnAcquire(self)
    -- Important ! We need the frame is instantly styled as this may affect 
    -- its height.
    self:InstantApplyStyle()

    self:Show()
    self:AdjustContentHeight()
    self:AdjustHeight(true)
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "PaddingBottom" {
    type      = Number,
    default   = 10
  }

  property "Flags" {
    type    = ScenarioContentView.Flags,
    default = ScenarioContentView.Flags.NONE
  }

  property "ObjectivesClass" {
    type    = ClassType,
    default = ObjectiveListView
  }
  
  property "BonusObjectivesClass" {
    type    = ClassType,
    default = ObjectiveListView
  }

  property "FlagsStyles" {
    type = Table
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  -- __Template__ {
  --   Header  = ScenarioContentHeader,
  --   Stage   = Frame,
  --   {
  --     Stage = {
  --       Counter = SLTFontString,
  --       Name    = SLTFontString
  --     }
  --   }
  -- }

  __Template__ {
    {
      Header = {
        ScenarioName = SLTFontString
      },
      Content = {
        Stage = Frame,
        {
          Stage = {
            Counter = SLTFontString,
            Name    = SLTFontString
          }
        }
      }
    }
  }
  function __ctor(self)
    -- Important! As the frame ajusts its height depending of its children height
    -- we need to set its height when contructed for the event "OnSizechanged" of
    -- its children is triggered.
    self:SetHeight(1) -- !important

    self.OnObjectivesSizeChanged = function() self:AdjustHeight(true) end

    self:SetClipsChildren(true)

    self:AdjustContentHeight()
  end

end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [ScenarioContentHeader] = {
    Label = {
      sharedMediaFont = FontType("PT Sans Narrow Bold", 13),
      justifyV = "TOP",
    },
    Name = {
      sharedMediaFont = FontType("PT Sans Caption Bold", 13),
      textColor = Color(1, 233/255, 174/255),
      justifyV = "BOTTOM",
      textTransform = "UPPERCASE",
      location = {
        Anchor("TOP"),
        Anchor("LEFT", 0, 0, "IconBadge", "RIGHT"),
        Anchor("RIGHT"),
        Anchor("BOTTOM", 0, 2)
      }
    }
  },

  [ScenarioContentView] = {
    backdrop = { 
      bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
      -- edgeFile = [[Interface\Buttons\WHITE8X8]],
      -- edgeSize = 1
    },
    backdropColor = { r = 35/255, g = 40/255, b = 46/255, a = 0.73},

    Header = {
      height = 32,
      -- backdropColor = { r = 0, g = 74/255, b = 127/255, a = 0.73 },
      backdropBorderColor = { r = 0, g = 0, b = 0, a = 0 },
      location = {
        Anchor("TOPLEFT"),
        Anchor("TOPRIGHT")
      },

      IconBadge = {
        backdropColor = { r = 0, g = 0, b = 0, a = 0},
        Icon = {
          atlas = AtlasType("ScenariosIcon")
        }
      },

      Label = {
        text = "Scenario",
        sharedMediaFont = FontType("PT Sans Narrow Bold", 14),
        justifyV = "TOP"
      },

      ScenarioName = {
        sharedMediaFont = FontType("PT Sans Caption Bold", 13),
        textColor = Color(1, 233/255, 174/255),
        justifyV = "BOTTOM",
        textTransform = "UPPERCASE",
        location = {
          Anchor("TOP"),
          Anchor("LEFT", 0, 0, "IconBadge", "RIGHT"),
          Anchor("RIGHT"),
          Anchor("BOTTOM", 0, 2)
        }
      }
    },
    Content = {
      Stage = {
        height = 20,
        location = {
          Anchor("TOP"),
          Anchor("LEFT"),
          Anchor("RIGHT")
        },

        Counter = {
          sharedMediaFont = FontType("PT Sans Narrow Bold", 13),
          textColor = Color(1, 1, 1),
          location = {
            Anchor("TOP", 0, -4),
            Anchor("LEFT", 4, 0),
            Anchor("BOTTOM", 0, 4)
          }
        },

        Name = {
          sharedMediaFont = FontType("PT Sans Narrow Bold", 13),
          textColor = Color(1, 1, 0),
          justifyH = "LEFT",
          location = {
            Anchor("TOP", 0, -4),
            Anchor("LEFT", 10, 0, "Counter", "RIGHT"),
            Anchor("BOTTOM", 0, 4),
            Anchor("RIGHT")
          }
        }
      }
    },
    FlagsStyles = {
      [ScenarioContentView.Flags.HAS_OBJECTIVES] = {
        Content = {
          Objectives = {
            location = {
              Anchor("TOP", 0, -4, "Stage", "BOTTOM"),
              Anchor("LEFT"),
              Anchor("RIGHT")
            }
          }
        }
      },
      [ScenarioContentView.Flags.HAS_OBJECTIVES + ScenarioContentView.Flags.HAS_BONUS_OBJECTIVES] = {
        Content = {
          Objectives = {
            location = {
              Anchor("TOP", 0, -4, "Stage", "BOTTOM"),
              Anchor("LEFT"),
              Anchor("RIGHT")
            }
          },

          BonusObjectivesText = {
            text = TRACKER_HEADER_BONUS_OBJECTIVES,
            height = 16,
            sharedMediaFont = FontType("PT Sans Narrow Bold", 13),
            location = {
              Anchor("TOP", 0, -8, "Objectives", "BOTTOM"),
            }
          },

          BonusObjectivesIcon = {
            width = 16,
            height = 16,
            Icon = {
              atlas = AtlasType("VignetteEventElite")
            },
            location = {
              Anchor("RIGHT", 0, 0, "BonusObjectivesText", "LEFT")
            }
          },

          BonusObjectives = {
            location = {
              Anchor("TOP", 0, -4, "BonusObjectivesText", "BOTTOM"),
              Anchor("LEFT"),
              Anchor("RIGHT")
            }
          }
        }
      }
    }
  }
})