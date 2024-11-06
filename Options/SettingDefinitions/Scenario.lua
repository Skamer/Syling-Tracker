-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling         "SylingTracker_Options.SettingDefinitions.Scenario"           ""
-- ========================================================================= --
export {
  L                                   = _Locale,
  newtable                            = Toolset.newtable
}

__Widget__()
class "SettingDefinitions.Scenario" (function(_ENV)
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
    showHeaderCheckBox:SetLabel(L.SHOW)
    showHeaderCheckBox:BindUISetting("scenario.showHeader")
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
    showBackgroundCheckBox:BindUISetting("scenario.header.showBackground")
    self.HeaderTabControls.showBackgroundCheckBox = showBackgroundCheckBox

    local backgroundColorPicker = Widgets.SettingsColorPicker.Acquire(false, backgroundSection)
    backgroundColorPicker:SetID(20)
    backgroundColorPicker:SetLabel(L.COLOR)
    backgroundColorPicker:BindUISetting("scenario.header.backgroundColor")
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
    showBorderCheckBox:BindUISetting("scenario.header.showBorder")
    self.HeaderTabControls.showBorderCheckBox = showBorderCheckBox

    local borderColorPicker = Widgets.SettingsColorPicker.Acquire(false, borderSection)
    borderColorPicker:SetID(20)
    borderColorPicker:SetLabel(L.COLOR)
    borderColorPicker:BindUISetting("scenario.header.borderColor")
    self.HeaderTabControls.borderColorPicker = borderColorPicker

    local borderSizeSlider = Widgets.SettingsSlider.Acquire(false, borderSection)
    borderSizeSlider:SetID(30)
    borderSizeSlider:SetLabel(L.SIZE)
    borderSizeSlider:SetMinMaxValues(1, 10)
    borderSizeSlider:BindUISetting("scenario.header.borderSize")
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
    titleFont:BindUISetting("scenario.header.label.mediaFont")
    self.HeaderTabControls.titleFont = titleFont

    local textColorPicker = Widgets.SettingsColorPicker.Acquire(false, titleSection)
    textColorPicker:SetID(20)
    textColorPicker:SetLabel(L.TEXT_COLOR)
    textColorPicker:BindUISetting("scenario.header.label.textColor")
    self.HeaderTabControls.textColorPicker = textColorPicker

    local textTransform = Widgets.SettingsDropDown.Acquire(false, titleSection)
    textTransform:SetID(30)
    textTransform:SetLabel(L.TEXT_TRANSFORM)
    textTransform:SetEntries(TEXT_TRANSFORM_ENTRIES)
    textTransform:BindUISetting("scenario.header.label.textTransform")
    self.HeaderTabControls.textTransform = textTransform

    local textJustifyV = Widgets.SettingsDropDown.Acquire(false, titleSection)
    textJustifyV:SetID(40)
    textJustifyV:SetLabel(L.TEXT_JUSITFY_V)
    textJustifyV:SetEntries(TEXT_JUSTIFY_V_ENTRIES)
    textJustifyV:BindUISetting("scenario.header.label.justifyV")
    self.HeaderTabControls.textJustifyV = textJustifyV

    local textJustifyH = Widgets.SettingsDropDown.Acquire(false, titleSection)
    textJustifyH:SetID(50)
    textJustifyH:SetLabel(L.TEXT_JUSITFY_H)
    textJustifyH:SetEntries(TEXT_JUSTIFY_H_ENTRIES)
    textJustifyH:BindUISetting("scenario.header.label.justifyH")
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
  --                        [Top Info] Tab Builder                           --
  -----------------------------------------------------------------------------
  function BuildTopInfoTab(self)
    ---------------------------------------------------------------------------
    --- Background Section
    ---------------------------------------------------------------------------
    -- local backgroundSection = Widgets.ExpandableSection.Acquire(false, self)
    -- backgroundSection:SetExpanded(false)
    -- backgroundSection:SetID(30)
    -- backgroundSection:SetTitle("Background")
    -- Style[backgroundSection].marginTop = 10
    -- self.TopInfoTabControls.backgroundSection = backgroundSection

    -- local showBackgroundCheckBox = Widgets.SettingsCheckBox.Acquire(false, backgroundSection)
    -- showBackgroundCheckBox:SetID(10)
    -- showBackgroundCheckBox:SetLabel("Show")
    -- showBackgroundCheckBox:BindUISetting("scenario.topInfo.showBackground")
    -- self.TopInfoTabControls.showBackgroundCheckBox = showBackgroundCheckBox

    -- local backgroundColorPicker = Widgets.SettingsColorPicker.Acquire(false, backgroundSection)
    -- backgroundColorPicker:SetID(20)
    -- backgroundColorPicker:SetLabel("Color")
    -- backgroundColorPicker:BindUISetting("scenario.topInfo.backgroundColor")
    -- self.TopInfoTabControls.backgroundColorPicker = backgroundColorPicker
    ---------------------------------------------------------------------------
    --- Border Section
    ---------------------------------------------------------------------------
    -- local borderSection = Widgets.ExpandableSection.Acquire(false, self)
    -- borderSection:SetExpanded(false)
    -- borderSection:SetID(40)
    -- borderSection:SetTitle("Border")
    -- self.TopInfoTabControls.borderSection = borderSection

    -- local showBorderCheckBox = Widgets.SettingsCheckBox.Acquire(false, borderSection)
    -- showBorderCheckBox:SetID(10)
    -- showBorderCheckBox:SetLabel("Show")
    -- showBorderCheckBox:BindUISetting("scenario.topInfo.showBorder")
    -- self.TopInfoTabControls.showBorderCheckBox = showBorderCheckBox

    -- local borderColorPicker = Widgets.SettingsColorPicker.Acquire(false, borderSection)
    -- borderColorPicker:SetID(20)
    -- borderColorPicker:SetLabel("Color")
    -- borderColorPicker:BindUISetting("scenario.topInfo.borderColor")
    -- self.TopInfoTabControls.borderColorPicker = borderColorPicker

    -- local borderSizeSlider = Widgets.SettingsSlider.Acquire(false, borderSection)
    -- borderSizeSlider:SetID(30)
    -- borderSizeSlider:SetLabel("Size")
    -- borderSizeSlider:BindUISetting("scenario.topInfo.borderSize")
    -- borderSizeSlider:SetMinMaxValues(1, 10)
    -- self.TopInfoTabControls.borderSizeSlider = borderSizeSlider
    ---------------------------------------------------------------------------
    --- Scenario Name Section
    ---------------------------------------------------------------------------
    local scenarioNameSection = Widgets.ExpandableSection.Acquire(false, self)
    scenarioNameSection:SetExpanded(false)
    scenarioNameSection:SetID(50)
    scenarioNameSection:SetTitle(L.SCENARIO_NAME)
    self.TopInfoTabControls.scenarioName = scenarioNameSection

    local scenarioNameFont = Widgets.SettingsMediaFont.Acquire(false, scenarioNameSection)
    scenarioNameFont:SetID(10)
    scenarioNameFont:BindUISetting("scenario.name.mediaFont")
    self.TopInfoTabControls.scenarioNameFont = scenarioNameFont

    local scenarioNameTextColorPicker = Widgets.SettingsColorPicker.Acquire(false, scenarioNameSection)
    scenarioNameTextColorPicker:SetID(20)
    scenarioNameTextColorPicker:SetLabel(L.TEXT_COLOR)
    scenarioNameTextColorPicker:BindUISetting("scenario.name.textColor")
    self.TopInfoTabControls.scenarioNameTextColorPicker = scenarioNameTextColorPicker

    local scenarioNameTextTransform = Widgets.SettingsDropDown.Acquire(false, scenarioNameSection)
    scenarioNameTextTransform:SetID(30)
    scenarioNameTextTransform:SetLabel(L.TEXT_TRANSFORM)
    scenarioNameTextTransform:SetEntries(TEXT_TRANSFORM_ENTRIES)
    scenarioNameTextTransform:BindUISetting("scenario.name.textTransform")
    self.TopInfoTabControls.scenarioNameTextTransform = scenarioNameTextTransform

    local scenarioNameTextJustifyV = Widgets.SettingsDropDown.Acquire(false, scenarioNameSection)
    scenarioNameTextJustifyV:SetLabel(L.TEXT_JUSITFY_V)
    scenarioNameTextJustifyV:SetEntries(TEXT_JUSTIFY_V_ENTRIES)
    scenarioNameTextJustifyV:BindUISetting("scenario.name.justifyV")
    self.TopInfoTabControls.scenarioNameTextJustifyV = scenarioNameTextJustifyV

    local scenarioNameTextJustifyH = Widgets.SettingsDropDown.Acquire(false, scenarioNameSection)
    scenarioNameTextJustifyH:SetID(50)
    scenarioNameTextJustifyH:SetLabel(L.TEXT_JUSITFY_H)
    scenarioNameTextJustifyH:SetEntries(TEXT_JUSTIFY_H_ENTRIES)
    scenarioNameTextJustifyH:BindUISetting("scenario.name.justifyH")
    self.TopInfoTabControls.scenarioNameTextJustifyH = scenarioNameTextJustifyH
    ---------------------------------------------------------------------------
    --- Stage Section
    ---------------------------------------------------------------------------
    local stageSection = Widgets.ExpandableSection.Acquire(false, self)
    stageSection:SetExpanded(false)
    stageSection:SetID(60)
    stageSection:SetTitle(L.SCENARIO_STAGE)
    self.TopInfoTabControls.stageSection = stageSection
    ---------------------------------------------------------------------------
    --- Stage Sub Section
    ---------------------------------------------------------------------------
    local stageTabControl = Widgets.TabControl.Acquire(false, stageSection)
    stageTabControl:SetID(10)
    stageTabControl:AddTabPage({
      name = L.NAME,
      onAcquire = function()
        local font = Widgets.SettingsMediaFont.Acquire(false, stageTabControl)
        font:SetID(10)
        font:BindUISetting("scenario.stageName.mediaFont")
        self.StageNameTabControls.font = font

        local textTransform = Widgets.SettingsDropDown.Acquire(false, stageTabControl)
        textTransform:SetID(20)
        textTransform:SetLabel(L.TEXT_TRANSFORM)
        textTransform:SetEntries(TEXT_TRANSFORM_ENTRIES)
        textTransform:BindUISetting("scenario.stageName.textTransform")
        self.StageNameTabControls.textTransform = textTransform    
      end,

      onRelease = function()
        for index, control in pairs(self.StageNameTabControls) do 
          control:Release()
          self.StageNameTabControls[index] = nil
        end
      end
    })

    stageTabControl:AddTabPage({
      name = L.COUNTER,
      onAcquire = function()
        local font = Widgets.SettingsMediaFont.Acquire(false, stageTabControl)
        font:SetID(10)
        font:BindUISetting("scenario.stageCounter.mediaFont")
        self.StageCounterTabControls.font = font

        local textTransform = Widgets.SettingsDropDown.Acquire(false, stageTabControl)
        textTransform:SetID(20)
        textTransform:SetLabel(L.TEXT_TRANSFORM)
        textTransform:SetEntries(TEXT_TRANSFORM_ENTRIES)
        textTransform:BindUISetting("scenario.stageCounter.textTransform")
        self.StageCounterTabControls.textTransform = textTransform    
      end,

      onRelease = function()
        for index, control in pairs(self.StageCounterTabControls) do 
          control:Release()
          self.StageCounterTabControls[index] = nil
        end
      end
    })

    stageTabControl:Refresh()
    stageTabControl:SelectTab(1)
    self.TopInfoTabControls.stageTabControl = stageTabControl
    -- ---------------------------------------------------------------------------
    -- --- Header Sub Sections
    -- ---------------------------------------------------------------------------
    -- local headertabControl = Widgets.TabControl.Acquire(false, headerSection)
    -- headertabControl:SetID(50)
    -- headertabControl:SetID(1)
    -- headertabControl:AddTabPage({
    --   name = "Title",
    --   onAcquire = function()  
    --     local font = Widgets.SettingsMediaFont.Acquire(false, headertabControl)
    --     font:SetID(10)
    --     font:BindUISetting("collectable.name.mediaFont")
    --     self.CollectableHeaderTitleTabControls.font = font

    --     local textTransform = Widgets.SettingsDropDown.Acquire(false, headertabControl)
    --     textTransform:SetID(20)
    --     textTransform:SetLabel("Text Transform")
    --     textTransform:SetEntries(TEXT_TRANSFORM_ENTRIES)
    --     textTransform:BindUISetting("collectable.name.textTransform")
    --     self.CollectableHeaderTitleTabControls.textTransform = textTransform
      
    --   end,
    --   onRelease = function()  
    --     for index, control in pairs(self.CollectableHeaderTitleTabControls) do 
    --         control:Release()
    --         self.CollectableHeaderTitleTabControls[index] = nil
    --     end
    --   end,
    -- })
    -- headertabControl:Refresh()
    -- headertabControl:SelectTab(1)
    -- self.CollectableTabControls.headertabControl = headertabControl
  end
  -----------------------------------------------------------------------------
  --                        [TopInfo] Release Builder                        --
  -----------------------------------------------------------------------------
  function ReleaseTopInfoTab(self)
    for index, control in pairs(self.TopInfoTabControls) do 
      control:Release()
      self.TopInfoTabControls[index] = nil
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
      name = L.TOP_INFO,
      onAcquire = function() self:BuildTopInfoTab() end,
      onRelease = function() self:ReleaseTopInfoTab() end,
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
    self:ReleaseTopInfoTab()
    
    for index, control in pairs(self.StageNameTabControls) do 
      control:Release()
      self.StageNameTabControls[index] = nil
    end

    for index, control in pairs(self.StageCounterTabControls) do 
      control:Release()
      self.StageCounterTabControls[index] = nil
    end
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

  property "TopInfoTabControls" {
    set = false,
    default = function() return newtable(false, true) end
  }

  property "StageNameTabControls" {
    set = false, 
    default = function() return newtable(false, true) end 
  }

  property "StageCounterTabControls" {
    set = false,
    default = function() return newtable(false, true) end 
  }

end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [SettingDefinitions.Scenario] = {
    height        = 1,
    layoutManager = Layout.VerticalLayoutManager(true, true)
  }
})