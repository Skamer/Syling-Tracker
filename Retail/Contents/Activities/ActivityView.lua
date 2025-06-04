-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                 "SylingTracker.Contents.ActivityView"                 ""
-- ========================================================================= --
export {
  FromUIProperty                      = Wow.FromUIProperty,
  FromBackdrop                        = Frame.FromBackdrop,
  ContextMenu_Show                    = API.ContextMenu_Show,
  RegisterUISetting                   = API.RegisterUISetting,
  FromUISetting                       = API.FromUISetting,
}

__UIElement__()
class "ActivityView" (function(_ENV)
  inherit "Button" extend "IView"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnClickHandler(self, mouseButton)
    local contextMenuPattern  = self.ContextMenuPattern
    local activityID          = self.ActivityID

    if IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() then
      local perksActivityLink = C_PerksActivities.GetPerksActivityChatLink(activityID)
      ChatEdit_InsertLink(perksActivityLink)
    elseif mouseButton ~= "RightButton" then 
      if not EncounterJournal then
        EncounterJournal_LoadUI();
      end
      if IsModifiedClick("QUESTWATCHTOGGLE") then
        C_PerksActivities.RemoveTrackedPerksActivity(activityID);
      else
        MonthlyActivitiesFrame_OpenFrameToActivity(activityID);
      end

      PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    else
      if contextMenuPattern and activityID then
        ContextMenu_Show(contextMenuPattern, self, activityID)
      end
    end
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data, ...)
    if data.objectives then 
      Style[self].Objectives.visible = true 
      local objectivesView = self:GetPropertyChild("Objectives")

      objectivesView:UpdateView(data.objectives, ...)
    end

    self.ActivityID   = data.activityID
    self.ActivityName = data.name
  end

  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  __Observable__()
  property "ActivityName" {
    type = String,
    default = ""
  }

  property "ActivityID" {
    type = Number
  }

  property "ContextMenuPattern" {
    type = String,
    default = "activity"
  }
  -----------------------------------------------------------------------------
  --                              Constructors                               --
  -----------------------------------------------------------------------------
  __Template__ {
    Name = FontString
  }
  function __ctor(self) 
    self.OnClick = self.OnClick + OnClickHandler
  end
end)

-- Optional Children for QuestView 
__ChildProperty__(ActivityView, "Objectives")
class(tostring(ActivityView) .. ".Objectives") { ObjectiveListView }


__UIElement__()
class "ActivityListView" { ListView }
-------------------------------------------------------------------------------
--                              UI Settings                                  --
-------------------------------------------------------------------------------
RegisterUISetting("activity.showBackground", true)
RegisterUISetting("activity.showBorder", true)
RegisterUISetting("activity.backgroundColor", Color(35/255, 40/255, 46/255, 0.73))
RegisterUISetting("activity.borderColor", Color(0, 0, 0, 0.4))
RegisterUISetting("activity.borderSize", 1)
RegisterUISetting("activity.name.mediaFont", FontType("DejaVuSansCondensed Bold", 10))
RegisterUISetting("activity.name.textTransform", "NONE")
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [ActivityView] = {
    autoAdjustHeight                  = true, 
    registerForClicks                 = { "LeftButtonDown", "RightButtonDown" },
    backdrop                        = FromBackdrop(),
    showBackground                  = FromUISetting("activity.showBackground"),
    showBorder                      = FromUISetting("activity.showBorder"),
    backdropColor                   = FromUISetting("activity.backgroundColor"),
    backdropBorderColor             = FromUISetting("activity.borderColor"),
    borderSize                      = FromUISetting("activity.borderSize"),

    Name = {
      text                            = FromUIProperty("ActivityName"),
      justifyV                        = "MIDDLE",
      mediaFont                       = FromUISetting("activity.name.mediaFont"),
      textTransform                   = FromUISetting("activity.name.textTransform"),
      location                        = {
                                        Anchor("TOP", 0, -5),
                                        Anchor("LEFT"),
                                        Anchor("RIGHT")
                                      }
    },

    [ActivityView.Objectives] = {
      spacing                         = 5,
      location                        = {
                                        Anchor("TOPLEFT", 0, -5, "Name", "BOTTOMLEFT"),
                                        Anchor("TOPRIGHT", 0, -5, "Name", "BOTTOMRIGHT")
                                      }
    }
  },

  [ActivityListView] = {
    viewClass                         = ActivityView,
    indexed                           = false
  }
})