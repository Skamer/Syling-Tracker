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
  FromBackdrop                        = Frame.FromBackdrop,
  RegisterUISetting                   = API.RegisterUISetting,
  FromUISetting                       = API.FromUISetting,
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
      -- AutoQuestPopupTracker_RemovePopUp(questID)
      QuestObjectiveTracker:RemoveAutoQuestPopUp(questID)
    elseif questType == "COMPLETE" then 
      ShowQuestComplete(questID)
      -- AutoQuestPopupTracker_RemovePopUp(questID)
      QuestObjectiveTracker:RemoveAutoQuestPopUp(questID)
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
--                              UI Settings                                  --
-------------------------------------------------------------------------------
RegisterUISetting("autoQuest.showBackground", true)
RegisterUISetting("autoQuest.showBorder", true)
RegisterUISetting("autoQuest.backgroundColor", Color(35/255, 40/255, 46/255, 0.73))
RegisterUISetting("autoQuest.borderColor", Color(0, 0, 0, 0.4))
RegisterUISetting("autoQuest.borderSize", 1)
RegisterUISetting("autoQuest.header.mediaFont", FontType("PT Sans Narrow Bold", 12))
RegisterUISetting("autoQuest.header.textTransform", "NONE")
RegisterUISetting("autoQuest.header.justifyH", "CENTER")

RegisterUISetting("autoQuest.questName.mediaFont", FontType("PT Sans Narrow Bold", 13))
RegisterUISetting("autoQuest.questName.textColor", Color(0.9, 0.9, 0.9))
RegisterUISetting("autoQuest.questName.textTransform", "UPPERCASE")
RegisterUISetting("autoQuest.questName.justifyH", "CENTER")

RegisterUISetting("autoQuest.subText.mediaFont", FontType("PT Sans Narrow Bold", 12))
RegisterUISetting("autoQuest.subText.textColor", Color(0.55, 0.55, 0.55))
RegisterUISetting("autoQuest.subText.textTransform", "NONE")
RegisterUISetting("autoQuest.subText.justifyH", "CENTER")
-------------------------------------------------------------------------------
--                              Observables                                  --
-------------------------------------------------------------------------------
function FromHeaderText()
  return FromUIProperty("AutoQuestType"):Map(function(type)
    if type == "COMPLETE" then 
      return QUEST_WATCH_POPUP_QUEST_COMPLETE
    end

    return QUEST_WATCH_POPUP_QUEST_DISCOVERED
  end)
end

function FromHeaderTextColor()
  return FromUIProperty("AutoQuestType"):Map(function(type)
    if type == "COMPLETE" then 
      return Color(0, 1, 0)
    end 

    return Color(1, 216/255, 0)
  end)
end

function FromSubText()
  return FromUIProperty("AutoQuestType"):Map(function(type)
    if type == "COMPLETE" then 
      return QUEST_WATCH_POPUP_CLICK_TO_COMPLETE
    end

    return QUEST_WATCH_POPUP_CLICK_TO_VIEW
  end)
end
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [AutoQuestView] = {
    height                            = 55,
    width                             = 250,
    backdrop                          = FromBackdrop(),
    showBackground                    = FromUISetting("autoQuest.showBackground"),
    showBorder                        = FromUISetting("autoQuest.showBorder"),
    backdropColor                     = FromUISetting("autoQuest.backgroundColor"),
    backdropBorderColor               = FromUISetting("autoQuest.borderColor"),
    borderSize                        = FromUISetting("autoQuest.borderSize"),
    registerForClicks                 = { "LeftButtonDown" },

    HighlightTexture = {
      file                            = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
      vertexColor                     = { r = 35/255, g = 40/255, b = 46/255, a = 0.4},
      setAllPoints                    = true,
    },

    ---------------------------------------------------------------------------
    -- Icon 
    ---------------------------------------------------------------------------
    Icon = {
      width                           = 45,
      height                          = 45,
      mediaTexture                    = { atlas = AtlasType("AutoQuest-Badge-Campaign") },
      location                        = { Anchor("LEFT", 5, 0) }
    },
    ---------------------------------------------------------------------------
    -- Header Text 
    ---------------------------------------------------------------------------
    HeaderText = {
      mediaFont                       = FromUISetting("autoQuest.header.mediaFont"),
      text                            = FromHeaderText(),
      textColor                       = FromHeaderTextColor(),
      textTransform                   = FromUISetting("autoQuest.header.textTransform"),
      justifyH                        = FromUISetting("autoQuest.header.justifyH"),
      location                        = {
                                          Anchor("TOP", 0, -2),
                                          Anchor("LEFT", 0, 0, "Icon", "RIGHT"),
                                          Anchor("RIGHT", -2, 0)
                                      }      
    },
    ---------------------------------------------------------------------------
    -- Quest Name
    ---------------------------------------------------------------------------
    QuestName = {
      mediaFont                       = FromUISetting("autoQuest.questName.mediaFont"),
      text                            = FromUIProperty("AutoQuestName"),
      textTransform                   = FromUISetting("autoQuest.questName.textTransform"),
      textColor                       = FromUISetting("autoQuest.questName.textColor"),
      justifyH                        = FromUISetting("autoQuest.questName.justifyH"),
      location                        = {
                                          Anchor("TOP", 0, -4, "HeaderText", "BOTTOM"),
                                          Anchor("LEFT", 0, 0, "Icon", "RIGHT"),
                                          Anchor("RIGHT", -2, 0)
                                      }     
    },
    ---------------------------------------------------------------------------
    -- Sub Text
    ---------------------------------------------------------------------------
    SubText = {
      mediaFont                       = FromUISetting("autoQuest.subText.mediaFont"),
      text                            = FromSubText(),
      textTransform                   = FromUISetting("autoQuest.subText.textTransform"),
      textColor                       = FromUISetting("autoQuest.subText.textColor"),
      justifyH                        = FromUISetting("autoQuest.subText.justifyH"),
      location                        = {
                                          Anchor("TOP", 0, -4, "QuestName", "BOTTOM"),
                                          Anchor("LEFT", 0, 0, "Icon", "RIGHT"),
                                          Anchor("RIGHT", -2, 0),
                                          Anchor("BOTTOM", 0, 2)
                                      }
    }
  },

  [AutoQuestListView] = {
    viewClass = AutoQuestView,
    indexed = false
  }
})