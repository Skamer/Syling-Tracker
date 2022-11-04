-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                      "SylingTracker.Options"                          ""
-- ========================================================================= --
export {
  IterateTrackers = SLT.API.IterateTrackers
}

SLT_LOGO_WHITE = [[Interface\AddOns\SylingTracker_Options\Media\logo_white]]

_SETTINGS_PANEL = nil

--- Create the text transform  entries
TEXT_TRANSFORM_ENTRIES = Array[SUI.EntryData]()
TEXT_TRANSFORM_ENTRIES:Insert({ text = "Normal"})
TEXT_TRANSFORM_ENTRIES:Insert({ text = "UPPERCASE"})
TEXT_TRANSFORM_ENTRIES:Insert({ text = "lowercase"})

local function AddTrackerEntries(panel)
  panel:AddCategoryEntry({
    text = "Main",
    id = "main",
    value = function()
      local settings = SLT.SettingDefinitions.Tracker.Acquire()
      settings.TrackerID = "main"
      return settings
    end
  }, "trackers")

  for trackerId, tracker in IterateTrackers(false) do
    panel:AddCategoryEntry({
      text = trackerId:gsub("^%l", string.upper),
      id = trackerId,
      value = function()
        local settings = SLT.SettingDefinitions.Tracker.Acquire()
        settings.TrackerID = trackerId
        return settings
      end
    }, "trackers")
  end

  panel:AddCategoryEntry({
    text = "|A:tradeskills-icon-add:16:16|a |cff00ff00Create a tracker|r", 
    value = SLT.SettingDefinitions.CreateTracker,
    styles = {
      marginTop = 10
    }
  }, "trackers")
end

__SystemEvent__()
function SLT_OPEN_OPTIONS()
  if not _SETTINGS_PANEL then 
      local panel = SUI.SettingsPanel.Acquire()
      panel:SetParent(UIParent)
      panel:SetPoint("CENTER")
      panel:SetFrameStrata("HIGH")
      panel:SetTitle("Syling Tracker Options")
      panel:EnableMouse(true)
      panel:SetAddonVersion(SLT_VERSION)
      panel:SetAddonLogo(SLT_LOGO_WHITE)
      panel:InstantApplyStyle()

      --- Create categories
      panel:CreateCategory("general", "General")
      panel:CreateCategory("trackers", "My Trackers")

      --- General category entries
      panel:AddCategoryEntry({ text = "Settings", value = SLT.SettingDefinitions.General}, "general")
      panel:AddCategoryEntry({ text = "Item Bar", value = SLT.SettingDefinitions.ItemBar}, "general")

      --- My Trackers entries 
      AddTrackerEntries(panel)

      --- Refresh the panel for creating entries
      panel:Refresh()

      --- We select the first entry of general category
      panel:SelectEntry("general", 1)

      --- We makes the panel is closable with the Escape key
      _G["SLT_OptionsPanel"] = panel
      tinsert(UISpecialFrames, "SLT_OptionsPanel")

      _SETTINGS_PANEL = panel
  end

  _SETTINGS_PANEL:Show()
end

__SystemEvent__()
function SLT_CLOSE_OPTIONS()
  if _SETTINGS_PANEL then 
    _SETTINGS_PANEL:Hide() 
  end
end

__SystemEvent__()
function SLT_TRACKER_CREATED(tracker)
  _SETTINGS_PANEL:ClearEntries("trackers")
  AddTrackerEntries(_SETTINGS_PANEL)
  _SETTINGS_PANEL:Refresh()

  _SETTINGS_PANEL:SelectEntryById("trackers", tracker.ID)
end

__SystemEvent__()
function SLT_TRACKER_DELETED(tracker)
  _SETTINGS_PANEL:RemoveEntryById(tracker.ID)
  _SETTINGS_PANEL:SelectEntry("general", 1)
  _SETTINGS_PANEL:Refresh("trackers")
end