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
export {
  L                                   = _Locale
}

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
    textColorPicker:SetLabel(L.TEXT_COLOR)
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
    local mediaFont = Widgets.SettingsMediaFont.Acquire(false, self)
    mediaFont:SetID(10)
    mediaFont:BindUISetting("objective.text.mediaFont")
    self.TabSettingControls.mediaFont = mediaFont

    local textColorSection = Widgets.SettingsExpandableSection.Acquire(false, self)
    textColorSection:SetID(20)
    textColorSection:SetTitle(L.TEXT_COLOR)
    self.TabSettingControls.textColorSection = textColorSection

    local textColorProgressColorPicker = Widgets.SettingsColorPicker.Acquire(false, textColorSection)
    textColorProgressColorPicker:SetID(10)
    textColorProgressColorPicker:SetLabel(Color.LIGHTGRAY .. L.STATE_PROGRESS)
    textColorProgressColorPicker:SetLabelStyle("small")
    textColorProgressColorPicker:BindUISetting("objective.progress.text.textColor")
    self.TabSettingControls.textColorProgressColorPicker = textColorProgressColorPicker

    local textColorCompletedColorPicker = Widgets.SettingsColorPicker.Acquire(false, textColorSection)
    textColorCompletedColorPicker:SetID(20)
    textColorCompletedColorPicker:SetLabel(Color.GREEN .. L.STATE_COMPLETED)
    textColorCompletedColorPicker:SetLabelStyle("small")
    textColorCompletedColorPicker:BindUISetting("objective.completed.text.textColor")
    self.TabSettingControls.textColorCompletedColorPicker = textColorCompletedColorPicker

    local textColorFailedColorPicker = Widgets.SettingsColorPicker.Acquire(false, textColorSection)
    textColorFailedColorPicker:SetID(30)
    textColorFailedColorPicker:SetLabel(Color.RED .. L.STATE_FAILED)
    textColorFailedColorPicker:SetLabelStyle("small")
    textColorFailedColorPicker:BindUISetting("objective.failed.text.textColor")
    self.TabSettingControls.textColorFailedColorPicker = textColorFailedColorPicker

    -- local textTransform = Widgets.SettingsDropDown.Acquire(false, self)
    -- textTransform:SetID(30)
    -- textTransform:SetLabel("Text Transform")
    -- self.TabSettingControls.textTransform = textTransform

    -- local textJustifyV = Widgets.SettingsDropDown.Acquire(false, self)
    -- textJustifyV:SetID(40)
    -- textJustifyV:SetLabel("Text Justify V")
    -- self.TabSettingControls.textJustifyV = textJustifyV

    -- local textJustifyH = Widgets.SettingsDropDown.Acquire(false, self)
    -- textJustifyH:SetID(50)
    -- textJustifyH:SetLabel("Text Justify H")
    -- self.TabSettingControls.textJustifyH = textJustifyH
  end

  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function BuildSettingControls(self)
    local tabControl = Widgets.TabControl.Acquire(false, self)
    tabControl:SetID(1)

    -- tabControl:AddTabPage({
    --   name = "General",
    --   onAcquire = function() end,
    --   onRelease = function() end, 
    -- })

    tabControl:AddTabPage({
      name = L.TEXT,
      onAcquire = function() self:BuildTextTab() end,
      onRelease = function() self:ReleaseTabSettingControls() end, 
    })

    -- tabControl:AddTabPage({
    --   name = "Icon",
    --   onAcquire = function() end,
    --   onRelease = function() end, 
    -- })

    -- tabControl:AddTabPage({
    --   name = "Progress Bar",
    --   onAcquire = function() end,
    --   onRelease = function() end, 
    -- })

    -- tabControl:AddTabPage({
    --   name = "Timer",
    --   onAcquire = function() end,
    --   onRelease = function() end, 
    -- })

    tabControl:Refresh()
    tabControl:SelectTab(1)
    self.SettingControls.tabControl = tabControl
  end

  function OnBuildSettings(self)
    self:BuildSettingControls()
  end

  function ReleaseSettingControls(self)
    for key, control in pairs(self.SettingControls) do 
      self.SettingControls[key] = nil 
      control:Release()
    end    
  end

  function ReleaseTabSettingControls(self)
    for key, control in pairs(self.TabSettingControls) do 
      self.TabSettingControls[key] = nil 
      control:Release()
    end       
  end

  function OnRelease(self)
    self:SetID(0)
    self:SetParent()
    self:ClearAllPoints()
    self:Hide()

    self:ReleaseSettingControls()
    self:ReleaseTabSettingControls()
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "SettingControls" {
    set = false,
    default = function() return Toolset.newtable(false, true) end 
  }

  property "TabSettingControls" {
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