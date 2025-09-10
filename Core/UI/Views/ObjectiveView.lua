-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                 "SylingTracker.UI.ObjectiveView"                      ""
-- ========================================================================= --
export {
  FromUIProperty                      = Wow.FromUIProperty,
  GetFrameByType                      = Wow.GetFrameByType,
  RegisterUISetting                   = API.RegisterUISetting,
  FromUISetting                       = API.FromUISetting,
  FromUISettings                      = API.FromUISettings,
  GenerateUISettings                  = API.GenerateUISettings,
  GetUISetting                        = API.GetUISetting
}

__UIElement__()
__Sealed__()
class "ObjectiveView" (function(_ENV)
  inherit "Frame" extend "IView"

  enum "EState" {
    Progress = 1,
    Completed = 2,
    Failed = 3
  }
  -----------------------------------------------------------------------------
  --                                Methods                                  --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data)
    if data.hasProgress then
      Style[self].Progress.visible = true
      -- local progress = self:GetPropertyChild("Progress")
      -- progress:InstantApplyStyle()
      -- Style[self].Progress.value = 20
      -- Style[self].Progress.minMaxValues = MinMax(0, 100)
      self.ObjectiveHasProgress   = true
      self.ObjectiveMaxProgress   = data.maxProgress
      self.ObjectiveMinProgress   = data.minProgress
      self.ObjectiveProgress      = data.progress
      self.ObjectiveProgressText  = data.progressText
    else
      Style[self].Progress = NIL
      self.ObjectiveHasProgress = false
      self.ObjectiveMaxProgress   = nil
      self.ObjectiveMinProgress   = nil
      self.ObjectiveProgress      = nil
      self.ObjectiveProgressText  = nil
    end

    if data.hasTimer then 
      Style[self].Timer.visible = true 
      Style[self].Timer.startTime = data.startTime
      Style[self].Timer.duration = data.duration
      Style[self].Timer.started = true
      self.ObjectiveHasTimer = true
    else
      Style[self].Timer = NIL
      self.ObjectiveHasTimer = false
    end

    if data then 
      if data.isCompleted then 
        self.ObjectiveState = EState.Completed
      elseif data.isFailed then 
        self.ObjectiveState = EState.Failed
      else 
        self.ObjectiveState = EState.Progress
      end 
    else
      self.ObjectiveState = EState.Progress
    end

    self.ObjectiveText = data and data.text
  end

  function OnRelease(self)
    self.ObjectiveState = nil
    self.ObjectiveText = nil
    self.ObjectiveHasProgress = nil 
    self.ObjectiveProgress = nil 
    self.ObjectiveMinProgress = nil
    self.ObjectiveMaxProgress = nil 
    self.ObjectiveHasTimer = nil 
    self.ObjectiveProgressText = nil
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  __Observable__()
  property "ObjectiveState" {
    type = EState,
    default = EState.Progress
  }

  __Observable__()
  property "ObjectiveText" {
    type = String,
    default = "Default"
  }

  __Observable__()
  property "ObjectiveHasProgress" {
    type = Boolean,
    default = false 
  }
  
  __Observable__()
  property "ObjectiveProgress" {
    type = Number,
    default = 0
  }

  __Observable__()
  property "ObjectiveMinProgress" {
    type = Number,
    default = 0
  }

  __Observable__()
  property "ObjectiveMaxProgress" {
    type = Number,
    default = 100
  }

  __Observable__()
  property "ObjectiveHasTimer" {
    type = Boolean,
    default = false 
  }

  __Observable__()
  property "ObjectiveProgressText" {
    type = String,
    default = ""
  }
  -----------------------------------------------------------------------------
  --                              Constructors                               --
  -----------------------------------------------------------------------------
  __Template__ {
    Icon = Texture,
    Text = TextFrame,
  } 
  function __ctor(self)
  end
end)

-- Optional children for Objective View
__ChildProperty__(ObjectiveView, "Progress")
__UIElement__()
class(tostring(ObjectiveView) .. ".Progress")  { ProgressBar }

__ChildProperty__(ObjectiveView, "Timer")
__UIElement__()
class(tostring(ObjectiveView) .. ".Timer") { SylingTracker.Timer }

__UIElement__()
class "ObjectiveListView"(function(_ENV)
  inherit "ListView"
  -----------------------------------------------------------------------------
  --                                Methods                                  --
  -----------------------------------------------------------------------------
  function IsFilteredItem(self, key, objectiveData, metadata)
    if self.HideCompleted and objectiveData.isCompleted then 
      return true
    end 

    return super.IsFilteredItem(self, key, objectiveData, metadata)
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "HideCompleted" {
    type = Boolean,
    default = false,
    handler = function(self) self:RefreshView() end
  }
end)

-------------------------------------------------------------------------------
--                              UI Settings                                  --
-------------------------------------------------------------------------------
RegisterUISetting("objectives.hideCompleted", false)

RegisterUISetting("objective.text.justifyH", "LEFT")
RegisterUISetting("objective.text.JustifyV", "TOP")
RegisterUISetting("objective.text.mediaFont", FontType("PT Sans Narrow Bold", 13))
RegisterUISetting("objective.text.textTransform", "NONE")

-- IMPORTANT: We need to generate before the settings inherits of our states. 
GenerateUISettings("objective.completed", "objective")
GenerateUISettings("objective.progress", "objective")
GenerateUISettings("objective.failed", "objective")

-- Progress state 
RegisterUISetting("objective.progress.text.textColor", Color(148/255, 148/255, 148/255))
RegisterUISetting("objective.progress.icon.size", Size(8, 8))
RegisterUISetting("objective.progress.icon.mediaTexture", { 
  color = { r = 148/255, g = 148/255, b =  148/255 }
})

-- Completed state
RegisterUISetting("objective.completed.text.textColor", Color(0, 1, 0))
RegisterUISetting("objective.completed.icon.size", Size(10, 10))
RegisterUISetting("objective.completed.icon.mediaTexture", { 
  atlas = AtlasType("groupfinder-icon-greencheckmark")
})

-- Failed state
RegisterUISetting("objective.failed.text.textColor", Color(1, 0, 0))
RegisterUISetting("objective.failed.icon.size", Size(10, 10))
RegisterUISetting("objective.failed.icon.mediaTexture", { 
  atlas = AtlasType("communities-icon-redx")
})
-------------------------------------------------------------------------------
--                              Observables                                  --
-------------------------------------------------------------------------------
__Static__() function ObjectiveView.FromStateWithChildUISetting(childKey, uiSetting)
  local progessUISetting = ("objective.progress.%s.%s"):format(childKey, uiSetting)
  local completedUISetting = ("objective.completed.%s.%s"):format(childKey, uiSetting)
  local failedUISetting = ("objective.failed.%s.%s"):format(childKey, uiSetting)

  return FromUIProperty("ObjectiveState"):CombineLatest(
    FromUISettings(progessUISetting, completedUISetting, failedUISetting))
    :Next()
    :Map(function(state, progressValue, completedValue, failedValue)
      -- print("State", state, ...)
      if state then 
        if state == 2 then 
          return GetUISetting(completedUISetting)
        elseif state == 3 then 
          return GetUISetting(failedUISetting)
        end 
      end

      return GetUISetting(progessUISetting)
    end)
end

__Static__() function ObjectiveView.FromStateWithTextUISetting(uiSetting)
  return ObjectiveView.FromStateWithChildUISetting("text", uiSetting)
end

__Static__() function ObjectiveView.FromStateWithIconUISetting(uiSetting)
  return ObjectiveView.FromStateWithChildUISetting("icon", uiSetting)
end
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [ObjectiveView] = {
    height = 15,
    width = 150,
    -- clipChildren = true,
    autoAdjustHeight = true,

    -- backdrop = { 
    --   bgFile              = [[Interface\Buttons\WHITE8X8]],
    --   edgeFile            = [[Interface\Buttons\WHITE8X8]],
    --   edgeSize            = 1
    -- },
    -- backdropColor         = { r = 0, g = 0, b = 1, a = 0.5},
    -- backdropBorderColor   = { r = 0, g = 0, b = 1, a = 1 },

    Icon = {
      -- mediaTexture =  { color = { r = 148/255, g = 148/255, b =  148/255 } },
      mediaTexture = ObjectiveView.FromStateWithIconUISetting("mediaTexture"),
      size = ObjectiveView.FromStateWithIconUISetting("size"),
      -- SnapToPixelGrid = false,
      -- TexelSnappingBias = 0 ,

      -- size = Size(8, 8),

      location = {
        Anchor("TOPLEFT", 2, -2)
      }
    },

    Text = {
      Text = {
        setAllPoints = true,
        text = FromUIProperty("ObjectiveText"),
        -- mediaFont = FontType("PT Sans Narrow Bold", 13),
        mediaFont       = ObjectiveView.FromStateWithTextUISetting("mediaFont"),
        justifyH        = ObjectiveView.FromStateWithTextUISetting("justifyH"),
        justifyV        = ObjectiveView.FromStateWithTextUISetting("justifyV"),
        textTransform   = ObjectiveView.FromStateWithTextUISetting("textTransform"),
        wordWrap        = true, 
        nonSpaceWrap    = true,
        textColor       = ObjectiveView.FromStateWithTextUISetting("textColor"),
      },
      location = {
        Anchor("TOP"),
        Anchor("LEFT", 5, 0, "Icon", "RIGHT"),
        Anchor("RIGHT")
      }
    },

    [Progress] = {
      value = FromUIProperty("ObjectiveProgress"),
      minMaxValues = FromUIProperty("ObjectiveMinProgress", "ObjectiveMaxProgress"):Map(function(min, max)
        return MinMax(min, max)
      end),

      Text = {
        text = FromUIProperty("ObjectiveProgressText")
      },
      
      location = {
        Anchor("TOP", 0, -10, "Text", "BOTTOM"),
        Anchor("LEFT", 20, 0),
        Anchor("RIGHT", -20, 0)
      }
    },

    [Timer] = {
      location = {
        Anchor("TOP", 0, -10, "Text", "BOTTOM"),
        Anchor("LEFT"),
        Anchor("RIGHT")    
      },
    },
  },


  [ObjectiveListView] = {
    viewClass = ObjectiveView,
    indexed = false,
    hideCompleted = FromUISetting("objectives.hideCompleted")
  }
})