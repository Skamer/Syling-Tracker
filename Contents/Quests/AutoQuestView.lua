-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                "SylingTracker.AutoQuests.AutoQuestView"               ""
-- ========================================================================= --
namespace                          "SLT"
-- ========================================================================= --
-- Iterator helper for ignoring the children are used for backdrop, and avoiding
-- they are taken as account for their parent height
IterateFrameChildren = Utils.IterateFrameChildren
-- ========================================================================= --
ResetStyles          = Utils.ResetStyles
-- ========================================================================= --
-- NOTE: We don't inherit from "ContentView" because we don't need the header 
__Recyclable__ "SylingTracker_AutoQuestView%d"
class "AutoQuestView" (function(_ENV)
  enum "State" {
    Offer    = 1,
    Complete = 2
  }

  inherit "Button" extend "IView"
  function OnViewUpdate(self, data)
    local type, questName      = data.type, data.name
    local questNameText   = self:GetChild("QuestName")

    -- Determine the state
    local state = State.Offer
    if type == "OFFER" then 
      state = State.Offer
    elseif type == "COMPLETE" then 
      state = State.Complete
    end

    if not self.State or state ~= self.State then 
      local headerText      = self:GetChild("HeaderText")
      local iconBadge       = self:GetChild("IconBadge")
      local subText         = self:GetChild("SubText")

      -- If the state or the flags has changed, clear styles for preparing a 
      -- style
      ResetStyles(self)
      ResetStyles(headerText)
      ResetStyles(iconBadge)
      ResetStyles(questNameText)
      ResetStyles(subText)

      local statesStyles = self.StatesStyles and self.StatesStyles[state]
      if statesStyles then 
        Style[self] = statesStyles
      end
    end

    if questName then 
      Style[questNameText].text = questName
    end

    self.State = state
  end

  function OnAcquire(self)
    -- Important ! We need the frame is instantly styled as this may affect 
    -- its height.
    self:InstantApplyStyle()

    self:Show()

    -- self:AdjustHeight()
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "State" {
    type = AutoQuestView.State,
  }

  -- The styles used for states
  property "StatesStyles" {
    type = Table, 
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__{
    IconBadge = IconBadge, 
    HeaderText = SLTFontString,
    QuestName = SLTFontString, 
    SubText = SLTFontString,
  }
  function __ctor(self)
    -- Important! As the frame ajusts its height depending of its children height
    -- we need to set its height when contructed for the event "OnSizechanged" of
    -- its children is triggered.
    -- self:SetHeight(1)

    self:SetClipsChildren(true)
  end
end)


__Recyclable__ "SylingTracker_AutoQuestListView%d"
class "AutoQuestListView" (function(_ENV)
  inherit "Frame" extend "IView"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data)
    local autoQuestIndex = 0
    wipe(self.autoQuestsID)

    local previousAutoQuest
    for _, autoQuestData in pairs(data) do 
      autoQuestIndex = autoQuestIndex + 1
      local questID = autoQuestData.questID 
      local autoQuest = self:AcquireAutoQuest(questID)

      if autoQuestIndex > 1 then 
        autoQuest:SetPoint("TOP", previousAutoQuest, "BOTTOM", 0, -self.AutoQuestsSpacing)
      elseif autoQuestIndex == 1 then 
        autoQuest:SetPoint("TOP")
      end
      autoQuest:Show()
      autoQuest:UpdateView(autoQuestData)

      previousAutoQuest = autoQuest 

      self.autoQuestsID[questID] = true 
    end
    
    self:ReleaseUnsedAutoQuests()
  end

  function AcquireAutoQuest(self, id)
    local autoQuest = self.autoQuestsCache[id]
    if not autoQuest then 
      autoQuest = AutoQuestView.Acquire()
      autoQuest:SetParent(self)
      autoQuest:SetPoint("LEFT")
      autoQuest:SetPoint("RIGHT")

      autoQuest.OnSizeChanged = autoQuest.OnSizeChanged + self.OnAutoQuestSizeChanged

      self:AdjustHeight()

      self.autoQuestsCache[id] = autoQuest
    end

    return autoQuest
  end

  function ReleaseUnsedAutoQuests(self)
    for questID, autoQuest in pairs(self.autoQuestsCache) do 
      if not self.autoQuestsID[questID] then 
        self.autoQuestsCache[questID] = nil 

        autoQuest.OnSizeChanged = autoQuest.OnSizeChanged - self.OnAutoQuestSizeChanged
        autoQuest:Release()
        self:AdjustHeight()
      end
    end 
  end

  function OnAdjustHeight(self, useAnimation)
    local height = 0
    local count  = 0
    for _, child in IterateFrameChildren(self) do 
      height  = height + child:GetHeight() 
      count   = count + 1
    end 

    height = height + self.AutoQuestsSpacing * math.max(0, count-1)

    if useAnimation then
      self:SetAnimatedHeight(height)
    else
      self:SetHeight(height)
    end
  end 

  function OnRelease(self)
    wipe(self.autoQuestsID)
    self:ReleaseUnsedAutoQuests()

    self:ClearAllPoints()
    self:SetParent()
    self:Hide()
    self:CancelAdjustHeight()
    self:CancelAnimatingHeight()

    self:SetHeight(1)
  end

  function OnAcquire(self)
    --     Important ! We need the frame is instantly styled as this may affect 
    -- its height.
    self:InstantApplyStyle()

    self:Show()

    self:AdjustHeight()
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "AutoQuestsSpacing" {
    type    = Number, 
    default = 5
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  function __ctor(self)
    -- Important! As the frame ajusts its height depending of its children height
    -- we need to set its height when contructed for the event "OnSizechanged" of
    -- its children is triggered.
    self:SetHeight(1) -- !important

    -- Keep in the cache the bonus quest, to be reused. 
    -- use: self.questsCache[questID] = questObject
    self.autoQuestsCache = setmetatable({}, { __mode = "v"})

    -- Get the current auto quest id's list. Used internally to release the 
    -- unused auto quests
    -- use: self.autoQuestsID[questID] = true or nil
    self.autoQuestsID = {}

    self.OnAutoQuestSizeChanged = function() self:AdjustHeight() end 

    self:SetClipsChildren(true)
  end
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [AutoQuestView] = {
    height = 46,
    -- width  = 300, 
    backdrop = { 
      bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
      edgeFile = [[Interface\Buttons\WHITE8X8]],
      edgeSize = 1
    },
    backdropColor = { r = 35/255, g = 40/255, b = 46/255, a = 0.73},
    backdropBorderColor = { r = 35/255, g = 40/255, b = 46/255, a = 0.83},
    registerForClicks = { "LeftButtonDown" },

    HighlightTexture = {
      file = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
      vertexColor = { r = 35/255, g = 40/255, b = 46/255, a = 0.2},
      setAllPoints = true,
    },

    IconBadge = {
      width = 20,
      height = 30,
      Icon = {
        atlas = AtlasType("QuestPortraitIcon-SandboxQuest")
      },

      location = {
        Anchor("LEFT", 5, 0)
      }
    },

    HeaderText = {
      -- text = "Quête decouverte",
      sharedMediaFont = FontType("PT Sans Narrow Bold", 12),
      -- textColor       = Color(1, 216/255, 0),
      location = {
        Anchor("TOP", 0, -2),
        Anchor("LEFT", 0, 0, "IconBadge", "RIGHT"),
        Anchor("RIGHT")
      }
    },

    QuestName = {
      -- text = "L'Assaut de Haut Roc",
      sharedMediaFont = FontType("PT Sans Narrow Bold", 13),
      textTransform = "UPPERCASE",
      textColor       = Color(0.9, 0.9, 0.9),
      location = {
        Anchor("TOP", 0, -4, "HeaderText", "BOTTOM"),
        Anchor("LEFT", 0, 0, "IconBadge", "RIGHT"),
        Anchor("RIGHT")
      }
    },

    SubText = {
      -- text = "Cliquer pour consulter la quête",
      sharedMediaFont = FontType("PT Sans Narrow Bold", 12),
      textColor       = Color(0.55, 0.55, 0.55),
      location = {
        Anchor("TOP", 0, -4, "QuestName", "BOTTOM"),
        Anchor("LEFT", 0, 0, "IconBadge", "RIGHT"),
        Anchor("RIGHT"),
        Anchor("BOTTOM", 0, 2)
      }
    },

    StatesStyles = {
      [AutoQuestView.State.Offer] = {
        HeaderText = {
          text      = QUEST_WATCH_POPUP_QUEST_DISCOVERED,
          textColor = Color(1, 216/255, 0),
        },

        SubText = {
          text      = QUEST_WATCH_POPUP_CLICK_TO_VIEW
        }
      },

      [AutoQuestView.State.Complete] = {
        HeaderText = {
          text      = QUEST_WATCH_POPUP_QUEST_COMPLETE,
          textColor = Color(0, 1, 0)
        },

        SubText = {
          text      = QUEST_WATCH_POPUP_CLICK_TO_COMPLETE
        }
      }
    }
  }
})