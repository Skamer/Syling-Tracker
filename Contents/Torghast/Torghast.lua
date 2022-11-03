-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                      "SylingTracker.Torghast"                         ""
-- ========================================================================= --
import                              "SLT"
-- ========================================================================= --
_Active                             = false
-- ========================================================================= --
export {
  RegisterContentType               = API.RegisterContentType,
  RegisterModel                     = API.RegisterModel,

  CreateAtlasMarkup                 = CreateAtlasMarkup,
  IsInJailersTower                  = IsInJailersTower,
  GetJailersTowerLevel              = GetJailersTowerLevel,
  GetAnimaPowerRarity               = Utils.Torghast.GetAnimaPowerRarity,
  GetStepInfo                       = C_Scenario.GetStepInfo,
  GetScenarioWidgetInfo             = C_UIWidgetManager.GetScenarioHeaderCurrenciesAndBackgroundWidgetVisualizationInfo,
  GetStatusBarWidgetInfo            = C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo,
  UnitAura                          = UnitAura
}
-- ========================================================================= --
local _TorghastModel                = RegisterModel(Model, "torghast-data")
-- ========================================================================= --
_TorghastIconMarkupAtlas = CreateAtlasMarkup("poi-torghast", 16, 16)
RegisterContentType({
  ID = "torghast",
  Name = "Torghast",
  DisplayName = _TorghastIconMarkupAtlas.." Torghast",
  Description = "TORGHAST_PH_DESCRIPTION",
  DefaultOrder = 40,
  DefaultModel = _TorghastModel,
  DefaultViewClass = TorghastContentView,
  Events = "PLAYER_ENTERING_WORLD",
  Status = function() return IsInJailersTower() end 
})
-- ========================================================================= --
local TORGHAST_WIDGET_ID            = 2319
local TORGHAST_TARRAGRUE_WIDGET_ID  = 2321
local MAX_BUFF_MAX_DISPLAY          = 44
-- ========================================================================= --
__ActiveOnEvents__ "PLAYER_ENTERING_WORLD"
function BecomeActiveOn(self)
  return IsInJailersTower() 
end 
-- ========================================================================= --
function OnActive(self)
  self:UpdateDeathAndFantasmCurrency()
  self:UpdateAnimaPowers()
  self:UpdateLevel()
  self:UpdateObjectives()

  _TorghastModel:Flush()
end

function OnInactive(self)
  _TorghastModel:ClearData()
end
-- ========================================================================= --
__SystemEvent__()
function UPDATE_UI_WIDGET(widgetInfo)
  if widgetInfo.widgetID == TORGHAST_WIDGET_ID then 
    _M:UpdateDeathAndFantasmCurrency()
    _TorghastModel:Flush()
  elseif widgetInfo.widgetID == TORGHAST_TARRAGRUE_WIDGET_ID then 
    _M:UpdateTarragrueTimer()
    _TorghastModel:Flush()
  end 
end

__SystemEvent__()
function SCENARIO_UPDATE(isNewStage)
  if isNewStage then 
    _M:UpdateObjectives()
    _TorghastModel:Flush()
  end 
end

__SystemEvent__()
function JAILERS_TOWER_LEVEL_UPDATE(level, type)
  _TorghastModel:AddData({ level = level }, "torghast")
  _TorghastModel:Flush()
end

__SystemEvent__()
function UNIT_AURA(unit)
  if unit == "player" then 
    _M:UpdateAnimaPowers()
    _TorghastModel:Flush()
  end
end 
-- ========================================================================= --
function UpdateObjectives(self)
    local stageName, stageDescription, numObjectives = GetStepInfo()
    _TorghastModel:AddData({ stageName = stageName, stageDescription = stageDescription}, "torghast")
end

--- The death and the fantasm currency are provided by the Widget System and represented by
--- a ScenarioHeaderCurrenciesAndBackgroundWidgetVisualizationInfo
--- /dump C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo(2319)
--- in Torghast for more information
function UpdateDeathAndFantasmCurrency(self)
  -- local widget = GetWidgetVisualizationInfo(TORGHAST_WIDGET_ID)
  -- GetScenarioHeaderCurrenciesAndBackgroundWidgetVisualizationInfo
  local info = GetScenarioWidgetInfo(TORGHAST_WIDGET_ID)

  if info then
    local data = {} 
    -- The first currency is the remaining death 
    local deathCurrency = info.currencies[1]
    data.remainingDeath = tonumber(deathCurrency.text)
    data.deathTooltip = deathCurrency.tooltip 

    -- The second currency is fantasm
    local fanstasmCurrency = info.currencies[2]
    data.fanstasm = tonumber(fanstasmCurrency.text)
    data.fanstasmTooltip = fanstasmCurrency.tooltip 

    -- The level text (is 100% correct)
    local levelText = info.headerText
    data.levelText = levelText

    _TorghastModel:AddData(data, "torghast")
  end 
end

--- The timer information is provided by the Widget system and represented by
--- a GetStatusBarWidgetVisualizationInfo
--- /dump C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo(2321)
--- in Torghast for more information
function UpdateTarragrueTimer(self)
  -- local info = C_UIWidgetManager.GetStatusBarWidgetVisualizationInfo(TORGHAST_TARRAGRUE_WIDGET_ID)
  local info = GetStatusBarWidgetInfo(TORGHAST_TARRAGRUE_WIDGET_ID)
  local shownState = info.shownState 
  
  -- If the widget is shown, update the data
  if shownState == 1 then
    local data = {} 
    data.barMin    = info.barMin
    data.barValue  = info.barValue
    data.barMax    = info.barMax

    -- text = "Tarragrue arrives in:"
    data.text = info.text
    -- tooltip = "Get to the exist quickly!"
    data.tooltip = info.tooltip

    -- overrideBarText = "Hurry"
    -- This shows "Hurry" when the player has mouseover on the bar. 
    data.overrideBarText = info.overrideBarText

    _TorghastModel:AddData(data, "torghast", "tarragrue")
  else 
    _TorghastModel:RemoveData("torghast", "tarragrue")
  end 
end

function UpdateAnimaPowers(self)
  local data = {}
  local animaPowersData = {}
  local numAnimaPowers = 0
  for i = 1, MAX_BUFF_MAX_DISPLAY do 
    local _, icon, count, _, _, _, _, _, _, spellID = UnitAura("player", i, "MAW"); 
    if icon then
      if count == 0 then 
        count = 1
      end

      local rarity = GetAnimaPowerRarity(spellID)
      animaPowersData[spellID] = { icon = icon, spellID = spellID, count = count, rarity = rarity, slot = i }

      numAnimaPowers = numAnimaPowers + count
    end 
  end

  data.numAnimaPowers = numAnimaPowers
  data.animaPowers = animaPowersData
  
  _TorghastModel:AddData(data, "torghast")
end

function UpdateLevel(self)
  _TorghastModel:AddData({ level = GetJailersTowerLevel() }, "torghast")
end
-- ========================================================================= --
-- Debug Utils Tools
-- ========================================================================= --
if ViragDevTool_AddData then 
  ViragDevTool_AddData(_TorghastModel, "SLT Torghast Model")
end