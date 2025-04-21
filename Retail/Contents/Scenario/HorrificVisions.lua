-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                 "SylingTracker.Contents.HorrificVisions"              ""
-- ========================================================================= --
_Active                             = false
-- ========================================================================= --
export {
  -- Addon API 
  RegisterObservableContent  = API.RegisterObservableContent,

  -- WoW API & Utils
  IsInHorrificVisions = Utils.IsInHorrificVisions
}

__DataProperties__ {
  { name = "mementos", type = Number },
}
class "HorrificVisionsContentSubject" { ContentSubject }

local HORRIFIC_VISION_DATA = RegisterObservableContent("horrificVisions", HorrificVisionsContentSubject)

local MEMENTOS_CURRENCY_ID = 1744
local HORRIFIC_VISION_WIDGET_ID = 6977

__ActiveOnEvents__ "PLAYER_ENTERING_WORLD" "SCENARIO_POI_UPDATE" "SCENARIO_UPDATE"
function BecomeActiveOn(self, event)
  return IsInHorrificVisions()
end

function OnActive(self)
  HORRIFIC_VISION_DATA.mementos = self:GetMementoCurrencyAmount()
end

function GetMementoCurrencyAmount(self)
  local info = C_UIWidgetManager.GetScenarioHeaderCurrenciesAndBackgroundWidgetVisualizationInfo(HORRIFIC_VISION_WIDGET_ID)
  local amount = 0

  if info and info.currencies then 
    amount = tonumber(info.currencies[1].text)
  end

  return amount
end

__SystemEvent__()
function CURRENCY_DISPLAY_UPDATE(currencyID, total, gained)
  if currencyID == MEMENTOS_CURRENCY_ID then 
    HORRIFIC_VISION_DATA.mementos = total 
  end 
end
-- ========================================================================= --
-- Debug Utils Tools
-- ========================================================================= --
DebugTools.TrackData(HORRIFIC_VISION_DATA, "Horific Visions Content Subject")

