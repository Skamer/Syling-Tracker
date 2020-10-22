-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                      "SylingTracker.Torghast"                        ""
-- ========================================================================= --
import                              "SLT"
-- ========================================================================= --
_Active                             = false
-- ========================================================================= --
local RegisterContentType           = API.RegisterContentType
local RegisterModel                 = API.RegisterModel
-- ========================================================================= --
local IsInJailersTower              = IsInJailersTower
local GetJailersTowerLevel          = GetJailersTowerLevel
-- ========================================================================= --
local _TorghastModel                = RegisterModel(Model, "torghast-data")
-- ========================================================================= --
RegisterContentType({
  ID = "torghast",
  DisplayName = "Torghast",
  Description = "TORGHAST_PH_DESCRIPTION",
  DefaultOrder = 4,
  DefaultModel = _TorghastModel,
  DefaultViewClass = TorghastContentView,
  Events = "PLAYER_ENTERING_WORLD",
  Status = function() return IsInJailersTower() end 
})
-- ========================================================================= --
local TORGHAST_WIDGET_ID = 2319

__ActiveOnEvents__ "PLAYER_ENTERING_WORLD"
function ActivateOn(self)
  return IsInJailersTower() 
end 
-- [[
  -- local data = {
  --   level = GetJailersTowerLevel(),
  --   remainingDeath 
  --   deathTooltip 
  --   fanstasm
  --   fanstasmTooltip
  -- }

--]]

__SystemEvent__()
function UPDATE_UI_WIDGET(widgetInfo)
  if widgetInfo.widgetID == TORGHAST_WIDGET_ID then 
    UpdateDeathAndFantasmCurrency(_M)
    _TorghastModel:Flush()
  end 
end

function UpdateDeathAndFantasmCurrency(self)
  local widget = C_UIWidgetManager.GetScenarioHeaderCurrenciesAndBackgroundWidgetVisualizationInfo(2319)
  if widget then
    local data = {} 
    -- The first currency is the remaining death 
    local deathCurrency = widget.currencies[1]
    data.remainingDeath = tonumber(deathCurrency.text)
    data.deathTooltip = deathCurrency.tooltip 

    -- The second currency is fantasm
    local fanstasmCurrency = widget.currencies[2]
    data.fanstasm = tonumber(fanstasmCurrency.text)
    data.fanstasmTooltip = fanstasmCurrency.tooltip 


    _TorghastModel:AddData(data, "torghast")
  end 
end


-- ========================================================================= --
-- Debug Utils Tools
-- ========================================================================= --
if ViragDevTool_AddData then 
  ViragDevTool_AddData(_TorghastModel, "SLT Torghast Model")
end