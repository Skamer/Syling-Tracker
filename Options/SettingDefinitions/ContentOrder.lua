-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling          "SylingTracker_Options.SettingDefinitions.ContentOrder"     ""
-- ========================================================================= --
export {
  L         = _Locale,
  newtable  = Toolset.newtable,
  SetSetting = SylingTracker.API.SetSetting
}

-- Content order slider configuration
local CONTENT_ORDER_MIN = 5
local CONTENT_ORDER_MAX = 200
local CONTENT_ORDER_STEP = 5

__Widget__()
class "SettingDefinitions.ContentOrder" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function BuildSettingControls(self)
    -- Auto Quests Order
    local autoQuestsOrderSlider = Widgets.SettingsSlider.Acquire(false, self)
    autoQuestsOrderSlider:SetID(10)
    autoQuestsOrderSlider:SetLabel(L.AUTO_QUESTS .. " " .. L.ORDER)
    autoQuestsOrderSlider:SetMinMaxValues(CONTENT_ORDER_MIN, CONTENT_ORDER_MAX)
    autoQuestsOrderSlider:SetValueStep(CONTENT_ORDER_STEP)
    autoQuestsOrderSlider:BindSetting("autoQuestsOrder")
    self.SettingControls.autoQuestsOrderSlider = autoQuestsOrderSlider

    -- Widgets Order
    local widgetsOrderSlider = Widgets.SettingsSlider.Acquire(false, self)
    widgetsOrderSlider:SetID(20)
    widgetsOrderSlider:SetLabel(L.WIDGETS .. " " .. L.ORDER)
    widgetsOrderSlider:SetMinMaxValues(CONTENT_ORDER_MIN, CONTENT_ORDER_MAX)
    widgetsOrderSlider:SetValueStep(CONTENT_ORDER_STEP)
    widgetsOrderSlider:BindSetting("widgetsOrder")
    self.SettingControls.widgetsOrderSlider = widgetsOrderSlider

    -- Scenario Order
    local scenarioOrderSlider = Widgets.SettingsSlider.Acquire(false, self)
    scenarioOrderSlider:SetID(30)
    scenarioOrderSlider:SetLabel(L.SCENARIO .. " " .. L.ORDER)
    scenarioOrderSlider:SetMinMaxValues(CONTENT_ORDER_MIN, CONTENT_ORDER_MAX)
    scenarioOrderSlider:SetValueStep(CONTENT_ORDER_STEP)
    scenarioOrderSlider:BindSetting("scenarioOrder")
    self.SettingControls.scenarioOrderSlider = scenarioOrderSlider

    -- Delve Order
    local delveOrderSlider = Widgets.SettingsSlider.Acquire(false, self)
    delveOrderSlider:SetID(40)
    delveOrderSlider:SetLabel(L.DELVE .. " " .. L.ORDER)
    delveOrderSlider:SetMinMaxValues(CONTENT_ORDER_MIN, CONTENT_ORDER_MAX)
    delveOrderSlider:SetValueStep(CONTENT_ORDER_STEP)
    delveOrderSlider:BindSetting("delveOrder")
    self.SettingControls.delveOrderSlider = delveOrderSlider

    -- Horrific Visions Order
    local horrificVisionsOrderSlider = Widgets.SettingsSlider.Acquire(false, self)
    horrificVisionsOrderSlider:SetID(50)
    horrificVisionsOrderSlider:SetLabel(L.HORRIFIC_VISIONS .. " " .. L.ORDER)
    horrificVisionsOrderSlider:SetMinMaxValues(CONTENT_ORDER_MIN, CONTENT_ORDER_MAX)
    horrificVisionsOrderSlider:SetValueStep(CONTENT_ORDER_STEP)
    horrificVisionsOrderSlider:BindSetting("horrificVisionsOrder")
    self.SettingControls.horrificVisionsOrderSlider = horrificVisionsOrderSlider

    -- Dungeon Order
    local dungeonOrderSlider = Widgets.SettingsSlider.Acquire(false, self)
    dungeonOrderSlider:SetID(60)
    dungeonOrderSlider:SetLabel(L.DUNGEON .. " " .. L.ORDER)
    dungeonOrderSlider:SetMinMaxValues(CONTENT_ORDER_MIN, CONTENT_ORDER_MAX)
    dungeonOrderSlider:SetValueStep(CONTENT_ORDER_STEP)
    dungeonOrderSlider:BindSetting("dungeonOrder")
    self.SettingControls.dungeonOrderSlider = dungeonOrderSlider

    -- Keystone Order
    local keystoneOrderSlider = Widgets.SettingsSlider.Acquire(false, self)
    keystoneOrderSlider:SetID(70)
    keystoneOrderSlider:SetLabel(L.KEYSTONE .. " " .. L.ORDER)
    keystoneOrderSlider:SetMinMaxValues(CONTENT_ORDER_MIN, CONTENT_ORDER_MAX)
    keystoneOrderSlider:SetValueStep(CONTENT_ORDER_STEP)
    keystoneOrderSlider:BindSetting("keystoneOrder")
    self.SettingControls.keystoneOrderSlider = keystoneOrderSlider

    -- World Quests Order
    local worldQuestsOrderSlider = Widgets.SettingsSlider.Acquire(false, self)
    worldQuestsOrderSlider:SetID(80)
    worldQuestsOrderSlider:SetLabel(L.WORLD_QUESTS .. " " .. L.ORDER)
    worldQuestsOrderSlider:SetMinMaxValues(CONTENT_ORDER_MIN, CONTENT_ORDER_MAX)
    worldQuestsOrderSlider:SetValueStep(CONTENT_ORDER_STEP)
    worldQuestsOrderSlider:BindSetting("worldQuestsOrder")
    self.SettingControls.worldQuestsOrderSlider = worldQuestsOrderSlider

    -- Tasks Order
    local tasksOrderSlider = Widgets.SettingsSlider.Acquire(false, self)
    tasksOrderSlider:SetID(90)
    tasksOrderSlider:SetLabel(L.TASKS .. " " .. L.ORDER)
    tasksOrderSlider:SetMinMaxValues(CONTENT_ORDER_MIN, CONTENT_ORDER_MAX)
    tasksOrderSlider:SetValueStep(CONTENT_ORDER_STEP)
    tasksOrderSlider:BindSetting("tasksOrder")
    self.SettingControls.tasksOrderSlider = tasksOrderSlider

    -- Bonus Tasks Order
    local bonusTasksOrderSlider = Widgets.SettingsSlider.Acquire(false, self)
    bonusTasksOrderSlider:SetID(100)
    bonusTasksOrderSlider:SetLabel(L.BONUS_TASKS .. " " .. L.ORDER)
    bonusTasksOrderSlider:SetMinMaxValues(CONTENT_ORDER_MIN, CONTENT_ORDER_MAX)
    bonusTasksOrderSlider:SetValueStep(CONTENT_ORDER_STEP)
    bonusTasksOrderSlider:BindSetting("bonusTasksOrder")
    self.SettingControls.bonusTasksOrderSlider = bonusTasksOrderSlider

    -- Achievements Order
    local achievementsOrderSlider = Widgets.SettingsSlider.Acquire(false, self)
    achievementsOrderSlider:SetID(110)
    achievementsOrderSlider:SetLabel(L.ACHIEVEMENTS .. " " .. L.ORDER)
    achievementsOrderSlider:SetMinMaxValues(CONTENT_ORDER_MIN, CONTENT_ORDER_MAX)
    achievementsOrderSlider:SetValueStep(CONTENT_ORDER_STEP)
    achievementsOrderSlider:BindSetting("achievementsOrder")
    self.SettingControls.achievementsOrderSlider = achievementsOrderSlider

    -- Activities Order
    local activitiesOrderSlider = Widgets.SettingsSlider.Acquire(false, self)
    activitiesOrderSlider:SetID(120)
    activitiesOrderSlider:SetLabel(L.ACTIVITIES .. " " .. L.ORDER)
    activitiesOrderSlider:SetMinMaxValues(CONTENT_ORDER_MIN, CONTENT_ORDER_MAX)
    activitiesOrderSlider:SetValueStep(CONTENT_ORDER_STEP)
    activitiesOrderSlider:BindSetting("activitiesOrder")
    self.SettingControls.activitiesOrderSlider = activitiesOrderSlider

    -- Profession Order
    local professionOrderSlider = Widgets.SettingsSlider.Acquire(false, self)
    professionOrderSlider:SetID(130)
    professionOrderSlider:SetLabel(L.PROFESSION .. " " .. L.ORDER)
    professionOrderSlider:SetMinMaxValues(CONTENT_ORDER_MIN, CONTENT_ORDER_MAX)
    professionOrderSlider:SetValueStep(CONTENT_ORDER_STEP)
    professionOrderSlider:BindSetting("professionOrder")
    self.SettingControls.professionOrderSlider = professionOrderSlider

    -- Collections Order
    local collectionsOrderSlider = Widgets.SettingsSlider.Acquire(false, self)
    collectionsOrderSlider:SetID(140)
    collectionsOrderSlider:SetLabel(L.COLLECTIONS .. " " .. L.ORDER)
    collectionsOrderSlider:SetMinMaxValues(CONTENT_ORDER_MIN, CONTENT_ORDER_MAX)
    collectionsOrderSlider:SetValueStep(CONTENT_ORDER_STEP)
    collectionsOrderSlider:BindSetting("collectionsOrder")
    self.SettingControls.collectionsOrderSlider = collectionsOrderSlider

    -- Campaign Quests Order
    local campaignQuestsOrderSlider = Widgets.SettingsSlider.Acquire(false, self)
    campaignQuestsOrderSlider:SetID(150)
    campaignQuestsOrderSlider:SetLabel(L.CAMPAIGN_QUESTS .. " " .. L.ORDER)
    campaignQuestsOrderSlider:SetMinMaxValues(CONTENT_ORDER_MIN, CONTENT_ORDER_MAX)
    campaignQuestsOrderSlider:SetValueStep(CONTENT_ORDER_STEP)
    campaignQuestsOrderSlider:BindSetting("campaignQuestsOrder")
    self.SettingControls.campaignQuestsOrderSlider = campaignQuestsOrderSlider

    -- Quests Order
    local questsOrderSlider = Widgets.SettingsSlider.Acquire(false, self)
    questsOrderSlider:SetID(160)
    questsOrderSlider:SetLabel(L.QUESTS .. " " .. L.ORDER)
    questsOrderSlider:SetMinMaxValues(CONTENT_ORDER_MIN, CONTENT_ORDER_MAX)
    questsOrderSlider:SetValueStep(CONTENT_ORDER_STEP)
    questsOrderSlider:BindSetting("questsOrder")
    self.SettingControls.questsOrderSlider = questsOrderSlider

    -- Pets Order
    local petsOrderSlider = Widgets.SettingsSlider.Acquire(false, self)
    petsOrderSlider:SetID(170)
    petsOrderSlider:SetLabel("Pets " .. L.ORDER)
    petsOrderSlider:SetMinMaxValues(CONTENT_ORDER_MIN, CONTENT_ORDER_MAX)
    petsOrderSlider:SetValueStep(CONTENT_ORDER_STEP)
    petsOrderSlider:BindSetting("petsOrder")
    self.SettingControls.petsOrderSlider = petsOrderSlider

    -- Reset to Defaults Button
    local resetButton = Widgets.PushButton.Acquire(false, self)
    resetButton:SetID(180)
    resetButton:SetText(L.RESET .. " " .. L.CONTENT_ORDER)
    resetButton:SetScript("OnClick", function()
      self:ResetToDefaults()
    end)
    self.SettingControls.resetButton = resetButton
  end

  function ResetToDefaults(self)
    -- Reset all content order settings to their defaults
    SetSetting("autoQuestsOrder", nil)
    SetSetting("widgetsOrder", nil)
    SetSetting("scenarioOrder", nil)
    SetSetting("delveOrder", nil)
    SetSetting("horrificVisionsOrder", nil)
    SetSetting("dungeonOrder", nil)
    SetSetting("keystoneOrder", nil)
    SetSetting("worldQuestsOrder", nil)
    SetSetting("tasksOrder", nil)
    SetSetting("bonusTasksOrder", nil)
    SetSetting("achievementsOrder", nil)
    SetSetting("activitiesOrder", nil)
    SetSetting("professionOrder", nil)
    SetSetting("collectionsOrder", nil)
    SetSetting("campaignQuestsOrder", nil)
    SetSetting("questsOrder", nil)
    SetSetting("petsOrder", nil)
    
    -- Refresh the UI controls to show default values
    self:ReleaseSettingControls()
    self:BuildSettingControls()
  end

  function ReleaseSettingControls(self)
    for index, control in pairs(self.SettingControls) do 
      control:Release()
      self.SettingControls[index] = nil
    end
  end

  function OnBuildSettings(self)
    self:BuildSettingControls()
  end

  function OnRelease(self)
    self:SetID(0)
    self:SetParent()
    self:ClearAllPoints()
    self:Hide()

    self:ReleaseSettingControls()
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "SettingControls" {
    set = false,
    default = function() return newtable(false, true) end 
  }
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [SettingDefinitions.ContentOrder] = {
    layoutManager = Layout.VerticalLayoutManager(true, true)
  }
})