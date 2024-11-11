-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling          "SylingTracker_Options.SettingDefinitions.Tasks"             ""
-- ========================================================================= --
export {
  L                                   = _Locale,
  newtable                            = Toolset.newtable
}

__Widget__()
class "SettingDefinitions.Tasks" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                   [General] Tab Builder                                 --
  -----------------------------------------------------------------------------
  function BuildGeneralTab(self)
    -- ---------------------------------------------------------------------------
    -- --- Background Section
    -- ---------------------------------------------------------------------------
    -- local backgroundSection = Widgets.ExpandableSection.Acquire(false, self)
    -- backgroundSection:SetExpanded(false)
    -- backgroundSection:SetID(30)
    -- backgroundSection:SetTitle("Background")
    -- Style[backgroundSection].marginTop = 10
    -- self.GeneralTabControls.backgroundSection = backgroundSection

    -- local showBackgroundCheckBox = Widgets.SettingsCheckBox.Acquire(false, backgroundSection)
    -- showBackgroundCheckBox:SetID(10)
    -- showBackgroundCheckBox:SetLabel("Show Background")
    -- -- showBackgroundCheckBox:BindTrackerSetting(trackerID, "showBackground")
    -- self.GeneralTabControls.showBackgroundCheckBox = showBackgroundCheckBox

    -- local backgroundColorPicker = Widgets.SettingsColorPicker.Acquire(false, backgroundSection)
    -- backgroundColorPicker:SetID(20)
    -- backgroundColorPicker:SetLabel("Background Color")
    -- -- backgroundColorPicker:BindTrackerSetting(trackerID, "backgroundColor")
    -- self.GeneralTabControls.backgroundColorPicker = backgroundColorPicker
    -- ---------------------------------------------------------------------------
    -- --- Border Section
    -- ---------------------------------------------------------------------------
    -- local borderSection = Widgets.ExpandableSection.Acquire(false, self)
    -- borderSection:SetExpanded(false)
    -- borderSection:SetID(40)
    -- borderSection:SetTitle("Border")
    -- self.GeneralTabControls.borderSection = borderSection

    -- local showBorderCheckBox = Widgets.SettingsCheckBox.Acquire(false, borderSection)
    -- showBorderCheckBox:SetID(10)
    -- showBorderCheckBox:SetLabel("Show Border")
    -- -- showBorderCheckBox:BindTrackerSetting(trackerID, "showBorder")
    -- self.GeneralTabControls.showBorderCheckBox = showBorderCheckBox

    -- local borderColorPicker = Widgets.SettingsColorPicker.Acquire(false, borderSection)
    -- borderColorPicker:SetID(20)
    -- borderColorPicker:SetLabel("Border Color")
    -- -- borderColorPicker:BindTrackerSetting(trackerID, "borderColor")
    -- self.GeneralTabControls.borderColorPicker = borderColorPicker

    -- local borderSizeSlider = Widgets.SettingsSlider.Acquire(false, borderSection)
    -- borderSizeSlider:SetID(30)
    -- borderSizeSlider:SetLabel("Border Size")
    -- -- borderSizeSlider:BindTrackerSetting(trackerID, "borderSize")
    -- borderSizeSlider:SetMinMaxValues(1, 10)
    -- self.GeneralTabControls.borderSizeSlider = borderSizeSlider
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
    showHeaderCheckBox:SetLabel(L.SHOW)
    showHeaderCheckBox:BindUISetting("tasks.showHeader")
    -- enableTrackerCheckBox:BindTrackerSetting(trackerID, "enabled")
    self.HeaderTabControls.showHeaderCheckBox = showHeaderCheckBox 

    ---------------------------------------------------------------------------
    --- Background Section
    ---------------------------------------------------------------------------
    local backgroundSection = Widgets.ExpandableSection.Acquire(false, self)
    backgroundSection:SetExpanded(false)
    backgroundSection:SetID(30)
    backgroundSection:SetTitle(L.BACKGROUND)
    Style[backgroundSection].marginTop = 10
    self.HeaderTabControls.backgroundSection = backgroundSection

    local showBackgroundCheckBox = Widgets.SettingsCheckBox.Acquire(false, backgroundSection)
    showBackgroundCheckBox:SetID(10)
    showBackgroundCheckBox:SetLabel(L.SHOW)
    showBackgroundCheckBox:BindUISetting("tasks.header.showBackground")
    self.HeaderTabControls.showBackgroundCheckBox = showBackgroundCheckBox

    local backgroundColorPicker = Widgets.SettingsColorPicker.Acquire(false, backgroundSection)
    backgroundColorPicker:SetID(20)
    backgroundColorPicker:SetLabel(L.COLOR)
    backgroundColorPicker:BindUISetting("tasks.header.backgroundColor")
    self.HeaderTabControls.backgroundColorPicker = backgroundColorPicker
    ---------------------------------------------------------------------------
    --- Border Section
    ---------------------------------------------------------------------------
    local borderSection = Widgets.ExpandableSection.Acquire(false, self)
    borderSection:SetExpanded(false)
    borderSection:SetID(40)
    borderSection:SetTitle(L.BORDER)
    self.HeaderTabControls.borderSection = borderSection

    local showBorderCheckBox = Widgets.SettingsCheckBox.Acquire(false, borderSection)
    showBorderCheckBox:SetID(10)
    showBorderCheckBox:SetLabel(L.SHOW)
    showBorderCheckBox:BindUISetting("tasks.header.showBorder")
    self.HeaderTabControls.showBorderCheckBox = showBorderCheckBox

    local borderColorPicker = Widgets.SettingsColorPicker.Acquire(false, borderSection)
    borderColorPicker:SetID(20)
    borderColorPicker:SetLabel(L.COLOR)
    borderColorPicker:BindUISetting("tasks.header.borderColor")
    self.HeaderTabControls.borderColorPicker = borderColorPicker

    local borderSizeSlider = Widgets.SettingsSlider.Acquire(false, borderSection)
    borderSizeSlider:SetID(30)
    borderSizeSlider:SetLabel(L.SIZE)
    borderSizeSlider:SetMinMaxValues(1, 10)
    borderSizeSlider:BindUISetting("tasks.header.borderSize")
    self.HeaderTabControls.borderSizeSlider = borderSizeSlider
    ---------------------------------------------------------------------------
    --- Title Section
    ---------------------------------------------------------------------------
    local titleSection = Widgets.ExpandableSection.Acquire(false, self)
    titleSection:SetExpanded(false)
    titleSection:SetID(60)
    titleSection:SetTitle(L.TITLE)
    self.HeaderTabControls.titleSection = titleSection

    local titleFont = Widgets.SettingsMediaFont.Acquire(false, titleSection)
    titleFont:SetID(10)
    titleFont:BindUISetting("tasks.header.label.mediaFont")
    self.HeaderTabControls.titleFont = titleFont

    local textColorPicker = Widgets.SettingsColorPicker.Acquire(false, titleSection)
    textColorPicker:SetID(20)
    textColorPicker:SetLabel(L.TEXT_COLOR)
    textColorPicker:BindUISetting("tasks.header.label.textColor")
    self.HeaderTabControls.textColorPicker = textColorPicker

    local textTransform = Widgets.SettingsDropDown.Acquire(false, titleSection)
    textTransform:SetID(30)
    textTransform:SetLabel(L.TEXT_TRANSFORM)
    textTransform:SetEntries(TEXT_TRANSFORM_ENTRIES)
    textTransform:BindUISetting("tasks.header.label.textTransform")
    self.HeaderTabControls.textTransform = textTransform

    local textJustifyV = Widgets.SettingsDropDown.Acquire(false, titleSection)
    textJustifyV:SetID(40)
    textJustifyV:SetLabel(L.TEXT_JUSITFY_V)
    textJustifyV:SetEntries(TEXT_JUSTIFY_V_ENTRIES)
    textJustifyV:BindUISetting("tasks.header.label.justifyV")
    self.HeaderTabControls.textJustifyV = textJustifyV

    local textJustifyH = Widgets.SettingsDropDown.Acquire(false, titleSection)
    textJustifyH:SetID(50)
    textJustifyH:SetLabel(L.TEXT_JUSITFY_H)
    textJustifyH:SetEntries(TEXT_JUSTIFY_H_ENTRIES)
    textJustifyH:BindUISetting("tasks.header.label.justifyH")
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
  --                        [Task] Tab Builder                              --
  -----------------------------------------------------------------------------
  function BuildTaskTab(self)
    ---------------------------------------------------------------------------
    --- Background Section
    ---------------------------------------------------------------------------
    local backgroundSection = Widgets.ExpandableSection.Acquire(false, self)
    backgroundSection:SetExpanded(false)
    backgroundSection:SetID(30)
    backgroundSection:SetTitle(L.BACKGROUND)
    Style[backgroundSection].marginTop = 10
    self.TaskTabControls.backgroundSection = backgroundSection

    local showBackgroundCheckBox = Widgets.SettingsCheckBox.Acquire(false, backgroundSection)
    showBackgroundCheckBox:SetID(10)
    showBackgroundCheckBox:SetLabel(L.SHOW)
    showBackgroundCheckBox:BindUISetting("task.showBackground")
    self.TaskTabControls.showBackgroundCheckBox = showBackgroundCheckBox

    local backgroundColorPicker = Widgets.SettingsColorPicker.Acquire(false, backgroundSection)
    backgroundColorPicker:SetID(20)
    backgroundColorPicker:SetLabel(L.COLOR)
    backgroundColorPicker:BindUISetting("task.backgroundColor")
    self.TaskTabControls.backgroundColorPicker = backgroundColorPicker
    ---------------------------------------------------------------------------
    --- Border Section
    ---------------------------------------------------------------------------
    local borderSection = Widgets.ExpandableSection.Acquire(false, self)
    borderSection:SetExpanded(false)
    borderSection:SetID(40)
    borderSection:SetTitle(L.BORDER)
    self.TaskTabControls.borderSection = borderSection

    local showBorderCheckBox = Widgets.SettingsCheckBox.Acquire(false, borderSection)
    showBorderCheckBox:SetID(10)
    showBorderCheckBox:SetLabel(L.SHOW)
    showBorderCheckBox:BindUISetting("task.showBorder")
    self.TaskTabControls.showBorderCheckBox = showBorderCheckBox

    local borderColorPicker = Widgets.SettingsColorPicker.Acquire(false, borderSection)
    borderColorPicker:SetID(20)
    borderColorPicker:SetLabel(L.COLOR)
    borderColorPicker:BindUISetting("task.borderColor")
    self.TaskTabControls.borderColorPicker = borderColorPicker

    local borderSizeSlider = Widgets.SettingsSlider.Acquire(false, borderSection)
    borderSizeSlider:SetID(30)
    borderSizeSlider:SetLabel(L.SIZE)
    borderSizeSlider:SetMinMaxValues(1, 10)
    borderSizeSlider:BindUISetting("task.borderSize")
    self.TaskTabControls.borderSizeSlider = borderSizeSlider
    ---------------------------------------------------------------------------
    --- Header Section
    ---------------------------------------------------------------------------
    local headerSection = Widgets.ExpandableSection.Acquire(false, self)
    headerSection:SetExpanded(false)
    headerSection:SetID(50)
    headerSection:SetTitle(L.HEADER)
    self.TaskTabControls.headerSection = headerSection

    ---------------------------------------------------------------------------
    --- Header Sub Sections
    ---------------------------------------------------------------------------
    local headertabControl = Widgets.TabControl.Acquire(false, headerSection)
    headertabControl:SetID(50)
    headertabControl:SetID(1)
    headertabControl:AddTabPage({
      name = L.TITLE,
      onAcquire = function()  
        local font = Widgets.SettingsMediaFont.Acquire(false, headertabControl)
        font:SetID(10)
        font:BindUISetting("task.name.mediaFont")
        self.TaskHeaderTitleTabControls.font = font

        local textTransform = Widgets.SettingsDropDown.Acquire(false, headertabControl)
        textTransform:SetID(20)
        textTransform:SetLabel(L.TEXT_TRANSFORM)
        textTransform:SetEntries(TEXT_TRANSFORM_ENTRIES)
        textTransform:BindUISetting("task.name.textTransform")
        self.TaskHeaderTitleTabControls.textTransform = textTransform

        local textJustifyH = Widgets.SettingsDropDown.Acquire(false, headertabControl)
        textJustifyH:SetID(30)
        textJustifyH:SetLabel(L.TEXT_JUSITFY_H)
        textJustifyH:SetEntries(TEXT_JUSTIFY_H_ENTRIES)
        textJustifyH:BindUISetting("task.name.justifyH")
        self.TaskHeaderTitleTabControls.textJustifyH = textJustifyH
      
      end,
      onRelease = function()  
        for index, control in pairs(self.TaskHeaderTitleTabControls) do 
            control:Release()
            self.TaskHeaderTitleTabControls[index] = nil
        end
      end,
    })

    headertabControl:Refresh()
    headertabControl:SelectTab(1)

    self.TaskTabControls.headertabControl = headertabControl

    ---------------------------------------------------------------------------
    --- Objectives Section
    ---------------------------------------------------------------------------
    -- local objectivesSection = Widgets.ExpandableSection.Acquire(false, self)
    -- objectivesSection:SetExpanded(false)
    -- objectivesSection:SetID(50)
    -- objectivesSection:SetTitle("Objectives")
    -- self.QuestTabControls.objectivesSection = objectivesSection
  end
  -----------------------------------------------------------------------------
  --                        [Task] Release Builder                          --
  -----------------------------------------------------------------------------
  function ReleaseTaskTab(self)
    for index, control in pairs(self.TaskTabControls) do 
      control:Release()
      self.TaskTabControls[index] = nil
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
      name = L.HEADER,
      onAcquire = function() self:BuildHeaderTab() end,
      onRelease = function() self:ReleaseHeaderTab() end,
    })

    tabControl:AddTabPage({
      name = L.TASK,
      onAcquire = function() self:BuildTaskTab() end,
      onRelease = function() self:ReleaseTaskTab() end,
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
    self:ReleaseTaskTab()
  
    for index, control in pairs(self.TaskHeaderTitleTabControls) do 
        control:Release()
        self.TaskHeaderTitleTabControls[index] = nil
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

  property "GeneralTabControls" {
    set = false, 
    default = function() return newtable(false, true) end
  }

  property "HeaderTabControls" {
    set = false,
    default = function() return newtable(false, true) end
  }

  property "TaskTabControls" {
    set = false,
    default = function() return newtable(false, true) end
  }

  property "TaskHeaderTitleTabControls" {
    set = false, 
    default = function() return newtable(false, true) end
  }
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [SettingDefinitions.Tasks] = {
    layoutManager = Layout.VerticalLayoutManager(true, true)
  }
})