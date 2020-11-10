-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                   "SylingTracker.Tasks.Task"                         ""
-- ========================================================================= --
namespace                           "SLT"
-- ========================================================================= --
export {
  -- Iterator helper for ignoring the children are used for backdrop, and avoiding
  -- they are taken as account for their parent height
  IterateFrameChildren              = Utils.IterateFrameChildren,

  ResetStyles                       = Utils.ResetStyles,
  ShowContextMenu                   = API.ShowContextMenu,
  ValidateFlags                     = System.Toolset.validateflags,

  GameTooltip                       = GameTooltip
}
-- ========================================================================= --
__Recyclable__ "SylingTracker_TaskView%d"
class "TaskView" (function(_ENV)
  inherit "Button" extend "IView"

  __Flags__()
  enum "Flags" {
    NONE = 0,
    HAS_OBJECTIVES = 1,
    HAS_ITEM = 2
  }
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data, updater)
    local header = self:GetChild("Header")
    local objectives = self:GetChild("Objectives")
    local nameFS = header:GetChild("Name")

    -- Determines the flags 
    local flags = Flags.NONE 
    if data.objectives then 
      flags = flags + Flags.HAS_OBJECTIVES
    end

    if data.item then 
      flags = flags + Flags.HAS_ITEM
    end

    if flags ~= self.Flags then 
      ResetStyles(self)
      ResetStyles(header)
      ResetStyles(nameFS)

      -- Is the task has objectives 
      if ValidateFlags(Flags.HAS_OBJECTIVES, flags) then 
        self:AcquireObjectives()
      else
        self:ReleaseObjectives() 
      end

      -- Is the task has an item quest 
      if ValidateFlags(Flags.HAS_ITEM, flags) then 
        self:AcquireItemBadge()
      else 
        self:ReleaseItemBadge()
      end

      -- Styling stuff 
      if flags ~= Flags.NONE then 
        local styles = self.FlagsStyles and self.FlagsStyles[flags]
        if styles then 
          Style[self] = styles 
        end 
      end 
    end

    -- Update the context menu if exists 
    if self.ContextMenuID and data.questID then 
      self.OnClick = function(_, mouseButton) 
         if mouseButton == "RightButton" then 
            ShowContextMenu(self.ContextMenuID, self, data.questID)
         end
      end
    end

    -- Update the task name
    Style[nameFS].text = data.name

    -- Update the objectives if needed
    local objectivesData = data.objectives 
    if objectivesData then 
      local objectivesView = self:AcquireObjectives()
      objectivesView:UpdateView(objectivesData)
    end

    -- Update the item if needed
    local itemData = data.item 
    if itemData then 
      local itemBadge = self:AcquireItemBadge() 
      Style[itemBadge].Icon.fileID = itemData.texture 

      if itemData.link then 
        itemBadge.OnLeave = function() GameTooltip:Hide() end
        itemBadge.OnEnter = function()
          GameTooltip:SetOwner(itemBadge, "ANCHOR_LEFT")
          GameTooltip:SetHyperlink(itemData.link)
          GameTooltip:Show()
        end
      end
    end

    self.Flags = flags
  end

  function OnAdjustHeight(self, useAnimation)
    local maxOuterBottom
    for childName, child in IterateFrameChildren(self) do

      local outerBottom = child:GetBottom()
      local outerTop = child:GetTop()
      if outerBottom then 
        if not maxOuterBottom or maxOuterBottom > outerBottom then 
            maxOuterBottom = outerBottom
            maxChild = child
        end
      end
    end

    if maxOuterBottom then 
      local computeHeight = (self:GetTop() - maxOuterBottom) + self.PaddingBottom
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

      -- We need to keep the old name when we'll release it. 
      self.__PreviousObjectivesName = objectives:GetName() 

      objectives:SetParent(self)
      objectives:SetName("Objectives")
      objectives:InstantApplyStyle()

      -- Register the events 
      objectives.OnSizeChanged = objectives.OnSizeChanged + self.OnObjectivesSizeChanged

      self:AdjustHeight()
    end

    return objectives
  end

  function ReleaseObjectives(self)
    local objectives = self:GetChild("Objectives")
    if objectives then
      -- Give its old name (generated by the recycle system) 
      objectives:SetName(self.__PreviousObjectivesName)
      self.__PreviousObjectivesName = nil

      -- Unregister the events 
      objectives.OnSizeChanged = objectives.OnSizeChanged - self.OnObjectivesSizeChanged

      -- It's better to release it after the event has been unregistered for avoiding
      -- useless call 
      objectives:Release()

      self:AdjustHeight()
    end
  end

  function AcquireItemBadge(self)
    local itemBadge = self:GetChild("Item")
    if not itemBadge then 
      itemBadge = IconBadge.Acquire()
      self.__PreviousItemBadgeName = itemBadge:GetName()

      itemBadge:SetParent(self)
      itemBadge:SetName("Item")
      itemBadge:InstantApplyStyle()

      self:AdjustHeight()
    end

    return itemBadge
  end

  function ReleaseItemBadge(self)
    local itemBadge = self:GetChild("Item")
    if itemBadge then 
      itemBadge:SetName(self.__PreviousItemBadgeName)
      self.__PreviousItemBadgeName = nil 

      itemBadge.OnLeave = nil 
      itemBadge.OnEnter = nil 

      itemBadge:Release() 

      self:AdjustHeight()
    end 
  end

  function OnRelease(self)
    -- Release first the children
    self:ReleaseObjectives()
    self:ReleaseItemBadge()

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
    self.Type   = nil 
    self.Flags  = nil

    -- Will Remove all custom styles properties, so the  next time the object will
    -- be used, this one will be in a clean state
    ResetStyles(self)
  end

  function OnAcquire(self)
    -- Important ! We need the frame is instantly styled as this may affect 
    -- its height.
    self:InstantApplyStyle()


    self:AdjustHeight()

    self:Show()
  end 
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "PaddingBottom" {
    type    = Number,
    default = 5
  }

  property "ObjectivesClass" {
    type    = ClassType,
    default = ObjectiveListView
  }

  property "Flags" {
    type = TaskView.Flags, 
    default = TaskView.Flags.NONE
  }

  property "FlagsStyles" {
    type = Table,
  }

  property "ContextMenuID" {
    type    = String,
    default = "task"
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__{
    Header = Frame,
    {
      Header = {
        Name = SLTFontString
      }
    }
  }
  function __ctor(self)
    -- Important! As the frame ajusts its height depending of its children height
    -- we need to set its height when contructed for the event "OnSizechanged" of
    -- its children is triggered.
    self:SetHeight(1)

    self.OnObjectivesSizeChanged = function() self:AdjustHeight() end

    self:SetClipsChildren(true) 
  end
end)

__Recyclable__ "SylingTracker_TaskListView%d"
class "TaskListView" (function(_ENV)
  inherit "Frame" extend "IView"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data, updater)
    local questIndex = 0
    wipe(self.questsID)

    local previousQuest
    for _, questData in pairs(data) do 
      questIndex = questIndex + 1

      local questID =  questData.questID

    
      local quest = self:AcquireQuest(questID)

      if questIndex > 1 then 
        quest:SetPoint("TOP", previousQuest, "BOTTOM", 0, -self.TasksSpacing)
      elseif questIndex == 1 then 
        quest:SetPoint("TOP")
      end
      quest:Show()
      quest:UpdateView(questData, updater)

      previousQuest = quest

      self.questsID[questID] = true 
    end 

    self:ReleaseUnusedQuests()
  end

  function AcquireQuest(self, id)
    local quest = self.questsCache[id]
    if not quest then
      quest = TaskView.Acquire()
      quest:SetParent(self)
      quest:SetPoint("LEFT")
      quest:SetPoint("RIGHT")

      quest.OnSizeChanged = quest.OnSizeChanged + self.OnTaskSizeChanged
      
      self:AdjustHeight()

      self.questsCache[id] = quest
    end

    return quest
  end

  function ReleaseUnusedQuests(self)
    for questID, quest in pairs(self.questsCache) do 
      if not self.questsID[questID] then
        self.questsCache[questID] = nil

        quest.OnSizeChanged = quest.OnSizeChanged - self.OnTaskSizeChanged
        quest:Release()
        self:AdjustHeight()
      end 
    end 
  end

  function OnAdjustHeight(self, useAnimation)
    local height = 0
    local count = 0
    for _, child in IterateFrameChildren(self) do
      height = height + child:GetHeight() 

      count = count + 1
    end

    height = height + self.TasksSpacing * math.max(0, count-1)

    if useAnimation then 
      self:SetAnimatedHeight(height)
    else 
      self:SetHeight(height)
    end
  end

  function OnRelease(self)
    wipe(self.questsID)
    self:ReleaseUnusedQuests()

    self:ClearAllPoints()
    self:SetParent()
    self:Hide()
    self:CancelAdjustHeight()
    self:CancelAnimatingHeight()

    self:SetHeight(1)
  end 

  function OnAcquire(self)
    self:Show()
    -- Important ! We need the frame is instantly styled as this may affect 
    -- its height.
    -- self:InstantApplyStyle()
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "TasksSpacing" {
    type    = Number,
    default = 5
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  function __ctor(self)
    -- -- Important ! We need the frame is instantly styled as this may affect 
    -- -- its height.
    -- self:InstantApplyStyle()

    -- Important! As the frame ajusts its height depending of its children height
    -- we need to set its height when contructed for the event "OnSizechanged" of
    -- its children is triggered.
    self:SetHeight(1) -- !important

     -- Keep in the cache the bonus quest, to be reused. 
    -- use: self.questsCache[questID] = questObject
    self.questsCache = setmetatable({}, { __mode = "v"})

    -- Get the current bonus quest id's list. Used internally to release the 
    -- unused bonus quests
    -- use: self.questsID[questID] = true or nil
    self.questsID = {}

    self.OnTaskSizeChanged = function() self:AdjustHeight() end


    self:SetClipsChildren(true)
  end
end)
-- ========================================================================= --
--                                Styles                                     --
-- ========================================================================= --
Style.UpdateSkin("Default", {
  [TaskView] = {
    backdrop = {
      bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]]
    },
    backdropColor = { r = 35/255, g = 40/255, b = 46/255, a = 0.73},
    registerForClicks = { "RightButtonDown" },

    -- Header Child
    Header = {
      height    = 24,
      location  = {
        Anchor("TOPLEFT"),
        Anchor("TOPRIGHT")
      },

      -- Header/Name child 
      Name = {
        setAllPoints    = true,
        sharedMediaFont =  FontType("DejaVuSansCondensed Bold", 10),
        textColor       = Color(1, 106/255, 0)
      },
    },

    FlagsStyles = {
      [TaskView.Flags.HAS_OBJECTIVES] = {
        Objectives  = {
          spacing   = 5,
          location  = {
            Anchor("TOP", 0, -4, "Header", "BOTTOM"),
            Anchor("LEFT"),
            Anchor("RIGHT")
          }
        }
      },

      [TaskView.Flags.HAS_OBJECTIVES + TaskView.Flags.HAS_ITEM] = {
        Item = {
          height    = 28,
          width     = 28,
          location  = {
            Anchor("TOPLEFT", 4, -4, "Header", "BOTTOMLEFT")
          },

          Icon = {
            texCoords = RectType(0.07, 0.93, 0.07, 0.93)
          }
        },

        Objectives = {
          spacing   = 5,
          location  = {
            Anchor("TOP", 2, -4, "Header", "BOTTOM"),
            Anchor("LEFT", 2, 0, "Item", "RIGHT"),
            Anchor("RIGHT")            
          }
        }
      }
    }
  }
})
