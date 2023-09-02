-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                     "SylingTracker.Tasks"                             ""
-- ========================================================================= --
_Active                             = false
-- ========================================================================= --
export {
  -- Addon API
  RegisterObservableContent           = API.RegisterObservableContent,

  HasTasks                            = Utils.HasTasks
}

TASKS_CONTENT_SUBJECT = RegisterObservableContent("tasks", TasksContentSubject)

-- ========================================================================= --
-- Debug Utils Tools
-- ========================================================================= --
DebugTools.TrackData(TASKS_CONTENT_SUBJECT, "Tasks Content Subject")