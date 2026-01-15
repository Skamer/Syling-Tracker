-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                 "SylingTracker.Contents.CollectableView"              ""
-- ========================================================================= --
export {
  FromUIProperty                      = Wow.FromUIProperty,
  FromBackdrop                        = Frame.FromBackdrop,
  ContextMenu_Show                    = API.ContextMenu_Show,
  RegisterUISetting                   = API.RegisterUISetting,
  FromUISetting                       = API.FromUISetting,
}

__UIElement__()
class "CollectableView" (function(_ENV)
  inherit "Button" extend "IView"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnClickHandler(self, mouseButton)
    local contextMenuPattern  = self.ContextMenuPattern
    local collectableID       = self.CollectableID
    local collectableType     = self.CollectableType

    if mouseButton == "RightButton" then
      if contextMenuPattern and collectableID and collectableType ~= nil then
        ContextMenu_Show(contextMenuPattern, self, collectableID, collectableType)
      end
    else 
      ContentTrackingUtil.OpenMapToTrackable(collectableType, collectableID)
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

    self.CollectableID    = data.collectableID
    self.CollectableName  = data.name
    self.CollectableType  = data.collectableType
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  __Observable__()
  property "CollectableName" {
    type = String,
    default = ""
  }

  property "CollectableID" {
    type = Number
  }

  property "CollectableType" {
    type = Number
  }

  property "ContextMenuPattern" {
    type = String,
    default = "collection"
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
__ChildProperty__(CollectableView, "Objectives")
class(tostring(CollectableView) .. ".Objectives") { ObjectiveListView }

__UIElement__()
class "CollectableListView" { ListView }
-------------------------------------------------------------------------------
--                              UI Settings                                  --
-------------------------------------------------------------------------------
RegisterUISetting("collectable.showBackground", true)
RegisterUISetting("collectable.showBorder", true)
RegisterUISetting("collectable.backgroundColor", Color(35/255, 40/255, 46/255, 0.73))
RegisterUISetting("collectable.borderColor", Color(0, 0, 0, 0.4))
RegisterUISetting("collectable.borderSize", 1)
RegisterUISetting("collectable.name.mediaFont", FontType("DejaVuSansCondensed Bold", 10))
RegisterUISetting("collectable.name.textTransform", "NONE")
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [CollectableView] = {
    autoAdjustHeight                  = true,
    registerForClicks                 = { "LeftButtonDown", "RightButtonDown" },
    backdrop                          = FromBackdrop(),
    showBackground                    = FromUISetting("collectable.showBackground"),
    showBorder                        = FromUISetting("collectable.showBorder"),
    backdropColor                     = FromUISetting("collectable.backgroundColor"),
    backdropBorderColor               = FromUISetting("collectable.borderColor"),
    borderSize                        = FromUISetting("collectable.borderSize"),
    
    Name = {
      text                            = FromUIProperty("CollectableName"),
      justifyV                        = "MIDDLE",
      mediaFont                       = FromUISetting("collectable.name.mediaFont"),
      textTransform                   = FromUISetting("collectable.name.textTransform"),
      location                        = {
                                        Anchor("TOP", 0, -5),
                                        Anchor("LEFT"),
                                        Anchor("RIGHT")
                                      }
    },

    [CollectableView.Objectives] = {
      spacing                         = 5,
      location                        = {
                                        Anchor("TOPLEFT", 0, -5, "Name", "BOTTOMLEFT"),
                                        Anchor("TOPRIGHT", 0, -5, "Name", "BOTTOMRIGHT")
                                      }
    }
  },

  [CollectableListView] = {
    viewClass                         = CollectableView,
    indexed                           = false
  }
})
