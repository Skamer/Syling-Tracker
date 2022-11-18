-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling          "SylingTracker.Options.SettingDefinitions.Trackers"          ""
-- ========================================================================= --
export {
  GetContentTypes = SLT.API.GetContentTypes,
  NewTracker      = SLT.API.NewTracker,
  DeleteTracker   = SLT.API.DeleteTracker,
  GetTracker      = SLT.API.GetTracker
}
-- ========================================================================= --
__Iterator__()
function IterateContentTypes()
  local yield = coroutine.yield

  --- Name is used for sorting as there is no markup inside
  for k,v in GetContentTypes():Sort("x,y=>x.Name<y.Name"):GetIterator() do 
    yield(k,v)
  end
end

__Widget__()
class "SLT.SettingDefinitions.CreateTracker" (function(_ENV)
  inherit "Frame"
  ----------------------------------------------------------------------------
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
    local trackerNameEditBox = SUI.SettingsEditBox.Acquire(false, self)
    trackerNameEditBox:SetID(10)
    trackerNameEditBox:SetLabel("Tracker Name")
    trackerNameEditBox:SetInstructions("Enter the tracker name")
    self.SettingControls.trackerNameEditBox = trackerNameEditBox
    ---------------------------------------------------------------------------
    --- Contents Tracked Section Header 
    ---------------------------------------------------------------------------
    local contentsTrackedSectionHeader = SUI.SettingsSectionHeader.Acquire(false, self)
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

    for index, contentType in IterateContentTypes() do 
      local content = SUI.SettingsCheckBox.Acquire(true, self)
      content:SetID(30+index)
      content:SetLabel(contentType.DisplayName)
      content:SetChecked(false)
      content:SetUserData("contentID", contentType.ID)
      content:SetUserHandler("OnCheckBoxClick", OnContentCheckBoxClick)
      Style[content].MarginLeft = 20

      self.SettingControls[content] = content
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
            tracker:ApplyAndSaveSetting("contentTracked", contentID, isTracked)
            Scorpio.Next()
          end
        end)
      end
    end

    local createButton = SUI.SuccessPushButton.Acquire(true, self)
    createButton:SetText("Create")
    createButton:SetPoint("BOTTOM")
    createButton:SetUserHandler("OnClick", OnCreateButtonClick)
    self.SettingControls.createButton = createButton
  end


  function ReleaseSettingControls(self)
    --- Release the widgets
    for index, control in pairs(self.SettingControls) do
      control:Release()
      self.SettingControls[control] = nil 
    end
  end

  function OnAcquire(self)
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
class "SLT.SettingDefinitions.Tracker" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                   [General] Tab Builder                                 --
  -----------------------------------------------------------------------------
  function BuildGeneralTab(self)
    ---------------------------------------------------------------------------
    --- Lock Tracker
    ---------------------------------------------------------------------------
    local function OnLockTrackerCheckBoxClick(checkBox)
      local isLocked = checkBox:IsChecked()
      self.Tracker:ApplyAndSaveSetting("locked", isLocked)
    end

    local lock = SUI.SettingsCheckBox.Acquire(false, self)
    lock:SetID(10)
    lock:SetLabel("Lock")
    lock:SetChecked(self.Tracker.Locked)
    lock:SetUserHandler("OnCheckBoxClick", OnLockTrackerCheckBoxClick)
    self.GeneralTabControls.lockTrackerButton = lock
    ---------------------------------------------------------------------------
    --- Show Tracker
    ---------------------------------------------------------------------------
    local function OnShowTrackerCheckBoxClick(checkBox)
      local isShow = checkBox:IsChecked()
      self.Tracker:ApplyAndSaveSetting("hidden", not isShow)
    end

    local show = SUI.SettingsCheckBox.Acquire(false, self)
    show:SetID(20)
    show:SetLabel("Show")
    show:SetChecked(self.Tracker:IsShown())
    show:SetUserHandler("OnCheckBoxClick", OnShowTrackerCheckBoxClick)
    self.GeneralTabControls.showTrackerButton = show
    ---------------------------------------------------------------------------
    --- Tracker Scale
    ---------------------------------------------------------------------------
    local function OnTrackerScaleChanged(slider, value)
      self.Tracker:ApplyAndSaveSetting("scale", value)
    end

    local scaleSlider = SUI.SettingsSlider.Acquire(false, self)
    scaleSlider:SetID(30)
    scaleSlider:SetLabel("Scale")
    scaleSlider:SetSliderLabelFormatter(SUI.Slider.Label.Right)
    scaleSlider:SetMinMaxValues(0.1, 5)
    scaleSlider:SetValueStep(0.01)
    scaleSlider:SetValue(Style[self.Tracker].Scale)
    scaleSlider:SetUserHandler("OnValueChanged", OnTrackerScaleChanged)
    self.GeneralTabControls.trackerScaleSlider = scaleSlider
    ---------------------------------------------------------------------------
    --- Background Section
    ---------------------------------------------------------------------------
    local backgroundSection = self:CreateBackgroundSection()
    backgroundSection:SetExpanded(false)
    backgroundSection:SetID(40)
    backgroundSection:SetTitle("Background")
    Style[backgroundSection].marginTop = 15
    self.GeneralTabControls.backgroundSection = backgroundSection
    ---------------------------------------------------------------------------
    --- Border Section
    ---------------------------------------------------------------------------
    local borderSection = self:CreateBorderSection()
    borderSection:SetExpanded(false)
    borderSection:SetID(50)
    borderSection:SetTitle("Border")
    self.GeneralTabControls.borderSection = borderSection
    ---------------------------------------------------------------------------
    --- Scroll Bar Section
    ---------------------------------------------------------------------------
    local scrollBarSection = self:CreateScrollBarSection()
    scrollBarSection:SetExpanded(false)
    scrollBarSection:SetID(60)
    scrollBarSection:SetTitle("Scroll Bar")
    self.GeneralTabControls.scrollBarSection = scrollBarSection 
    ---------------------------------------------------------------------------
    --- Danger Zone Section
    ---------------------------------------------------------------------------
    --- The "Danger zone" won't appear for main tracker as it's not intended to be deleted.
    if self.Tracker.ID ~= "main" then 
      local dangerZoneSection = self:CreateDangerZoneSection()
      dangerZoneSection:SetExpanded(false)
      dangerZoneSection:SetID(999)
      dangerZoneSection:SetTitle("|cffff0000Danger Zone|r")
      self.GeneralTabControls.dangerZoneSection = dangerZoneSection
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
  --                    [General] Background Section                         --
  -----------------------------------------------------------------------------
  function CreateBackgroundSection(self)
    local backgroundSection = SUI.ExpandableSection.Acquire(false, self)
    ---------------------------------------------------------------------------
    --- Background -> Show Background
    ---------------------------------------------------------------------------
    local function OnShowBackgroundCheckBoxClick(checkBox)
      local isShow = checkBox:IsChecked()
      self.Tracker:ApplyAndSaveSetting("showBackground", isShow) 
    end

    local showBackground = SUI.SettingsCheckBox.Acquire(true, backgroundSection)
    showBackground:SetID(10)
    showBackground:SetLabel("Show")
    showBackground:SetChecked(Style[self.Tracker].BackgroundTexture.visible)
    showBackground:SetUserHandler("OnCheckBoxClick", OnShowBackgroundCheckBoxClick)
    self.GeneralTabControls.showBackgroundCheckBox = showBackground
    ---------------------------------------------------------------------------
    --- Background -> Background Color
    ---------------------------------------------------------------------------
    local function OnBackgroundColorChangedHandler(colorPicker, r, g, b, a)
      self.Tracker:ApplySetting("backgroundColor", r, g, b, a)
    end

    local function OnBackgroundColorConfirmedHandler(colorPicker, r, g, b, a)
      self.Tracker:ApplyAndSaveSetting("backgroundColor", r, g, b, a)
    end

    local backgroundColor = Style[self.Tracker].BackgroundTexture.vertexColor
    local backgroundColorPicker = SUI.SettingsColorPicker.Acquire(true, backgroundSection)
    backgroundColorPicker:SetID(20)
    backgroundColorPicker:SetLabel("Background color")

    if backgroundColor then 
      backgroundColorPicker:SetColor(backgroundColor.r, backgroundColor.g, backgroundColor.b, backgroundColor.a)
    end

    backgroundColorPicker:SetUserHandler("OnColorChanged", OnBackgroundColorChangedHandler)
    backgroundColorPicker:SetUserHandler("OnColorConfirmed", OnBackgroundColorConfirmedHandler)
    self.GeneralTabControls.backgroundColorPicker = backgroundColorPicker


    --- NOTE: The section will be added in the controls list and configured by outside. 
    return backgroundSection
  end
  -----------------------------------------------------------------------------
  --                    [General] Border Section                             --
  -----------------------------------------------------------------------------
  _BorderControlsInfo = {
    --- Edges
    { id = "topBorder", settingShow = "showTopBorder", settingColor = "topBorderColor", settingSize = "topBorderSize", label = "Top Edge" },
    { id = "bottomBorder", settingShow = "showBottomBorder", settingColor = "bottomBorderColor", settingSize = "bottomBorderSize", label = "Bottom Edge"},
    { id = "leftBorder", settingShow = "showLeftBorder", settingColor = "leftBorderColor", settingSize = "leftBorderSize", label = "Left Edge"},
    { id = "rightBorder", settingShow = "showRightBorder", settingColor = "rightBorderColor", settingSize = "rightBorderSize", label = "Right Edge"},
    --- Corners
    { id = "topLeftBorder", settingShow = "showTopLeftBorder", settingColor = "topLeftBorderColor", label = "Top Left Corner", isCorner = true},
    { id = "topRightBorder", settingShow = "showTopRightBorder", settingColor = "topRightBorderColor", label = "Top Right Corner", isCorner = true},
    { id = "bottomLeftBorder", settingShow = "showBottomLeftBorder", settingColor = "bottomLeftBorderColor", label = "Bottom Left Corner", isCorner = true},
    { id = "bottomRightBorder", settingShow = "showBottomRightBorder", settingColor = "bottomRightBorderColor", label = "Bottom Right Corner", isCorner = true}
  }  

  function CreateBorderSection(self)
    local borderSection = SUI.ExpandableSection.Acquire(false, self)
    ---------------------------------------------------------------------------
    --- Border -> Grid Border Controls 
    ---------------------------------------------------------------------------
    local gridBorders = SUI.GridControls.Acquire(true, borderSection)
    gridBorders:SetID(10)
    gridBorders:SetColumnCount(4)
    gridBorders:SetRowCount(#_BorderControlsInfo + 2)
    gridBorders:SetDefaultRowHeight(40)
    gridBorders:SetColumnWidths(150, 60, 60, 180)
    self.GeneralTabControls.gridBorders = gridBorders
    ---------------------------------------------------------------------------
    --- Border -> Grid Border -> Headers
    ---------------------------------------------------------------------------
    local showBorderHeader = SUI.SettingsText.Acquire(true, gridBorders)
    showBorderHeader:SetText("Show")
    gridBorders:SetCellControl(1, 2, showBorderHeader, 1, 1)
    self.GeneralTabControls.showBorderHeader = showBorderHeader

    local borderColorHeader = SUI.SettingsText.Acquire(true, gridBorders)
    borderColorHeader:SetText("Color")
    gridBorders:SetCellControl(1, 3, borderColorHeader, 1, 1)
    self.GeneralTabControls.borderColorHeader = borderColorHeader

    local borderSizeHeader = SUI.SettingsText.Acquire(true, gridBorders)
    borderSizeHeader:SetText("Size")
    gridBorders:SetCellControl(1, 4, borderSizeHeader, 1, 1)
    self.GeneralTabControls.borderSizeHeader = borderSizeHeader
    ---------------------------------------------------------------------------
    --- Border -> Grid Border -> Show All Borders
    ---------------------------------------------------------------------------
    local function OnShowAllBorderCheckBoxClick(checkBox)
      local checked = checkBox:GetChecked()

      for _, info in pairs(_BorderControlsInfo) do 
        self.Tracker:ApplyAndSaveSetting(info.settingShow, checked)
      end

      for _, control in pairs(self.GeneralTabControls) do 
        if control:GetUserData("showBorderControl") then 
          control:SetChecked(checked)
        end
      end
    end

    local showAllBorder = SUI.CheckBox.Acquire(true, gridBorders)
    showAllBorder:SetUserHandler("OnClick", OnShowAllBorderCheckBoxClick)
    gridBorders:SetCellControl(2, 2, showAllBorder, nil, nil, nil, -6)
    self.GeneralTabControls.showAllBorderCheckBox = showAllBorder
    ---------------------------------------------------------------------------
    --- Border -> Grid Border -> All Border Color
    ---------------------------------------------------------------------------
    local function OnAllBorderColorChanged(colorPicker, r, g, b, a)
      for _, info in pairs(_BorderControlsInfo) do 
        self.Tracker:ApplySetting(info.settingColor, r, g, b, a)
      end

      for _, control in pairs(self.GeneralTabControls) do 
        if control:GetUserData("borderColorControl") then 
          control:SetColor(r, g, b, a)
        end
      end 
    end

    local function OnAllBorderColorConfirmed(colorPicker, r, g, b, a)
      for _, info in pairs(_BorderControlsInfo) do 
        self.Tracker:ApplyAndSaveSetting(info.settingColor, r, g, b, a)
      end

      for _, control in pairs(self.GeneralTabControls) do 
        if control:GetUserData("borderColorControl") then 
          control:SetColor(r, g, b, a)
        end
      end 
    end

    local allBorderColorPicker = SUI.ColorPicker.Acquire(true, gridBorders)
    allBorderColorPicker:SetUserHandler("OnColorChanged", OnAllBorderColorChanged)
    allBorderColorPicker:SetUserHandler("OnColorConfirmed", OnAllBorderColorConfirmed)
    gridBorders:SetCellControl(2, 3, allBorderColorPicker)
    self.GeneralTabControls.allBorderColorPicker = allBorderColorPicker
    ---------------------------------------------------------------------------
    --- Border -> Grid Border -> All Border Size
    ---------------------------------------------------------------------------
    local function OnAllBorderSizeChanged(slider, value)
      for _, info in pairs(_BorderControlsInfo) do
        if not info.isCorner then  
          self.Tracker:ApplyAndSaveSetting(info.settingSize, value)
        end
      end
      
      for _, control in pairs(self.GeneralTabControls) do 
        if control:GetUserData("borderSizeControl") then 
          control:SetValue(value)
        end
      end       
    end

    local allBorderSize = SUI.Slider.Acquire(true, gridBorders)
    allBorderSize:SetLabelFormatter(SUI.Slider.Label.Right)
    allBorderSize:SetMinMaxValues(MinMax(1, 20))
    allBorderSize:SetValueStep(1)
    allBorderSize:SetValue(1)
    allBorderSize:SetUserHandler("OnValueChanged", OnAllBorderSizeChanged)
    gridBorders:SetCellControl(2, 4, allBorderSize, 1)
    self.GeneralTabControls.allBorderSizeSlider = allBorderSize
    ---------------------------------------------------------------------------
    --- Border -> Grid Border -> Border Controls
    ---------------------------------------------------------------------------
    local function OnShowBorderCheckBoxClick(checkBox)
      local setting = checkBox:GetUserData("setting")
      local checked = checkBox:GetChecked()
      self.Tracker:ApplyAndSaveSetting(setting, checked)
    end

    local function OnBorderColorChanged(colorPicker, r, g, b, a)
      local setting = colorPicker:GetUserData("setting")
      self.Tracker:ApplySetting(setting, r, g, b, a)
    end

    local function OnBorderColorConfirmed(colorPicker, r, g, b, a)
      local setting = colorPicker:GetUserData("setting")
      self.Tracker:ApplyAndSaveSetting(setting, r, g, b, a)
    end

    local function OnBorderSizeChanged(slider, value)
      local setting = slider:GetUserData("setting")
      self.Tracker:ApplyAndSaveSetting(setting, value)  
    end

    for index, info in ipairs(_BorderControlsInfo) do 
      --- Border Label
      local borderLabel = SUI.SettingsText.Acquire(true, gridBorders)
      borderLabel:SetText(info.label)
      gridBorders:SetCellControl(2 + index, 1, borderLabel, 1, 1)
      self.GeneralTabControls[borderLabel] = borderLabel
      
      --- Show Border
      local showBorder = SUI.CheckBox.Acquire(true, gridBorders)
      showBorder:SetChecked(Style[self.Tracker][info.settingShow])
      showBorder:SetUserData("setting", info.settingShow)
      showBorder:SetUserData("showBorderControl", true)
      showBorder:SetUserHandler("OnClick", OnShowBorderCheckBoxClick)
      gridBorders:SetCellControl(2 + index, 2, showBorder, nil, nil, nil, -6)
      self.GeneralTabControls[showBorder] = showBorder

      --- Border Color 
      local borderColor = Style[self.Tracker][info.settingColor]
      local borderColorPicker = SUI.ColorPicker.Acquire(true, gridBorders)
      borderColorPicker:SetColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
      borderColorPicker:SetUserData("setting", info.settingColor)
      borderColorPicker:SetUserData("borderColorControl", true)
      borderColorPicker:SetUserHandler("OnColorChanged", OnBorderColorChanged)
      borderColorPicker:SetUserHandler("OnColorConfirmed", OnBorderColorConfirmed)
      gridBorders:SetCellControl(2 + index, 3, borderColorPicker)
      self.GeneralTabControls[borderColorPicker] = borderColorPicker

      --- Border Size
      if not info.isCorner then 
        local borderSize = SUI.Slider.Acquire(true, gridBorders)
        borderSize:SetLabelFormatter(SUI.Slider.Label.Right)
        borderSize:SetMinMaxValues(MinMax(1, 20))
        borderSize:SetValueStep(1)
        borderSize:SetValue(Style[self.Tracker][info.settingSize])
        borderSize:SetUserData("setting", info.settingSize)
        borderSize:SetUserData("borderSizeControl", true)
        borderSize:SetUserHandler("OnValueChanged", OnBorderSizeChanged)
        gridBorders:SetCellControl(2 + index, 4, borderSize, 1)
        self.GeneralTabControls[borderSize] = borderSize
      end
    end
    --- Don't forget to refresh the grid control at last
    gridBorders:Refresh()

    --- NOTE: The section will be added in the controls list and configured by outside. 
    return borderSection
  end
  -----------------------------------------------------------------------------
  --                    [General] Scroll Bar Section                         --
  -----------------------------------------------------------------------------
  function CreateScrollBarSection(self)
    local scrollBarSection = SUI.ExpandableSection.Acquire(false, self)
    ---------------------------------------------------------------------------
    --- Scroll Bar -> Show
    ---------------------------------------------------------------------------
    local function OnShowScrollBarCheckBoxClick(checkBox)
      local isShow = checkBox:IsChecked()
      self.Tracker:ApplyAndSaveSetting("showScrollBar", isShow)
    end

    local showScrollBar = SUI.SettingsCheckBox.Acquire(true, scrollBarSection)
    showScrollBar:SetID(10)
    showScrollBar:SetLabel("Show")
    showScrollBar:SetChecked(self.Tracker.ShowScrollBar)
    showScrollBar:SetUserHandler("OnCheckBoxClick", OnShowScrollBarCheckBoxClick)
    self.GeneralTabControls.showScrollBarCheckBox = showScrollBar
    ---------------------------------------------------------------------------
    --- Scroll Bar -> Position
    ---------------------------------------------------------------------------
    local function OnScrollBarPositionEntrySelected(dropdown, entry)
      local data = entry:GetEntryData()
      self.Tracker:ApplyAndSaveSetting("scrollBarPosition", data.value)
    end

    local scrollBarPosition = SUI.SettingsDropDown.Acquire(true, scrollBarSection)
    scrollBarPosition:SetID(20)
    scrollBarPosition:SetLabel("Position")
    scrollBarPosition:AddEntry({ text = "Left", value = "LEFT"})
    scrollBarPosition:AddEntry({ text = "Right", value = "RIGHT"})
    scrollBarPosition:SelectByValue(self.Tracker.ScrollBarPosition)
    scrollBarPosition:SetUserHandler("OnEntrySelected", OnScrollBarPositionEntrySelected)
    self.GeneralTabControls.scrollBarPositionDropDown = scrollBarPosition
    ---------------------------------------------------------------------------
    --- Scroll Bar -> Thumb Color
    ---------------------------------------------------------------------------
    local function OnThumbColorChanged(colorPicker, r, g, b, a)
      self.Tracker:ApplySetting("scrollBarThumbColor", r, g, b, a)
    end

    local function OnThumbColorConfirmed(colorPicker, r, g, b, a)
      self.Tracker:ApplyAndSaveSetting("scrollBarThumbColor", r, g, b, a)
    end

    local thumbColor = self.Tracker:GetScrollBar():GetThumb():GetNormalColor()
    local thumbColorPicker = SUI.SettingsColorPicker.Acquire(true, scrollBarSection)
    thumbColorPicker:SetID(30)
    thumbColorPicker:SetLabel("Thumb color")
    thumbColorPicker:SetColor(thumbColor.r, thumbColor.g, thumbColor.b, thumbColor.a)
    thumbColorPicker:SetUserHandler("OnColorChanged", OnThumbColorChanged)
    thumbColorPicker:SetUserHandler("OnColorConfirmed", OnThumbColorConfirmed)
    self.GeneralTabControls.thumbColorPicker = thumbColorPicker

    --- NOTE: The section will be added in the controls list and configured by outside. 
    return scrollBarSection
  end
  -----------------------------------------------------------------------------
  --                    [General] Danger Zone Section                        --
  -----------------------------------------------------------------------------
  function CreateDangerZoneSection(self)
    local dangerZoneSection = SUI.ExpandableSection.Acquire(false, self)
    ---------------------------------------------------------------------------
    --- Danger Zone -> Delete the tracker
    ---------------------------------------------------------------------------
    local function OnDeleteTrackerClick(button)
      DeleteTracker(self.TrackerID)
    end

    local deleteTracker = SUI.DangerPushButton.Acquire(true, dangerZoneSection)
    deleteTracker:SetText("Delete the tracker")
    deleteTracker:SetID(10)
    deleteTracker:SetUserHandler("OnClick", OnDeleteTrackerClick)
    Style[deleteTracker].marginLeft = 0.35
    self.GeneralTabControls.deleteTrackerButton = deleteTracker

    --- NOTE: The section will be added in the controls list and configured by outside. 
    return dangerZoneSection
  end
  -----------------------------------------------------------------------------
  --                 [Contents Tracked] Tab Builder                          --
  -----------------------------------------------------------------------------
  function BuildContentsTrackedTab(self)
    ---------------------------------------------------------------------------
    --- Contents Tracked Section Header 
    ---------------------------------------------------------------------------
    local contentsTrackedSectionHeader = SUI.SettingsSectionHeader.Acquire(false, self)
    contentsTrackedSectionHeader:SetID(2)
    contentsTrackedSectionHeader:SetTitle("Contents Tracked")
    self.ContentTabControls.contentsTrackedSectionHeader = contentsTrackedSectionHeader
    ---------------------------------------------------------------------------
    --- Contents Controls 
    ---------------------------------------------------------------------------
    local function OnContentCheckBoxClick(checkBox)
      local contentID = checkBox:GetUserData("contentID")
      local isTracked = checkBox:IsChecked() 
      self.Tracker:ApplyAndSaveSetting("contentTracked", contentID, isTracked)
    end

    for index, contentType in IterateContentTypes() do 
      local content = SUI.SettingsCheckBox.Acquire(true, self)
      content:SetID(3+index)
      content:SetLabel(contentType.DisplayName)
      content:SetChecked(self.Tracker:IsContentTracked(contentType.ID))
      content:SetUserData("contentID", contentType.ID)
      content:SetUserHandler("OnCheckBoxClick", OnContentCheckBoxClick)
      Style[content].MarginLeft = 20
      
      self.ContentTabControls[content] = content
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
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function BuildSettingControls(self)
    local tabControl = SUI.TabControl.Acquire(false, self)
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
    default = function() return Toolset.newtable(false, true) end 
  }

  property "GeneralTabControls" {
    set = false, 
    default = function() return Toolset.newtable(false, true) end 
  }

  property "ContentTabControls" {
    set = false,
    default = function() return Toolset.newtable(false, true) end
  }

  property "TrackerID" {
    type = String,
    handler = function(self, new)
      if new ~= nil then 
        self.Tracker = GetTracker(new)
      else
        self.Tracker = nil 
      end
    end
  }

  property "Tracker" {
    type = SLT.Tracker
  }
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [SLT.SettingDefinitions.CreateTracker] = {
    paddingBottom = 50,
    layoutManager = Layout.VerticalLayoutManager(true, true),
  },
  [SLT.SettingDefinitions.Tracker] = {
    layoutManager = Layout.VerticalLayoutManager(true, true),
  }
})