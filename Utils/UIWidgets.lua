-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                  "SylingTracker.Utils.UIWidgets"                      ""
-- ========================================================================= --
export {
  GetAllWidgetsBySetID                = C_UIWidgetManager.GetAllWidgetsBySetID
}

OBJECTIVE_TRACKER_WIDGET_SET_ID = C_UIWidgetManager.GetObjectiveTrackerWidgetSetID()

function HasObjectiveWidgets()
  local widgets = GetAllWidgetsBySetID(OBJECTIVE_TRACKER_WIDGET_SET_ID)
  for _, widgetInfo in pairs(widgets) do 
    local widgetTypeInfo = UIWidgetManager:GetWidgetTypeInfo(widgetInfo.widgetType)
    if widgetTypeInfo and widgetTypeInfo.visInfoDataFunction(widgetInfo.widgetID) then 
      return true 
    end
  end

  return false
end

-- Export as utils functions 
Utils.HasObjectiveWidgets = HasObjectiveWidgets