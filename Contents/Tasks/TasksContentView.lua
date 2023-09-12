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
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [TasksContentView] = {
    [TasksContentView.Tasks] = {
      location = {
        Anchor("TOP", 0, -10, "Header", "BOTTOM"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      }
    }
  }
})
