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

__Widget__()
class "SettingDefinitions.ContentOrder" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function BuildSettingControls(self)
    -- Auto Quests Order
    local autoQuestsOrderEditBox = Widgets.SettingsEditBox.Acquire(false, self)
    autoQuestsOrderEditBox:SetID(10)
    autoQuestsOrderEditBox:SetLabel(L.AUTO_QUESTS .. " " .. L.ORDER)
    autoQuestsOrderEditBox:BindSetting("autoQuestsOrder")
    self.SettingControls.autoQuestsOrderEditBox = autoQuestsOrderEditBox

    -- Widgets Order
    local widgetsOrderEditBox = Widgets.SettingsEditBox.Acquire(false, self)
    widgetsOrderEditBox:SetID(20)
    widgetsOrderEditBox:SetLabel(L.WIDGETS .. " " .. L.ORDER)
    widgetsOrderEditBox:BindSetting("widgetsOrder")
    self.SettingControls.widgetsOrderEditBox = widgetsOrderEditBox

    -- Scenario Order
    local scenarioOrderEditBox = Widgets.SettingsEditBox.Acquire(false, self)
    scenarioOrderEditBox:SetID(30)
    scenarioOrderEditBox:SetLabel(L.SCENARIO .. " " .. L.ORDER)
    scenarioOrderEditBox:BindSetting("scenarioOrder")
    self.SettingControls.scenarioOrderEditBox = scenarioOrderEditBox

    -- Delve Order
    local delveOrderEditBox = Widgets.SettingsEditBox.Acquire(false, self)
    delveOrderEditBox:SetID(40)
    delveOrderEditBox:SetLabel(L.DELVE .. " " .. L.ORDER)
    delveOrderEditBox:BindSetting("delveOrder")
    self.SettingControls.delveOrderEditBox = delveOrderEditBox

    -- Horrific Visions Order
    local horrificVisionsOrderEditBox = Widgets.SettingsEditBox.Acquire(false, self)
    horrificVisionsOrderEditBox:SetID(50)
    horrificVisionsOrderEditBox:SetLabel(L.HORRIFIC_VISIONS .. " " .. L.ORDER)
    horrificVisionsOrderEditBox:BindSetting("horrificVisionsOrder")
    self.SettingControls.horrificVisionsOrderEditBox = horrificVisionsOrderEditBox

    -- Dungeon Order
    local dungeonOrderEditBox = Widgets.SettingsEditBox.Acquire(false, self)
    dungeonOrderEditBox:SetID(60)
    dungeonOrderEditBox:SetLabel(L.DUNGEON .. " " .. L.ORDER)
    dungeonOrderEditBox:BindSetting("dungeonOrder")
    self.SettingControls.dungeonOrderEditBox = dungeonOrderEditBox

    -- Keystone Order
    local keystoneOrderEditBox = Widgets.SettingsEditBox.Acquire(false, self)
    keystoneOrderEditBox:SetID(70)
    keystoneOrderEditBox:SetLabel(L.KEYSTONE .. " " .. L.ORDER)
    keystoneOrderEditBox:BindSetting("keystoneOrder")
    self.SettingControls.keystoneOrderEditBox = keystoneOrderEditBox

    -- World Quests Order
    local worldQuestsOrderEditBox = Widgets.SettingsEditBox.Acquire(false, self)
    worldQuestsOrderEditBox:SetID(80)
    worldQuestsOrderEditBox:SetLabel(L.WORLD_QUESTS .. " " .. L.ORDER)
    worldQuestsOrderEditBox:BindSetting("worldQuestsOrder")
    self.SettingControls.worldQuestsOrderEditBox = worldQuestsOrderEditBox

    -- Tasks Order
    local tasksOrderEditBox = Widgets.SettingsEditBox.Acquire(false, self)
    tasksOrderEditBox:SetID(90)
    tasksOrderEditBox:SetLabel(L.TASKS .. " " .. L.ORDER)
    tasksOrderEditBox:BindSetting("tasksOrder")
    self.SettingControls.tasksOrderEditBox = tasksOrderEditBox

    -- Bonus Tasks Order
    local bonusTasksOrderEditBox = Widgets.SettingsEditBox.Acquire(false, self)
    bonusTasksOrderEditBox:SetID(100)
    bonusTasksOrderEditBox:SetLabel(L.BONUS_TASKS .. " " .. L.ORDER)
    bonusTasksOrderEditBox:BindSetting("bonusTasksOrder")
    self.SettingControls.bonusTasksOrderEditBox = bonusTasksOrderEditBox

    -- Achievements Order
    local achievementsOrderEditBox = Widgets.SettingsEditBox.Acquire(false, self)
    achievementsOrderEditBox:SetID(110)
    achievementsOrderEditBox:SetLabel(L.ACHIEVEMENTS .. " " .. L.ORDER)
    achievementsOrderEditBox:BindSetting("achievementsOrder")
    self.SettingControls.achievementsOrderEditBox = achievementsOrderEditBox

    -- Activities Order
    local activitiesOrderEditBox = Widgets.SettingsEditBox.Acquire(false, self)
    activitiesOrderEditBox:SetID(120)
    activitiesOrderEditBox:SetLabel(L.ACTIVITIES .. " " .. L.ORDER)
    activitiesOrderEditBox:BindSetting("activitiesOrder")
    self.SettingControls.activitiesOrderEditBox = activitiesOrderEditBox

    -- Profession Order
    local professionOrderEditBox = Widgets.SettingsEditBox.Acquire(false, self)
    professionOrderEditBox:SetID(130)
    professionOrderEditBox:SetLabel(L.PROFESSION .. " " .. L.ORDER)
    professionOrderEditBox:BindSetting("professionOrder")
    self.SettingControls.professionOrderEditBox = professionOrderEditBox

    -- Collections Order
    local collectionsOrderEditBox = Widgets.SettingsEditBox.Acquire(false, self)
    collectionsOrderEditBox:SetID(140)
    collectionsOrderEditBox:SetLabel(L.COLLECTIONS .. " " .. L.ORDER)
    collectionsOrderEditBox:BindSetting("collectionsOrder")
    self.SettingControls.collectionsOrderEditBox = collectionsOrderEditBox

    -- Campaign Quests Order
    local campaignQuestsOrderEditBox = Widgets.SettingsEditBox.Acquire(false, self)
    campaignQuestsOrderEditBox:SetID(150)
    campaignQuestsOrderEditBox:SetLabel(L.CAMPAIGN_QUESTS .. " " .. L.ORDER)
    campaignQuestsOrderEditBox:BindSetting("campaignQuestsOrder")
    self.SettingControls.campaignQuestsOrderEditBox = campaignQuestsOrderEditBox

    -- Quests Order
    local questsOrderEditBox = Widgets.SettingsEditBox.Acquire(false, self)
    questsOrderEditBox:SetID(160)
    questsOrderEditBox:SetLabel(L.QUESTS .. " " .. L.ORDER)
    questsOrderEditBox:BindSetting("questsOrder")
    self.SettingControls.questsOrderEditBox = questsOrderEditBox

    -- Pets Order
    local petsOrderEditBox = Widgets.SettingsEditBox.Acquire(false, self)
    petsOrderEditBox:SetID(170)
    petsOrderEditBox:SetLabel("Pets " .. L.ORDER)
    petsOrderEditBox:BindSetting("petsOrder")
    self.SettingControls.petsOrderEditBox = petsOrderEditBox

    -- Reset to Defaults Button
    local resetButton = Widgets.SettingsButton.Acquire(false, self)
    resetButton:SetID(180)
    resetButton:SetLabel(L.RESET .. " " .. L.CONTENT_ORDER)
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