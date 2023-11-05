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
}

__UIElement__()
class "TaskView" (function(_ENV)
  inherit "Frame" extend "IView"
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
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  __Observable__()
  property "TaskName" {
    type = String,
    default = ""
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
  function __ctor(self) end
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
    height = 24,
    minResize = { width = 0, height = 24},
    autoAdjustHeight = true, 

    backdrop = { 
      bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
    },
    backdropColor = { r = 35/255, g = 40/255, b = 46/255, a = 0.73},

    Header = {
      height = 24,

      Name = {
        text = FromUIProperty("TaskName"),
        justifyV = "MIDDLE",
        mediaFont = FontType("DejaVuSansCondensed Bold", 10),
        textColor = { r = 1, g = 106/255, b = 0 },
        location = {
          Anchor("TOP"),
          Anchor("LEFT"),
          Anchor("RIGHT"),
          Anchor("BOTTOM")
        }
      },

      location = {
        Anchor("TOPLEFT"),
        Anchor("TOPRIGHT")
      }
    },

    [TaskView.Objectives] = {
      spacing = 5,

      location = {
        Anchor("TOPLEFT", 0, -5, "Header", "BOTTOMLEFT"),
        Anchor("TOPRIGHT", 0, -5, "Header", "BOTTOMRIGHT")
      }
    }
  },

  [TaskListView] = {
    viewClass = TaskView,
    indexed = false
  }
})


