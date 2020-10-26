-- ========================================================================= --
--                              EskaTracker 2                                --
--           https://www.curseforge.com/wow/addons/eskatracker-2             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/EskaTracker2                  --
--                                                                           --
-- ========================================================================= --
Syling                "SylingTracker.Achievements.AchievementView"           ""
-- ========================================================================= --
namespace                          "SLT"
-- ========================================================================= --
-- Iterator helper for ignoring the children are used for backdrop, and avoiding
-- they are taken as account for their parent height
IterateFrameChildren = Utils.IterateFrameChildren
-- ========================================================================= --
ShowContextMenu       = API.ShowContextMenu
wipe                  = wipe 
ValidateFlags         = System.Toolset.validateflags
ResetStyles           = Utils.ResetStyles
-- ========================================================================= --
__Recyclable__ "SylingTracker_AchievementView%d"
class "AchievementView" (function(_ENV)
  inherit "Button" extend "IView"

  __Flags__()
  enum "Flags" {
    NONE = 0,
    HAS_OBJECTIVES = 1,
    HAS_PROGRESS_BAR = 2
  }

  function OnViewUpdate(self, data)
    local nameFS = self:GetChild("Name")
    local descFS = self:GetChild("Description")
    local iconBadge = self:GetChild("IconBadge")

    -- Determines the flags
    local flags = Flags.NONE 
    local hasProgressBar = false 
    local objectivesData = data.objectives
    local firstObjectiveData
    if objectivesData then 
      local firstObjectiveData = objectivesData[1]
      if firstObjectiveData then 
        hasProgressBar = firstObjectiveData.hasProgressBar 
      end 

      if hasProgressBar then 
        flags = Flags.HAS_PROGRESS_BAR + Flags.HAS_OBJECTIVES
      else 
        flags = Flags.HAS_OBJECTIVES
      end
    end

    if flags ~= self.Flags then 
      ResetStyles(self)
      ResetStyles(nameFS)
      ResetStyles(descFS)

      -- Is the achievement has objectives
      if ValidateFlags(Flags.HAS_OBJECTIVES, flags) then 
        self:AcquireObjectives()
      else
        self:ReleaseObjectives()
      end

      -- Styling stuff 
      if flags ~= Flags.NONE then 
        local styles = self.FlagsStyles and self.FlagsStyles[flags]
        if styles then 
          Style[self] = styles 
        end 
      end
    end 

    -- Update the achievement name 
    Style[nameFS].text = data.name 

    -- Update the description 
    Style[descFS].text = data.description 

    -- Update the icon 
    Style[iconBadge].Icon.fileID = data.icon

    -- Update the context menu 
    if data.achievementID then 
      self.OnClick = function() 
        ShowContextMenu("achievement", self, data.achievementID)
      end 
    end

    -- Update the objectives if needed 
    if objectivesData then 
      local objectivesView = self:AcquireObjectives() 
      objectivesView:UpdateView(objectivesData)
    end 

    self.Flags = flags 
  end 

  function OnAdjustHeight(self, useAnimation)
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
      local computeHeight = self:GetTop() - maxOuterBottom + self.PaddingBottom
      if useAnimation then 
        self:SetAnimatedHeight(computeHeight)
      else 
        self:SetHeight(computeHeight)
      end
    end
  end

  function AcquireObjectives(self)
    local objectives = self:GetChild("Objectives")
    if not objectives then
      objectives = ObjectiveListView.Acquire() 

      -- We need to keep the old name when we'll release the objective list 
      self.__PreviousObjectivesName = objectives:GetName()

      objectives:SetParent(self)
      objectives:SetName("Objectives")
      objectives:InstantApplyStyle()
      
      -- if self.Objectives then 
      --   Style[objectives] = self.Objectives 
      -- end

      -- Register the events 
      objectives.OnSizeChanged = objectives.OnSizeChanged + self.OnObjectivesSizeChanged

      self:AdjustHeight()
    end

    return objectives
  end

  function ReleaseObjectives(self)
    local objectives = self:GetChild("Objectives")
    if objectives then 
      objectives:SetName(self.__PreviousObjectivesName)
      self.__PreviousObjectivesName = nil 

      -- Unregister the events 
      objectives.OnSizeChanged = objectives.OnSizeChanged - self.OnObjectivesSizeChanged

      objectives:Release() 

      self:AdjustHeight()
    end
  end

  function OnRelease(self)
    -- Release first the children
    self:ReleaseObjectives()

    self:Hide()
    self:ClearAllPoints()
    self:SetParent()

    -- "CancelAdjustHeight" and "CancelAnimatingHeight" wiil cancel the pending
    -- computing stuff for height, so they not prevent "SetHeight" here doing 
    -- its stuff.
    self:CancelAdjustHeight()
    self:CancelAnimatingHeight()
    self:SetHeight(1)

    -- Reset the class properties
    self.Flags = nil

    -- Will Remove all custom styles properties, so the  next time the object will
    -- be used, this one will be in a clean state
    ResetStyles(self)
  end

  function OnAcquire(self)
    -- Important ! We need the frame is instantly styled as this may affect 
    -- its height.
    self:InstantApplyStyle()

    self:Show()
    self:AdjustHeight()
  end 

  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "FlagsStyles" {
    type = Table
  }

  property "Flags" {
    type    = AchievementView.Flags,
    default = AchievementView.Flags.NONE
  }

  property "ObjectivesClass" {
    type    = ClassType,
    default = ObjectiveListView
  }

  property "PaddingBottom" {
    type = Number,
    default = 5
  }

  property "Objectives" {
    type = Table
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    Name          = SLTFontString,
    Description   = SLTFontString,
    IconBadge     = IconBadge
  }
  function __ctor(self)
    -- Important ! We need the frame is instantly styled as this may affect 
    -- its height.
    self:InstantApplyStyle()

    -- Important! As the frame ajusts its height depending of its children height
    -- we need to set its height when contructed for the event "OnSizechanged" of
    -- its children is triggered.
    self:SetHeight(1)

    self.OnObjectivesSizeChanged = function() self:AdjustHeight() end

    self:SetClipsChildren(true)
  end 
end)

--- Manages the achievements, if your view may have various achievements, this
-- is advised using this class 
__Recyclable__ "SylingTracker_AchievementListView%d"
class "AchievementListView" (function(_ENV)
  inherit "Frame" extend "IView"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data)
    local achievementIndex = 0

    -- Clear the current achievement id list 
    wipe(self.achievementsID)

    local previousAchievement
    for achievementID, achievementData in pairs(data) do 
      achievementIndex = achievementIndex + 1

      local achievement = self:AcquireAchievement(achievementID)

      -- NOTE: Don't put other anchor could modify the width (e.g, LEFT or RIGHT) as
      -- it will trigger useless "OnSizeChanged" event, breaking animation stuff.
      if achievementIndex > 1 then 
        achievement:SetPoint("TOP", previousAchievement, "BOTTOM", 0, -self.AchievementSpacing)
      else 
        achievement:SetPoint("TOP")
      end

      -- Update our achievement with data 
      achievement:UpdateView(achievementData, updater)

      -- Build the current achievement id list 
      self.achievementsID[achievementID] = true 

      previousAchievement = achievement 
    end

    self:ReleaseUnusedAchievements()
  end

  function AcquireAchievement(self, id)
    local achievement = self.achievementsCache[id]
    if not achievement then 
      achievement = AchievementView.Acquire()
      achievement:SetParent(self)
      achievement:SetPoint("LEFT")
      achievement:SetPoint("RIGHT")

      achievement.OnSizeChanged = achievement.OnSizeChanged + self.OnAchievementSizeChanged

      self.achievementsCache[id] = achievement

      self:AdjustHeight() 
    end 

    return achievement
  end

  function ReleaseUnusedAchievements(self)
    for achievementID, achievement in pairs(self.achievementsCache) do 
      if not self.achievementsID[achievementID] then
        self.achievementsCache[achievementID] = nil

        achievement.OnSizeChanged = achievement.OnSizeChanged - self.OnAchievementSizeChanged

        achievement:Release()

        self:AdjustHeight()
      end
    end
  end

  function OnAdjustHeight(self, useAnimation)
    local height  = 0
    local count   = 0

    for _, child in IterateFrameChildren(self) do 
      height  = height + child:GetHeight() 
      count   = count + 1 
    end

    height = height + self.AchievementSpacing * math.max(0, count-1)

    if useAnimation then 
      self:SetAnimatedHeight(height)
    else 
      self:SetHeight(height)
    end
  end

  function OnRelease(self)
    wipe(self.achievementsID)
    self:ReleaseUnusedAchievements()

    self:Hide()
    self:ClearAllPoints()
    self:SetParent()
    self:CancelAdjustHeight()
    self:CancelAnimatingHeight()

    self:SetHeight(1)
   
    ResetStyles(self)
  end 

  function OnAcquire(self)
    -- Important ! We need the frame is instantly styled as this may affect 
    -- its height.
    self:InstantApplyStyle()

    self:Show()

    self:AdjustHeight()
  end 
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "AchievementSpacing" {
    type      = Number,
    default   = 10
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
    self:SetHeight(1) -- !important


    -- Keep in the cache the achievement, to be reused. 
    -- use: self.achievementsCache[achievementID] = achievementObject
    self.achievementsCache = setmetatable({}, { __mode = "v"} )

    -- Get the current achievement id's list. Used internally to release the 
    -- unused achievements
    -- use: self.achievementsID[achievementID] = true or nil
    self.achievementsID = {}

    self.OnAchievementSizeChanged = function() self:AdjustHeight() end

    self:SetClipsChildren(true)
  end
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [AchievementView] = {
    width = 300,
    backdrop = {
      bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]]
    },
    backdropColor = { r = 35/255, g = 40/255, b = 46/255, a = 0.73},
    registerForClicks = { "RightButtonDown" },

    Name = {
      sharedMediaFont = FontType("DejaVuSansCondensed Bold", 10),
      height = 26,
      location = {
        Anchor("TOP"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      }
    },

    IconBadge = {
      height = 46,
      width = 46,
      location = {
        Anchor("TOPLEFT", 5, -5, "Name", "BOTTOMLEFT")
      },
      Icon = {
        texCoords = RectType(0.07, 0.93, 0.07, 0.93)
      }
    },

    Description = {
      height = 46,
      sharedMediaFont = FontType("PT Sans Bold", 11),
      textColor = Color(1, 1, 1),
      justifyH = "LEFT",
      justifyV = "TOP",
      location = {
        Anchor("TOP", 0, -5, "Name", "BOTTOM"),
        Anchor("LEFT", 5, 0, "IconBadge", "RIGHT"),
        Anchor("RIGHT")
      }
    },

    FlagsStyles = {
      [AchievementView.Flags.HAS_OBJECTIVES] = {
        Objectives = {
          spacing = 5,
          location = {
            Anchor("TOP", 0, -10, "IconBadge", "BOTTOM"),
            Anchor("LEFT"),
            Anchor("RIGHT")
          }
        }
      },

      [AchievementView.Flags.HAS_OBJECTIVES + AchievementView.Flags.HAS_PROGRESS_BAR] = {
        Description = {
          visible = false 
        },

        Objectives = {
          spacing = 5,
          location = {
            Anchor("TOP", 0, -5, "Name", "BOTTOM"),
            Anchor("LEFT", 5, 0, "IconBadge", "RIGHT"),
            Anchor("RIGHT", -5, 0)
          }
        }
      }
    }
  }
})
