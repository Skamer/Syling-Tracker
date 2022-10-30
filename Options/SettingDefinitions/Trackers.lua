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

  for k,v in GetContentTypes():Sort("x,y=>x.DisplayName<y.DisplayName"):GetIterator() do 
    yield(k,v)
  end
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
      tracker.Locked = false
      for contentID in pairs(self.ContentsTracked) do 
        tracker:TrackContentType(contentID)
      end
    end
  end

  local function OnContentCheckBoxClick(self, contentCheckBox)
    local contentID = self.SettingControls.contentsTrackedControls[contentCheckBox]
    self.ContentsTracked[contentID] = true
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------  
  function BuildSettingControls(self)
    local trackerNameEditBox = SUI.SettingsEditBox.Acquire(false, self)
    trackerNameEditBox:SetID(1)
    trackerNameEditBox:SetLabel("Tracker Name")
    trackerNameEditBox:SetInstructions("Enter the tracker name")
    self.SettingControls.trackerNameEditBox = trackerNameEditBox

    local contentsTrackedSection = SUI.SettingsSectionHeader.Acquire(false, self)
    contentsTrackedSection:SetID(2)
    contentsTrackedSection:SetTitle("Contents Tracked")
    self.SettingControls.contentsTrackedSection = contentsTrackedSection

    for index, contentType in IterateContentTypes() do
      local contentsTrackedControls = self.SettingControls.contentsTrackedControls
      if not contentsTrackedControls then
        contentsTrackedControls = System.Toolset.newtable(true, false)
        self.SettingControls.contentsTrackedControls = contentsTrackedControls
      end 

      local content = SUI.SettingsCheckBox.Acquire(true, self)
      content:SetID(3+index)
      content:SetLabel(contentType.DisplayName)
      content:SetChecked(false)
      Style[content].MarginLeft = 20

      content.OnCheckBoxClick = content.OnCheckBoxClick + self.OnContentCheckBoxClick

      contentsTrackedControls[content] = contentType.ID
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
    local contentsTrackedControls = self.SettingControls.contentsTrackedControls
    if contentsTrackedControls then 
      for control, contentID in pairs(contentsTrackedControls) do 
        control:Release()
        contentsTrackedControls[control] = nil
      end

      self.SettingControls.contentsTrackedControls = nil
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
    local tracker = GetTracker(self.TrackerID)
    local contentID = self.ContentControls[contentCheckBox]
    local isTracked = contentCheckBox:IsChecked()

    if isTracked then 
      tracker:TrackContentType(contentID)
    else
      tracker:UntrackContentType(contentID)
    end
  end

  local function OnDeleteButtonClick(self, deleteButton)
    DeleteTracker(self.TrackerID)
  end

  local function OnBuildGeneralTab(self, tabControl)
    local enable = SUI.SettingsCheckBox.Acquire(false, self)
    enable:SetID(2)
    enable:SetLabel("Enable")
    self.GeneralTabControls.enableTrackerButton = enable

    local lock = SUI.SettingsCheckBox.Acquire(false, self)
    lock:SetID(3)
    lock:SetLabel("Lock")
    self.GeneralTabControls.lockTrackerButton = lock

    local show = SUI.SettingsCheckBox.Acquire(false, self)
    show:SetID(4)
    show:SetLabel("Show")
    self.GeneralTabControls.showTrackerButton = show

    local scrollBarSection = SUI.ExpandableSection.Acquire(false, self)
    scrollBarSection:SetExpanded(true)
    scrollBarSection:SetID(5)
    scrollBarSection:SetTitle("Scroll Bar")
    Style[scrollBarSection].marginTop = 15
    self.GeneralTabControls.scrollBarSection = scrollBarSection

    local showScrollBar = SUI.SettingsCheckBox.Acquire(true, scrollBarSection)
    showScrollBar:SetID(1)
    showScrollBar:SetLabel("Show ScrollBar")
    self.GeneralTabControls.showScrollBarCheckBox = showScrollBar


    local contentsExpandableSection = SUI.ExpandableSection.Acquire(false, self)
    contentsExpandableSection:SetExpanded(false)
    contentsExpandableSection:SetID(6)
    contentsExpandableSection:SetTitle("|cffff0000Danger Zone|r")
    Style[contentsExpandableSection].marginTop = 15
    self.GeneralTabControls.contentsExpandableSection = contentsExpandableSection

    local deleteButton = SUI.DangerPushButton.Acquire(true, contentsExpandableSection)
    deleteButton:SetText("Delete the tracker")
    deleteButton:SetID(1)
    deleteButton.OnClick = deleteButton.OnClick + self.OnDeleteButtonClick
    Style[deleteButton].marginLeft = 250
    self.GeneralTabControls.deleteButton = deleteButton
  end

  local function OnReleaseGeneralTab(self, tabControl)
    self.GeneralTabControls.deleteButton = self.GeneralTabControls.deleteButton - self.OnDeleteButtonClick


    for index, control in pairs(self.GeneralTabControls) do
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
      content:SetChecked(false)
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
    --default = ""
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  function __ctor(self)
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