-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling         "SylingTracker_Options.SettingDefinitions.Dungeon"            ""
-- ========================================================================= --
export {
  L                                   = _Locale,
  newtable                            = Toolset.newtable
}

__Widget__()
class "SettingDefinitions.Dungeon" (function(_ENV)
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
    showHeaderCheckBox:BindUISetting("dungeon.showHeader")
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
    showBackgroundCheckBox:BindUISetting("dungeon.header.showBackground")
    self.HeaderTabControls.showBackgroundCheckBox = showBackgroundCheckBox

    local backgroundColorPicker = Widgets.SettingsColorPicker.Acquire(false, backgroundSection)
    backgroundColorPicker:SetID(20)
    backgroundColorPicker:SetLabel(L.COLOR)
    backgroundColorPicker:BindUISetting("dungeon.header.backgroundColor")
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
    showBorderCheckBox:BindUISetting("dungeon.header.showBorder")
    self.HeaderTabControls.showBorderCheckBox = showBorderCheckBox

    local borderColorPicker = Widgets.SettingsColorPicker.Acquire(false, borderSection)
    borderColorPicker:SetID(20)
    borderColorPicker:SetLabel(L.COLOR)
    borderColorPicker:BindUISetting("dungeon.header.borderColor")
    self.HeaderTabControls.borderColorPicker = borderColorPicker

    local borderSizeSlider = Widgets.SettingsSlider.Acquire(false, borderSection)
    borderSizeSlider:SetID(30)
    borderSizeSlider:SetLabel(L.SIZE)
    borderSizeSlider:SetMinMaxValues(1, 10)
    borderSizeSlider:BindUISetting("dungeon.header.borderSize")
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
    titleFont:BindUISetting("dungeon.header.label.mediaFont")
    self.HeaderTabControls.titleFont = titleFont

    local textColorPicker = Widgets.SettingsColorPicker.Acquire(false, titleSection)
    textColorPicker:SetID(20)
    textColorPicker:SetLabel(L.TEXT_COLOR)
    textColorPicker:BindUISetting("dungeon.header.label.textColor")
    self.HeaderTabControls.textColorPicker = textColorPicker

    local textTransform = Widgets.SettingsDropDown.Acquire(false, titleSection)
    textTransform:SetID(30)
    textTransform:SetLabel(L.TEXT_TRANSFORM)
    textTransform:SetEntries(TEXT_TRANSFORM_ENTRIES)
    textTransform:BindUISetting("dungeon.header.label.textTransform")
    self.HeaderTabControls.textTransform = textTransform

    local textJustifyV = Widgets.SettingsDropDown.Acquire(false, titleSection)
    textJustifyV:SetID(40)
    textJustifyV:SetLabel(L.TEXT_JUSITFY_V)
    textJustifyV:SetEntries(TEXT_JUSTIFY_V_ENTRIES)
    textJustifyV:BindUISetting("dungeon.header.label.justifyV")
    self.HeaderTabControls.textJustifyV = textJustifyV

    local textJustifyH = Widgets.SettingsDropDown.Acquire(false, titleSection)
    textJustifyH:SetID(50)
    textJustifyH:SetLabel(L.TEXT_JUSITFY_H)
    textJustifyH:SetEntries(TEXT_JUSTIFY_H_ENTRIES)
    textJustifyH:BindUISetting("dungeon.header.label.justifyH")
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
    --- Dungeon Name Section
    ---------------------------------------------------------------------------
    local dungeonNameSection = Widgets.ExpandableSection.Acquire(false, self)
    dungeonNameSection:SetExpanded(false)
    dungeonNameSection:SetID(50)
    dungeonNameSection:SetTitle(L.DUNGEON_NAME)
    self.TopInfoTabControls.dungeonNameSection = dungeonNameSection

    local dungeonNameFont = Widgets.SettingsMediaFont.Acquire(false, dungeonNameSection)
    dungeonNameFont:SetID(10)
    dungeonNameFont:BindUISetting("dungeon.name.mediaFont")
    self.TopInfoTabControls.dungeonNameFont = dungeonNameFont

    local dungeonNameTextColorPicker = Widgets.SettingsColorPicker.Acquire(false, dungeonNameSection)
    dungeonNameTextColorPicker:SetID(20)
    dungeonNameTextColorPicker:SetLabel(L.TEXT_COLOR)
    dungeonNameTextColorPicker:BindUISetting("dungeon.name.textColor")
    self.TopInfoTabControls.dungeonNameTextColorPicker = dungeonNameTextColorPicker

    local dungeonNameTextTransform = Widgets.SettingsDropDown.Acquire(false, dungeonNameSection)
    dungeonNameTextTransform:SetID(30)
    dungeonNameTextTransform:SetLabel(L.TEXT_TRANSFORM)
    dungeonNameTextTransform:SetEntries(TEXT_TRANSFORM_ENTRIES)
    dungeonNameTextTransform:BindUISetting("dungeon.name.textTransform")
    self.TopInfoTabControls.dungeonNameTextTransform = dungeonNameTextTransform

    local dungeonNameTextJustifyV = Widgets.SettingsDropDown.Acquire(false, dungeonNameSection)
    dungeonNameTextJustifyV:SetLabel(L.TEXT_JUSITFY_V)
    dungeonNameTextJustifyV:SetEntries(TEXT_JUSTIFY_V_ENTRIES)
    dungeonNameTextJustifyV:BindUISetting("dungeon.name.justifyV")
    self.TopInfoTabControls.dungeonNameTextJustifyV = dungeonNameTextJustifyV

    local dungeonNameTextJustifyH = Widgets.SettingsDropDown.Acquire(false, dungeonNameSection)
    dungeonNameTextJustifyH:SetID(50)
    dungeonNameTextJustifyH:SetLabel(L.TEXT_JUSITFY_H)
    dungeonNameTextJustifyH:SetEntries(TEXT_JUSTIFY_H_ENTRIES)
    dungeonNameTextJustifyH:BindUISetting("dungeon.name.justifyH")
    self.TopInfoTabControls.dungeonNameTextJustifyH = dungeonNameTextJustifyH
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
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [SettingDefinitions.Dungeon] = {
    height        = 1,
    layoutManager = Layout.VerticalLayoutManager(true, true)
  }
})