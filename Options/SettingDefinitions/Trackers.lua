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
  IterateContents = SylingTracker.API.IterateContents
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
            tracker:ApplyAndSaveSetting("contentTracked", contentID, isTracked)
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
    -- createButton:SetUserHandler("OnClick", OnCreateButtonClick)
    self.SettingControls.createButton = createButton


  end

  function ReleaseSettingControls(self)
    --- Release the widgets 
    for index, control in pairs(self.SettingControls) do 
      control:Release()
      self.SettingControls[index] = control
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
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function BuildSettingControls(self)
    local tabControl = Widgets.TabControl.Acquire(false, self)
    tabControl:SetID(1)
    tabControl:AddTabPage({
      name = "General",
      onAcquire = function() end,
      onRelease = function() end 
    })

    tabControl:AddTabPage({
      name = "Contents Tracked",
      onAcquire = function() end,
      onRelease = function() end 
    })

    tabControl:AddTabPage({
      name = "Visibility Rules",
      onAcquire = function() end,
      onRelease = function() end 
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
  };
  [SettingDefinitions.Tracker] = {
    layoutManager = Layout.VerticalLayoutManager(true, true)
  }
})