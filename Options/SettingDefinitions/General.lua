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
    showMinimapIconCheckBox:SetID(1)
    showMinimapIconCheckBox:SetLabel("Show Minimap Icon")
    showMinimapIconCheckBox:BindSetting("show-minimap-icon")
    self.SettingControls.showMinimapIconCheckBox = showMinimapIconCheckBox

    local showBlizzardObjectiveTrackerCheckBox = SUI.SettingsCheckBox.Acquire(false, self)
    showBlizzardObjectiveTrackerCheckBox:SetID(2)
    showBlizzardObjectiveTrackerCheckBox:SetLabel("Show Blizzard Objective Tracker")
    showBlizzardObjectiveTrackerCheckBox:BindSetting("replace-blizzard-objective-tracker", true)
    self.SettingControls.showBlizzardObjectiveTrackerCheckBox = showBlizzardObjectiveTrackerCheckBox

    local mouseWheelScrollStepSlider = SUI.SettingsSlider.Acquire(false, self)
    mouseWheelScrollStepSlider:SetID(3)
    mouseWheelScrollStepSlider:SetLabel("Mouse Wheel Scroll Step")
    mouseWheelScrollStepSlider:SetSliderLabelFormatter(SUI.Slider.Label.Right)
    mouseWheelScrollStepSlider:SetMinMaxValues(0.01, 0.25)
    mouseWheelScrollStepSlider:SetValueStep(0.01)
    mouseWheelScrollStepSlider:BindSetting("mouse-wheel-scroll-step")
    self.SettingControls.mouseWheelScrollStepSlider = mouseWheelScrollStepSlider
  end

  function ReleaseSettingControls(self)
    self.SettingControls.showMinimapIconCheckBox:Release()
    self.SettingControls.showBlizzardObjectiveTrackerCheckBox:Release()
    self.SettingControls.mouseWheelScrollStepSlider:Release()

    self.SettingControls.showMinimapIconCheckBox = nil 
    self.SettingControls.showBlizzardObjectiveTrackerCheckBox = nil
    self.SettingControls.mouseWheelScrollStepSlider = nil
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