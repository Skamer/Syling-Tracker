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
    trackerNameEditBox:SetLabel("Tracker Name")
    trackerNameEditBox:SetInstructions("Enter the tracker name")
    self.SettingControls.trackerNameEditBox = trackerNameEditBox
    ---------------------------------------------------------------------------
    --- Contents Tracked Section Header 
    ---------------------------------------------------------------------------
    local contentsTrackedSectionHeader = Widgets.SettingsSectionHeader.Acquire(false, self)
    contentsTrackedSectionHeader:SetID(20)
    contentsTrackedSectionHeader:SetTitle("Contents Tracked")
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
    createButton:SetText("Create")
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
    enableTrackerCheckBox:SetLabel("Enable")
    enableTrackerCheckBox:BindTrackerSetting(trackerID, "enabled")
    self.GeneralTabControls.enableTrackerCheckBox = enableTrackerCheckBox

    ---------------------------------------------------------------------------
    --- Lock Tracker
    ---------------------------------------------------------------------------
    local lockTrackerCkeckBox = Widgets.SettingsCheckBox.Acquire(false, self)
    lockTrackerCkeckBox:SetID(20)
    lockTrackerCkeckBox:SetLabel("Lock")
    lockTrackerCkeckBox:BindTrackerSetting(trackerID, "locked")
    self.GeneralTabControls.lockTrackerCkeckBox = lockTrackerCkeckBox
    ---------------------------------------------------------------------------
    --- Scale Tracker
    ---------------------------------------------------------------------------
    local scaleSlider = Widgets.SettingsSlider.Acquire(false, self)
    scaleSlider:SetID(40)
    scaleSlider:SetLabel("Scale")
    scaleSlider:SetSliderLabelFormatter(Widgets.Slider.Label.Right)
    scaleSlider:BindTrackerSetting(trackerID, "scale")
    scaleSlider:SetValueStep(0.01)
    scaleSlider:SetMinMaxValues(0.4, 10)
    self.GeneralTabControls.scaleSlider = scaleSlider
    ---------------------------------------------------------------------------
    --- Show Minimise Button
    ---------------------------------------------------------------------------
    local showMinimizeButtonCkeckBox = Widgets.SettingsCheckBox.Acquire(false, self)
    showMinimizeButtonCkeckBox:SetID(50)
    showMinimizeButtonCkeckBox:SetLabel("Show Minimize Button")
    showMinimizeButtonCkeckBox:BindTrackerSetting(trackerID, "showMinimizeButton")
    self.GeneralTabControls.showMinimizeButtonCkeckBox = showMinimizeButtonCkeckBox
    ---------------------------------------------------------------------------
    --- Background Section
    ---------------------------------------------------------------------------
    local backgroundSection = Widgets.ExpandableSection.Acquire(false, self)
    backgroundSection:SetExpanded(false)
    backgroundSection:SetID(60)
    backgroundSection:SetTitle("Background")
    Style[backgroundSection].marginTop = 10
    self.GeneralTabControls.backgroundSection = backgroundSection

    local showBackgroundCheckBox = Widgets.SettingsCheckBox.Acquire(false, backgroundSection)
    showBackgroundCheckBox:SetID(10)
    showBackgroundCheckBox:SetLabel("Show")
    showBackgroundCheckBox:BindTrackerSetting(trackerID, "showBackground")
    self.GeneralTabControls.showBackgroundCheckBox = showBackgroundCheckBox

    local backgroundColorPicker = Widgets.SettingsColorPicker.Acquire(false, backgroundSection)
    backgroundColorPicker:SetID(20)
    backgroundColorPicker:SetLabel("Color")
    backgroundColorPicker:BindTrackerSetting(trackerID, "backgroundColor")
    self.GeneralTabControls.backgroundColorPicker = backgroundColorPicker
    ---------------------------------------------------------------------------
    --- Border Section
    ---------------------------------------------------------------------------
    local borderSection = Widgets.ExpandableSection.Acquire(false, self)
    borderSection:SetExpanded(false)
    borderSection:SetID(70)
    borderSection:SetTitle("Border")
    self.GeneralTabControls.borderSection = borderSection

    local showBorderCheckBox = Widgets.SettingsCheckBox.Acquire(false, borderSection)
    showBorderCheckBox:SetID(10)
    showBorderCheckBox:SetLabel("Show")
    showBorderCheckBox:BindTrackerSetting(trackerID, "showBorder")
    self.GeneralTabControls.showBorderCheckBox = showBorderCheckBox

    local borderColorPicker = Widgets.SettingsColorPicker.Acquire(false, borderSection)
    borderColorPicker:SetID(20)
    borderColorPicker:SetLabel("Color")
    borderColorPicker:BindTrackerSetting(trackerID, "borderColor")
    self.GeneralTabControls.borderColorPicker = borderColorPicker

    local borderSizeSlider = Widgets.SettingsSlider.Acquire(false, borderSection)
    borderSizeSlider:SetID(30)
    borderSizeSlider:SetLabel("Size")
    borderSizeSlider:SetSliderLabelFormatter(Widgets.Slider.Label.Right)
    borderSizeSlider:BindTrackerSetting(trackerID, "borderSize")
    borderSizeSlider:SetMinMaxValues(1, 10)
    self.GeneralTabControls.borderSizeSlider = borderSizeSlider
    ---------------------------------------------------------------------------
    --- Scroll Bar Section
    ---------------------------------------------------------------------------
    local scrollBarSection = Widgets.ExpandableSection.Acquire(false, self)
    scrollBarSection:SetExpanded(false)
    scrollBarSection:SetID(80)
    scrollBarSection:SetTitle("Scroll Bar")
    self.GeneralTabControls.scrollBarSection = scrollBarSection

    local showScrollBarCheckBox = Widgets.SettingsCheckBox.Acquire(false, scrollBarSection)
    showScrollBarCheckBox:SetID(10)
    showScrollBarCheckBox:SetLabel("Show")
    showScrollBarCheckBox:BindTrackerSetting(trackerID, "showScrollBar")
    self.GeneralTabControls.showScrollBarCheckBox = showScrollBarCheckBox

    local scrollBarPositionDropDown = Widgets.SettingsDropDown.Acquire(true, scrollBarSection)
    scrollBarPositionDropDown:SetID(20)
    scrollBarPositionDropDown:SetLabel("Position")
    scrollBarPositionDropDown:AddEntry({ text = "Left", value = "LEFT"})
    scrollBarPositionDropDown:AddEntry({ text = "Right", value = "RIGHT"})
    scrollBarPositionDropDown:BindTrackerSetting(trackerID, "scrollBarPosition")
    self.GeneralTabControls.scrollBarPositionDropDown = scrollBarPositionDropDown

    local scrollBarThumbColorPicker = Widgets.SettingsColorPicker.Acquire(false, scrollBarSection)
    scrollBarThumbColorPicker:SetID(30)
    scrollBarThumbColorPicker:SetLabel("Thumb Color")
    scrollBarThumbColorPicker:BindTrackerSetting(trackerID, "scrollBarThumbColor")
    self.GeneralTabControls.scrollBarThumbColorPicker = scrollBarThumbColorPicker
    ---------------------------------------------------------------------------
    --- Danger Zone Section
    ---------------------------------------------------------------------------
    --- The "Danger zone" won't appear for main tracker as it's not intended to be deleted.
    if self.TrackerID ~= "main" then
      local dangerZoneSection = Widgets.ExpandableSection.Acquire(false, self)
      dangerZoneSection:SetExpanded(false)
      dangerZoneSection:SetID(999)
      dangerZoneSection:SetTitle("|cffff0000Danger Zone|r")
      self.GeneralTabControls.dangerZoneSection = dangerZoneSection
      -------------------------------------------------------------------------
      --- Danger Zone -> Delete the tracker
      -------------------------------------------------------------------------   
      local function OnDeleteTrackerClick(button)
        DeleteTracker(self.TrackerID)
      end

      local deleteTrackerButton = Widgets.DangerPushButton.Acquire(false, dangerZoneSection)
      deleteTrackerButton:SetText("Delete the tracker")
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
    contentsTrackedSectionHeader:SetTitle("Contents Tracked")
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
  _ENTRIES_CONDITIONS_DROPDOWN:Insert({ text = "|cffff0000Hide|r", value = "hide"})
  _ENTRIES_CONDITIONS_DROPDOWN:Insert({ text = "|cff00ff00Show|r", value = "show"})
  _ENTRIES_CONDITIONS_DROPDOWN:Insert({ text = "Default", value = "default"})
  _ENTRIES_CONDITIONS_DROPDOWN:Insert({ text = "Ignore", value = "ignore"})

  -- Contains below the info for every instance or group size condition option to 
  -- build 
  _INSTANCE_VISIBILITY_ROWS_INFO = {
    [1] = { label = "Dungeon", setting = "inDungeonVisibility" },
    [2] = { label = "Mythic +", setting = "inKeystoneVisibility"},
    [3] = { label = "Raid", setting = "inRaidVisibility"}, 
    [4] = { label = "Scenario", setting = "inScenarioVisibility"},
    [5] = { label = "Arena", setting = "inArenaVisibility"},
    [6] = { label = "Battleground", setting = "inBattlegroundVisibility"}
  }

  _GROUP_SIZE_VISIBILITY_ROWS_INFO = {
    [1] = { label = "Party", setting = "inPartyVisibility"},
    [2] = { label = "Raid Group", setting = "inRaidGroupVisibility" }
  }

  function BuildVisibilityRulesTab(self)
    local trackerID = self.TrackerID
    ---------------------------------------------------------------------------
    ---  Default Visibility
    ---------------------------------------------------------------------------
    local defaultVisibilityDropDown = Widgets.SettingsDropDown.Acquire(false, self)
    defaultVisibilityDropDown:SetID(10)
    defaultVisibilityDropDown:SetLabel("Default Visibility")
    defaultVisibilityDropDown:AddEntry({ text = "|cffff0000Hidden|r", value = "hide"})
    defaultVisibilityDropDown:AddEntry({ text = "|cff00ff00Show|r", value = "show"})
    defaultVisibilityDropDown:BindTrackerSetting(trackerID, "visibilityRules", "defaultVisibility")
    self.VisibilityRulesControls.defaultVisibilityDropDown = defaultVisibilityDropDown
    ---------------------------------------------------------------------------
    ---  Hide when empty
    ---------------------------------------------------------------------------
    local hideWhenEmptyCheckBox = Widgets.SettingsCheckBox.Acquire(false, self)
    hideWhenEmptyCheckBox:SetID(20)
    hideWhenEmptyCheckBox:SetLabel("Hide when empty")
    hideWhenEmptyCheckBox:BindTrackerSetting(trackerID, "visibilityRules", "hideWhenEmpty")
    self.VisibilityRulesControls.hideWhenEmptyCheckBox = hideWhenEmptyCheckBox
    ---------------------------------------------------------------------------
    ---  Advanced Rules
    ---------------------------------------------------------------------------
    local advancedRulesSection = Widgets.SettingsExpandableSection.Acquire(false, self)
    advancedRulesSection:SetID(30)
    advancedRulesSection:SetTitle("Advanced Rules")
    self.VisibilityRulesControls.advancedRulesSection = advancedRulesSection
    ---------------------------------------------------------------------------
    ---  Enable Advanced Rules
    ---------------------------------------------------------------------------
    local enableAdvancedRulesCheckBox = Widgets.SettingsCheckBox.Acquire(false, advancedRulesSection)
    enableAdvancedRulesCheckBox:SetID(10)
    enableAdvancedRulesCheckBox:SetLabel("Enable")
    enableAdvancedRulesCheckBox:BindTrackerSetting(trackerID, "visibilityRules", "enableAdvancedRules")
    self.VisibilityRulesControls.enableAdvancedRulesCheckBox = enableAdvancedRulesCheckBox
    ---------------------------------------------------------------------------
    ---  Instance Visibility
    ---------------------------------------------------------------------------
    local instanceConditionHeader = Widgets.SettingsSectionHeader.Acquire(false, advancedRulesSection)
    instanceConditionHeader:SetID(100)
    instanceConditionHeader:SetTitle("Instance")
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
    groupSizeConditionsHeader:SetTitle("Group Size")
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
    macroConditionsHeader:SetTitle("Macro")
    self.VisibilityRulesControls.macroConditionsHeader = macroConditionsHeader
    ---------------------------------------------------------------------------
    --- Macro -> Evaluate Macro At First
    ---------------------------------------------------------------------------
    local evaluateMacroAtFirstCheckBox = Widgets.SettingsCheckBox.Acquire(false, advancedRulesSection)
    evaluateMacroAtFirstCheckBox:SetID(310)
    evaluateMacroAtFirstCheckBox:SetLabel("Evaluate the macro at first")
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
      name = "General",
      onAcquire = function() self:BuildGeneralTab() end,
      onRelease = function() self:ReleaseGeneralTab() end 
    })

    tabControl:AddTabPage({
      name = "Contents Tracked",
      onAcquire = function() self:BuildContentsTrackedTab() end,
      onRelease = function() self:ReleaseContentsTrackedTab() end 
    })

    tabControl:AddTabPage({
      name = "Visibility Rules",
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