-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling          "SylingTracker_Options.SettingDefinitions.General"           ""
-- ========================================================================= --
export {
  newtable  = Toolset.newtable
}

__Widget__()
class "SettingDefinitions.General" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function BuildSettingControls(self)
    local showMinimapIconCheckBox = Widgets.SettingsCheckBox.Acquire(false, self)
    showMinimapIconCheckBox:SetID(10)
    showMinimapIconCheckBox:SetLabel("Show Minimap Icon")
    showMinimapIconCheckBox:BindSetting("showMinimapIcon")
    self.SettingControls.showMinimapIconCheckBox = showMinimapIconCheckBox

    local showBlizzardObjectiveTrackerCheckBox = Widgets.SettingsCheckBox.Acquire(false, self)
    showBlizzardObjectiveTrackerCheckBox:SetID(20)
    showBlizzardObjectiveTrackerCheckBox:SetLabel("Show Blizzard Objective Tracker")
    showBlizzardObjectiveTrackerCheckBox:BindSetting("showBlizzardObjectiveTracker")
    self.SettingControls.showBlizzardObjectiveTrackerCheckBox = showBlizzardObjectiveTrackerCheckBox
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
  [SettingDefinitions.General] = {
    layoutManager = Layout.VerticalLayoutManager(true, true)
  }
})
