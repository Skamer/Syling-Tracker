-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling          "SylingTracker_Options.SettingDefinitions.Trackers"          ""
-- ========================================================================= --
export {
  L                             = _Locale,
  newtable                      = Toolset.newtable,
  IterateContents               = SylingTracker.API.IterateContents,
  NewTracker                    = SylingTracker.API.NewTracker,
  DeleteTracker                 = SylingTracker.API.DeleteTracker,
  GetTracker                    = SylingTracker.API.GetTracker,
  SetContentTracked             = SylingTracker.API.SetContentTracked,
  GetTrackerSetting             = SylingTracker.API.GetTrackerSetting,
  GetTrackerSettingWithDefault  = SylingTracker.API.GetTrackerSettingWithDefault,
  SetTrackerSetting             = SylingTracker.API.SetTrackerSetting
}

__Widget__()
class "SettingDefinitions.CreateTracker" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function BuildSettingControls(self)
    --- We wipe the content tracked in case the user has already create a tracker.
    --- The reason this is done here instead in the "OnRelease" method, 
    --- this is because there an issue where the data would be wiped too early 
    --- before the tracker tracks the content chosen if it's done in "OnRelease"
    wipe(self.ContentsTracked)

    ---------------------------------------------------------------------------
    --- Tracker Name 
    ---------------------------------------------------------------------------
    local trackerNameEditBox = Widgets.SettingsEditBox.Acquire(false, self)
    trackerNameEditBox:SetID(10)
    trackerNameEditBox:SetLabel(L.TRACKER_NAME)
    trackerNameEditBox:SetInstructions(L.TRACKER_ENTER_NAME)
    self.SettingControls.trackerNameEditBox = trackerNameEditBox
    ---------------------------------------------------------------------------
    --- Contents Tracked Section Header 
    ---------------------------------------------------------------------------
    local contentsTrackedSectionHeader = Widgets.SettingsSectionHeader.Acquire(false, self)
    contentsTrackedSectionHeader:SetID(20)
    contentsTrackedSectionHeader:SetTitle(L.CONTENTS_TRACKED)
    self.SettingControls.contentsTrackedSectionHeader = contentsTrackedSectionHeader
    ---------------------------------------------------------------------------
    --- Contents Controls 
    ---------------------------------------------------------------------------
    local function OnContentCheckBoxClick(checkBox)
      local contentID = checkBox:GetUserData("contentID")
      local isTracked = checkBox:IsChecked() 
      self.ContentsTracked[contentID] = isTracked
    end

    for index, content in List(IterateContents()):Sort("x,y=>x.Name<y.Name"):GetIterator() do
      local contentCheckBox = Widgets.SettingsCheckBox.Acquire(false, self)
      contentCheckBox:SetID(30 * index)
      contentCheckBox:SetLabel(content.FormattedName)
      contentCheckBox:SetChecked(false)
      contentCheckBox:SetUserData("contentID", content.id)
      contentCheckBox:SetUserHandler("OnCheckBoxClick", OnContentCheckBoxClick)

      self.SettingControls[contentCheckBox] = contentCheckBox
    end
      ---------------------------------------------------------------------------
    --- Create Button
    ---------------------------------------------------------------------------
    local function OnCreateButtonClick(button)
      local trackerName = trackerNameEditBox:GetValue()
      if trackerName and trackerName ~= "" then 
        local tracker = NewTracker(trackerName)
        --- We put TrackContentType in a thread for avoiding small freeze for low end 
        --- computer users if there many content tracked, and these ones need to 
        --- create lof of frame.
        Scorpio.Continue(function()
          for contentID, isTracked in pairs(self.ContentsTracked) do
            -- SetContentTracked(tracker, contentID, isTracked)
            SetTrackerSetting(trackerName, "contentsTracked", isTracked, nil, contentID)
            Scorpio.Next()
          end
        end)
      end
    end

    local createButton = Widgets.SuccessPushButton.Acquire(false, self)
    createButton:SetText(L.CREATE)
    createButton:SetPoint("BOTTOM")
    createButton:SetID(9999)
    Style[createButton].marginLeft = 0.35
    createButton:SetUserHandler("OnClick", OnCreateButtonClick)
    self.SettingControls.createButton = createButton
  end

  function ReleaseSettingControls(self)
    --- Release the widgets 
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
    default = function() return Toolset.newtable(false, true) end 
  }

  property "ContentsTracked" {
    set = false,
    default = {}
  }
end)

__Widget__()
class "SettingDefinitions.Tracker" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                   [General] Tab Builder                                 --
  -----------------------------------------------------------------------------
  function BuildGeneralTab(self)
    local trackerID = self.TrackerID
    ---------------------------------------------------------------------------
    --- Enable Tracker
    ---------------------------------------------------------------------------
    local enableTrackerCheckBox = Widgets.SettingsCheckBox.Acquire(false, self)
    enableTrackerCheckBox:SetID(10)
    enableTrackerCheckBox:SetLabel(L.ENABLE)
    enableTrackerCheckBox:BindTrackerSetting(trackerID, "enabled")
    self.GeneralTabControls.enableTrackerCheckBox = enableTrackerCheckBox
    ---------------------------------------------------------------------------
    --- Lock Tracker
    ---------------------------------------------------------------------------
    local lockTrackerCkeckBox = Widgets.SettingsCheckBox.Acquire(false, self)
    lockTrackerCkeckBox:SetID(20)
    lockTrackerCkeckBox:SetLabel(L.LOCK)
    lockTrackerCkeckBox:BindTrackerSetting(trackerID, "locked")
    self.GeneralTabControls.lockTrackerCkeckBox = lockTrackerCkeckBox
    ---------------------------------------------------------------------------
    --- Scale Tracker
    ---------------------------------------------------------------------------
    local scaleSlider = Widgets.SettingsSlider.Acquire(false, self)
    scaleSlider:SetID(30)
    scaleSlider:SetLabel(L.SCALE)
    scaleSlider:SetValueStep(0.01)
    scaleSlider:SetMinMaxValues(0.8, 1.5)
    scaleSlider:BindTrackerSetting(trackerID, "scale")
    self.GeneralTabControls.scaleSlider = scaleSlider
    ---------------------------------------------------------------------------
    --- Size Section
    ---------------------------------------------------------------------------
    local sizeSection = Widgets.SettingsExpandableSection.Acquire(false, self)
    sizeSection:SetExpanded(false)
    sizeSection:SetID(40)
    sizeSection:SetTitle(L.SIZE)
    self.GeneralTabControls.sizeSection = sizeSection
    
    local sizeSliders = Widgets.SettingsSize.Acquire(true, sizeSection)
    local screenWidth = floor(GetScreenWidth() + 0.5)
    local screenHeight = floor(GetScreenHeight() + 0.5)

    sizeSliders:SetID(10)
    sizeSliders:SetMinMaxValues(100, max(screenWidth, screenHeight))
    sizeSliders:BindTrackerSetting(trackerID, "size")
    self.GeneralTabControls.sizeSliders = sizeSliders
    ---------------------------------------------------------------------------
    --- Position Section
    ---------------------------------------------------------------------------
    local positionSection = Widgets.SettingsExpandableSection.Acquire(false, self)
    positionSection:SetExpanded(false)
    positionSection:SetID(60)
    positionSection:SetTitle(L.POSITION)
    self.GeneralTabControls.positionSection = positionSection
    
    local relativePositionAnchorDropDown = Widgets.SettingsFramePointPicker.Acquire(true, positionSection)
    relativePositionAnchorDropDown:SetID(10)
    relativePositionAnchorDropDown:SetText(L.TO_SCREEN)
    relativePositionAnchorDropDown:DisablePoint("CENTER")
    relativePositionAnchorDropDown:BindTrackerSetting(trackerID, "relativePositionAnchor")
    self.GeneralTabControls.relativePositionAnchorDropDown = relativePositionAnchorDropDown

    local positionSliders = Widgets.SettingsPosition.Acquire(true, positionSection)
    local screenWidth = floor(GetScreenWidth() + 0.5)
    local screenHeight = floor(GetScreenHeight() + 0.5)

    positionSliders:SetID(20)
    positionSliders:SetXLabel(L.OFFSET_X)
    positionSliders:SetYLabel(L.OFFSET_Y)
    positionSliders:SetXMinMaxValues(-screenWidth, screenWidth)
    positionSliders:SetYMinMaxValues(-screenHeight, screenHeight)
    positionSliders:BindTrackerSetting(trackerID, "position")
    self.GeneralTabControls.positionSliders = positionSliders
    ---------------------------------------------------------------------------
    --- Show Minimise Button
    ---------------------------------------------------------------------------
    local minimizeButtonSection = Widgets.ExpandableSection.Acquire(false, self)
    minimizeButtonSection:SetExpanded(false)
    minimizeButtonSection:SetID(70)
    minimizeButtonSection:SetTitle(L.MINIMIZE_BUTTON)
    Style[minimizeButtonSection].marginTop = 10
    self.GeneralTabControls.minimizeButtonSection = minimizeButtonSection

    local showMinimizeButtonCkeckBox = Widgets.SettingsCheckBox.Acquire(false, minimizeButtonSection)
    showMinimizeButtonCkeckBox:SetID(10)
    showMinimizeButtonCkeckBox:SetLabel(L.SHOW_MINIMIZE_BUTTON)
    showMinimizeButtonCkeckBox:BindTrackerSetting(trackerID, "showMinimizeButton")
    self.GeneralTabControls.showMinimizeButtonCkeckBox = showMinimizeButtonCkeckBox

    local minimizeButtonPositionSection = Widgets.SettingsExpandableSection.Acquire(false, minimizeButtonSection)
    minimizeButtonPositionSection:SetExpanded(false)
    minimizeButtonPositionSection:SetID(60)
    minimizeButtonPositionSection:SetTitle(L.POSITION)
    self.GeneralTabControls.minimizeButtonPositionSection = minimizeButtonPositionSection

    local minimizeButtonFramePointPickerPosition = Widgets.SettingsFramePointPicker.Acquire(true, minimizeButtonPositionSection)
    minimizeButtonFramePointPickerPosition:SetID(10)
    minimizeButtonFramePointPickerPosition:SetText(L.TO_TRACKER)
    minimizeButtonFramePointPickerPosition:DisablePoint("CENTER")
    minimizeButtonFramePointPickerPosition:BindTrackerSetting(trackerID, "minimizeButtonPosition")
    self.GeneralTabControls.minimizeButtonFramePointPickerPosition = minimizeButtonFramePointPickerPosition

    local minimizeButtonPositionOffsetXSlider = Widgets.SettingsSlider.Acquire(false, minimizeButtonPositionSection)
    minimizeButtonPositionOffsetXSlider:SetID(20)
    minimizeButtonPositionOffsetXSlider:SetLabel(L.OFFSET_X)
    minimizeButtonPositionOffsetXSlider:SetValueStep(1)
    minimizeButtonPositionOffsetXSlider:SetMinMaxValues(-50, 50)
    minimizeButtonPositionOffsetXSlider:BindTrackerSetting(trackerID, "minimizeButtonPositionOffsetX")
    self.GeneralTabControls.minimizeButtonPositionOffsetXSlider = minimizeButtonPositionOffsetXSlider

    local minimizeButtonPositionOffsetYSlider = Widgets.SettingsSlider.Acquire(false, minimizeButtonPositionSection)
    minimizeButtonPositionOffsetYSlider:SetID(30)
    minimizeButtonPositionOffsetYSlider:SetLabel(L.OFFSET_Y)
    minimizeButtonPositionOffsetYSlider:SetValueStep(1)
    minimizeButtonPositionOffsetYSlider:SetMinMaxValues(-50, 50)
    minimizeButtonPositionOffsetYSlider:BindTrackerSetting(trackerID, "minimizeButtonPositionOffsetY")
    self.GeneralTabControls.minimizeButtonPositionOffsetYSlider = minimizeButtonPositionOffsetYSlider
    ---------------------------------------------------------------------------
    --- Background Section
    ---------------------------------------------------------------------------
    local backgroundSection = Widgets.ExpandableSection.Acquire(false, self)
    backgroundSection:SetExpanded(false)
    backgroundSection:SetID(80)
    backgroundSection:SetTitle(L.BACKGROUND)
    self.GeneralTabControls.backgroundSection = backgroundSection

    local showBackgroundCheckBox = Widgets.SettingsCheckBox.Acquire(false, backgroundSection)
    showBackgroundCheckBox:SetID(10)
    showBackgroundCheckBox:SetLabel(L.SHOW)
    showBackgroundCheckBox:BindTrackerSetting(trackerID, "showBackground")
    self.GeneralTabControls.showBackgroundCheckBox = showBackgroundCheckBox

    local backgroundColorPicker = Widgets.SettingsColorPicker.Acquire(false, backgroundSection)
    backgroundColorPicker:SetID(20)
    backgroundColorPicker:SetLabel(L.COLOR)
    backgroundColorPicker:BindTrackerSetting(trackerID, "backgroundColor")
    self.GeneralTabControls.backgroundColorPicker = backgroundColorPicker
    ---------------------------------------------------------------------------
    --- Border Section
    ---------------------------------------------------------------------------
    local borderSection = Widgets.ExpandableSection.Acquire(false, self)
    borderSection:SetExpanded(false)
    borderSection:SetID(90)
    borderSection:SetTitle(L.BORDER)
    self.GeneralTabControls.borderSection = borderSection

    local showBorderCheckBox = Widgets.SettingsCheckBox.Acquire(false, borderSection)
    showBorderCheckBox:SetID(10)
    showBorderCheckBox:SetLabel(L.SHOW)
    showBorderCheckBox:BindTrackerSetting(trackerID, "showBorder")
    self.GeneralTabControls.showBorderCheckBox = showBorderCheckBox

    local borderColorPicker = Widgets.SettingsColorPicker.Acquire(false, borderSection)
    borderColorPicker:SetID(20)
    borderColorPicker:SetLabel(L.COLOR)
    borderColorPicker:BindTrackerSetting(trackerID, "borderColor")
    self.GeneralTabControls.borderColorPicker = borderColorPicker

    local borderSizeSlider = Widgets.SettingsSlider.Acquire(false, borderSection)
    borderSizeSlider:SetID(30)
    borderSizeSlider:SetLabel(L.SIZE)
    borderSizeSlider:SetMinMaxValues(1, 10)
    borderSizeSlider:BindTrackerSetting(trackerID, "borderSize")
    self.GeneralTabControls.borderSizeSlider = borderSizeSlider
    ---------------------------------------------------------------------------
    --- Scroll Bar Section
    ---------------------------------------------------------------------------
    local scrollBarSection = Widgets.ExpandableSection.Acquire(false, self)
    scrollBarSection:SetExpanded(false)
    scrollBarSection:SetID(100)
    scrollBarSection:SetTitle(L.SCROLL_BAR)
    self.GeneralTabControls.scrollBarSection = scrollBarSection

    local showScrollBarCheckBox = Widgets.SettingsCheckBox.Acquire(false, scrollBarSection)
    showScrollBarCheckBox:SetID(10)
    showScrollBarCheckBox:SetLabel(L.SHOW)
    showScrollBarCheckBox:BindTrackerSetting(trackerID, "showScrollBar")
    self.GeneralTabControls.showScrollBarCheckBox = showScrollBarCheckBox

    local scrollBarPositionDropDown = Widgets.SettingsDropDown.Acquire(true, scrollBarSection)
    scrollBarPositionDropDown:SetID(20)
    scrollBarPositionDropDown:SetLabel(L.POSITION)
    scrollBarPositionDropDown:AddEntry({ text = L.LEFT, value = "LEFT"})
    scrollBarPositionDropDown:AddEntry({ text = L.RIGHT, value = "RIGHT"})
    scrollBarPositionDropDown:BindTrackerSetting(trackerID, "scrollBarPosition")
    self.GeneralTabControls.scrollBarPositionDropDown = scrollBarPositionDropDown

    local scrollBarPositionOffsetXSlider = Widgets.SettingsSlider.Acquire(true, scrollBarSection)
    scrollBarPositionOffsetXSlider:SetID(25)
    scrollBarPositionOffsetXSlider:SetLabel(L.POSITION_OFFSET_X)
    scrollBarPositionOffsetXSlider:SetValueStep(1)
    scrollBarPositionOffsetXSlider:SetMinMaxValues(-50, 100)
    scrollBarPositionOffsetXSlider:BindTrackerSetting(trackerID, "scrollBarPositionOffsetX")
    self.GeneralTabControls.scrollBarPositionOffsetXSlider = scrollBarPositionOffsetXSlider

    local scrollBarThumbColorPicker = Widgets.SettingsColorPicker.Acquire(false, scrollBarSection)
    scrollBarThumbColorPicker:SetID(30)
    scrollBarThumbColorPicker:SetLabel(L.THUMB_COLOR)
    scrollBarThumbColorPicker:BindTrackerSetting(trackerID, "scrollBarThumbColor")
    self.GeneralTabControls.scrollBarThumbColorPicker = scrollBarThumbColorPicker

    local scrollBarUseTrackerHeightCheckBox = Widgets.SettingsCheckBox.Acquire(false, scrollBarSection)
    scrollBarUseTrackerHeightCheckBox:SetID(10)
    scrollBarUseTrackerHeightCheckBox:SetLabel(L.USE_TRACKER_HEIGHT)
    scrollBarUseTrackerHeightCheckBox:BindTrackerSetting(trackerID, "scrollBarUseTrackerHeight")
    self.GeneralTabControls.scrollBarUseTrackerHeightCheckBox = scrollBarUseTrackerHeightCheckBox
    ---------------------------------------------------------------------------
    --- Danger Zone Section
    ---------------------------------------------------------------------------
    --- The "Danger zone" won't appear for main tracker as it's not intended to be deleted.
    if self.TrackerID ~= "main" then
      local dangerZoneSection = Widgets.ExpandableSection.Acquire(false, self)
      dangerZoneSection:SetExpanded(false)
      dangerZoneSection:SetID(999)
      dangerZoneSection:SetTitle(("|cffff0000%s|r"):format(L.DANGER_ZONE))
      self.GeneralTabControls.dangerZoneSection = dangerZoneSection
      -------------------------------------------------------------------------
      --- Danger Zone -> Delete the tracker
      -------------------------------------------------------------------------   
      local function OnDeleteTrackerClick(button)
        DeleteTracker(self.TrackerID)
      end

      local deleteTrackerButton = Widgets.DangerPushButton.Acquire(false, dangerZoneSection)
      deleteTrackerButton:SetText(L.TRACKER_DELETE)
      deleteTrackerButton:SetID(10)
      deleteTrackerButton:SetUserHandler("OnClick", OnDeleteTrackerClick)
      Style[deleteTrackerButton].marginLeft = 0.35
      self.GeneralTabControls.deleteTrackerButton = deleteTrackerButton
    end

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
  --                 [Contents Tracked] Tab Builder                          --
  -----------------------------------------------------------------------------
  function BuildContentsTrackedTab(self)
    local trackerID = self.TrackerID
    ---------------------------------------------------------------------------
    --- Contents Tracked Section Header 
    ---------------------------------------------------------------------------
    local contentsTrackedSectionHeader = Widgets.SettingsSectionHeader.Acquire(false, self)
    contentsTrackedSectionHeader:SetID(10)
    contentsTrackedSectionHeader:SetTitle(L.CONTENTS_TRACKED)
    self.ContentTabControls.contentsTrackedSectionHeader = contentsTrackedSectionHeader
    ---------------------------------------------------------------------------
    --- Contents Controls 
    ---------------------------------------------------------------------------
    for index, content in List(IterateContents()):Sort("x,y=>x.Name<y.Name"):GetIterator() do
      local contentID = content.id
      local contentTracked = GetTrackerSetting(self.TrackerID, "contentsTracked", contentID)

      local contentCheckBox = Widgets.SettingsCheckBox.Acquire(false, self)
      contentCheckBox:SetID(20 + index)
      contentCheckBox:SetLabel(content.FormattedName)
      contentCheckBox:BindTrackerSetting(trackerID, "contentsTracked", contentID)
      Style[contentCheckBox].MarginLeft = 20

      self.ContentTabControls[contentCheckBox] = contentCheckBox
    end
  end
  -----------------------------------------------------------------------------
  --                 [Contents Tracked] Tab Release                          --
  -----------------------------------------------------------------------------
  function ReleaseContentsTrackedTab(self)
    for index, control in pairs(self.ContentTabControls) do
      control:Release()
      self.ContentTabControls[index] = nil
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
    local trackerID = self.TrackerID
    ---------------------------------------------------------------------------
    ---  Default Visibility
    ---------------------------------------------------------------------------
    local defaultVisibilityDropDown = Widgets.SettingsDropDown.Acquire(false, self)
    defaultVisibilityDropDown:SetID(10)
    defaultVisibilityDropDown:SetLabel(L.DEFAULT_VISIBILITY)
    defaultVisibilityDropDown:AddEntry({ text = ("|cffff0000%s|r"):format(L.HIDDEN), value = "hide"})
    defaultVisibilityDropDown:AddEntry({ text = ("|cff00ff00%s|r"):format(L.SHOW), value = "show"})
    defaultVisibilityDropDown:BindTrackerSetting(trackerID, "visibilityRules", "defaultVisibility")
    self.VisibilityRulesControls.defaultVisibilityDropDown = defaultVisibilityDropDown
    ---------------------------------------------------------------------------
    ---  Hide when empty
    ---------------------------------------------------------------------------
    local hideWhenEmptyCheckBox = Widgets.SettingsCheckBox.Acquire(false, self)
    hideWhenEmptyCheckBox:SetID(20)
    hideWhenEmptyCheckBox:SetLabel(L.HIDE_WHEN_EMPTY)
    hideWhenEmptyCheckBox:BindTrackerSetting(trackerID, "visibilityRules", "hideWhenEmpty")
    self.VisibilityRulesControls.hideWhenEmptyCheckBox = hideWhenEmptyCheckBox
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
    enableAdvancedRulesCheckBox:BindTrackerSetting(trackerID, "visibilityRules", "enableAdvancedRules")
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
      dropDownControl:BindTrackerSetting(trackerID, "visibilityRules", info.setting)
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
      dropDownControl:BindTrackerSetting(trackerID, "visibilityRules", info.setting)
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
    evaluateMacroAtFirstCheckBox:BindTrackerSetting(trackerID, "visibilityRules", "evaluateMacroVisibilityAtFirst")
    Style[evaluateMacroAtFirstCheckBox].marginLeft = 20
    self.VisibilityRulesControls.evaluateMacroAtFirstCheckBox = evaluateMacroAtFirstCheckBox
    ---------------------------------------------------------------------------
    --- Macro -> Macro Visibility Text
    ---------------------------------------------------------------------------
    local function OnMacroTextEnterPressed(editBox)
      local value = editBox:GetText()
      editBox:ClearFocus()
      SetTrackerSetting(trackerID, "visibilityRules", value, nil, "macroVisibility")
    end

    local function OnMacroTextEscapePressed(editBox)
      editBox:ClearFocus()
    end

    local macroTextEditBox = Widgets.MultiLineEditBox.Acquire(false, advancedRulesSection)
    macroTextEditBox:SetID(320)
    macroTextEditBox:SetInstructions("[combat] hide; show")
    macroTextEditBox:SetText(GetTrackerSettingWithDefault(trackerID, "visibilityRules", "macroVisibility"))
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
      onRelease = function() self:ReleaseGeneralTab() end 
    })

    tabControl:AddTabPage({
      name = L.CONTENTS_TRACKED,
      onAcquire = function() self:BuildContentsTrackedTab() end,
      onRelease = function() self:ReleaseContentsTrackedTab() end 
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

    self.TrackerID = nil
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

  property "ContentTabControls" {
    set = false,
    default = function() return newtable(false, true) end
  }

  property "VisibilityRulesControls" {
    set = false,
    default = function() return newtable(false, true) end
  }

  property "TrackerID" {
    type = String
  }
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [SettingDefinitions.CreateTracker] = {
    layoutManager = Layout.VerticalLayoutManager(true, true)
  },
  [SettingDefinitions.Tracker] = {
    layoutManager = Layout.VerticalLayoutManager(true, true)
  }
})