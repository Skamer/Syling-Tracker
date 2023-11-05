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
  FromUIProperty                  = Wow.FromUIProperty,
  GetQuestDifficultyColor         = GetQuestDifficultyColor,
  TryToComputeHeightFromChildren  = Utils.Frame_TryToComputeHeightFromChildren,
  ContextMenu_Show                = API.ContextMenu_Show
}

__UIElement__()
class "QuestView" (function(_ENV)
  inherit "Button" extend "IView" 
  -----------------------------------------------------------------------------
  --                            Helper functions                             --
  -----------------------------------------------------------------------------
  local function RegisterHandlersToChild(parent, child, handler)
    if child.OnSizeChanged then 
      child.OnSizeChanged = child.OnSizeChanged + handler
    end 

    if child.OnTextHeightChanged then 
      child.OnTextHeightChanged = child.OnTextHeightChanged + handler
    end
  end

  local function UnregisterHandlersFromChild(parent, child, handler)
    if child.OnSizeChanged then 
      child.OnSizeChanged = child.OnSizeChanged - handler
    end

    if child.OnTextHeightChanged then 
      child.OnTextHeightChanged = child.OnTextHeightChanged - handler
    end   
  end
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnClickHandler(self, mouseButton)
    local questID = self.QuestID
    local contextMenuPattern = self.ContextMenuPattern

    if mouseButton == "RightButton" then 
      if questID and contextMenuPattern then 
        ContextMenu_Show(contextMenuPattern, self, questID)
      end
    end
  end

  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data, ...)
    if data.objectives then
      Style[self].Objectives.visible = true
      local child = self:GetPropertyChild("Objectives")

      -- child:InstantApplyStyle()
      child:UpdateView(data.objectives, ...)
    end

    if data.hasTimer then 
      Style[self].Timer.visible     = true 
      Style[self].Timer.startTime   = data.startTime
      Style[self].Timer.duration    = data.totalTime
      self.ObjectiveHasTimer        = true 
    else
      Style[self].Timer             = NIL
      self.ObjectiveHasTimer        = false 
    end

    self.QuestID = data.questID
    self.QuestName = data.name 
    self.QuestLevel = data.level
    self.QuestTagID = data.tag and data.tag.tagID
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
  property "QuestTagID" {
    type = Number
  }

  property "QuestID" {
    type = Number
  }

  property "ContextMenuPattern" {
    type = String
  }
  -----------------------------------------------------------------------------
  --                              Constructors                               --
  -----------------------------------------------------------------------------
  __Template__ {
    Header = Frame, 
    {
      Header = {
        Tag     = Texture, 
        Name    = FontString, 
        Level   = FontString
      }
    }
  }
  function __ctor(self) 
    local header = self:GetChild("Header")
    local name = header:GetChild("Name")
    local level = header:GetChild("Level")

    self.AdjustHeaderHeight = function()
      self:OnAdjustHeaderHeight(header)
    end

    self:SetClipsChildren(true)

    self.OnClick = self.OnClick + OnClickHandler
    self.ContextMenuPattern = "quests"
  end   
end)

-- Optional Children for QuestView 
__ChildProperty__(QuestView, "Objectives")
class(tostring(QuestView) .. ".Objectives") { ObjectiveListView }

__ChildProperty__(QuestView, "Timer")
class(tostring(QuestView) .. ".Timer") { SylingTracker.Timer }

__UIElement__()
class "RaidQuestView" { QuestView }

__UIElement__()
class "DungeonQuestView" { QuestView }

__UIElement__()
class "LegendaryQuestView" { QuestView }

__UIElement__()
class "QuestListView" { ListView }
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [QuestView] = {
    height = 24,
    minResize = { width = 0, height = 24},
    width = 250,
    autoAdjustHeight = true,
    registerForClicks = { "LeftButtonDown", "RightButtonDown" },

    backdrop = { 
      bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
    },
    backdropColor = { r = 35/255, g = 40/255, b = 46/255, a = 0.73},

    Header = {
      height = 24,

      Tag = {
        -- atlas = AtlasType("questlog-questtypeicon-dungeon"),
        atlas = FromUIProperty("QuestTagID"):Map(function(tagID)
          if not tagID then 
            return 
          end

          return { atlas = QUEST_TAG_ATLAS[tagID] }
        end),
        height = 18,
        width = 18,
        location = {
          Anchor("LEFT", 3, 0)
        }        
      },

      Name = {
        text = FromUIProperty("QuestName"),
        justifyV = "MIDDLE",
        mediaFont = FontType("DejaVuSansCondensed Bold", 10),
        location = {
          Anchor("LEFT", 0, 0, "Tag", "RIGHT"),
          Anchor("RIGHT", 0, 0, "Level", "LEFT"),
          Anchor("TOP"),
          Anchor("BOTTOM")
        }
      },

      Level = {
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
        mediaFont = FontType("PT Sans Caption Bold", 10),
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
    }
  },

  [QuestView.Objectives] = {
    spacing = 5,

    location = {
      Anchor("TOPLEFT", 0, 0, "Header", "BOTTOMLEFT"),
      Anchor("TOPRIGHT", 0, 0, "Header", "BOTTOMRIGHT"),
    }
  },

  [QuestView.Timer] = {
    location = {
      Anchor("TOPLEFT", 0, 0, "Objectives", "BOTTOMLEFT"),
      Anchor("TOPRIGHT", 0, 0, "Objectives", "BOTTOMRIGHT"),
    }
  },

  [LegendaryQuestView] = {
    backdropColor = { r = 35/255, g = 40/255, b = 46/255, a = 0.73},
  },

  [RaidQuestView] = {
    backdropColor = { r = 0, g = 84/255, b = 2/255, a = 0.73}
  },
  [DungeonQuestView] = {
    backdropColor = { r = 0, g = 72/255, b = 124/255, a = 0.73 }
  },

  [QuestListView] = {
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