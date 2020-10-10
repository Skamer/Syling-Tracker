-- ========================================================================= --
--                              EskaTracker 2                                --
--           https://www.curseforge.com/wow/addons/eskatracker-2             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/EskaTracker2                  --
--                                                                           --
-- ========================================================================= --
Syling                        "SylingTracker.UI.ObjectiveView"               ""
-- ========================================================================= --
namespace                          "SLT"
-- ========================================================================= --
-- Iterator helper for ignoring the children are used for backdrop, and avoiding
-- they are taken as account for their parent height
IterateFrameChildren = Utils.IterateFrameChildren

-- Helper function for resetting the styles
ClearStyles         = Utils.ClearStyles
ClearChildStyles    = Utils.ClearChildStyles
ResetStyles = Utils.ResetStyles

-- Helper functions
ValidateFlags       = System.Toolset.validateflags


__Recyclable__ "SylingTracker_ObjectiveTimer%d"
class "ObjectiveTimer" (function(_ENV)
  inherit "Frame"

  local function OnUpdateHandler(self, elapsed)
    local timeNow = GetTime()
    local timeRemaining = self.Duration - (timeNow - self.StartTime)

    local textFrame = self:GetChild("Text")
    Style[textFrame].text = SecondsToClock(timeRemaining)
    textFrame:SetTextColor(self:GetTimerTextColor(self.Duration, self.Duration - timeRemaining))
  end

  local function UpdateTimeHandler(self, new, old, prop)
    if (prop == "StartTime") and (new > 0 and self.Duration) then 
      self.OnUpdate = OnUpdateHandler
    elseif (prop == "Duration") and (new > 0 and self.StartTime) then
      self.OnUpdate = OnUpdateHandler
    else
      self.OnUpdate = nil 
    end
  end

  function GetTimerTextColor(self, duration, elapsed)
    local START_PERCENTAGE_YELLOW = self.StartPercentageYellow
    local START_PERCENTAGE_RED    = self.StartPercentageRed

    local percentageLeft = 1 - (elapsed / duration)
    if (percentageLeft > START_PERCENTAGE_YELLOW) then
      return 1, 1, 1
    elseif (percentageLeft > START_PERCENTAGE_RED) then 
      local blueOffset = (percentageLeft - START_PERCENTAGE_RED) / (START_PERCENTAGE_RED - START_PERCENTAGE_YELLOW)
      return 1, 1, blueOffset
    else
      local greenOffset = percentageLeft / START_PERCENTAGE_RED
      return 1, greenOffset, 0
    end 
  end


  property "StartTime" {
    type    = Number,
    default = 0,
    handler = UpdateTimeHandler
  }

  property "Duration" {
    type    = Number,
    default = 0,
    handler = UpdateTimeHandler
  }

  property "StartPercentageYellow" {
    type    = Number,
    default = 0.66
  }

  property "StartPercentageRed" {
    type    = Number,
    default = 0.33
  }

  function OnAcquire(self)
    self:Show()
  end

  function OnRelease(self)
    self:Hide()
    self:ClearAllPoints()
    self:SetParent()

    self.OnUpdate = nil
    self.StartTime = nil 
    self.Duration = nil 
    self.StartPercentageYellow = nil 
    self.StartPercentageRed = nil
  end


  __Template__{
    Icon = Texture,
    Text = SLTFontString
  }
  function __ctor(self)

  end

end)



__Recyclable__ "SylingTracker_ObjectiveView%d"
class "ObjectiveView" (function(_ENV)
  inherit "Frame" extend "IView"

  enum "State" {
    Progress  = 1,
    Completed = 2,
    Failed    = 3
  }

  __Flags__()
  enum "Flags" {
    NONE            = 0,
    HAS_PROGRESSBAR = 1,
    HAS_TIMER       = 2,
  }
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  __Async__()
  function OnViewUpdate(self, data)
    local completed, text, failed = data.isCompleted, data.text, data.failed
    local textFrame = self:GetChild("Text")
    local iconFrame = self:GetChild("Icon")

    -- Determine the state
    local state 
    if completed then 
      state = State.Completed
    elseif failed then 
      state = State.Failed
    else 
      state = State.Progress
    end

    -- Determine the ui flags
    local flags = Flags.NONE 
    if data.hasProgressBar then 
      flags = flags + Flags.HAS_PROGRESSBAR 
    end
    if data.hasTimer then 
      flags = flags + Flags.HAS_TIMER
    end

    if not self.State or state ~= self.State or self.Flags ~= flags then
      -- If the state or the flags has changed, clear styles for preparing 
      -- a new styles 
      ResetStyles(self)
      ResetStyles(textFrame)
      ResetStyles(iconFrame)

      local statesStyles = self.StatesStyles and self.StatesStyles[state]
      if statesStyles then
        Style[self] = statesStyles 
      end

      if self.Flags ~= flags then

        if ValidateFlags(Flags.HAS_PROGRESSBAR, flags) then 
          local progressBar = self:AcquireProgressBar()
          progressBar:Show() 
        else 
          self:ReleaseProgressBar() 
        end

        if ValidateFlags(Flags.HAS_TIMER, flags) then 
          local timer = self:AcquireTimer()
          timer:Show()
        else 
          self:ReleaseTimer()
        end

        if flags ~= Flags.NONE then 
          -- Skin Stuff for flags
          local flagsStyles = self.FlagsStyles and self.FlagsStyles[flags]
          if flagsStyles then
            Style[self] = flagsStyles 
          end
          
          -- Override the flags styles by those of state if exists 
          flagsStyles = self.StatesStyles and self.StatesStyles[state] and self.StatesStyles[state].FlagsStyles
          if flagsStyles then 
            Style[self] = flagsStyles
          end
        end
      end
    end

    if data.hasProgressBar then 
      local progressBar = self:AcquireProgressBar()
      progressBar:SetMinMaxValues(data.minProgress or 0, data.maxProgress)
      progressBar:SetValue(data.progress or 0)
      
      Style[progressBar].Text.text = data.progressText or ""
    end

    if data.hasTimer then 
      local timer = self:AcquireTimer()
      timer.Duration  = data.duration
      timer.StartTime = data.startTime
    end 
    
    self.Flags = flags
    self.State = state

    if textFrame:GetText() ~= text then
      local left = textFrame:GetLeft()
      local right = textFrame:GetRight()

      if left and right then 
        textFrame:SetWidth(right - left)
      end

      textFrame:SetText(text)

      -- Waiting the next "OnUpdater" for getting a valid string height
      Next()

      self:SetHeight(textFrame:GetStringHeight() + 2)

      self:AdjustHeight()
    end
  end 


  -- __Async__()
  -- function OnUpdate(self, data)
  --   local completed, type, text, failed = data.isCompleted, data.type, data.text, data.failed
  --   local textFrame = self:GetChild("Text")
  --   local iconFrame = self:GetChild("Icon")

  --   local state
  --   if completed then 
  --     state = ObjectiveView.State.Completed
  --   elseif failed then 
  --     state = ObjectiveView.State.Failed
  --   else 
  --     state = ObjectiveView.State.Progress
  --   end

  --   if not self.State or state ~= self.State then 
  --     local textStyles = {
  --       [ObjectiveView.State.Progress] = self.TextProgress,
  --       [ObjectiveView.State.Completed] = self.TextCompleted,
  --       [ObjectiveView.State.Failed] = self.TextFailed
  --     }

  --     local iconStyles = {
  --       [ObjectiveView.State.Progress] = self.IconProgress,
  --       [ObjectiveView.State.Completed] = self.IconCompleted,
  --       [ObjectiveView.State.Failed] = self.IconFailed
  --     }

  --     -- Clear the old styles if needed
  --     if self.State then 
  --       ClearStyles(textFrame, textStyles[self.State])
  --       ClearStyles(iconFrame, iconStyles[self.State])
  --     end

  --     -- Apply the new styles 
  --     Style[textFrame]  = textStyles[state]
  --     Style[iconFrame]  = iconStyles[state]

  --     -- Request an "OnAdjustHeight"
  --     self:AdjustHeight()

  --     self.State = state
  --   end

  --   local flags = 0
  --   if data.hasProgress then 
  --     flags = ObjectiveView.Flags.PROGRESSBAR
  --   end

  --   if not self.Flags or flags ~= self.Flags then 
  --     if ValidateFlags(ObjectiveView.Flags.PROGRESSBAR, flags) then
  --       local progressBar = self:AcquireProgressBar()
  --       progressBar:Show() 

  --       Style[progressBar] = self.ProgressBar

  --       Style[self].ProgressBar = self.Progress
  --     else 
  --       Style[self].ProgressBar = nil 
  --     end

  --     -- Request an "OnAdjustHeight"
  --     self:AdjustHeight()
  --   end

  --   if textFrame:GetText() ~= text then 
  --     local left = textFrame:GetLeft()
  --     local right = textFrame:GetRight() 

  --     if left and right then 
  --       textFrame:SetWidth(right - left)
  --     end

  --     textFrame:SetText(text)

  --     -- Waiting the next "OnUpdate" in order to get a valid string height
  --     Next() 

  --     self:SetHeight(textFrame:GetStringHeight() + 2)

  --     -- Request an "OnAdjustHeight"
  --     self:AdjustHeight()
  --   end
  -- end

  __Async__()
  function UpdateTextHeight(self)
    local textFrame = self:GetChild("Text")
    local left = textFrame:GetLeft()
    local right = textFrame:GetRight()

    if left and right then 
      textFrame:SetWidth(right - left)
    end


    textFrame:SetText(textFrame:GetText() or "")

    Next()

    -- self:SetHeight(textFrame:GetStringHeight() + 2)
    self:AdjustHeight()
  end

  function OnAdjustHeight(self)
    local maxOuterBottom
    for childName, child in IterateFrameChildren(self) do
      local outerBottom = child:GetBottom()
      if outerBottom then 
        if not maxOuterBottom or maxOuterBottom > outerBottom then 
              maxOuterBottom = outerBottom
        end
      end
    end

    if maxOuterBottom then 
      local computeHeight = (self:GetTop() - maxOuterBottom) + self.PaddingBottom
      PixelUtil.SetHeight(self, computeHeight)
    end
  end

  function AcquireProgressBar(self)
    local progressBar = self:GetChild("ProgressBar")
    if not progressBar then 
      progressBar = ProgressBar.Acquire()
      self.__previousProgressBar = progressBar:GetName()

      progressBar:SetParent(self)
      progressBar:SetName("ProgressBar")
      progressBar:InstantApplyStyle()

      self:AdjustHeight()
    end

    return progressBar
  end

  function ReleaseProgressBar(self)
    local progressBar = self:GetChild("ProgressBar")
    if progressBar then 
      progressBar:SetName(self.__previousProgressBar)
      self.__previousProgressBar = nil 

      progressBar:Release()

      self:AdjustHeight()
    end 
  end

  function AcquireTimer(self)
    local timer = self:GetChild("Timer")
    if not timer then
      timer = ObjectiveTimer.Acquire()
      self.__previousTimerName = timer:GetName()

      timer:SetParent(self)
      timer:SetName("Timer")
      timer:InstantApplyStyle()

      self:AdjustHeight()
    end

    return timer
  end

  function ReleaseTimer(self)
    local timer = self:GetChild("Timer")
    if timer then 
      timer:SetName(self.__previousTimerName)
      self.__previousTimerName = nil

      timer:Release()
      self:AdjustHeight()
    end
  end 

  --- Recycle System
  function OnRelease(self)
    self.OnSizeChanged = self.OnSizeChanged - self.OnSizeChangedHandler


    self:SetParent()
    self:ClearAllPoints()
    self:Hide()
    self:CancelAdjustHeight()
    self:CancelAnimatingHeight()

    self:SetHeight(1)
    self:ReleaseProgressBar()
    self:ReleaseTimer()

    self:GetChild("Text"):SetText("")

    self.State = nil 
    self.Flags = nil

    ResetStyles(self)
  end 

  function OnAcquire(self)
    self.OnSizeChanged = self.OnSizeChanged + self.OnSizeChangedHandler

    self:Show()
  end
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  property "PaddingBottom" {
    type = Number,
    default = 0
  }

  -- The state of frame, used internally for avoiding useless Style update
  property "State" {
    type = ObjectiveView.State,
  }

  -- The state of frame, used internally for avoiding useless Style update
  property "Flags" {
    type = ObjectiveView.Flags,
    default = ObjectiveView.Flags.NONE
  }

  -- The styles used for flags
  property "FlagsStyles" {
    type = Table
  }

  -- The styles used for states
  property "StatesStyles" {
    type = Table
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__{
    Icon = Texture,
    Text  = SLTFontString
  }
  function __ctor(self) 
    -- Important ! We need the frame is instantly styled as this may affect 
    -- its height.
    self:InstantApplyStyle()

    -- Important! As the frame ajusts its height depending of its children height
    -- we need to set its height when contructed for the event "OnSizechanged" of
    -- its children is triggered.
    self:SetHeight(1)

    -- self.OnSizeChanged = self.OnSizeChanged + function(f, width, height)
    --   self:UpdateTextHeight() 
    -- end

    self.OnSizeChangedHandler = function(_, width, height)
      local w = Round(width)
      if not self.__width or (self.__width ~= w) then
        self.__width = w
        self:UpdateTextHeight()
      end 
    end
  end
end)


--- This is a helper manages multiple objectives.

__Recyclable__ "SylingTracker_ObjectiveListView%d"
class "ObjectiveListView" (function(_ENV)
  inherit "Frame" extend "IView"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data, updater)
    local objectiveCount = #data

    for index, objectiveData in ipairs(data) do 
      local objective = self:AcquireObjective(index)
      objective:UpdateView(objectiveData, updater)
    end 
  

    self:ReleaseUnusedObjectives(objectiveCount)
  end

  function AcquireObjective(self, index)
    if not self.objectiveViews then 
      self.objectiveViews = setmetatable({}, { __mode = "v"})
    end

    local objective = self.objectiveViews[index]
    if not objective then 
      objective = ObjectiveView.Acquire()
      objective:SetParent(self)

      if index > 1 then 
        objective:SetPoint("TOP", self.objectiveViews[index-1], "BOTTOM", 0, -self.Spacing)
        objective:SetPoint("LEFT", 4, 0)
        objective:SetPoint("RIGHT", -4, 0)
      elseif index == 1 then
        objective:SetPoint("TOP")
        objective:SetPoint("LEFT", 4, 0)
        objective:SetPoint("RIGHT", -4, 0)
      end


      objective.OnSizeChanged = objective.OnSizeChanged + self.OnObjectiveSizeChanged

      self.objectiveViews[index] = objective
    end

    return objective
  end
  
  function ReleaseUnusedObjectives(self, releaseFromIndex)
    if not self.objectiveViews then 
      return 
    end

    for index, objective in pairs(self.objectiveViews) do 
      if index > releaseFromIndex then
        objective.OnSizeChanged = objective.OnSizeChanged - self.OnObjectiveSizeChanged
  
        objective:Release()
        self.objectiveViews[index] = nil

        self:AdjustHeight()
      end 
    end 
  end

  function OnAdjustHeight(self)
    local height = 0
    local count = 0
    for childName, child in IterateFrameChildren(self) do
      height = height + child:GetHeight() 

      count = count + 1
    end
    
    height = height + self.Spacing * math.max(0, count-1)

    self:SetHeight(height)
  end

  function OnRelease(self)
    self:ReleaseUnusedObjectives(0)

    self:ClearAllPoints()
    self:SetParent()
    self:Hide()
    self:CancelAdjustHeight()
    self:CancelAnimatingHeight()

    self:SetHeight(1)

    -- REVIEW: Should be enought ?
    ResetStyles(self)
  end

  function OnAcquire(self)
    self:Show()
  end 
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "Spacing" { 
    type = Number,
    default = 0
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  function __ctor(self)
    -- Important ! We need the frame is instantly styled as this may affect 
    -- its height.
    self:InstantApplyStyle()

    -- Important! As the frame ajusts its height depending of its children height
    -- we need to set its height when contructed for the event "OnSizechanged" of
    -- its children is triggered.
    self:SetHeight(1)

    self.OnObjectiveSizeChanged = function() self:AdjustHeight() end
  end
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [ObjectiveTimer] = {
    height = 24,

    -- Icon = {
    --   atlas = AtlasType("socialqueuing-icon-clock"),
    --   width = 16,
    --   height = 16,
    --   location = {
    --     Anchor("LEFT")
    --   }

    -- },
    Text = {
      setAllPoints = true,
      text = "Timer",
      sharedMediaFont = FontType("PT Sans Narrow Bold", 15),
    }
  },

  [ObjectiveView] = {
    Text = {
      justifyH = "LEFT",
      justifyV = "TOP",
      wordWrap = true,
      nonSpaceWrap = true,
      sharedMediaFont = FontType("PT Sans Narrow Bold", 13),
      location = {
        Anchor("TOPLEFT", 15, 0),
        Anchor("TOPRIGHT")
      }
    },

    FlagsStyles = {
      [ObjectiveView.Flags.HAS_PROGRESSBAR] = {
        PaddingBottom = 5,
        ProgressBar = {
          height = 24,
          location = {
            Anchor("TOP", 0, -4, "Text", "BOTTOM"),
            Anchor("LEFT", 20, 0),
            Anchor("RIGHT", -15, 0)
          }
        }
      },
      [ObjectiveView.Flags.HAS_TIMER] = {
        PaddingBottom = 5,
        Timer = {
          height = 24,
          location = {
            Anchor("TOP", 0, -4, "Text", "BOTTOM"),
            Anchor("LEFT", 0, 0),
            Anchor("RIGHT", 0, 0)
          }
        }
      },
      [ObjectiveView.Flags.HAS_PROGRESSBAR + ObjectiveView.Flags.HAS_TIMER] = {
        PaddingBottom = 5,
        ProgressBar = {
          height = 24,
          location = {
            Anchor("TOP", 0, -4, "Text", "BOTTOM"),
            Anchor("LEFT", 20, 0),
            Anchor("RIGHT", -15, 0)
          }
        },

        -- Timer = {
        --   location = {
        --     Anchor("TOP", 0, -4, "ProgressBar", "BOTTOM"),
        --     Anchor("LEFT", 20, 0),
        --     Anchor("RIGHT", -15, 0)
        --   }
        -- }
      }
    },

    StatesStyles = {
      [ObjectiveView.State.Progress] = {
        Icon = {
          size = Size(8, 8),
          color = ColorType(148/255, 148/255, 148/255),
          location = {
            Anchor("TOPLEFT", 2, -2)
          }
        },

        Text = {
          textColor = Color(148/255, 148/255, 148/255)
        }
      },

      [ObjectiveView.State.Completed] = {
        Icon = {
          atlas = AtlasType("groupfinder-icon-greencheckmark"),
          size  = Size(10, 10),
          location = {
            Anchor("TOPLEFT", 2, -1)
          }
        },

        Text = {
          textColor = Color(0, 1, 0)
        }
      },

      [ObjectiveView.State.Failed] = {
        Icon = {
          atlas = AtlasType("communities-icon-redx"),
          size = Size(10, 10),
          location = {
            Anchor("TOPLEFT", 2, -1)
          }
        },

        Text = {
          textColor = Color(1, 0, 0)
        }
      }
    }
  }
})
