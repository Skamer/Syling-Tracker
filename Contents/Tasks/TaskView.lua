-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling               "SylingTracker.Contents.TaskView"                       ""
-- ========================================================================= --
export {
  FromUIProperty            = Wow.FromUIProperty,
  FromBackdrop              = Frame.FromBackdrop,
  ContextMenu_Show          = API.ContextMenu_Show,
  RegisterUISetting         = API.RegisterUISetting,
  FromUISetting             = API.FromUISetting,
}

__UIElement__()
class "TaskView" (function(_ENV)
  inherit "Button" extend "IView"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnClickHandler(self, mouseButton)
    local questID             = self.QuestID
    local contextMenuPattern  = self.ContextMenuPattern

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
      local objectivesView = self:GetPropertyChild("Objectives")

      objectivesView:UpdateView(data.objectives, ...)
    end

    self.TaskName = data.name
    self.QuestID = data.questID

    if data.item then 
      Style[self].Item.visible = true 
      local itemIcon = self:GetPropertyChild("Item")
      itemIcon.ItemTexture = data.item.texture 
      itemIcon.ItemLink = data.item.link
      itemIcon.id = data.questID

      self.HasItem = true 
    else 
      Style[self].Item = NIL
      self.HasItem = false
    end
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  __Observable__()
  property "TaskName" {
    type = String,
    default = ""
  }

  property "QuestID" {
    type = Number
  }

  __Observable__()
  property "HasItem" {
    type = Boolean,
    default = false 
  }

  property "ContextMenuPattern" {
    type = String,
    default = "quest"
  }
  -----------------------------------------------------------------------------
  --                              Constructors                               --
  -----------------------------------------------------------------------------
  __Template__ {
    Header = Frame, 
    {
      Header = {
        Name    = FontString, 
      }
    }
  }
  function __ctor(self) 
    self.OnClick = self.OnClick + OnClickHandler
  end
end)

-- Optional Children for QuestView 
__ChildProperty__(TaskView, "Objectives")
class(tostring(TaskView) .. ".Objectives") { ObjectiveListView }

__ChildProperty__(TaskView, "Item")
class(tostring(TaskView) .. ".Item") { SylingTracker.QuestItemIcon }

__UIElement__()
class "TaskListView" { ListView }
-------------------------------------------------------------------------------
--                              UI Settings                                  --
-------------------------------------------------------------------------------
RegisterUISetting("task.showBackground", true)
RegisterUISetting("task.showBorder", true)
RegisterUISetting("task.backgroundColor", Color(35/255, 40/255, 46/255, 0.73))
RegisterUISetting("task.borderColor", Color(0, 0, 0, 0.4))
RegisterUISetting("task.borderSize", 1)
RegisterUISetting("task.name.mediaFont", FontType("DejaVuSansCondensed Bold", 10))
RegisterUISetting("task.name.textTransform", "NONE")
RegisterUISetting("task.name.textColor", Color(1, 106/255, 0))
-------------------------------------------------------------------------------
--                              Observables                                  --
-------------------------------------------------------------------------------
function FromObjectivesLocation()
  return FromUIProperty("HasItem"):Map(function(hasItem)
    return {
      Anchor("TOP", 0, -5, "Header", "BOTTOM"),
      Anchor("LEFT"),
      Anchor("RIGHT", hasItem and -29 or 0, 0)
    }
  end)
end
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [TaskView] = {
    height                            = 24,
    minResize                         = { width = 0, height = 24},
    autoAdjustHeight                  = true,
    registerForClicks                 = { "LeftButtonDown", "RightButtonDown" },
    backdrop                          = FromBackdrop(),
    showBackground                    = FromUISetting("task.showBackground"),
    showBorder                        = FromUISetting("task.showBorder"),
    backdropColor                     = FromUISetting("task.backgroundColor"),
    backdropBorderColor               = FromUISetting("task.borderColor"),
    borderSize                        = FromUISetting("task.borderSize"),
    
    Header = {
      height                          = 24,

      Name = {
        text                          = FromUIProperty("TaskName"),
        justifyV                      = "MIDDLE",
        mediaFont                     = FromUISetting("task.name.mediaFont"),
        textTransform                 = FromUISetting("task.name.textTransform"),
        textColor                     = FromUISetting("task.name.textColor"),
        location                      = {
                                        Anchor("TOP"),
                                        Anchor("LEFT"),
                                        Anchor("RIGHT"),
                                        Anchor("BOTTOM")
                                      }
      },

      location                        = { Anchor("TOPLEFT"), Anchor("TOPRIGHT") }
    },

    [TaskView.Objectives] = {
      spacing                         = 5,
      location                        = FromObjectivesLocation(),
    },

    [TaskView.Item] = {
      location                        = {
                                        Anchor("TOPLEFT", 0, 0, "Objectives", "BOTTOMLEFT"),
                                        Anchor("TOPRIGHT", 0, 0, "Objectives", "BOTTOMRIGHT"),
                                      }
    }
  },

  [TaskListView] = {
    viewClass                         = TaskView,
    indexed                           = false
  }
})


