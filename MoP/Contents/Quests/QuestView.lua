-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                 "SylingTracker.Contents.QuestView"                    ""
-- ========================================================================= --
export {
  FromUIProperty                        = Wow.FromUIProperty,
  GetQuestDifficultyColor               = GetQuestDifficultyColor,
  TryToComputeHeightFromChildren        = Utils.Frame_TryToComputeHeightFromChildren,
  ContextMenu_Show                      = API.ContextMenu_Show,
  RegisterUISetting                     = API.RegisterUISetting,
  FromUISetting                         = API.FromUISetting,
  FromUISettings                        = API.FromUISettings,
  GenerateUISettings                    = API.GenerateUISettings,
  GetFrame                              = Wow.GetFrame,

  -- Wow API & Utils
  Secure_OpenToQuestDetails             = Utils.Secure_OpenToQuestDetails,
  ShouldQuestIconsUseCampaignAppearance = QuestUtil.ShouldQuestIconsUseCampaignAppearance,
  GetQuestLogIndexByID                  = GetQuestLogIndexByID,
}

__UIElement__()
class "QuestItemIcon" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnLeaveHandler(self)
    GameTooltip:Hide()
  end

  local function OnEnterHandler(self)
    local itemLink = self.ItemLink
    if itemLink then 
      GameTooltip:SetOwner(self)
      GameTooltip:SetHyperlink(itemLink)
      GameTooltip:Show()
    end
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function OnSystemEvent(self, event)
    local questID = self.id

    if not event == "BAG_UPDATE_COOLDOWN" or not questID or questID <= 0 then 
      return 
    end

    local questLogIndex = GetQuestLogIndexByID(questID)

    if questLogIndex then 
      local start, duration, enable = GetQuestLogSpecialItemCooldown(questLogIndex)

      CooldownFrame_Set(self.__cooldown, start, duration, enable)

      if duration and duration > 0 and enable and enable == 0 then 
        self.ItemUsable = false
      else
        self.ItemUsable = true
      end
    end
  end

  function OnAcquire(self)
    self:RegisterSystemEvent("BAG_UPDATE_COOLDOWN")
  end

  function OnRelease(self)
    self:UnregisterSystemEvent("BAG_UPDATE_COOLDOWN")
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  __Observable__()
  property "ItemLink" {
    type = Any
  }

  __Observable__()
  property "ItemTexture" {
    type = Any
  }

  __Observable__()
  property "ItemUsable" {
    type = Boolean,
    default = true
  }

  property "id" {
    type = Number
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__ {
    Icon = Texture
  }
  function __ctor(self, name)
    local cooldown = CreateFrame("Cooldown", name.."Cooldown", self, "CooldownFrameTemplate")
    cooldown:SetAllPoints()
    self.__cooldown = cooldown

    self.OnEnter = self.OnEnter + OnEnterHandler
    self.OnLeave = self.OnLeave + OnLeaveHandler
  end
end)

__UIElement__()
class "QuestViewContent"(function(_ENV)
  inherit "Button"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnClickHandler(self, mouseButton)
    local parent = self:GetParent()
    local questID = parent.QuestID
    local contextMenuPattern = parent.ContextMenuPattern
    local data = parent and parent.Data

    if mouseButton == "RightButton" then
      if questID and contextMenuPattern then 
        ContextMenu_Show(contextMenuPattern, parent, questID)
      end
    else
      if not IsShiftKeyDown() then 
        if data.isAutoComplete and data.isComplete then 
          WatchFrameAutoQuest_ClearPopUp(questID)
          ShowQuestComplete(GetQuestLogIndexByID(questID))
        else
          -- The quest details won't be shown if the player is in combat.
          -- Secure_OpenToQuestDetails(questID)
        end
      else 
        RemoveQuestWatch(GetQuestLogIndexByID(questID))
      end
    end
  end
  -----------------------------------------------------------------------------
  --                              Constructors                               --
  -----------------------------------------------------------------------------
  __Template__ {
    Header = Frame,
    {
      Header = {
        Tag   = Texture,
        Name  = FontString,
        Level = FontString
      }
    }
  }
  function __ctor(self) 
    self.OnClick = self.OnClick + OnClickHandler
  end
end)

__UIElement__()
class "QuestView" (function(_ENV)
  inherit "Frame" extend "IView" 
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnEnablePOIHandler(self, enable)
    if enable then 
      self:UpdatePOI()
    else
      Style[self].POI = NIL 
    end
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data, ...)
    local questID = data.questID


    if data.objectives then
      Style[self].Content.Objectives.visible = true
      local child = self:GetChild("Content"):GetPropertyChild("Objectives")

      -- child:InstantApplyStyle()
      child:UpdateView(data.objectives, ...)
    end

    if data.item then 
      Style[self].Content.Item.visible = true
      local itemIcon = self:GetChild("Content"):GetPropertyChild("Item")
      itemIcon.ItemTexture = data.item.texture 
      itemIcon.ItemLink = data.item.link
      itemIcon.id = questID

      self.QuestHasItem = true
    else 
      Style[self].Content.Item = NIL

      self.QuestHasItem = false
    end

    if data.hasTimer then 
      Style[self].Content.Timer.visible     = true 
      Style[self].Content.Timer.startTime   = data.startTime
      Style[self].Content.Timer.duration    = data.totalTime
      self.ObjectiveHasTimer        = true 
    else
      Style[self].Content.Timer     = NIL
      self.ObjectiveHasTimer        = false 
    end

    self.QuestID = data.questID
    self.IsNew = data.isNew
    self.QuestName = data.name 
    self.QuestLevel = data.level
    self.QuestTagID = data.tag and data.tag.tagID
  end

  function OnRelease(self)
    self.QuestName = nil 
    self.QuestLevel = nil 
    self.QuestHasTimer = nil 
    self.QuestHasItem = nil
    self.QuestTagID = nil 
    self.QuestID = nil

    Style[self].Content.Objectives = NIL
    Style[self].Content.Timer = NIL
    Style[self].Content.Item = NIL
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------   
  __Observable__()
  property "QuestName" {
    type = String, 
    default = ""
  } 

  __Observable__()
  property "QuestLevel" {
    type = Number,
    default = 70,
  }

  __Observable__()
  property "QuestHasTimer" {
    type = Boolean,
    default = false, 
  }

  __Observable__()
  property "QuestHasItem" {
    type = Boolean,
    default = false
  }

  __Observable__()
  property "QuestTagID" {
    type = Number
  }

  __Observable__()
  property "IsNew" {
    type = Boolean,
    default = false
  }

  property "QuestID" {
    type = Number
  }

  property "ContextMenuPattern" {
    type = String,
    default = "quest"
  }
  -----------------------------------------------------------------------------
  --                              Constructors                               --
  -----------------------------------------------------------------------------
  __Template__ {
    Content = QuestViewContent
  }
  function __ctor(self) end   
end)

-- Optional Children for QuestView 
__ChildProperty__(QuestViewContent, "Objectives")
class(tostring(QuestView) .. ".Objectives") { ObjectiveListView }

__ChildProperty__(QuestViewContent, "Timer")
class(tostring(QuestView) .. ".Timer") { SylingTracker.Timer }

__ChildProperty__(QuestViewContent, "Item")
class(tostring(QuestView) .. ".Item") { SylingTracker.QuestItemIcon }

__UIElement__()
class "RaidQuestView" { QuestView }

__UIElement__()
class "DungeonQuestView" { QuestView }

__UIElement__()
class "LegendaryQuestView" { QuestView }

__UIElement__()
class "QuestListView" (function(_ENV)
  inherit "ListView"

  __Iterator__()
  function IterateData(self, data, metadata)
    local yield = coroutine.yield 

    wipe(self.QuestsOrder)

    for _, questData in pairs(data) do 
      tinsert(self.QuestsOrder, questData)
    end

    table.sort(self.QuestsOrder, function(a, b)
      local aDistance, bDistance = a.distance, b.distance
      if aDistance and bDistance then 
        return aDistance < bDistance
      end

      return a.questID < b.questID
    end)
    
    for index, questData in ipairs(self.QuestsOrder) do 
      yield(questData.questID, questData, metadata)
    end
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "QuestsOrder" {
    set = false,
    default = function() return {} end
  }
end)
-------------------------------------------------------------------------------
--                              UI Settings                                  --
-------------------------------------------------------------------------------
enum "QuestLevetVisibilityPolicyType" {
  "AlwaysShow",
  "AlwaysHide",
  "HideWhenCharIsMaxLevel",
  "ShowOnlyWhenBelowMaxLevel",
}


RegisterUISetting("quest.showBackground", true)
RegisterUISetting("quest.showBorder", true)
RegisterUISetting("quest.backgroundColor", Color(35/255, 40/255, 46/255, 0.73))
RegisterUISetting("quest.borderColor", Color(0, 0, 0, 0.4))
RegisterUISetting("quest.borderSize", 1)
RegisterUISetting("quest.name.textColor", Color.NORMAL)
RegisterUISetting("quest.name.mediaFont", FontType("DejaVuSansCondensed Bold", 10))
RegisterUISetting("quest.name.textTransform", "NONE")
RegisterUISetting("quest.name.justifyH", "CENTER")
RegisterUISetting("quest.level.mediaFont", FontType("PT Sans Caption Bold", 10))
RegisterUISetting("quest.level.visibilityPolicy", QuestLevetVisibilityPolicyType.AlwaysShow)
RegisterUISetting("quest.enablePOI", true)
RegisterUISetting("quest.showNewQuestIndicator", true)

GenerateUISettings("dungeonQuest", "quest", function(generatedSettings)
  if generatedSettings["dungeonQuest.backgroundColor"] then 
     generatedSettings["dungeonQuest.backgroundColor"].default = { r = 0, g = 72/255, b = 124/255, a = 0.73 }
  end
end)

GenerateUISettings("raidQuest", "quest", function(generatedSettings)
  if generatedSettings["raidQuest.backgroundColor"] then 
     generatedSettings["raidQuest.backgroundColor"].default = { r = 0, g = 84/255, b = 2/255, a = 0.73}
  end
end)

GenerateUISettings("legendaryQuest", "quest", function(generatedSettings)
  if generatedSettings["legendaryQuest.backgroundColor"] then 
     generatedSettings["legendaryQuest.backgroundColor"].default = { r = 35/255, g = 40/255, b = 46/255, a = 0.73}
  end
end)
-------------------------------------------------------------------------------
--                              Observables                                  --
-------------------------------------------------------------------------------
function FromBackdrop()
 return GetFrame("OnBackdropChanged")
    :Next()
    :Map(function(tracker, value, _, prop)
      local showBackground = tracker.ShowBackground
      local showBorder = tracker.ShowBorder
      if not showBackground and not showBorder then 
        return nil 
      end

      local backdrop = {}
      if showBackground then 
        backdrop.bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]]
      end

      if showBorder then 
        backdrop.edgeFile = [[Interface\Buttons\WHITE8X8]]
        backdrop.edgeSize = tracker.BorderSize
      end

      return backdrop
    end)
end

function FromObjectivesLocation()
  return FromUIProperty("QuestHasItem"):Map(function(hasItem)
    return {
      Anchor("TOP", 0, -5, "Header", "BOTTOM"),
      Anchor("LEFT"),
      Anchor("RIGHT", hasItem and -29 or 0, 0)
    }
  end)
end

function FromQuestTagIconTexCoords()
  return FromUIProperty("QuestTagID"):Map(function(tagID)
      if not tagID or not QUEST_TAG_TCOORDS[tagID] then
        return 
      end

      local left, right, top, bottom = unpack(QUEST_TAG_TCOORDS[tagID])

      if left and right and top and bottom then 
        return { left = left, right = right, top = top, bottom = bottom }
      end
    end)
end

function FromPlayerLevel()
  return Observable.Switch(
    Observable(function(observer) return observer:OnNext(UnitLevel("player")) end),
    Wow.FromEvent("PLAYER_LEVEL_UP"):Map(function(newLevel) return newLevel end)
   )
end

function FromQuestName()
  return FromUISetting("quest.showNewQuestIndicator")
    :CombineLatest(FromUIProperty("QuestName", "IsNew"))
    :Map(function(showNew, name, isNew)
      
      if showNew and isNew then 
        return WrapTextInColorCode("NEW", "FFFFFFFF") .. " " .. name
      end
      
      return name
    end)
end

function FromQuestLevelVisible()
  local maxLevel = 85

  return FromUISetting("quest.level.visibilityPolicy")
    :CombineLatest(Wow.FromUIProperty("QuestLevel"))
    :CombineLatest(FromPlayerLevel())
    :Map(function(visibilityPolicy, questLevel, playerLevel)
      if visibilityPolicy == "AlwaysHide" then 
        return false 
      elseif visibilityPolicy == "HideWhenCharIsMaxLevel" then
        if playerLevel >= maxLevel then 
          return false 
        end 
      elseif visibilityPolicy == "ShowOnlyWhenBelowMaxLevel" then 
        if questLevel >= maxLevel then 
          return false 
        end
      end

      return true
    end)
end
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [QuestItemIcon] = {
    height                            = 24,
    width                             = 24,
    backdrop                          = FromBackdrop(),
    showBackground                    = false,
    showBorder                        = true, 
    backdropBorderColor               = Color(0, 0, 0, 0.4),
    borderSize                        = 1,
    autoAdjustHeight = true,
    
    Icon = {
      file = FromUIProperty("ItemTexture"),
      setAllPoints = true,
      texCoords = { left = 0.07, right = 0.93, top = 0.07, bottom = 0.93 },
      vertexColor = FromUIProperty("ItemUsable"):Map(function(usable)
        if usable then 
          return { r = 1, g = 1, b = 1 }
        end 

        return { r = 0.4, g = 0.4, b = 0.4}
      end)
    }
  },

  [QuestView] = {
    height                            = 24,
    minResize                         = { width = 0, height = 24},
    autoAdjustHeight                  = true,
    
    Content = {
      height                          = 24,
      minResize                       = { width = 0, height = 24},
      registerForClicks               = { "LeftButtonDown", "RightButtonDown" },
      autoAdjustHeight                = true,
      backdrop                        = FromBackdrop(),
      showBackground                  = FromUISetting("quest.showBackground"),
      showBorder                      = FromUISetting("quest.showBorder"),
      backdropColor                   = FromUISetting("quest.backgroundColor"),
      backdropBorderColor             = FromUISetting("quest.borderColor"),
      borderSize                      = FromUISetting("quest.borderSize"),
      paddingBottom                   = FromUIProperty("QuestHasItem"):Map(function(hasItem) return hasItem and 5 or 0 end),

      Header = {
        height                        = 24,
  
        Tag = {
          visible                     = FromUIProperty("QuestTagID"):Map(function(tagID) return (tagID and QUEST_TAG_TCOORDS[tagID]) and true or false end),
          file                        = [[Interface\QuestFrame\QuestTypeIcons]],
          texCoords                   = FromQuestTagIconTexCoords(),
          height                      = 18,
          width                       = 18,
          location                    = {Anchor("LEFT", 3, 0) }     
        },
  
        Name = {
           text                       = FromQuestName(),
          textColor                   = FromUISetting("quest.name.textColor"),
          justifyV                    = "MIDDLE",
          justifyH                    = FromUISetting("quest.name.justifyH"),
          mediaFont                   = FromUISetting("quest.name.mediaFont"),
          textTransform               = FromUISetting("quest.name.textTransform"),
          location = {
            Anchor("LEFT", 0, 0, "Tag", "RIGHT"),
            Anchor("RIGHT", 0, 0, "Level", "LEFT"),
            Anchor("TOP"),
            Anchor("BOTTOM")
          }
        },
  
        Level = {
          visible = FromQuestLevelVisible(),
          text = Wow.FromUIProperty("QuestLevel"):Map(function(level)
             local difficultyColor = GetQuestDifficultyColor(level)
             if difficultyColor then 
              return Color(difficultyColor.r, difficultyColor.g, difficultyColor.b, 1) .. level
             else
              return level 
             end
          end),
          width = 18,
          justifyV = "MIDDLE",
          justifyH = "RIGHT",
          
          mediaFont = FromUISetting("quest.level.mediaFont"),
          location = {
            Anchor("TOP"),
            Anchor("RIGHT", -5, 0),
            Anchor("BOTTOM")
          }
        },
  
        location = {
          Anchor("TOPLEFT"),
          Anchor("TOPRIGHT")
        }
      },
      [QuestView.Objectives] = {
        spacing = 5,
        location = FromObjectivesLocation()
      },
    
      [QuestView.Item] = {
        location = {
          Anchor("TOP", 0, -5, "Header", "BOTTOM"),
          Anchor("RIGHT", -5, 0)
        }
      },
    
      [QuestView.Timer] = {
        location = {
          Anchor("TOPLEFT", 0, 0, "Objectives", "BOTTOMLEFT"),
          Anchor("TOPRIGHT", 0, 0, "Objectives", "BOTTOMRIGHT"),
        }
      },

      location = {
        Anchor("TOP"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      }
    },
  },


  [LegendaryQuestView] = {
    Content = {
      backdropColor                   = FromUISetting("legendaryQuest.backgroundColor"),
      backdropBorderColor             = FromUISetting("legendaryQuest.borderColor"),

      Header = {
        Name = {
          textColor                   = FromUISetting("legendaryQuest.name.textColor"),
        }
      }
    }
  },

  [RaidQuestView] = {
    Content = {
      backdropColor                   = FromUISetting("raidQuest.backgroundColor"),
      backdropBorderColor             = FromUISetting("raidQuest.borderColor"),

      Header = {
        Name = {
          textColor                     = FromUISetting("raidQuest.name.textColor"),
        }
      }
    }
  },
  [DungeonQuestView] = {
    Content = {
      backdropColor                   = FromUISetting("dungeonQuest.backgroundColor"),
      backdropBorderColor             = FromUISetting("dungeonQuest.borderColor"),

      Header = {
        Name = {
          textColor                     = FromUISetting("dungeonQuest.name.textColor"),
        }
      }
    }
  },

  [QuestListView] = {
    paddingLeft   = 0,
    paddingRight  = 5,
    viewClass = function(data)
      if data then 
        if data.isLegendary then 
          return LegendaryQuestView
        elseif data.isDungeon then 
          return DungeonQuestView
        elseif data.isRaid then 
          return RaidQuestView
        end
      end

      return QuestView
    end,
    indexed = false
  }
})