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

__UIElement__()
class "TaskListView" { ListView }
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
    showBackground                    = true,
    showBorder                        = true,
    backdropColor                     =  Color(35/255, 40/255, 46/255, 0.73),
    backdropBorderColor               = Color(0, 0, 0, 0.4),
    borderSize                        = 1,

    Header = {
      height                          = 24,

      Name = {
        text                          = FromUIProperty("TaskName"),
        justifyV                      = "MIDDLE",
        mediaFont                     = FontType("DejaVuSansCondensed Bold", 10),
        textColor                     =  { r = 1, g = 106/255, b = 0 },
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
      location                        = {
                                        Anchor("TOPLEFT", 0, -5, "Header", "BOTTOMLEFT"),
                                        Anchor("TOPRIGHT", 0, -5, "Header", "BOTTOMRIGHT")
                                      }
    }
  },

  [TaskListView] = {
    viewClass                         = TaskView,
    indexed                           = false
  }
})


