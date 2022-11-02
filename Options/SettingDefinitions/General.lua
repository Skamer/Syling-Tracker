-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling          "SylingTracker.Options.SettingDefinitions.General"           ""
-- ========================================================================= --
__Widget__()
class "SLT.SettingDefinitions.General" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function BuildSettingControls(self)
    local showMinimapIconCheckBox = SUI.SettingsCheckBox.Acquire(false, self)
    showMinimapIconCheckBox:SetID(10)
    showMinimapIconCheckBox:SetLabel("Show Minimap Icon")
    showMinimapIconCheckBox:BindSetting("showMinimapIcon")
    self.SettingControls.showMinimapIconCheckBox = showMinimapIconCheckBox

    local showBlizzardObjectiveTrackerCheckBox = SUI.SettingsCheckBox.Acquire(false, self)
    showBlizzardObjectiveTrackerCheckBox:SetID(20)
    showBlizzardObjectiveTrackerCheckBox:SetLabel("Show Blizzard Objective Tracker")
    showBlizzardObjectiveTrackerCheckBox:BindSetting("showBlizzardObjectiveTracker")
    self.SettingControls.showBlizzardObjectiveTrackerCheckBox = showBlizzardObjectiveTrackerCheckBox

    local mouseWheelScrollStepSlider = SUI.SettingsSlider.Acquire(false, self)
    mouseWheelScrollStepSlider:SetID(30)
    mouseWheelScrollStepSlider:SetLabel("Mouse Wheel Scroll Step")
    mouseWheelScrollStepSlider:SetSliderLabelFormatter(SUI.Slider.Label.Right)
    mouseWheelScrollStepSlider:SetMinMaxValues(0.01, 0.25)
    mouseWheelScrollStepSlider:SetValueStep(0.01)
    mouseWheelScrollStepSlider:BindSetting("mouseWheelScrollStep")
    self.SettingControls.mouseWheelScrollStepSlider = mouseWheelScrollStepSlider


    local showQuestCategories = SUI.SettingsCheckBox.Acquire(false, self)
    showQuestCategories:SetID(40)
    showQuestCategories:SetLabel("Display the categories for quests")
    showQuestCategories:BindSetting("questsEnableCategories")
    self.SettingControls.showQuestCategories = showQuestCategories
  end

  function ReleaseSettingControls(self)
    self.SettingControls.showMinimapIconCheckBox:Release()
    self.SettingControls.showBlizzardObjectiveTrackerCheckBox:Release()
    self.SettingControls.mouseWheelScrollStepSlider:Release()
    self.SettingControls.showQuestCategories:Release()

    self.SettingControls.showMinimapIconCheckBox = nil 
    self.SettingControls.showBlizzardObjectiveTrackerCheckBox = nil
    self.SettingControls.mouseWheelScrollStepSlider = nil
    self.SettingControls.showQuestCategories = nil
  end

  function OnAcquire(self)
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
    default = function() return Toolset.newtable(false, true) end
  }
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [SLT.SettingDefinitions.General] = {
    layoutManager = Layout.VerticalLayoutManager(true, true),
  }
})