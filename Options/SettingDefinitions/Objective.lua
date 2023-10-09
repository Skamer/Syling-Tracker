-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling          "SylingTracker_Options.SettingDefinitions.Objective"         ""
-- ========================================================================= --
__Widget__()
class "SettingDefinitions.Objective" (function(_ENV)
  inherit "Frame"

  local function BuildTextControlsForState(self, state)
    local font = Widgets.SettingsMediaFont.Acquire(true, self)
    font:SetID(20)
    font:BindUISetting(("objective.%s.text.mediaFont"):format(state))
    self.StateControls[font] = true 

    local textColorPicker = Widgets.SettingsColorPicker.Acquire(true, self)
    textColorPicker:SetID(30)
    textColorPicker:SetLabel("Text Color")
    textColorPicker:BindUISetting(("objective.%s.text.textColor"):format(state))
    self.StateControls[textColorPicker] = true
  end

  local function ReleaseStateControls(self)
    for control in pairs(self.StateControls) do 
      self.StateControls[control] = nil 
      control:Release()
    end
  end

  function BuildTextTab(self)
    local font = Widgets.SettingsMediaFont.Acquire(false, self)
    font:SetID(10)
    font:BindUISetting("objective.text.mediaFont")
    self.SettingControls[font] = true

    local textColorSection = Widgets.SettingsExpandableSection.Acquire(false, self)
    textColorSection:SetID(20)
    textColorSection:SetTitle("Text Color")
    self.SettingControls[textColorSection] = true

    local textColorProgressColorPicker = Widgets.SettingsColorPicker.Acquire(false, textColorSection)
    textColorProgressColorPicker:SetID(10)
    textColorProgressColorPicker:SetLabel(Color.LIGHTGRAY .. "Progress")
    textColorProgressColorPicker:SetLabelStyle("small")
    textColorProgressColorPicker:BindUISetting("objective.progress.text.textColor")
    self.SettingControls[textColorProgressColorPicker] = true

    local textColorCompletedColorPicker = Widgets.SettingsColorPicker.Acquire(false, textColorSection)
    textColorCompletedColorPicker:SetID(20)
    textColorCompletedColorPicker:SetLabel(Color.GREEN .. "Completed")
    textColorCompletedColorPicker:SetLabelStyle("small")
    textColorCompletedColorPicker:BindUISetting("objective.completed.text.textColor")
    self.SettingControls[textColorCompletedColorPicker] = true

    local textColorFailedColorPicker = Widgets.SettingsColorPicker.Acquire(false, textColorSection)
    textColorFailedColorPicker:SetID(30)
    textColorFailedColorPicker:SetLabel(Color.RED .. "Failed")
    textColorFailedColorPicker:SetLabelStyle("small")
    textColorFailedColorPicker:BindUISetting("objective.failed.text.textColor")
    self.SettingControls[textColorFailedColorPicker] = true

    local textTransform = Widgets.SettingsDropDown.Acquire(false, self)
    textTransform:SetID(30)
    textTransform:SetLabel("Text Transform")
    self.SettingControls[textTransform] = true

    local textJustifyV = Widgets.SettingsDropDown.Acquire(false, self)
    textJustifyV:SetID(40)
    textJustifyV:SetLabel("Text Justify V")
    self.SettingControls[textJustifyV] = true

    local textJustifyH = Widgets.SettingsDropDown.Acquire(false, self)
    textJustifyH:SetID(50)
    textJustifyH:SetLabel("Text Justify H")
    self.SettingControls[textJustifyH] = true
  end

  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function BuildSettingControls(self)
    local tabControl = Widgets.TabControl.Acquire(false, self)
    tabControl:SetID(1)

    tabControl:AddTabPage({
      name = "General",
      onAcquire = function() end,
      onRelease = function() end, 
    })

    tabControl:AddTabPage({
      name = "Text",
      onAcquire = function() self:BuildTextTab() end,
      onRelease = function() self:ReleaseSettingControls() end, 
    })

    tabControl:AddTabPage({
      name = "Icon",
      onAcquire = function() end,
      onRelease = function() end, 
    })

    tabControl:AddTabPage({
      name = "Progress Bar",
      onAcquire = function() end,
      onRelease = function() end, 
    })

    tabControl:AddTabPage({
      name = "Timer",
      onAcquire = function() end,
      onRelease = function() end, 
    })

    tabControl:Refresh()
    tabControl:SelectTab(1)
  end

  function OnBuildSettings(self)
    self:BuildSettingControls()
  end

  function ReleaseSettingControls(self)
    for control in pairs(self.SettingControls) do 
      self.SettingControls[control] = nil 
      control:Release()
    end    
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "SettingControls" {
    set = false,
    default = function() return Toolset.newtable(false, true) end 
  }

  property "StateControls" {
    set = false,
    default = function() return Toolset.newtable(false, true) end 
  }

end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [SettingDefinitions.Objective] = {
    height = 1,
    layoutManager = Layout.VerticalLayoutManager(true, true),
  },
})