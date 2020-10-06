-- ========================================================================= --
--                              EskaTracker 2                                --
--           https://www.curseforge.com/wow/addons/eskatracker-2             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/EskaTracker2                  --
--                                                                           --
-- ========================================================================= --
Syling                      "SylingTracker.Quests.QuestView"                 ""
-- ========================================================================= --
namespace                          "SLT"
-- ========================================================================= --
-- Iterator helper for ignoring the children are used for backdrop, and avoiding
-- they are taken as account for their parent height
IterateFrameChildren  = Utils.IterateFrameChildren
-- Check if the player is on the Shadowlands environment
IsOnShadowlands       = Utils.IsOnShadowlands
-- ========================================================================= --
ResetStyles           = Utils.ResetStyles
ShowContextMenu       = API.ShowContextMenu
ValidateFlags         = System.Toolset.validateflags
GameTooltip           = GameTooltip
-- ========================================================================= --
__Recyclable__ "SylingTracker_QuestView%d"
class "QuestView" (function(_ENV)
  inherit "Button" extend "IView"

  enum "Type" {
    Common    = 1,
    Dungeon   = 2,
    Raid      = 3,
    Legendary = 4,
  }

  __Flags__()
  enum "Flags" {
    NONE = 0,
    HAS_OBJECTIVES = 1,
    HAS_ITEM = 2
  }
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data)
    local header          = self:GetChild("Header")
    local name            = header:GetChild("Name")
    local levelBadge      = header:GetChild("Level")
    local levelTextBadge  = levelBadge:GetChild("Label")
    local tagIcon         = header:GetChild("Tag")

    -- Set the quest title 
    name:SetText(data.name)

    -- Set the level 
    if data.level then
      levelTextBadge:SetText(data.level)
      local difficultyColor = GetQuestDifficultyColor(data.level)
      if difficultyColor then 
        Style[levelTextBadge].textColor = Color(difficultyColor)
        Style[levelBadge].backdropColor = {
          r = difficultyColor.r,
          g = difficultyColor.g,
          b = difficultyColor.b, 
          a = 0.5
        }
      end
    end

    -- Update the context menu
    if data.questID then 
      self.OnClick = function(_, mouseButton)
        if mouseButton == "RightButton" then 
          ShowContextMenu("quest", self, data.questID)
        else
          if data.isAutoComplete and data.isComplete then
            AutoQuestPopupTracker_RemovePopUp(data.questID)
            if IsOnShadowlands() then 
              ShowQuestComplete(data.questID)
            else 
              ShowQuestComplete(data.questLogIndex)
            end
          else 
            QuestMapFrame_OpenToQuestDetails(data.questID)
          end
        end
      end
    end

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
      ResetStyles(name)
      ResetStyles(header)
      ResetStyles(tagIcon)

      -- Is the quest has objectives
      if ValidateFlags(Flags.HAS_OBJECTIVES, flags) then 
        self:AcquireObjectives()
      else
        self:ReleaseObjectives()
      end

      -- Is the quest has an item quest
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

    -- Tag 
    local tag = data.tag 
    if tag and tag ~= 0 then
      local coords = QUEST_TAG_TCOORDS[tag]
      if coords then
        tagIcon:SetTexCoord(unpack(coords))
        tagIcon:Show() 
      else 
        tagIcon:Hide()
      end
    else 
      tagIcon:Hide()
    end

    -- Update the conditionnal children if exists
    local objectivesView = self.__objectivesView
    if objectivesView then
      if data.isAutoComplete and data.isComplete then
        objectivesView:UpdateView({
          [1] = { isCompleted = true, text = QUEST_WATCH_QUEST_COMPLETE},
          [2] = { isCompleted = false, text = QUEST_WATCH_CLICK_TO_COMPLETE}
        })
      else 
        objectivesView:UpdateView(data.objectives)
      end
    end

    local itemBadge = self.__itemBadge
    if itemBadge then
      Style[itemBadge].Icon.fileID = data.item.texture 
      if data.item.link then 
        itemBadge.OnLeave = function() GameTooltip:Hide() end
        itemBadge.OnEnter = function()
          GameTooltip:SetOwner(itemBadge, "ANCHOR_LEFT")
          GameTooltip:SetHyperlink(data.item.link)
          GameTooltip:Show()
        end
      end
    end

    self.Flags = flags
  end 


  -- function OnViewUpdate(self, data, updater)

  --   local header = self:GetChild("Header")
  --   local objectives
  --   local name = header:GetChild("Name")
  --   local levelBadge = header:GetChild("Level")
  --   local levelTextBadge = levelBadge:GetChild("Label")
  --   -- local levelText = levelFrame:GetChild("Text")

  --   name:SetText(data.name)

  --   levelTextBadge:SetText(data.level)

  --   if data.level then 
  --     local difficultyColor = GetQuestDifficultyColor(data.level)
  --     if difficultyColor then 
  --       Style[levelTextBadge].textColor = Color(difficultyColor)
  --       Style[levelBadge].backdropColor = {
  --         r = difficultyColor.r,
  --         g = difficultyColor.g,
  --         b = difficultyColor.b, 
  --         a = 0.5
  --       }
  --     end 
  --   end

  --   if data.objectives then 
  --     objectives = self:AcquireObjectives()
  --     objectives:Update(data.objectives, updater)
  --   else 
  --     self:ReleaseObjectives()
  --   end

  --   if data.questID then
  --     self.OnClick = function() 
  --       ShowContextMenu("quest", self, data.questID)
  --     end 
  --   end

  --   local flags = Flags.NONE
  --   if data.item then 
  --     flags = Flags.HAS_ITEM
  --   end

  --   if flags ~= self.Flags then
  --     print("Reset self")
  --     ResetStyles(self, nil, true)

  --     if objectives then
  --       print("Reset objectives")
  --       ResetStyles(objectives, nil, true)
  --       Style[objectives] = self.Objectives
  --     end
  --     ResetStyles(name)
  --     ResetStyles(header)

  --     if ValidateFlags(Flags.HAS_ITEM, flags) then 
  --       local item = self:AcquireItemBadge()
  --       item:Show()
  --       Style[item].Icon.fileID = data.item.texture 

  --       if data.item.link then 
  --         item.OnLeave = function() GameTooltip:Hide() end 

  --         item.OnEnter = function()
  --           GameTooltip:SetOwner(item, "ANCHOR_LEFT")
  --           GameTooltip:SetHyperlink(data.item.link)
  --           GameTooltip:Show()
  --         end
  --       end
  --     else 
  --       self:ReleaseItemBadge()
  --     end

  --     if flags ~= Flags.NONE then 
  --       local styles = self.FlagsStyles and self.FlagsStyles[flags]
  --       if styles then 
  --         Style[self] = styles 
  --       end 
  --     end
  --   end 

  --   self.Flags = flags
  -- end

  function OnAdjustHeight(self, useAnimation)
    local height = 0
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

  function AcquireItemBadge(self)
    local itemBadge = self:GetChild("Item")
    if not itemBadge then 
      itemBadge = IconBadge.Acquire()
      self.__previousItemBadgeName = itemBadge:GetName()

      itemBadge:SetParent(self)
      itemBadge:SetName("Item")
      -- REVIEW: Is Inst
      -- itemBadge:InstantApplyStyle()

      self:AdjustHeight()

      self.__itemBadge = itemBadge
    end

    return itemBadge
  end

  function ReleaseItemBadge(self)
    local itemBadge = self:GetChild("Item")
    if itemBadge then 
      itemBadge:SetName(self.__previousItemBadgeName)
      self.__previousItemBadgeName = nil 

      itemBadge.OnLeave = nil 
      itemBadge.OnEnter = nil 

      itemBadge:Release()

      self:AdjustHeight()

      self.__itemBadge = nil
    end 
  end

  function AcquireObjectives(self)
    local objectives = self:GetChild("Objectives")
    if not objectives then 
      objectives = self.ObjectivesClass.Acquire()

      -- We need to keep the old name when we'll release it
      self.__previousObjectivesName = objectives:GetName()

      objectives:SetParent(self)
      objectives:SetName("Objectives")

      -- It's important to only style it once we have set its parent and its new
      -- name
      -- if self.Objectives then 
      --   Style[objectives] = self.Objectives 
      -- end

      -- Register the events
      objectives.OnSizeChanged = objectives.OnSizeChanged + self.OnObjectivesSizeChanged

      self:AdjustHeight()

      self.__objectivesView = objectives
    end

    return objectives 
  end

  function ReleaseObjectives(self)
    local objectives = self:GetChild("Objectives")
    if objectives then
      -- Give its old name (generated by the recycle system)
      objectives:SetName(self.__previousObjectivesName)
      self.__previousObjectivesName = nil 

      -- Unregister the events
      objectives.OnSizeChanged = objectives.OnSizeChanged - self.OnObjectivesSizeChanged

      -- It's better to release after events have been unregistered for avoiding
      -- useless class 
      objectives:Release()

      self:AdjustHeight()

      self.__objectivesView = nil
    end
  end

  --- Recycle System
  function OnRelease(self)
    -- Release first the children
    self:ReleaseItemBadge()
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
    self.Type = nil 
    self.Flags = nil

    -- Will Remove all custom styles properties, so the  next time the object will
    -- be used, this one will be in a clean state
    ResetStyles(self)


    -- -- REVIEW: Probably find a better way ?
    -- local objectives = self:GetChild("Objectives")
    -- objectives:ReleaseUnusedObjectives(0)

    -- self.Type = nil
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

  property "Type" {
    type = QuestView.Type,
    default = QuestView.Type.Common
  }

  property "Flags" {
    type = QuestView.Flags,
    default = QuestView.Flags.NONE
  }

  property "ObjectivesClass" {
    type    = ClassType,
    default = ObjectiveListView
  }

  property "PaddingBottom" {
    type = Number, 
    default = 5
  }

  -- property "Objectives" {
  --   type = Table,
  -- }

  -- property "NewObjectives" {
  --   type = Table
  -- }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__{
    -- Objectives = ObjectiveListView,
    Header = Frame,
    {
      Header = {
        Tag  = Texture,
        Name = SLTFontString,
        Level = TextBadge
      }
    }
  }
  function __ctor(self)
    -- Important! As the frame ajusts its height depending of its children height
    -- we need to set its height when contructed for the event "OnSizechanged" of
    -- its children is triggered.
    self:SetHeight(1)

    -- local objectives = self:GetChild("Objectives")
    -- objectives.OnSizeChanged = objectives.OnSizeChanged + function(f, ...)
    --   self:AdjustHeight()
    -- end

    self.OnObjectivesSizeChanged = function() self:AdjustHeight() end

    -- self:AdjustHeight()

    -- Experimental 
    self:SetClipsChildren(true)
  end 
end)


__Recyclable__ "SylingTracker_LegendaryQuestView%d"
class "LegendaryQuestView" { QuestView }

__Recyclable__ "SylingTracker_RaidQuestView%d"
class "RaidQuestView" { QuestView }

__Recyclable__ "SylingTracker_DungeonQuestView%d"
class "DungeonQuestView" { QuestView }


--- Manages the quests, if your view may have various quests, this is advised
-- using this class
__Recyclable__ "SylingTracker_QuestListView%d"
class "QuestListView" (function(_ENV)
  inherit "Frame" extend "IView"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data, updater)
    local questIndex = 0

    wipe(self.questsID)
    wipe(self.questsOrder)
    
    for _, questData in pairs(data) do 
      tinsert(self.questsOrder, questData)
    end

    table.sort(self.questsOrder, function(a, b)
      local aDistance, bDistance = a.distance, b.distance
      if aDistance and bDistance then 
        return aDistance < bDistance 
      end

      return a.questID < b.questID
    end)

    local previousQuest
    for _, questData in ipairs(self.questsOrder) do
      questIndex = questIndex + 1

      local questID     = questData.questID
      local isLegendary = questData.isLegendary
      local isDungeon   = questData.isDungeon
      local isRaid      = questData.isRaid
      local type        = QuestView.Type.Common

      if isLegendary then 
        type = QuestView.Type.Legendary
      elseif isRaid then 
        type = QuestView.Type.Raid 
      elseif isDungeon then 
        type = QuestView.Type.Dungeon 
      end 

      local quest = self:AcquireQuest(questID, type)

      if questIndex > 1 then 
        quest:SetPoint("TOP", previousQuest, "BOTTOM", 0, -5) -- TODO: Add Spacing
        quest:SetPoint("LEFT", 0, 0) -- 4 
        quest:SetPoint("RIGHT", 0, 0) -- -4
      elseif questIndex == 1 then 
        quest:SetPoint("TOP")
        quest:SetPoint("LEFT", 0, 0) -- 4
        quest:SetPoint("RIGHT", 0, 0) -- -4
      end
      quest:UpdateView(questData, updater)

      previousQuest = quest

      self.questsID[questID] = true
    end

    self:ReleaseUnusedQuests()
  end

  __Static__() function IsCorrectObjectForType(obj, type)
    if type == QuestView.Type.Common and Class.IsObjectType(obj, QuestView) then 
      return true 
    elseif type == QuestView.Type.Dungeon and Class.IsObjectType(obj, DungeonQuestView) then 
      return true 
    elseif type == QuestView.Type.Raid and Class.IsObjectType(obj, RaidQuestView) then 
      return true 
    elseif type == QuestView.Type.Legendary and Class.IsObjectType(obj, LegendaryQuestView) then 
      return true 
    end 

    return false 
  end

  function AcquireQuest(self, id, type)
    local quest = self.questsCache[id]
    local new = false 

    if quest and not IsCorrectObjectForType(quest, type) then 
      quest:Release()
      self.questsCache[id] = nil 
      new = true 
    end

    if not quest or new then 
      if type == QuestView.Type.Legendary then 
        quest = LegendaryQuestView.Acquire() 
      elseif type == QuestView.Type.Raid then 
        quest = RaidQuestView.Acquire()
      elseif type == QuestView.Type.Dungeon then 
        quest = DungeonQuestView.Acquire()
      else 
        quest = QuestView.Acquire() 
      end
      quest:Show()

      quest:SetParent(self)

      quest.OnSizeChanged = quest.OnSizeChanged + self.OnQuestSizeChanged

      self:AdjustHeight()

      self.questsCache[id] = quest
    end

    return quest
  end


  function ReleaseUnusedQuests(self)
    for questID, quest in pairs(self.questsCache) do 
      if not self.questsID[questID] then
        self.questsCache[questID] = nil 

        quest.OnSizeChanged = quest.OnSizeChanged - self.OnQuestSizeChanged
        quest:Release()
        self:AdjustHeight()
      end 
    end 
  end 

  function OnAdjustHeight(self)
    local height = 0
    local count = 0
    for _, child in IterateFrameChildren(self) do
      height = height + child:GetHeight() 

      count = count + 1
    end

    height = height + 5 * math.max(0, count-1)

    -- self:SetHeight(height)
    PixelUtil.SetHeight(self, height)
  end

  function OnRelease(self)
    wipe(self.questsID)
    wipe(self.questsOrder)
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
  end
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

     -- Keep in the cache the quest, to be reused. 
    -- use: self.questsCache[questID] = questObject
    self.questsCache = setmetatable({}, { __mode = "v"})

    -- Get the current quest id's list. Used internally to release the 
    -- unused quests
    -- use: self.questsID[questID] = true or nil
    self.questsID = {}

    self.questsOrder = {}


    self.OnQuestSizeChanged = function() self:AdjustHeight() end


    self:SetClipsChildren(true)
  end

end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [QuestView] = {
    width = 300,
    backdrop = { 
      bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
    },
    backdropColor = { r = 35/255, g = 40/255, b = 46/255, a = 0.73},
    registerForClicks = { "LeftButtonDown", "RightButtonDown" },

    -- NormalTexture = {
    --   file = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
    --   vertexColor =  { r = 35/255, g = 40/255, b = 46/255, a = 0.73},
    --   setAllPoints = true,
    -- },

    -- HighlightTexture = {
    --   file = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
    --   vertexColor = { r = 35/255, g = 40/255, b = 46/255, a = 0.1},
    --   setAllPoints = true,
    -- },
    
    -- Header Child
    Header = {
      height = 24,
      location = {
        Anchor("TOPLEFT"),
        Anchor("TOPRIGHT")
      },
      
      Tag = {
        height = 18,
        width  = 18,
        file = QUEST_ICONS_FILE,
        location = {
          Anchor("LEFT", 3, 0)
        }
      },

      -- Header/Name child 
      Name = {
        location = {
          Anchor("TOP"),
          Anchor("LEFT", 0, 0, "Tag", "RIGHT"),
          Anchor("RIGHT", 0, 0, "Level", "LEFT"),
          Anchor("BOTTOM")
        },
        sharedMediaFont = FontType("DejaVuSansCondensed Bold", 10)
      },
      -- Header/Level child 
      Level = {
        height = 16,
        width  = 30,
        backdropColor = { r = 160/255, g = 160/255, b = 160/255, a = 0.5},
        location = {
          Anchor("RIGHT", -5, 0)
        },

        Label = {
          justifyH = "RIGHT"
        }
      },
    },

    FlagsStyles = {
      [QuestView.Flags.HAS_OBJECTIVES] = {
        Objectives = {
          spacing = 5,
          location = {
            Anchor("TOP", 0, -4, "Header", "BOTTOM"),
            Anchor("LEFT"),
            Anchor("RIGHT")
          }
        }
      },
      [QuestView.Flags.HAS_OBJECTIVES + QuestView.Flags.HAS_ITEM] = {
        Item = {
          height = 28,
          width  = 28,
          location = {
            Anchor("TOPLEFT", 4, -4, "Header", "BOTTOMLEFT")
          },

          Icon = {
            texCoords = { top = 0.93, left = 0.07, bottom = 0.07, right = 0.93}
          }
        },
        Objectives = {
          spacing = 5,
          location = {
            Anchor("TOP", 2, -4, "Header", "BOTTOM"),
            Anchor("LEFT", 2, 0, "Item", "RIGHT"),
            Anchor("RIGHT")            
          }
        }
      }
    }
  },
  [LegendaryQuestView] = {
    backdropColor = { r = 11/255, g = 101/255, b = 142/255, a = 0.73 }
  },

  [RaidQuestView] = {
    backdropColor = { r = 0, g = 84/255, b = 2/255, a = 0.73}
  },
  [DungeonQuestView] = {
    -- backdropColor = { r = 11/255, g = 101/255, b = 142/255, a = 0.83 }
    backdropColor = { r = 38/255, g = 97/255, b = 0/255, a = 0.73 }
  }
})