-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling         "SylingTracker_Options.SettingDefinitions.Achievements"       ""
-- ========================================================================= --
export {
  newtable                            = Toolset.newtable
}

__Widget__()
class "SettingDefinitions.Achievements" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                   [General] Tab Builder                                 --
  -----------------------------------------------------------------------------
  function BuildGeneralTab(self)


  end
  -----------------------------------------------------------------------------
  --                    [General] Tab Release                                --
  -----------------------------------------------------------------------------
  function ReleaseGeneralTab(self)
    for index, control in pairs(self.GeneralTabControls) do 
      control:Release()
      self.GeneralTabControls[index] = nil
    end
  end
  -----------------------------------------------------------------------------
  --                      [Header] Tab Builder                               --
  -----------------------------------------------------------------------------
  function BuildHeaderTab(self)
    local showHeaderCheckBox = Widgets.SettingsCheckBox.Acquire(false, self)
    showHeaderCheckBox:SetID(10)
    showHeaderCheckBox:SetLabel("Show")
    showHeaderCheckBox:BindUISetting("achievements.showHeader")
    -- enableTrackerCheckBox:BindTrackerSetting(trackerID, "enabled")
    self.HeaderTabControls.showHeaderCheckBox = showHeaderCheckBox

    ---------------------------------------------------------------------------
    --- Background Section
    ---------------------------------------------------------------------------
    local backgroundSection = Widgets.ExpandableSection.Acquire(false, self)
    backgroundSection:SetExpanded(false)
    backgroundSection:SetID(30)
    backgroundSection:SetTitle("Background")
    Style[backgroundSection].marginTop = 10
    self.HeaderTabControls.backgroundSection = backgroundSection

    local showBackgroundCheckBox = Widgets.SettingsCheckBox.Acquire(false, backgroundSection)
    showBackgroundCheckBox:SetID(10)
    showBackgroundCheckBox:SetLabel("Show")
    showBackgroundCheckBox:BindUISetting("achievements.header.showBackground")
    self.HeaderTabControls.showBackgroundCheckBox = showBackgroundCheckBox

    local backgroundColorPicker = Widgets.SettingsColorPicker.Acquire(false, backgroundSection)
    backgroundColorPicker:SetID(20)
    backgroundColorPicker:SetLabel("Color")
    backgroundColorPicker:BindUISetting("achievements.header.backgroundColor")
    self.HeaderTabControls.backgroundColorPicker = backgroundColorPicker
    ---------------------------------------------------------------------------
    --- Border Section
    ---------------------------------------------------------------------------
    local borderSection = Widgets.ExpandableSection.Acquire(false, self)
    borderSection:SetExpanded(false)
    borderSection:SetID(40)
    borderSection:SetTitle("Border")
    self.HeaderTabControls.borderSection = borderSection

    local showBorderCheckBox = Widgets.SettingsCheckBox.Acquire(false, borderSection)
    showBorderCheckBox:SetID(10)
    showBorderCheckBox:SetLabel("Show")
    showBorderCheckBox:BindUISetting("achievements.header.showBorder")
    self.HeaderTabControls.showBorderCheckBox = showBorderCheckBox

    local borderColorPicker = Widgets.SettingsColorPicker.Acquire(false, borderSection)
    borderColorPicker:SetID(20)
    borderColorPicker:SetLabel("Color")
    borderColorPicker:BindUISetting("achievements.header.borderColor")
    self.HeaderTabControls.borderColorPicker = borderColorPicker

    local borderSizeSlider = Widgets.SettingsSlider.Acquire(false, borderSection)
    borderSizeSlider:SetID(30)
    borderSizeSlider:SetLabel("Size")
    borderSizeSlider:SetSliderLabelFormatter(Widgets.Slider.Label.Right)
    borderSizeSlider:BindUISetting("achievements.header.borderSize")
    borderSizeSlider:SetMinMaxValues(1, 10)
    self.HeaderTabControls.borderSizeSlider = borderSizeSlider
    ---------------------------------------------------------------------------
    --- Title Section
    ---------------------------------------------------------------------------
    local titleSection = Widgets.ExpandableSection.Acquire(false, self)
    titleSection:SetExpanded(false)
    titleSection:SetID(60)
    titleSection:SetTitle("Title")
    self.HeaderTabControls.titleSection = titleSection

    local titleFont = Widgets.SettingsMediaFont.Acquire(false, titleSection)
    titleFont:SetID(10)
    titleFont:BindUISetting("achievements.header.label.mediaFont")
    self.HeaderTabControls.titleFont = titleFont

    local textColorPicker = Widgets.SettingsColorPicker.Acquire(false, titleSection)
    textColorPicker:SetID(20)
    textColorPicker:SetLabel("Text Color")
    textColorPicker:BindUISetting("achievements.header.label.textColor")
    self.HeaderTabControls.textColorPicker = textColorPicker

    local textTransform = Widgets.SettingsDropDown.Acquire(false, titleSection)
    textTransform:SetID(30)
    textTransform:SetLabel("Text Transform")
    textTransform:SetEntries(TEXT_TRANSFORM_ENTRIES)
    textTransform:BindUISetting("achievements.header.label.textTransform")
    self.HeaderTabControls.textTransform = textTransform

    local textJustifyV = Widgets.SettingsDropDown.Acquire(false, titleSection)
    textJustifyV:SetID(40)
    textJustifyV:SetLabel("Text Justify V")
    textJustifyV:SetEntries(TEXT_JUSTIFY_V_ENTRIES)
    textJustifyV:BindUISetting("achievements.header.label.justifyV")
    self.HeaderTabControls.textJustifyV = textJustifyV

    local textJustifyH = Widgets.SettingsDropDown.Acquire(false, titleSection)
    textJustifyH:SetID(50)
    textJustifyH:SetLabel("Text Justify H")
    textJustifyH:SetEntries(TEXT_JUSTIFY_H_ENTRIES)
    textJustifyH:BindUISetting("achievements.header.label.justifyH")
    self.HeaderTabControls.textJustifyH = textJustifyH
  end
  -----------------------------------------------------------------------------
  --                      [Header] Tab Release                               --
  -----------------------------------------------------------------------------
  function ReleaseHeaderTab(self)
    for index, control in pairs(self.HeaderTabControls) do 
      control:Release()
      self.HeaderTabControls[index] = nil
    end
  end
  -----------------------------------------------------------------------------
  --                    [Achievement] Tab Builder                            --
  -----------------------------------------------------------------------------
  function BuildAchievementTab(self)
    ---------------------------------------------------------------------------
    --- Background Section
    ---------------------------------------------------------------------------
    local backgroundSection = Widgets.ExpandableSection.Acquire(false, self)
    backgroundSection:SetExpanded(false)
    backgroundSection:SetID(30)
    backgroundSection:SetTitle("Background")
    Style[backgroundSection].marginTop = 10
    self.AchievementTabControls.backgroundSection = backgroundSection

    local showBackgroundCheckBox = Widgets.SettingsCheckBox.Acquire(false, backgroundSection)
    showBackgroundCheckBox:SetID(10)
    showBackgroundCheckBox:SetLabel("Show")
    showBackgroundCheckBox:BindUISetting("achievement.showBackground")
    self.AchievementTabControls.showBackgroundCheckBox = showBackgroundCheckBox

    local backgroundColorPicker = Widgets.SettingsColorPicker.Acquire(false, backgroundSection)
    backgroundColorPicker:SetID(20)
    backgroundColorPicker:SetLabel("Color")
    backgroundColorPicker:BindUISetting("achievement.backgroundColor")
    self.AchievementTabControls.backgroundColorPicker = backgroundColorPicker
    ---------------------------------------------------------------------------
    --- Border Section
    ---------------------------------------------------------------------------
    local borderSection = Widgets.ExpandableSection.Acquire(false, self)
    borderSection:SetExpanded(false)
    borderSection:SetID(40)
    borderSection:SetTitle("Border")
    self.AchievementTabControls.borderSection = borderSection

    local showBorderCheckBox = Widgets.SettingsCheckBox.Acquire(false, borderSection)
    showBorderCheckBox:SetID(10)
    showBorderCheckBox:SetLabel("Show")
    showBorderCheckBox:BindUISetting("achievement.showBorder")
    self.AchievementTabControls.showBorderCheckBox = showBorderCheckBox

    local borderColorPicker = Widgets.SettingsColorPicker.Acquire(false, borderSection)
    borderColorPicker:SetID(20)
    borderColorPicker:SetLabel("Color")
    borderColorPicker:BindUISetting("achievement.borderColor")
    self.AchievementTabControls.borderColorPicker = borderColorPicker

    local borderSizeSlider = Widgets.SettingsSlider.Acquire(false, borderSection)
    borderSizeSlider:SetID(30)
    borderSizeSlider:SetLabel("Size")
    borderSizeSlider:SetSliderLabelFormatter(Widgets.Slider.Label.Right)
    borderSizeSlider:BindUISetting("achievement.borderSize")
    borderSizeSlider:SetMinMaxValues(1, 10)
    self.AchievementTabControls.borderSizeSlider = borderSizeSlider
    ---------------------------------------------------------------------------
    --- Header Section
    ---------------------------------------------------------------------------
    local headerSection = Widgets.ExpandableSection.Acquire(false, self)
    headerSection:SetExpanded(false)
    headerSection:SetID(50)
    headerSection:SetTitle("Header")
    self.AchievementTabControls.headerSection = headerSection
    ---------------------------------------------------------------------------
    --- Header Sub Sections
    ---------------------------------------------------------------------------
    local headertabControl = Widgets.TabControl.Acquire(false, headerSection)
    headertabControl:SetID(50)
    headertabControl:SetID(1)
    headertabControl:AddTabPage({
      name = "Title",
      onAcquire = function()  
        local font = Widgets.SettingsMediaFont.Acquire(false, headertabControl)
        font:SetID(10)
        font:BindUISetting("achievement.name.mediaFont")
        self.AchievementHeaderTitleTabControls.font = font

        local textTransform = Widgets.SettingsDropDown.Acquire(false, headertabControl)
        textTransform:SetID(20)
        textTransform:SetLabel("Text Transform")
        textTransform:SetEntries(TEXT_TRANSFORM_ENTRIES)
        textTransform:BindUISetting("achievement.name.textTransform")
        self.AchievementHeaderTitleTabControls.textTransform = textTransform
      
      end,
      onRelease = function()  
        for index, control in pairs(self.AchievementHeaderTitleTabControls) do 
            control:Release()
            self.AchievementHeaderTitleTabControls[index] = nil
        end
      end,
    })
    headertabControl:Refresh()
    headertabControl:SelectTab(1)
    self.AchievementTabControls.headertabControl = headertabControl


  end

  function ReleaseAchievementTab(self)
    for index, control in pairs(self.AchievementTabControls) do 
      control:Release()
      self.AchievementTabControls[index] = nil
    end
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function BuildSettingControls(self)
    local tabControl = Widgets.TabControl.Acquire(false, self)
    tabControl:SetID(1)
    -- tabControl:AddTabPage({
    --   name = "General",
    --   onAcquire = function() self:BuildGeneralTab() end,
    --   onRelease = function() self:ReleaseGeneralTab() end,
    -- })
    
    tabControl:AddTabPage({
      name = "Header",
      onAcquire = function() self:BuildHeaderTab() end,
      onRelease = function() self:ReleaseHeaderTab() end,
    })

    tabControl:AddTabPage({
      name = "Achievement",
      onAcquire = function() self:BuildAchievementTab() end,
      onRelease = function() self:ReleaseAchievementTab() end,
    })
    

    tabControl:Refresh()
    tabControl:SelectTab(1)

    self.SettingControls.tabControl = tabControl
  end

  function ReleaseSettingControls(self)
    self.SettingControls.tabControl:Release()
    self.SettingControls.tabControl = nil

    self:ReleaseGeneralTab()
    self:ReleaseHeaderTab()
    self:ReleaseAchievementTab()
  end

  function OnBuildSettings(self)
    self:BuildSettingControls()
  end 

  function OnRelease(self)
    self:ReleaseSettingControls()
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "SettingControls" {
    set = false,
    default = function() return newtable(false, true) end 
  }

  property "GeneralTabControls" {
    set = false, 
    default = function() return newtable(false, true) end
  }

  property "HeaderTabControls" {
    set = false,
    default = function() return newtable(false, true) end
  }

  property "AchievementTabControls" {
    set = false,
    default = function() return newtable(false, true) end
  }

  property "AchievementHeaderTitleTabControls" {
    set = false, 
    default = function() return newtable(false, true) end
  }

end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [SettingDefinitions.Achievements] = {
    height        = 1,
    layoutManager = Layout.VerticalLayoutManager(true, true)
  }
})