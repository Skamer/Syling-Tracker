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
  L         = _Locale,
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
    showMinimapIconCheckBox:SetLabel(L.SHOW_MINIMAP_ICON)
    showMinimapIconCheckBox:BindSetting("showMinimapIcon")
    self.SettingControls.showMinimapIconCheckBox = showMinimapIconCheckBox

    local showBlizzardObjectiveTrackerCheckBox = Widgets.SettingsCheckBox.Acquire(false, self)
    showBlizzardObjectiveTrackerCheckBox:SetID(20)
    showBlizzardObjectiveTrackerCheckBox:SetLabel(L.SHOW_BLIZZARD_OBJECTIVE_TRACKER)
    showBlizzardObjectiveTrackerCheckBox:BindSetting("showBlizzardObjectiveTracker")
    self.SettingControls.showBlizzardObjectiveTrackerCheckBox = showBlizzardObjectiveTrackerCheckBox


    local enableTomTomCheckBox = Widgets.SettingsCheckBox.Acquire(false, self)
    enableTomTomCheckBox:SetID(20)
    enableTomTomCheckBox:SetLabel(("|cffff7f00(%s)|r %s"):format(L.EXPERIMENTAL, L.TOMTOM_ENABLE_INTEGRATION))
    enableTomTomCheckBox:BindSetting("enableTomTom")
    self.SettingControls.enableTomTomCheckBox = enableTomTomCheckBox
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
