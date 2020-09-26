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
ResetStyles           = Utils.ResetStyles
-- ========================================================================= --
GameTooltip           = GameTooltip

__Recyclable__ "SylingTracker_KeyStoneAffix%d"
class "KeystoneAffix" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnSetTexture(self, new)
    print("OnSetTexture", new)
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
  
  function __ctor(self)
    self:InstantApplyStyle()

    self.affixesCache = setmetatable({}, { __mode = "v"})
  end

end)



-- -- class "KeystoneAffixesView" (function(_ENV)
-- --   inherit "Frame" extend "IView"

-- --   function OnViewUpdate(self, data)
-- --     local affixeIndex = 0
-- --     for _, affixData in pairs(data) do 
-- --       affixeIndex = affixeIndex + 1

-- --       local affix = self:AcquireAffix(affixeIndex)

-- --       -- if affixeIndex > 1 then 



-- --     end 
-- --   end

-- --   function AcquireAffix(self, id)

-- --   end

-- --   function ReleaseIconBadge(self, id)

-- --   end

-- --   function __ctor(self)


-- --   end

-- -- end)

-- class "KeystoneTimer" (function(_ENV)
--   inherit "Frame"
-- end)


-- timer chromietime-32x32
-- unitframeicon-chromietime
class "KeystoneTimer" (function(_ENV)
  inherit "Frame" extend "ITimer"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  -- function OnTimerUpdate(self, elapsedTime)
  --   local timeLeft = math.max(0, self.TimeLimit - elapsedTime)
  --   local timerBar = self:GetChild("TimerBar")
  --   local timerText = self:GetChild("TimerText")
  --   timerBar:SetValue(timeLeft)

  --   if timeLeft == 0 then 
  --     timerText:SetTextColor(RED_FONT_COLOR:GetRGB())
  --   else
  --     timerText:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB())
  --   end

  --   Style[timerText].text = SecondsToClock(timeLeft)
  -- end

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
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "TimeLimit" {
    type = Number
  }

  property "ShowRemainingTime" {
    type = Boolean,
    default = false 
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__{
    TimerText = SLTFontString,
    TimerBar = ProgressBar,
  }
  function __ctor(self)
  end

end)

-- baseTime = ElapsedTime
-- timeSincdeBase = 0
-- OnUpdate  -> self.timeSinceBase = self.timeSinceBase + elapsed 
--              -> self.update(floor(self.baseTime + self.timeSinceBase))
--



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
    local dungeonNameFS   = headerFrame:GetChild("DungeonName")
    local levelFS         = contentFrame:GetChild("Level")
    local deathCountFrame = contentFrame:GetChild("DeathCount")
    local affixesFrame    = contentFrame:GetChild("Affixes")
    local dungeonIcon     = contentFrame:GetChild("DungeonIcon")
    local timerFrame      = contentFrame:GetChild("Timer")

    -- Determine the state
    local state = State.Progress

    -- Determine the flags 
    local flags = Flags.NONE 

    if keystoneData.Objectives then 
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

    -- UPDATE FROM DATA PART

    -- Update Level
    local level = keystoneData.level 
    if level then 
      Style[levelFS].text = CHALLENGE_MODE_POWER_LEVEL:format(level)
    end 

    -- Update Death
    local death = keystoneData.death 
    if death and death > 0 then 
      Style[deathCountFrame].visible = true 
      Style[deathCountFrame].Label.text = tostring(death)
    else
      Style[deathCountFrame].visible = false 
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
    local elapsed = keystoneData.elapsed

    if timeLimit and elapsed then 
      timerFrame.BaseTime = elapsed
      timerFrame.TimeLimit = timeLimit
      timerFrame:StartTimer()
    end

    self.Flags = flags 
    self.State = state 

    -- local content = self:GetChild("Content")
    -- local dungeonNameFS = self:GetChild("Header"):GetChild("DungeonName")
    -- if dungeonNameFS then 
    --   Style[dungeonNameFS].text = keystoneData.name
    -- end 


    -- local level = keystoneData.level 
    -- if level then 
    --   local levelFS = content:GetChild("Level")
    --   Style[levelFS].text = CHALLENGE_MODE_POWER_LEVEL:format(level)
    -- end

    -- local death = keystoneData.death
    -- local deathCountFrame = content:GetChild("DeathCount")
    -- if death and death > 0 then
    --   Style[deathCountFrame].visible = true 
    --   Style[deathCountFrame].Label.text = tostring(death) 
    -- else 
    --   Style[deathCountFrame].visible = false
    -- end

    -- -- Update Affixes
    -- local affixes = keystoneData.affixes 
    -- local numAffixes = #affixes
    -- local affixesFrame = content:GetChild("Affixes")
    -- affixesFrame.AffixesCount = numAffixes
    -- for affixIndex, affixData in ipairs(affixes) do 
    --     local affixFrame = affixesFrame:AcquireAffix(affixIndex)
    --     affixFrame.Name = affixData.name 
    --     affixFrame.Texture = affixData.texture 
    --     affixFrame.Desc = affixData.desc
    -- end

    -- -- Update Dungeon Icon
    -- local dungeonIcon = content:GetChild("DungeonIcon")
    -- if keystoneData.texture then
    --   Style[dungeonIcon].Icon.fileID = keystoneData.texture
    -- end

    -- -- Update Timer
    -- local timeLimit = keystoneData.timeLimit 
    -- local elapsed = keystoneData.elapsed

    -- if timeLimit and elapsed then 
    --   local keystoneTimer = content:GetChild("Timer")
    --   keystoneTimer.BaseTime = elapsed
    --   keystoneTimer.TimeLimit = timeLimit
    --   keystoneTimer:StartTimer()
    -- end
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



  -- __Async__()
  -- function OnAdjustHeight(self, duration)
  --   -- Next()
  --   -- Next()
  --   -- Next()
  --   -- Next()

  --   super.OnAdjustHeight(self, duration)
  -- end
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
        Level       = SLTFontString,
        Affixes     = KeystoneAffixes,
        DeathCount  = Badge,
        DungeonIcon = IconBadge,
        Timer       = KeystoneTimer
      }
    }
  }
  function __ctor(self) end
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  -- [KeystoneAffixes] = {

  -- },
  [KeystoneAffix] = {
    width   = 24,
    height  = 24,

    Icon = {
      setAllPoints = true,
      texCoords = { top = 0.93, left = 0.07, bottom = 0.07, right = 0.93}
    }
  },

  [KeystoneTimer] = {
    height = 60,

    TimerText = {
      height = 24,
      textColor = Color(1, 1, 1),
      sharedMediaFont = FontType("PT Sans Narrow", 22),
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
        height = 24,
        location = {
          Anchor("TOP", 0, -3)
        }
      },

      DeathCount = {
        height = 24,
        width = 40,
        location = {
          Anchor("TOP"),
          Anchor("RIGHT", -5, 0)
        },

        Label = {
          text = "14"
        },

        Icon = {
          height = 14,
          width  = 14,
          atlas = AtlasType("poi-graveyard-neutral", true)
        }
      },

      DungeonIcon = {
        width = 64,
        height = 64,
        location = {
          Anchor("TOP", 0, -5, "Level", "BOTTOM"),
          Anchor("LEFT", 5, 0)
        }
      },

      Timer = {
        location = {
          Anchor("TOP", 0, 0, "Affixes", "BOTTOM"),
          Anchor("LEFT", 0, 0, "DungeonIcon", "RIGHT"),
          Anchor("RIGHT")
        }
      }
    }
  }
})