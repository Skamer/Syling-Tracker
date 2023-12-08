-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling             "SylingTracker.Contents.TasksContentView"                 ""
-- ========================================================================= --
export {
  RegisterUISetting                   = API.RegisterUISetting,
  FromUISetting                       = API.FromUISetting,
  GenerateUISettings                  = API.GenerateUISettings,
}

__UIElement__()
class "TasksContentView"(function(_ENV)
  inherit "ContentView"
  -----------------------------------------------------------------------------
  --                                Methods                                  --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data, metadata)
    super.OnViewUpdate(self, data, metadata)

    if data and data.quests then
      Style[self].Tasks.visible = self.Expanded
      local taskListView = self:GetPropertyChild("Tasks")
      taskListView:UpdateView(data.quests, metadata) 
    else
      Style[self].Tasks = NIL
    end
  end


  function OnExpand(self)
    if self:GetPropertyChild("Tasks") then
      Style[self].Tasks.visible = true 
    end
  end

  function OnCollapse(self)
    if self:GetPropertyChild("Tasks") then 
      Style[self].Tasks.visible = false 
    end
  end
end)

__ChildProperty__(TasksContentView, "Tasks")
__UIElement__() class(tostring(TasksContentView) .. ".Tasks") { TaskListView }
-------------------------------------------------------------------------------
--                              UI Settings                                  --
-------------------------------------------------------------------------------
GenerateUISettings("tasks", "content")
-------------------------------------------------------------------------------
--                              Observables                                  --
-------------------------------------------------------------------------------
function FromTasksLocation()
  return FromUISetting("tasks.showHeader"):Map(function(visible)
    if visible then 
      return {
        Anchor("TOP", 0, -10, "Header", "BOTTOM"),
        Anchor("LEFT"),
        Anchor("RIGHT")        
      }
    end

    return {
        Anchor("TOP"),
        Anchor("LEFT"),
        Anchor("RIGHT")
    }
  end)
end
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [TasksContentView] = {
    Header = {
      visible                         = FromUISetting("tasks.showHeader"),
      showBackground                  = FromUISetting("tasks.header.showBackground"),
      showBorder                      = FromUISetting("tasks.header.showBorder"),
      backdropColor                   = FromUISetting("tasks.header.backgroundColor"),
      backdropBorderColor             = FromUISetting("tasks.header.borderColor"),
      borderSize                      = FromUISetting("tasks.header.borderSize"),

      Label = {
        mediaFont                     = FromUISetting("tasks.header.label.mediaFont"),
        textColor                     = FromUISetting("tasks.header.label.textColor"),
        justifyH                      = FromUISetting("tasks.header.label.justifyH"),
        justifyV                      = FromUISetting("tasks.header.label.justifyV"),
        textTransform                 = FromUISetting("tasks.header.label.textTransform"),
      }
    },

    [TasksContentView.Tasks] = {
      location = FromTasksLocation()
    }
  }
})