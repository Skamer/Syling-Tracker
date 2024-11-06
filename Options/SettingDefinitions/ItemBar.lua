-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling          "SylingTracker_Options.SettingDefinitions.ItemBar"           ""
-- ========================================================================= --
export {
  L                             = _Locale,
  newtable                      = Toolset.newtable,
  GetItemBarSetting             = SylingTracker.API.GetItemBarSetting,
  GetItemBarSettingWithDefault  = SylingTracker.API.GetItemBarSettingWithDefault,
  SetItemBarSetting             = SylingTracker.API.SetItemBarSetting
}

__Widget__()
class "SettingDefinitions.ItemBar" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                   [General] Tab Builder                                 --
  -----------------------------------------------------------------------------
  _ORIENTATION_ENTRIES = Array[Widgets.EntryData]()
  _ORIENTATION_ENTRIES:Insert({ text = L.VERTICAL, value = Orientation.VERTICAL})
  _ORIENTATION_ENTRIES:Insert({ text = L.HORIZONTAL, value = Orientation.HORIZONTAL})

  function BuildGeneralTab(self)
    ---------------------------------------------------------------------------
    --- Enable
    ---------------------------------------------------------------------------
    local enableCheckBox = Widgets.SettingsCheckBox.Acquire(false, self)
    enableCheckBox:SetID(10)
    enableCheckBox:SetLabel(L.ENABLE)
    enableCheckBox:BindItemBarSetting("enabled")
    self.GeneralTabControls.enableCheckBox = enableCheckBox
    ---------------------------------------------------------------------------
    --- Lock
    ---------------------------------------------------------------------------
    local lockCheckBox = Widgets.SettingsCheckBox.Acquire(false, self)
    lockCheckBox:SetID(20)
    lockCheckBox:SetLabel(L.LOCK)
    lockCheckBox:BindItemBarSetting("locked")
    self.GeneralTabControls.lockCheckBox = lockCheckBox
    ---------------------------------------------------------------------------
    --- Column Count
    ---------------------------------------------------------------------------
    local columnCountSlider = Widgets.SettingsSlider.Acquire(false, self)
    columnCountSlider:SetID(30)
    columnCountSlider:SetLabel(L.COLUMN_COUNT)
    columnCountSlider:SetMinMaxValues(1, 12)
    columnCountSlider:BindItemBarSetting("columnCount")
    self.GeneralTabControls.columnCountSlider = columnCountSlider
    ---------------------------------------------------------------------------
    --- Row Count
    ---------------------------------------------------------------------------    
    local rowCountSlider = Widgets.SettingsSlider.Acquire(false, self)
    rowCountSlider:SetID(40)
    rowCountSlider:SetLabel(L.ROW_COUNT)
    rowCountSlider:SetMinMaxValues(1, 12)
    rowCountSlider:BindItemBarSetting("rowCount")
    self.GeneralTabControls.rowCountSlider = rowCountSlider
    ---------------------------------------------------------------------------
    --- Margin Left
    ---------------------------------------------------------------------------
    local marginLeftSlider = Widgets.SettingsSlider.Acquire(false, self)
    marginLeftSlider:SetID(50)
    marginLeftSlider:SetLabel(L.MARGIN_LEFT)
    marginLeftSlider:SetMinMaxValues(0, 50)
    marginLeftSlider:BindItemBarSetting("marginLeft")
    self.GeneralTabControls.marginLeftSlider = marginLeftSlider
    ---------------------------------------------------------------------------
    --- Margin Right
    ---------------------------------------------------------------------------    
    local marginRightSlider = Widgets.SettingsSlider.Acquire(false, self)
    marginRightSlider:SetID(60)
    marginRightSlider:SetLabel(L.MARGIN_RIGHT)
    marginRightSlider:SetMinMaxValues(0, 50)
    marginRightSlider:BindItemBarSetting("marginRight")
    self.GeneralTabControls.marginRightSlider = marginRightSlider
    ---------------------------------------------------------------------------
    --- Margin Top
    ---------------------------------------------------------------------------
    local marginTopSlider = Widgets.SettingsSlider.Acquire(false, self)
    marginTopSlider:SetID(70)
    marginTopSlider:SetLabel(L.MARGIN_TOP)
    marginTopSlider:SetMinMaxValues(0, 50)
    marginTopSlider:BindItemBarSetting("marginTop")
    self.GeneralTabControls.marginTopSlider = marginTopSlider
    ---------------------------------------------------------------------------
    --- Margin Bottom
    ---------------------------------------------------------------------------
    local marginBottomSlider = Widgets.SettingsSlider.Acquire(false, self)
    marginBottomSlider:SetID(80)
    marginBottomSlider:SetLabel(L.MARGIN_BOTTOM)
    marginBottomSlider:BindItemBarSetting("marginBottom")
    marginBottomSlider:SetMinMaxValues(0, 50)
    self.GeneralTabControls.marginBottomSlider = marginBottomSlider
    ---------------------------------------------------------------------------
    --- Orientation
    ---------------------------------------------------------------------------
    local orientationDropDown = Widgets.SettingsDropDown.Acquire(false, self)
    orientationDropDown:SetID(90)
    orientationDropDown:SetLabel(L.ORIENTATION)
    orientationDropDown:SetEntries(_ORIENTATION_ENTRIES)
    orientationDropDown:BindItemBarSetting("orientation")
    self.GeneralTabControls.orientationDropDown = orientationDropDown
    ---------------------------------------------------------------------------
    --- Left to Right
    ---------------------------------------------------------------------------
    local leftToRightCheckBox = Widgets.SettingsCheckBox.Acquire(false, self)
    leftToRightCheckBox:SetID(100)
    leftToRightCheckBox:SetLabel(L.LEFT_TO_RIGHT)
    leftToRightCheckBox:BindItemBarSetting("leftToRight")
    self.GeneralTabControls.leftToRightCheckBox = leftToRightCheckBox
    ---------------------------------------------------------------------------
    --- Top to Bottom
    ---------------------------------------------------------------------------
    local topToBottomCheckBox = Widgets.SettingsCheckBox.Acquire(false, self)
    topToBottomCheckBox:SetID(110)
    topToBottomCheckBox:SetLabel(L.TOP_TO_BOTTOM)
    topToBottomCheckBox:BindItemBarSetting("topToBottom")
    self.GeneralTabControls.topToBottomCheckBox = topToBottomCheckBox
    ---------------------------------------------------------------------------
    --- Sort by Distance
    ---------------------------------------------------------------------------
    local sortByDistanceCheckBox = Widgets.SettingsCheckBox.Acquire(false, self)
    sortByDistanceCheckBox:SetID(120)
    sortByDistanceCheckBox:SetLabel(L.SORT_BY_DISTANCE)
    self.GeneralTabControls.sortByDistanceCheckBox = sortByDistanceCheckBox
    ---------------------------------------------------------------------------
    --- Background Section
    ---------------------------------------------------------------------------
    local backgroundSection = Widgets.ExpandableSection.Acquire(false, self)
    backgroundSection:SetExpanded(false)
    backgroundSection:SetID(130)
    backgroundSection:SetTitle(L.BACKGROUND)
    Style[backgroundSection].marginTop = 10
    self.GeneralTabControls.backgroundSection = backgroundSection

    local showBackgroundCheckBox = Widgets.SettingsCheckBox.Acquire(false, backgroundSection)
    showBackgroundCheckBox:SetID(10)
    showBackgroundCheckBox:SetLabel(L.SHOW)
    showBackgroundCheckBox:BindItemBarSetting("showBackground")
    self.GeneralTabControls.showBackgroundCheckBox = showBackgroundCheckBox

    local backgroundColorPicker = Widgets.SettingsColorPicker.Acquire(false, backgroundSection)
    backgroundColorPicker:SetID(20)
    backgroundColorPicker:SetLabel(L.COLOR)
    backgroundColorPicker:BindItemBarSetting("backgroundColor")
    self.GeneralTabControls.backgroundColorPicker = backgroundColorPicker
    ---------------------------------------------------------------------------
    --- Border Section
    ---------------------------------------------------------------------------
    local borderSection = Widgets.ExpandableSection.Acquire(false, self)
    borderSection:SetExpanded(false)
    borderSection:SetID(140)
    borderSection:SetTitle(L.BORDER)
    self.GeneralTabControls.borderSection = borderSection

    local showBorderCheckBox = Widgets.SettingsCheckBox.Acquire(false, borderSection)
    showBorderCheckBox:SetID(10)
    showBorderCheckBox:SetLabel(L.SHOW)
    showBorderCheckBox:BindItemBarSetting("showBorder")
    self.GeneralTabControls.showBorderCheckBox = showBorderCheckBox

    local borderColorPicker = Widgets.SettingsColorPicker.Acquire(false, borderSection)
    borderColorPicker:SetID(20)
    borderColorPicker:SetLabel(L.COLOR)
    borderColorPicker:BindItemBarSetting("borderColor")
    self.GeneralTabControls.borderColorPicker = borderColorPicker

    local borderSizeSlider = Widgets.SettingsSlider.Acquire(false, borderSection)
    borderSizeSlider:SetID(30)
    borderSizeSlider:SetLabel(L.SIZE)
    borderSizeSlider:SetMinMaxValues(1, 10)
    borderSizeSlider:BindItemBarSetting("borderSize")
    self.GeneralTabControls.borderSizeSlider = borderSizeSlider
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
  --                   [Item] Tab Builder                                --
  -----------------------------------------------------------------------------
  function BuildItemTab(self)
    local widthSlider = Widgets.SettingsSlider.Acquire(false, self)
    widthSlider:SetID(10)
    widthSlider:SetLabel(L.WIDTH)
    widthSlider:SetMinMaxValues(6, 92)
    widthSlider:BindItemBarSetting("elementWidth")
    self.ItemTabControls.widthSlider = widthSlider
    
    local heightSlider = Widgets.SettingsSlider.Acquire(false, self)
    heightSlider:SetID(20)
    heightSlider:SetLabel(L.HEIGHT)
    heightSlider:SetMinMaxValues(6, 92)
    heightSlider:BindItemBarSetting("elementHeight")
    self.ItemTabControls.heightSlider = heightSlider

    local hSpacingSlider = Widgets.SettingsSlider.Acquire(false, self)
    hSpacingSlider:SetID(30)
    hSpacingSlider:SetLabel(L.HORIZONTAL_SPACING)
    hSpacingSlider:SetMinMaxValues(0, 24)
    hSpacingSlider:BindItemBarSetting("hSpacing")
    self.ItemTabControls.hSpacingSlider = hSpacingSlider
    
    local vSpacingSlider = Widgets.SettingsSlider.Acquire(false, self)
    vSpacingSlider:SetID(40)
    vSpacingSlider:SetLabel(L.VERTICAL_SPACING)
    vSpacingSlider:SetMinMaxValues(0, 24)
    vSpacingSlider:BindItemBarSetting("vSpacing")
    self.ItemTabControls.vSpacingSlider = vSpacingSlider
  end
  -----------------------------------------------------------------------------
  --                    [Item] Tab Release                                --
  -----------------------------------------------------------------------------
  function ReleaseItemTab(self)
    for index, control in pairs(self.ItemTabControls) do 
      control:Release()
      self.ItemTabControls[index] = nil
    end
  end
  -----------------------------------------------------------------------------
  --                 [Visibility Rules] Tab Builder                          --
  -----------------------------------------------------------------------------
  -- hide     -> say explicitely the tracker must be hidden.
  -- show     -> say explicitely the tracker must be shown.
  -- default  -> say to take the default value.
  -- ignore   -> say to ignore this condition, and check the next one.
  _ENTRIES_CONDITIONS_DROPDOWN = Array[Widgets.EntryData]()
  _ENTRIES_CONDITIONS_DROPDOWN:Insert({ text = ("|cffff0000%s|r"):format(L.HIDE), value = "hide"})
  _ENTRIES_CONDITIONS_DROPDOWN:Insert({ text = ("|cff00ff00%s|r"):format(L.SHOW), value = "show"})
  _ENTRIES_CONDITIONS_DROPDOWN:Insert({ text = L.DEFAULT, value = "default"})
  _ENTRIES_CONDITIONS_DROPDOWN:Insert({ text = L.IGNORE, value = "ignore"})

  -- Contains below the info for every instance or group size condition option to 
  -- build 
  _INSTANCE_VISIBILITY_ROWS_INFO = {
    [1] = { label = L.DUNGEON, setting = "inDungeonVisibility" },
    [2] = { label = L.KEYSTONE, setting = "inKeystoneVisibility"},
    [3] = { label = L.RAID, setting = "inRaidVisibility"}, 
    [4] = { label = L.SCENARIO, setting = "inScenarioVisibility"},
    [5] = { label = L.ARENA, setting = "inArenaVisibility"},
    [6] = { label = L.BATTLEGROUND, setting = "inBattlegroundVisibility"}
  }

  _GROUP_SIZE_VISIBILITY_ROWS_INFO = {
    [1] = { label = L.PARTY, setting = "inPartyVisibility"},
    [2] = { label = L.RAID_GROUP, setting = "inRaidGroupVisibility" }
  }

  function BuildVisibilityRulesTab(self)
    ---------------------------------------------------------------------------
    ---  Default Visibility
    ---------------------------------------------------------------------------
    local defaultVisibilityDropDown = Widgets.SettingsDropDown.Acquire(false, self)
    defaultVisibilityDropDown:SetID(10)
    defaultVisibilityDropDown:SetLabel(L.DEFAULT_VISIBILITY)
    defaultVisibilityDropDown:AddEntry({ text = ("|cffff0000%s|r"):format(L.HIDDEN), value = "hide"})
    defaultVisibilityDropDown:AddEntry({ text = ("|cff00ff00%s|r"):format(L.SHOW), value = "show"})
    defaultVisibilityDropDown:BindItemBarSetting("visibilityRules", "defaultVisibility")
    self.VisibilityRulesControls.defaultVisibilityDropDown = defaultVisibilityDropDown
    ---------------------------------------------------------------------------
    ---  Hide when empty
    ---------------------------------------------------------------------------
    -- local hideWhenEmptyCheckBox = Widgets.SettingsCheckBox.Acquire(false, self)
    -- hideWhenEmptyCheckBox:SetID(20)
    -- hideWhenEmptyCheckBox:SetLabel("Hide when empty")
    -- hideWhenEmptyCheckBox:BindItemBarSetting("visibilityRules", "hideWhenEmpty")
    -- self.VisibilityRulesControls.hideWhenEmptyCheckBox = hideWhenEmptyCheckBox
    ---------------------------------------------------------------------------
    ---  Advanced Rules
    ---------------------------------------------------------------------------
    local advancedRulesSection = Widgets.SettingsExpandableSection.Acquire(false, self)
    advancedRulesSection:SetID(30)
    advancedRulesSection:SetTitle(L.ADVANCED_RULES)
    self.VisibilityRulesControls.advancedRulesSection = advancedRulesSection
    ---------------------------------------------------------------------------
    ---  Enable Advanced Rules
    ---------------------------------------------------------------------------
    local enableAdvancedRulesCheckBox = Widgets.SettingsCheckBox.Acquire(false, advancedRulesSection)
    enableAdvancedRulesCheckBox:SetID(10)
    enableAdvancedRulesCheckBox:SetLabel(L.ENABLE)
    enableAdvancedRulesCheckBox:BindItemBarSetting("visibilityRules", "enableAdvancedRules")
    self.VisibilityRulesControls.enableAdvancedRulesCheckBox = enableAdvancedRulesCheckBox
    ---------------------------------------------------------------------------
    ---  Instance Visibility
    ---------------------------------------------------------------------------
    local instanceConditionHeader = Widgets.SettingsSectionHeader.Acquire(false, advancedRulesSection)
    instanceConditionHeader:SetID(100)
    instanceConditionHeader:SetTitle(L.INSTANCE)
    self.VisibilityRulesControls.instanceConditionHeader = instanceConditionHeader
    
    for index, info in ipairs(_INSTANCE_VISIBILITY_ROWS_INFO) do 
      local dropDownControl = Widgets.SettingsDropDown.Acquire(false, advancedRulesSection)
      dropDownControl:SetID(100 + 10 * index)
      dropDownControl:SetLabel(info.label)
      dropDownControl:SetEntries(_ENTRIES_CONDITIONS_DROPDOWN)
      dropDownControl:BindItemBarSetting("visibilityRules", info.setting)
      Style[dropDownControl].marginLeft = 20
      self.VisibilityRulesControls[dropDownControl] = dropDownControl    
    end
    ---------------------------------------------------------------------------
    ---  Group Size Visibility
    ---------------------------------------------------------------------------
    local groupSizeConditionsHeader = Widgets.SettingsSectionHeader.Acquire(false, advancedRulesSection)
    groupSizeConditionsHeader:SetID(200)
    groupSizeConditionsHeader:SetTitle(L.GROUP_SIZE)
    self.VisibilityRulesControls.groupSizeConditionsHeader = groupSizeConditionsHeader

    for index, info in ipairs(_GROUP_SIZE_VISIBILITY_ROWS_INFO) do 
      local dropDownControl = Widgets.SettingsDropDown.Acquire(false, advancedRulesSection)
      dropDownControl:SetID(200 + 10 * index)
      dropDownControl:SetLabel(info.label)
      dropDownControl:SetEntries(_ENTRIES_CONDITIONS_DROPDOWN)
      dropDownControl:BindItemBarSetting("visibilityRules", info.setting)
      Style[dropDownControl].marginLeft = 20
      self.VisibilityRulesControls[dropDownControl] = dropDownControl
    end
    ---------------------------------------------------------------------------
    ---  Macro Visibility
    ---------------------------------------------------------------------------
    local macroConditionsHeader = Widgets.SettingsSectionHeader.Acquire(false, advancedRulesSection)
    macroConditionsHeader:SetID(300)
    macroConditionsHeader:SetTitle(L.MACRO)
    self.VisibilityRulesControls.macroConditionsHeader = macroConditionsHeader
    ---------------------------------------------------------------------------
    --- Macro -> Evaluate Macro At First
    ---------------------------------------------------------------------------
    local evaluateMacroAtFirstCheckBox = Widgets.SettingsCheckBox.Acquire(false, advancedRulesSection)
    evaluateMacroAtFirstCheckBox:SetID(310)
    evaluateMacroAtFirstCheckBox:SetLabel(L.EVALUATE_MACRO_FIRST)
    evaluateMacroAtFirstCheckBox:BindItemBarSetting("visibilityRules", "evaluateMacroVisibilityAtFirst")
    Style[evaluateMacroAtFirstCheckBox].marginLeft = 20
    self.VisibilityRulesControls.evaluateMacroAtFirstCheckBox = evaluateMacroAtFirstCheckBox
    ---------------------------------------------------------------------------
    --- Macro -> Macro Visibility Text
    ---------------------------------------------------------------------------
    local function OnMacroTextEnterPressed(editBox)
      local value = editBox:GetText()
      editBox:ClearFocus()
      SetItemBarSetting("visibilityRules", value, nil, "macroVisibility")
    end

    local function OnMacroTextEscapePressed(editBox)
      editBox:ClearFocus()
    end

    local macroTextEditBox = Widgets.MultiLineEditBox.Acquire(false, advancedRulesSection)
    macroTextEditBox:SetID(320)
    macroTextEditBox:SetInstructions("[combat] hide; show")
    macroTextEditBox:SetText(GetItemBarSettingWithDefault("visibilityRules", "macroVisibility"))
    macroTextEditBox:SetUserHandler("OnEnterPressed", OnMacroTextEnterPressed)
    macroTextEditBox:SetUserHandler("OnEscapePressed", OnMacroTextEscapePressed)
    Style[macroTextEditBox].marginLeft   = 20 
    Style[macroTextEditBox].marginRight  = 0
    self.VisibilityRulesControls.macroTextEditBox = macroTextEditBox  
  end
  -----------------------------------------------------------------------------
  --                 [Visibility Rules] Tab Release                          --
  -----------------------------------------------------------------------------
  function ReleaseVisibilityRulesTab(self)
    for index, control in pairs(self.VisibilityRulesControls) do 
      control:Release()
      self.VisibilityRulesControls[index] = nil
    end
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function BuildSettingControls(self)
    local tabControl = Widgets.TabControl.Acquire(false, self)
    tabControl:SetID(1)
    tabControl:AddTabPage({
      name = L.GENERAL,
      onAcquire = function() self:BuildGeneralTab() end,
      onRelease = function() self:ReleaseGeneralTab() end, 
    })

    tabControl:AddTabPage({
      name = L.ITEM,
      onAcquire = function() self:BuildItemTab() end,
      onRelease = function() self:ReleaseItemTab() end 
    })

    tabControl:AddTabPage({
      name = L.VISIBILITY_RULES,
      onAcquire = function() self:BuildVisibilityRulesTab() end,
      onRelease = function() self:ReleaseVisibilityRulesTab() end
    })

    tabControl:Refresh()
    tabControl:SelectTab(1)

    self.SettingControls.tabControl = tabControl
  end

  function ReleaseSettingControls(self)
    self.SettingControls.tabControl:Release()
    self.SettingControls.tabControl = nil
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

  property "ItemTabControls" {
    set = false, 
    default = function() return newtable(false, true) end
  }

  property "VisibilityRulesControls" {
    set = false,
    default = function() return newtable(false, true) end
  }
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [SettingDefinitions.ItemBar] = {
    height = 1,
    layoutManager = Layout.VerticalLayoutManager(true, true),
  },
})