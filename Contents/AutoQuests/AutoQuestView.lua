-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                  "SylingTracker.AutoQuestView"                        ""
-- ========================================================================= --
export {
  FromUIProperty                      = Wow.FromUIProperty,
  ShowQuestOffer                      = ShowQuestOffer,
  ShowQuestComplete                   = ShowQuestComplete,
}

__UIElement__()
class "AutoQuestView" (function(_ENV)
  inherit "Button" extend "IView"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnClickHandler(self)
    local questType = self.AutoQuestType
    local questID   = self.AutoQuestID

    if not questID or not questType then 
      return 
    end

    -- Important: Don't put AutoQuestPopupTracker_RemovePopUp as export, else the hooks are 
    -- not triggered, and the popup won't removed from SylingTracker.
    if questType == "OFFER" then 
      ShowQuestOffer(questID)
      AutoQuestPopupTracker_RemovePopUp(questID)
    elseif questType == "COMPLETE" then 
      ShowQuestComplete(questID)
      AutoQuestPopupTracker_RemovePopUp(questID)
    end
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data, ...)
    self.AutoQuestID    = data.questID
    self.AutoQuestName  = data.name
    self.AutoQuestType  = data.type
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  __Observable__()
  property "AutoQuestName" {
    type    = String,
    default = "",
  }

  __Observable__()
  property "AutoQuestID" {
    type    = Number
  }

  __Observable__()
  property "AutoQuestType" {
    type    = String
  }
  -----------------------------------------------------------------------------
  --                              Constructors                               --
  -----------------------------------------------------------------------------
  __Template__ {
    Icon        = Texture,
    HeaderText  = FontString,
    QuestName   = FontString,
    SubText     = FontString,
  }
  function __ctor(self) 
    self.OnClick = self.OnClick + OnClickHandler
  end 
end)

__UIElement__()
class "AutoQuestListView" { ListView }
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [AutoQuestView] = {
    height = 55,
    width = 250,

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
      vertexColor = { r = 35/255, g = 40/255, b = 46/255, a = 0.4},
      setAllPoints = true,
    },

    Icon = {
      width = 45,
      height = 45,
      mediaTexture = { atlas = AtlasType("AutoQuest-Badge-Campaign") },
      location = {
        Anchor("LEFT", 5, 0)
      }
    },

    HeaderText = {
      text = FromUIProperty("AutoQuestType"):Map(function(type)
        if type == "COMPLETE" then 
          return QUEST_WATCH_POPUP_QUEST_COMPLETE
        end

        return QUEST_WATCH_POPUP_QUEST_DISCOVERED
      end),
      textColor = FromUIProperty("AutoQuestType"):Map(function(type)
        if type == "COMPLETE" then 
          return Color(0, 1, 0)
        end 

        return Color(1, 216/255, 0)
      end),
      mediaFont = FontType("PT Sans Narrow Bold", 12),
      location = {
        Anchor("TOP", 0, -2),
        Anchor("LEFT", 0, 0, "Icon", "RIGHT"),
        Anchor("RIGHT")
      }      
    },

    QuestName = {
      mediaFont = FontType("PT Sans Narrow Bold", 13),
      text = FromUIProperty("AutoQuestName"),
      textTransform = "UPPERCASE",
      textColor       = Color(0.9, 0.9, 0.9),
      location = {
        Anchor("TOP", 0, -4, "HeaderText", "BOTTOM"),
        Anchor("LEFT", 0, 0, "Icon", "RIGHT"),
        Anchor("RIGHT")
      }     
    },

    SubText = {
      mediaFont = FontType("PT Sans Narrow Bold", 12),
      text = FromUIProperty("AutoQuestType"):Map(function(type)
        if type == "COMPLETE" then 
          return QUEST_WATCH_POPUP_CLICK_TO_COMPLETE
        end

        return QUEST_WATCH_POPUP_CLICK_TO_VIEW
      end),
      textColor       = Color(0.55, 0.55, 0.55),
      location = {
        Anchor("TOP", 0, -4, "QuestName", "BOTTOM"),
        Anchor("LEFT", 0, 0, "Icon", "RIGHT"),
        Anchor("RIGHT"),
        Anchor("BOTTOM", 0, 2)
      }
    }
  },

  [AutoQuestListView] = {
    viewClass = AutoQuestView,
    indexed = false
  }
})