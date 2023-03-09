-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                  "SylingTracker.Keystone.ContentView"                 ""
-- ========================================================================= --
namespace                          "SLT"
-- ========================================================================= --
-- Iterator helper for ignoring the children are used for backdrop, and avoiding
-- they are taken as account for their parent height
IterateFrameChildren  = Utils.IterateFrameChildren
-- ========================================================================= --
ValidateFlags         = System.Toolset.validateflags
ResetStyles           = Utils.ResetStyles
-- ========================================================================= --
GameTooltip           = GameTooltip
-- ========================================================================= --
__Recyclable__ "SylingTracker_KeyStoneAffix%d"
class "KeystoneAffix" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnSetTexture(self, new)
    Style[self].Icon.fileID = new
  end

  local function UpdateTooltip(self, new)
    if new then 
      self.OnEnter = function()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText(self.Name, 1, 1, 1, 1, true)
        GameTooltip:AddLine(new, nil, nil, nil, true)
        GameTooltip:Show()
      end

      self.OnLeave = function() GameTooltip:Hide() end 
    else 
      self.OnEnter  = nil 
      self.OnLeave  = nil
    end
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "Name" {
    type    = String,
  }

  property "Desc" {
    type    = String,
    handler = UpdateTooltip
  }

  property "Texture" {
    type    = String + Number,
    handler = OnSetTexture
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__{
    Icon = Texture
  }
  function __ctor(self) 
    self:InstantApplyStyle()
  end

end)

__Recyclable__ "SylingTracker_KeystoneAffixes%d"
class "KeystoneAffixes" (function(_ENV)
  inherit "Frame" 
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  local function OnAffixesCountChanged(self, new, old)
    if new > old then 
      for i = 1, new - old do 
        local affix = self:AcquireAffix(new)
      end 
    end
        
    -- Update the anchor
    local previousAffix
    local width = 0
    for i = 1, new do
      local affix = self:AcquireAffix(i)
      if i == 1 then
        affix:SetPoint("TOP")
        affix:SetPoint("LEFT")
      else 
        affix:SetPoint("TOP")
        affix:SetPoint("LEFT", previousAffix, "RIGHT", self.AffixSpacing, 0)
      end 

      width = width + affix:GetWidth()

      previousAffix = affix
    end
    
    self:SetWidth(width + math.max(0, new-1) * self.AffixSpacing)

    self:ReleaseUnusedAffixes(new)
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function AcquireAffix(self, index)
    local affix = self.affixesCache[index]
    if not affix then 
      affix = KeystoneAffix.Acquire()
      affix:SetParent(self)

      self.affixesCache[index] = affix 
    end
    
    return affix
  end

  function ReleaseUnusedAffixes(self, releaseAbove)
    for index, affix in ipairs(self.affixesCache) do 
      if index > releaseAbove then 
        affix:Release()
        self.affixesCache[index] = nil 
      end
    end 
  end 
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "AffixesCount" {
    type    = Number,
    default = 0,
    handler = OnAffixesCountChanged
  }

  property "AffixSpacing" {
    type = Number,
    default = 5,
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  function __ctor(self)
    self:InstantApplyStyle()

    self.affixesCache = setmetatable({}, { __mode = "v"})
  end
end)


class "KeystoneTimer" (function(_ENV)
  inherit "Frame" extend "ITimer"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------  
  local function OnTimeLimitChanged(self, new, old)
      local timeLimit2Key = new * 0.8
      local timeLimit3Key = new * 0.6

      local timerText         = self:GetChild("TimerText")
      local timeLimitPlus2FS  = self:GetChild("TimeLimitPlus2")
      local timeLimitPlus3FS  = self:GetChild("TimeLimitPlus3")


      if self.ShowRemainingTime then 
        Style[timerText].text = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(SecondsToClock(self.TimeLimit))
      else 
        Style[timerText].text = string.format("%s / %s", 
        HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(SecondsToClock(0)), 
        SecondsToClock(self.TimeLimit))
      end

      Style[timeLimitPlus2FS].text = string.format("[+2] %s", SecondsToClock(timeLimit2Key))
      Style[timeLimitPlus3FS].text = string.format("[+3] %s", SecondsToClock(timeLimit3Key))
  end

  local function OnPlusFailedChanged(self, new, old, prop)
    local color
    if new then 
      color = Color(1, 0, 0)
    else 
      color = Color(38/255, 127/255, 0)
    end

    if prop == "Plus2Failed" then 
      local timeLimitPlus2FS = self:GetChild("TimeLimitPlus2")
      Style[timeLimitPlus2FS].textColor = color 
    elseif prop == "Plus3Failed" then 
      local timeLimitPlus3FS = self:GetChild("TimeLimitPlus3")
      Style[timeLimitPlus3FS].textColor = color 
    end 
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function OnTimerUpdate(self, elapsedTime)
    local timerBar    = self:GetChild("TimerBar")
    local timerText   = self:GetChild("TimerText")

    local notTimed = elapsedTime > self.TimeLimit
    local timeLeft = math.max(0, self.TimeLimit - elapsedTime)

    local CURRENT_FONT_COLOR = HIGHLIGHT_FONT_COLOR
    if notTimed then 
      CURRENT_FONT_COLOR = RED_FONT_COLOR
    end
    local timeLeft = math.max(0, self.TimeLimit - elapsedTime)

    if self.ShowRemainingTime then 
      Style[timerText].text = CURRENT_FONT_COLOR:WrapTextInColorCode(SecondsToClock(timeLeft))
    else 
      Style[timerText].text = string.format("%s / %s", 
      CURRENT_FONT_COLOR:WrapTextInColorCode(SecondsToClock(elapsedTime)), 
      SecondsToClock(self.TimeLimit))
    end

    timerBar:SetMinMaxValues(0, self.TimeLimit)
    timerBar:SetValue(timeLeft)

    self.Plus2Failed = elapsedTime > (self.TimeLimit * 0.8)
    self.Plus3Failed = elapsedTime > (self.TimeLimit * 0.6)
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "TimeLimit" {
    type = Number,
    default = 0,
    handler = OnTimeLimitChanged
  }
  
  property "ShowRemainingTime" {
    type = Boolean,
    default = false 
  }

  property "Plus2Failed" {
    type = Boolean,
    default = false,
    handler = OnPlusFailedChanged
  }

  property "Plus3Failed" {
    type = Boolean,
    default = false,
    handler = OnPlusFailedChanged
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__{
    TimerText = SLTFontString,
    TimerBar = ProgressBar,
    TimeLimitPlus2 = SLTFontString,
    TimeLimitPlus3 = SLTFontString
  }
  function __ctor(self)
  end

end)

__Recyclable__ "SylingTracker_KeystoneContentView%d"
class "KeystoneContentView" (function(_ENV)
  inherit "ContentView"

  enum "State" {
    None      = 0,
    Progress  = 1,
    Finished  = 2
  }

  __Flags__()
  enum "Flags" {
    NONE            = 0,
    HAS_OBJECTIVES  = 1
  }
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data)
    local keystoneData = data.keystone 
    if not keystoneData then 
      return 
    end

    -- Get the elements
    local contentFrame    = self:GetChild("Content")
    local headerFrame     = self:GetChild("Header")
    local topInfoFrame    = contentFrame:GetChild("TopInfo")
    local dungeonNameFS   = headerFrame:GetChild("DungeonName")
    local levelFS         = topInfoFrame:GetChild("Level")
    local deathCountFrame = topInfoFrame:GetChild("DeathCount")
    local affixesFrame    = topInfoFrame:GetChild("Affixes")
    local dungeonIcon     = contentFrame:GetChild("DungeonIcon")
    local timerFrame      = contentFrame:GetChild("Timer")

    -- Determine the state
    local state = State.Progress

    -- Determine the flags 
    local flags = Flags.NONE 

    if keystoneData.objectives then 
      flags = flags + Flags.HAS_OBJECTIVES
    end

    -- ACQUIRE, RELEASE AND STYLING PART
    if state ~= self.State or flags ~= self.Flags then 
      ResetStyles(self)
      -- REVIEW Probably need adding the elements ???

      local stateStyles
      if state ~= State.None then 
        stateStyles = self.StatesStyles and self.StatesStyles[state]
        if stateStyle then 
         Style[self] = stateStyles
        end
      end
      
      if flags ~= self.Flags then

        -- Is the keystone has objectives
        if ValidateFlags(Flags.HAS_OBJECTIVES, flags) then 
          self:AcquireObjectives()
        else
          self:ReleaseObjectives() 
        end


        if flags ~= Flags.NONE then 
          -- Skin Stuffs for flags 
          local flagsStyles = self.FlagsStyles and self.FlagsStyles[flags]
          if flagsStyles then
            Style[self] = flagsStyles 
          end


          -- Override the flags styles by those of state if exists 
          flagsStyles = stateStyles and stateStyles.FlagsStyles
          if flagsStyles then 
            Style[self] = flagsStyles
          end
        end
      end
    end

    -- Update the elements with data

    -- Update dungeon Name 
    if dungeonNameFS then 
      Style[dungeonNameFS].text = keystoneData.name
    end 

    -- Update Level
    local level = keystoneData.level 
    if level then 
      Style[levelFS].text = CHALLENGE_MODE_POWER_LEVEL:format(level)
    end 

    -- Update Death
    local death = keystoneData.death
    local timeLost = keystoneData.timeLost or 0
    if death and death > 0 then 
      Style[deathCountFrame].visible = true 
      Style[deathCountFrame].TextFS.text = tostring(death)

      deathCountFrame.OnEnter = function()
        GameTooltip:SetOwner(deathCountFrame, "ANCHOR_TOPRIGHT")
        GameTooltip:SetText(CHALLENGE_MODE_DEATH_COUNT_TITLE:format(death), 1, 1, 1)
        GameTooltip:AddLine(CHALLENGE_MODE_DEATH_COUNT_DESCRIPTION:format(SecondsToClock(timeLost)))
        GameTooltip:Show()
      end

      deathCountFrame.OnLeave = function() GameTooltip:Hide() end 
    else
      Style[deathCountFrame].visible = false
      deathCountFrame.OnEnter = nil 
      deathCountFrame.OnLeave = nil
    end 

    -- Update Affixes
    local affixes = keystoneData.affixes 
    local numAffixes = keystoneData.numAffixes
    
    affixesFrame.AffixesCount = numAffixes
    for affixIndex, affixData in ipairs(affixes) do 
      local affixFrame = affixesFrame:AcquireAffix(affixIndex)
      affixFrame.Name = affixData.name 
      affixFrame.Texture = affixData.texture 
      affixFrame.Desc = affixData.desc 
    end

    -- Update Dungeon Icon
    local dungeonTexture = keystoneData.texture 
    if dungeonTexture then 
      Style[dungeonIcon].Icon.fileID = dungeonTexture
    end

    -- Update Timer
    local timeLimit = keystoneData.timeLimit 
    local startTime = keystoneData.startTime
    local completed = keystoneData.completed

    if timeLimit then 
      timerFrame.TimeLimit = timeLimit
    end

    if startTime then
      timerFrame.StartTime = startTime

      if not completed then 
        timerFrame:Start()
      else
        timerFrame:Stop()
      end
    end


    -- Update Objectives if exists 
    local objectivesData = keystoneData.objectives
    if objectivesData then 
      local objectivesView = self:AcquireObjectives()
      objectivesView:UpdateView(objectivesData)
    end 

    self.Flags = flags 
    self.State = state 
  end

  function AcquireObjectives(self)
    local content = self:GetChild("Content")
    local objectives = content:GetChild("Objectives")
    
    if not objectives then 
      objectives = self.ObjectivesClass.Acquire()

      -- We need to keep the old name when we'll release it
      self.__PreviousObjectivesName = objectives:GetName()

      objectives:SetParent(content)
      objectives:SetName("Objectives")
      objectives:InstantApplyStyle()

      objectives.OnSizeChanged = objectives.OnSizeChanged + self.OnObjectivesSizeChanged

      self:AdjustHeight(true)
    end

    return objectives
  end

  function ReleaseObjectives(self)
    local content = self:GetChild("Content")
    local objectives = content:GetChild("Objectives")

    if objectives then 
      -- Give its old name (generated by the recycle system)
      objectives:SetName(self.__PreviousObjectivesName)
      self.__PreviousObjectivesName = nil 

      -- Unregister the events 
      objectives.OnSizeChanged = objectives.OnSizeChanged - self.OnObjectivesSizeChanged

      -- It's better to release after events have been un registered for avoiding
      -- useless calls
      objectives:Release()

      self:AdjustHeight(true)
    end
  end

  function OnRelease(self)
    -- First, release the children
    self:ReleaseObjectives()

    -- Reset the timer 
    local timer =self:GetChild("Content"):GetChild("Timer")
    timer:Stop()
    timer.TimeLimit = nil 
    timer.ShowRemainingTime = nil 
    timer.Plus2Failed = nil 
    timer.Plus3Failed = nil

    -- We call the "Parent" onRelease (see, ContentView)
    super.OnRelease(self)

    -- Reset the class properties
    self.Flags = nil
    self.State = nil
  end 
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "Flags" {
    type    = KeystoneContentView.Flags,
    default = KeystoneContentView.Flags.NONE 
  }

  property "State" {
    type    = KeystoneContentView.State,
    default = KeystoneContentView.State.None
  }

  property "ObjectivesClass" {
    type    = ClassType,
    default = ObjectiveListView
  }


  property "FlagsStyles" {
    type = Table
  }

  property "StatesStyles" {
    type = Table
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__{
    {
      Header = {
        DungeonName = SLTFontString
      },
      Content = {
        TopInfo     = Frame, 
        DungeonIcon = IconBadge,
        Timer       = KeystoneTimer,
        {
          TopInfo = {
            Level       = SLTFontString,
            Affixes     = KeystoneAffixes,
            DeathCount  = Frame,
            {
              DeathCount = {
                IconTex  = Texture,
                TextFS   = SLTFontString
              }
            }
          }
        }
      }
    }
  }
  function __ctor(self)
    self.OnObjectivesSizeChanged = function() self:AdjustHeight(true) end
  end
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [KeystoneAffix] = {
    width   = 24,
    height  = 24,

    Icon = {
      setAllPoints = true,
      texCoords = RectType(0.07, 0.93, 0.07, 0.93)
    }
  },

  [KeystoneTimer] = {
    height = 64,

    TimerText = {
      height = 24,
      textColor = Color(1, 1, 1),
      sharedMediaFont = FontType("PT Sans Narrow Bold", 21),
      location = {
        Anchor("TOP"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      }
    },

    TimerBar = {
      height = 16,
      location = {
        Anchor("TOP", 0, -2, "TimerText", "BOTTOM"),
        Anchor("LEFT", 10, 0),
        Anchor("RIGHT", -10, 0)
      }
    },

    TimeLimitPlus2 = {
      height = 16,
      textColor = Color(38/255, 127/255, 0),
      sharedMediaFont = FontType("PT Sans Narrow Bold", 14),
      location = {
        Anchor("TOPRIGHT", 0, -5, "TimerBar", "BOTTOM"),
        Anchor("LEFT", 0, 0),
      }
    },
    TimeLimitPlus3 = {
      height = 16,
      textColor = Color(38/255, 127/255, 0),
      sharedMediaFont = FontType("PT Sans Narrow Bold", 14),
      location = {
        Anchor("TOPLEFT", 0, -5, "TimerBar", "BOTTOM"),
        Anchor("RIGHT", 0, 0),
      }
    }
  },

  [KeystoneContentView] = {
    Header = {
      IconBadge = {
        Icon = {
          atlas = AtlasType("Dungeon")
        }
      },

      Label = {
        text            = "Mythic +",
        sharedMediaFont = FontType("PT Sans Narrow Bold", 13),
        justifyV        = "TOP"
      },

      DungeonName = {
        sharedMediaFont = FontType("PT Sans Caption Bold", 13),
        textColor       = Color(1, 233/255, 174/255),
        justifyV        = "BOTTOM",
        textTransform   = "UPPERCASE",
        location        = {
          Anchor("TOP"),
          Anchor("LEFT", 0, 0, "IconBadge", "RIGHT"),
          Anchor("RIGHT"),
          Anchor("BOTTOM", 0, 2)
        }
      }
    },

    Content = {
      backdrop = {
        bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
      },
      backdropColor = { r = 35/255, g = 40/255, b = 46/255, a = 0.73},

      TopInfo = {
        height = 28,
        backdrop = { 
          bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
        },
        backdropColor = { r = 0.1, g = 0.1, b = 0.1, a = 0.7},
        location = {
          Anchor("TOP"),
          Anchor("LEFT"),
          Anchor("RIGHT")
        },

        Level = {
          height = 24,
          sharedMediaFont = FontType("PT Sans Narrow Bold", 13),
          textTransform   = "UPPERCASE",
          location = {
            Anchor("TOP"),
            Anchor("LEFT", 5, 0),
          }
        },

        Affixes = {
          height = 28,
          location = {
            Anchor("TOP", 0, -2)
          }
        },

        DeathCount = {
          height = 24,
          width = 38,
          location = {
            Anchor("TOP"),
            Anchor("RIGHT", -5, 0),
          },

          IconTex = {
            atlas = AtlasType("poi-graveyard-neutral", true),
            location = {
              Anchor("LEFT")
            }
          },

          TextFS = {
            sharedMediaFont = FontType("PT Sans Caption Bold", 10),
            shadowOffset = { x = 0.5, y = 0},
            shadowColor = Color(0, 0, 0, 1),
            justifyH = "LEFT",
            
            location = {
              Anchor("TOP"),
              Anchor("LEFT", 5, 0, "IconTex", "RIGHT"),
              Anchor("RIGHT"),
              Anchor("BOTTOM")              
            }
          }
        },
      },

      DungeonIcon = {
        width = 64,
        height = 64,
        location = {
          Anchor("TOP", 0, -5, "TopInfo", "BOTTOM"),
          Anchor("LEFT", 5, 0)
        }
      },

      Timer = {
        location = {
          Anchor("TOP", 0, -5, "TopInfo", "BOTTOM"),
          Anchor("LEFT", 5, 0, "DungeonIcon", "RIGHT"),
          Anchor("RIGHT", -5, 0)
        }
      }
    },

    FlagsStyles = {
      [KeystoneContentView.Flags.HAS_OBJECTIVES] = {
        Content = {
          Objectives = {
            spacing = 5,
            location = {
              Anchor("TOP", 0, -10, "DungeonIcon", "BOTTOM"),
              Anchor("LEFT", 5, 0),
              Anchor("RIGHT", -5, 0)
            }
          }
        }
      }
    }
  }
})