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
  NewTracker   = SLT.API.NewTracker,
  DeleteTracker = SLT.API.DeleteTracker,
  GetTracker    = SLT.API.GetTracker
}

__Iterator__()
function IterateContentTypes()
  local yield = coroutine.yield

  --- Name is used for sorting as there is no markup inside
  for k,v in GetContentTypes():Sort("x,y=>x.Name<y.Name"):GetIterator() do 
    yield(k,v)
  end
end

local function NoPersistUIElementHandler(tracker, handler, ...)
  tracker:SetPersistent(false)
  handler(...)
  tracker:SetPersistent(true)
end

__Widget__()
class "SLT.SettingDefinitions.CreateTracker" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnCreateButtonClick(self, createButton)
    local trackerName = self.SettingControls.trackerNameEditBox:GetValue()

    if trackerName and trackerName ~= "" then 
      local tracker = NewTracker(trackerName)
      --- We put TrackContentType in a thread for avoiding small freeze for low end 
      --- computer users if there many content tracked, and these ones need to 
      --- create lof of frame.
      Scorpio.Continue(function()
        for contentID in pairs(self.ContentsTracked) do 
          tracker:TrackContentType(contentID)
          Scorpio.Next()
        end
      end)
    end
  end

  local function OnContentCheckBoxClick(self, contentCheckBox)
    local contentID = self.ContentControls[contentCheckBox]
    self.ContentsTracked[contentID] = true
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------  
  function BuildSettingControls(self)
    --- We wipe the content tracked in case the user has already create a tracker.
    --- The reason this is done here instead in the "OnRelease" method, 
    --- this is because there an issue where the data would be wiped too early 
    --- before the tracker tracks the content chosen if it's done in "OnRelease"
    wipe(self.ContentsTracked)

    local trackerNameEditBox = SUI.SettingsEditBox.Acquire(false, self)
    trackerNameEditBox:SetID(10)
    trackerNameEditBox:SetLabel("Tracker Name")
    trackerNameEditBox:SetInstructions("Enter the tracker name")
    self.SettingControls.trackerNameEditBox = trackerNameEditBox

    local contentsTrackedSection = SUI.SettingsSectionHeader.Acquire(false, self)
    contentsTrackedSection:SetID(20)
    contentsTrackedSection:SetTitle("Contents Tracked")
    self.SettingControls.contentsTrackedSection = contentsTrackedSection

    for index, contentType in IterateContentTypes() do 
      local content = SUI.SettingsCheckBox.Acquire(true, self)
      content:SetID(30+index)
      content:SetLabel(contentType.DisplayName)
      content:SetChecked(false)
      Style[content].MarginLeft = 20

      content.OnCheckBoxClick = content.OnCheckBoxClick + self.OnContentCheckBoxClick
      
      self.ContentControls[content] = contentType.ID
    end

    local createButton = SUI.SuccessPushButton.Acquire(true, self)
    createButton:SetText("Create")
    createButton:SetPoint("BOTTOM")
    createButton.OnClick = createButton.OnClick + self.OnCreateButtonClick
    self.SettingControls.createButton = createButton
  end

  function ReleaseSettingControls(self)
    --- Release the widgets
    self.SettingControls.trackerNameEditBox:Release()
    self.SettingControls.trackerNameEditBox = nil

    self.SettingControls.contentsTrackedSection:Release()
    self.SettingControls.contentsTrackedSection = nil

    local createButton = self.SettingControls.createButton
    createButton.OnClick = createButton.OnClick - self.OnCreateButtonClick 
    createButton:Release()
    self.SettingControls.createButton = nil

    --- Release the contents tracked controls
    for control, contentID in pairs(self.ContentControls) do 
      control.OnCheckBoxClick = control.OnCheckBoxClick - self.OnContentCheckBoxClick

      control:Release()

      self.ContentControls[control] = nil
    end

    --- NOTE: The ContentsTracked table will be wiped in the next build if needed
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

  --- Contains the content controls of "content tracked"
  property "ContentControls" {
    set = false,
    default = function() return Toolset.newtable(true, false) end
  }

  property "ContentsTracked" {
    set = false,
    default = {}
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  function __ctor(self)
    self.OnCreateButtonClick = function(button) OnCreateButtonClick(self, button) end
    self.OnContentCheckBoxClick = function(checkBox) OnContentCheckBoxClick(self, checkBox) end
  end
end)

__Widget__()
class "SLT.SettingDefinitions.Tracker" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnContentCheckBoxClick(self, contentCheckBox)
    local contentID = self.ContentControls[contentCheckBox]
    local isTracked = contentCheckBox:IsChecked()
    self.Tracker:ApplyAndSaveSetting("contentTracked", contentID, isTracked)
  end

  local function OnDeleteButtonClick(self, deleteButton)
    DeleteTracker(self.TrackerID)
  end

  local function OnLockTrackerCheckBoxClick(self, checkBox)
    local isLocked = checkBox:IsChecked()
    self.Tracker:ApplyAndSaveSetting("locked", isLocked)
  end

  local function OnShowTrackerCheckBoxClick(self, checkBox)
    local isShow = checkBox:IsChecked()
    self.Tracker:ApplyAndSaveSetting("hidden", not isShow)
  end

  local function OnBackgroundColorChangedHandler(self, colorPicker, r, g, b, a)
    self.Tracker:ApplySetting("backgroundColor", r, g, b, a)
  end

  local function OnBackgroundColorConfirmedHandler(self, colorPicker, r, g, b, a)
    self.Tracker:ApplyAndSaveSetting("backgroundColor", r, g, b, a)
  end

  local function OnShowScrolBarTrackerCheckBoxClick(self, checkBox)
    local isShow = checkBox:IsChecked()
    self.Tracker:ApplyAndSaveSetting("showScrollBar", isShow)
  end

  local function OnScrollBarPositionEntrySelected(self, dropdown, entry)
    local data = entry:GetEntryData()
    self.Tracker:ApplyAndSaveSetting("scrollBarPosition", data.value)
  end

  local function OnThumbColorChangedHandler(self, colorPicker, r, g, b, a)
    self.Tracker:ApplySetting("scrollBarThumbColor", r, g, b, a)
    -- self.Tracker:GetScrollBar():GetThumb():SetNormalColor(ColorType(r, g, b, a))
  end

  local function OnThumbColorConfirmedHandler(self, colorPicker, r, g, b, a)
    self.Tracker:ApplyAndSaveSetting("scrollBarThumbColor", r, g, b, a)
  end

  local function OnBuildGeneralTab(self, tabControl)
    --- Lock the tracker
    local lock = SUI.SettingsCheckBox.Acquire(false, self)
    lock:SetID(10)
    lock:SetLabel("Lock")
    lock:SetChecked(self.Tracker.Locked)
    lock.OnCheckBoxClick = lock.OnCheckBoxClick + self.OnLockTrackerCheckBoxClick
    self.GeneralTabControls.lockTrackerButton = lock

    --- Show the tracker
    local show = SUI.SettingsCheckBox.Acquire(false, self)
    show:SetID(20)
    show:SetLabel("Show")
    show:SetChecked(self.Tracker:IsShown())
    show.OnCheckBoxClick = show.OnCheckBoxClick + self.OnShowTrackerCheckBoxClick
    self.GeneralTabControls.showTrackerButton = show

    --- Tracker Scale 
    local scaleSlider = SUI.SettingsSlider.Acquire(false, self)
    scaleSlider:SetID(30)
    scaleSlider:SetLabel("Scale")
    scaleSlider:SetSliderLabelFormatter(SUI.Slider.Label.Right)
    scaleSlider:SetMinMaxValues(0.1, 5)
    scaleSlider:SetValueStep(0.01)
    scaleSlider:SetValue(Style[self.Tracker].Scale)
    -- scaleSlider.OnValueChanged = function(_, value)
    --   -- TODO THe handler
    --   self.Tracker:ApplySetting("scale", value)
    -- end
    self.SettingControls.trackerScaleSlider = scaleSlider

    --- Background Color
    local backgroundColor = Style[self.Tracker].backdropColor
    local backgroundColorPicker = SUI.SettingsColorPicker.Acquire(false, self)
    backgroundColorPicker:SetID(40)
    backgroundColorPicker:SetLabel("Background color")

    if backgroundColor then 
      backgroundColorPicker:SetColor(backgroundColor.r, backgroundColor.g, backgroundColor.b, backgroundColor.a)
    end
    backgroundColorPicker.OnColorChanged = backgroundColorPicker.OnColorChanged + self.OnBackgroundColorChangedHandler
    backgroundColorPicker.OnColorConfirmed = backgroundColorPicker.OnColorConfirmed + self.OnBackgroundColorConfirmedHandler
    self.GeneralTabControls.backgroundColorPicker = backgroundColorPicker

    --- Scroll Bar Section
    local scrollBarSection = SUI.ExpandableSection.Acquire(false, self)
    scrollBarSection:SetExpanded(true)
    scrollBarSection:SetID(50)
    scrollBarSection:SetTitle("Scroll Bar")
    Style[scrollBarSection].marginTop = 15
    self.GeneralTabControls.scrollBarSection = scrollBarSection

    --- Scroll Bar -> Show 
    local showScrollBar = SUI.SettingsCheckBox.Acquire(true, scrollBarSection)
    showScrollBar:SetID(10)
    showScrollBar:SetLabel("Show")
    showScrollBar:SetChecked(self.Tracker.ShowScrollBar)
    showScrollBar.OnCheckBoxClick = showScrollBar.OnCheckBoxClick + self.OnShowScrolBarTrackerCheckBoxClick
    self.GeneralTabControls.showScrollBarCheckBox = showScrollBar

    --- Scroll Bar -> Position
    local scrollBarPosition = SUI.SettingsDropDown.Acquire(true, scrollBarSection)
    scrollBarPosition:SetID(20)
    scrollBarPosition:SetLabel("Position")
    scrollBarPosition:AddEntry({ text = "Left", value = "LEFT"})
    scrollBarPosition:AddEntry({ text = "Right", value = "RIGHT"})
    scrollBarPosition:SelectByValue(self.Tracker.ScrollBarPosition)
    scrollBarPosition.OnEntrySelected = scrollBarPosition.OnEntrySelected + self.OnScrollBarPositionEntrySelected
    self.GeneralTabControls.scrollBarPositionDropDown = scrollBarPosition

    -- local thumbColor = Style[self.Tracker].ScrollBar.Track.Thumb.BottomBGTexture.vertexColor
    local thumbColor = self.Tracker:GetScrollBar():GetThumb():GetNormalColor()
    local thumbColorPicker = SUI.SettingsColorPicker.Acquire(true, scrollBarSection)
    thumbColorPicker:SetID(30)
    thumbColorPicker:SetLabel("Thumb color")
    thumbColorPicker:SetColor(thumbColor.r, thumbColor.g, thumbColor.b, thumbColor.a)
    thumbColorPicker.OnColorChanged = thumbColorPicker.OnColorChanged + self.OnThumbColorChanged
    thumbColorPicker.OnColorConfirmed = thumbColorPicker.OnColorConfirmed + self.OnThumbColorConfirmed
    self.GeneralTabControls.thumbColorPicker = thumbColorPicker

    --- The "Danger zone" won't appear for main tracker as it's not intended to be deleted.
    if self.Tracker.ID ~= "main" then 
      --- Danger zone section
      local dangerZoneSection = SUI.ExpandableSection.Acquire(false, self)
      dangerZoneSection:SetExpanded(false)
      dangerZoneSection:SetID(999)
      dangerZoneSection:SetTitle("|cffff0000Danger Zone|r")
      Style[dangerZoneSection].marginTop = 15
      self.GeneralTabControls.dangerZoneSection = dangerZoneSection

      --- Danger zone -> delete button
      local deleteButton = SUI.DangerPushButton.Acquire(true, dangerZoneSection)
      deleteButton:SetText("Delete the tracker")
      deleteButton:SetID(10)
      deleteButton.OnClick = deleteButton.OnClick + self.OnDeleteButtonClick
      Style[deleteButton].marginLeft = 250
      self.GeneralTabControls.deleteButton = deleteButton
    end
  end

  local function OnReleaseGeneralTab(self, tabControl)
    for index, control in pairs(self.GeneralTabControls) do
      --- Remove the specific event handlers
      if index == "lockTrackerButton" then 
        control.OnCheckBoxClick = control.OnCheckBoxClick - self.OnLockTrackerCheckBoxClick
      elseif index == "showTrackerButton" then 
        control.OnCheckBoxClick = control.OnCheckBoxClick - self.OnShowTrackerCheckBoxClick
      elseif index == "showScrollBarCheckBox" then 
        control.OnCheckBoxClick = control.OnCheckBoxClick - self.OnShowScrolBarTrackerCheckBoxClick
      elseif index == "scrollBarPositionDropDown" then 
        control.OnEntrySelected = control.OnEntrySelected - self.OnScrollBarPositionEntrySelected
      elseif index == "deleteButton" then 
        control.OnClick = control.OnClick - self.OnDeleteButtonClick
      end

      --- Release the control
      control:Release()
      self.GeneralTabControls[index] = nil
    end
  end 

  local function OnBuildContentsTrackedTab(self, tabControl)
    local contentsTrackedSection = SUI.SettingsSectionHeader.Acquire(false, self)
    contentsTrackedSection:SetID(2)
    contentsTrackedSection:SetTitle("Contents Tracked")
    self.SettingControls.contentsTrackedSection = contentsTrackedSection

    for index, contentType in IterateContentTypes() do
      local content = SUI.SettingsCheckBox.Acquire(true, self)
      content:SetID(3+index)
      content:SetLabel(contentType.DisplayName)
      content:SetChecked(self.Tracker:IsContentTracked(contentType.ID))
      Style[content].MarginLeft = 20

      content.OnCheckBoxClick = content.OnCheckBoxClick + self.OnContentCheckBoxClick

      self.ContentControls[content] = contentType.ID
    end
  end

  local function OnReleaseContentsTrackedTab(self, tabControl)

    self.SettingControls.contentsTrackedSection:Release()
    self.SettingControls.contentsTrackedSection = nil

    --- Release the contents tracked controls
    for control, contentID in pairs(self.ContentControls) do 
      control.OnCheckBoxClick = control.OnCheckBoxClick - self.OnContentCheckBoxClick
      control:Release()
      self.ContentControls[control] = nil
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
      onAcquire = function(...) return OnBuildGeneralTab(self, ...) end,
      onRelease = function(...) return OnReleaseGeneralTab(self, ...) end
    })

    tabControl:AddTabPage({
      name = "Contents Tracked",
      onAcquire = function(...) return OnBuildContentsTrackedTab(self, ...) end,
      onRelease = function(...) return OnReleaseContentsTrackedTab(self, ...) end
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
  --- Contains all controls except the content controls
  property "SettingControls" {
    set = false,
    default = function() return Toolset.newtable(false, true) end 
  }

  property "GeneralTabControls" {
    set = false,
    default = function() return Toolset.newtable(false, true) end
  }

  --- Contains the contents control of "content tracked"
  property "ContentControls" {
    set = false,
    default = function() return Toolset.newtable(true, false) end
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
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  function __ctor(self)
    --- General tab handlers
    self.OnLockTrackerCheckBoxClick = function(checkBox) OnLockTrackerCheckBoxClick(self, checkBox) end
    self.OnShowTrackerCheckBoxClick = function(checkBox) OnShowTrackerCheckBoxClick(self, checkBox) end
    self.OnBackgroundColorChangedHandler = function(...) OnBackgroundColorChangedHandler(self, ...) end 
    self.OnBackgroundColorConfirmedHandler = function(...) OnBackgroundColorConfirmedHandler(self, ...) end
    self.OnShowScrolBarTrackerCheckBoxClick = function(checkBox) OnShowScrolBarTrackerCheckBoxClick(self, checkBox) end
    self.OnScrollBarPositionEntrySelected = function(...) OnScrollBarPositionEntrySelected(self, ...) end
    self.OnThumbColorChanged = function(...) OnThumbColorChangedHandler(self, ...) end
    self.OnThumbColorConfirmed = function(...) OnThumbColorConfirmedHandler(self, ...) end 

    --- Contents Tracked tab handlers 
    self.OnContentCheckBoxClick = function(checkBox) OnContentCheckBoxClick(self, checkBox) end
    self.OnDeleteButtonClick = function(button) OnDeleteButtonClick(self, button) end
  end
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