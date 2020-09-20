-- ========================================================================= --
--                              EskaTracker 2                                --
--           https://www.curseforge.com/wow/addons/eskatracker-2             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/EskaTracker2                  --
--                                                                           --
-- ========================================================================= --
Syling                "SylingTracker.Worldquests.WorldQuestView"            ""
-- ========================================================================= --
namespace                          "SLT"
-- ========================================================================= --
-- Iterator helper for ignoring the children are used for backdrop, and avoiding
-- they are taken as account for their parent height
IterateFrameChildren = Utils.IterateFrameChildren

__Recyclable__ "SylingTracker_WorldQuestView%d"
class "WorldQuestView" { TaskView }


__Recyclable__ "SylingTracker_WorldQuestListView%d"
class "WorldQuestListView" (function(_ENV)
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
        quest:SetPoint("TOP", previousQuest, "BOTTOM", 0, -self.WorldQuestsSpacing)
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
      quest = WorldQuestView.Acquire()
      quest:SetParent(self)
      quest:SetPoint("LEFT")
      quest:SetPoint("RIGHT")

      quest.OnSizeChanged = quest.OnSizeChanged + self.OnWorldQuestSizeChanged
      
      self:AdjustHeight()

      self.questsCache[id] = quest
    end

    return quest
  end

  function ReleaseUnusedQuests(self)
    for questID, quest in pairs(self.questsCache) do 
      if not self.questsID[questID] then
        self.questsCache[questID] = nil

        quest.OnSizeChanged = quest.OnSizeChanged - self.OnWorldQuestSizeChanged
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

    height = height + self.WorldQuestsSpacing * math.max(0, count-1)

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
  property "WorldQuestsSpacing" {
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
    self.questsCache = setmetatable({}, { __mode = "v"})

    -- Get the current bonus quest id's list. Used internally to release the 
    -- unused bonus quests
    -- use: self.questsID[questID] = true or nil
    self.questsID = {}

    self.OnWorldQuestSizeChanged = function() self:AdjustHeight() end 

    self:SetClipsChildren(true)
  end
end)
