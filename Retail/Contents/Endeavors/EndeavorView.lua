-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                 "SylingTracker.Contents.EndeavorView"                 ""
-- ========================================================================= --
export {
  FromUIProperty                      = Wow.FromUIProperty,
  FromBackdrop                        = Frame.FromBackdrop,
  ContextMenu_Show                    = API.ContextMenu_Show,
  RegisterUISetting                   = API.RegisterUISetting,
  FromUISetting                       = API.FromUISetting,
}

__UIElement__()
class "EndeavorView" (function(_ENV)
  inherit "Button" extend "IView"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnClickHandler(self, mouseButton)
    local contextMenuPattern  = self.ContextMenuPattern
    local endeavorID          = self.EndeavorID

    if IsModifiedClick("CHATLINK") and ChatFrameUtil.GetActiveWindow() then
      local endeavorLink = C_NeighborhoodInitiative.GetInitiativeTaskChatLink(endeavorID)
      ChatFrameUtil.InsertLink(endeavorLink)
    elseif mouseButton ~= "RightButton" then
      if IsModifiedClick("QUESTWATCHTOGGLE") then
        C_NeighborhoodInitiative.RemoveTrackedInitiativeTask(endeavorID);
      else
        HousingFramesUtil.OpenFrameToTaskID(endeavorID);
      end

      PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    else
      if contextMenuPattern and endeavorID then
        ContextMenu_Show(contextMenuPattern, self, endeavorID)
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

    self.EndeavorID   = data.endeavorID
    self.EndeavorName = data.name
  end

  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  __Observable__()
  property "EndeavorName" {
    type = String,
    default = ""
  }

  property "EndeavorID" {
    type = Number
  }

  property "ContextMenuPattern" {
    type = String,
    default = "endeavor"
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

-- Optional Children 
__ChildProperty__(EndeavorView, "Objectives")
class(tostring(EndeavorView) .. ".Objectives") { ObjectiveListView }


__UIElement__()
class "EndeavorListView" { ListView }
-------------------------------------------------------------------------------
--                              UI Settings                                  --
-------------------------------------------------------------------------------
RegisterUISetting("endeavor.showBackground", true)
RegisterUISetting("endeavor.showBorder", true)
RegisterUISetting("endeavor.backgroundColor", Color(35/255, 40/255, 46/255, 0.73))
RegisterUISetting("endeavor.borderColor", Color(0, 0, 0, 0.4))
RegisterUISetting("endeavor.borderSize", 1)
RegisterUISetting("endeavor.name.mediaFont", FontType("DejaVuSansCondensed Bold", 10))
RegisterUISetting("endeavor.name.textTransform", "NONE")
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [EndeavorView] = {
    autoAdjustHeight                  = true, 
    registerForClicks                 = { "LeftButtonDown", "RightButtonDown" },
    backdrop                        = FromBackdrop(),
    showBackground                  = FromUISetting("endeavor.showBackground"),
    showBorder                      = FromUISetting("endeavor.showBorder"),
    backdropColor                   = FromUISetting("endeavor.backgroundColor"),
    backdropBorderColor             = FromUISetting("endeavor.borderColor"),
    borderSize                      = FromUISetting("endeavor.borderSize"),

    Name = {
      text                            = FromUIProperty("EndeavorName"),
      justifyV                        = "MIDDLE",
      mediaFont                       = FromUISetting("endeavor.name.mediaFont"),
      textTransform                   = FromUISetting("endeavor.name.textTransform"),
      location                        = {
                                        Anchor("TOP", 0, -5),
                                        Anchor("LEFT"),
                                        Anchor("RIGHT")
                                      }
    },

    [EndeavorView.Objectives] = {
      spacing                         = 5,
      location                        = {
                                        Anchor("TOPLEFT", 0, -5, "Name", "BOTTOMLEFT"),
                                        Anchor("TOPRIGHT", 0, -5, "Name", "BOTTOMRIGHT")
                                      }
    }
  },

  [EndeavorListView] = {
    viewClass                         = EndeavorView,
    indexed                           = false
  }
})