-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                "SylingTracker_Options.Bootstrap"                      ""
-- ========================================================================= --
export {
  IterateTrackers               = SylingTracker.API.IterateTrackers
}

LOGO_WHITE = [[Interface\AddOns\SylingTracker_Options\Media\logo_white]]
SETTINGS_PANEL = nil 

__SystemEvent__()
__Async__() function SylingTracker_OPEN_OPTIONS()
  if not SETTINGS_PANEL then 
    local panel = Widgets.SettingsPanel.Acquire()
    panel:Hide()
    panel:SetParent(UIParent)
    panel:SetPoint("CENTER")
    panel:SetFrameStrata("HIGH")
    panel:SetTitle("Syling Tracker Options")
    panel:EnableMouse(true)
    panel:SetAddonVersion("2.0.0")
    panel:SetAddonLogo(LOGO_WHITE)
    panel:InstantApplyStyle()
    
    --- Create categories
    panel:CreateCategory("general", "General")
    panel:CreateCategory("trackers", "My Trackers")
    panel:CreateCategory("contents", "Contents")
    -- panel:CreateCategory("userContents", "My Contents")

    panel:AddCategoryEntry({ text = "Settings", value = SettingDefinitions.General }, "general")
    panel:AddCategoryEntry({ text = "Media"}, "general")
    panel:AddCategoryEntry({ text = "Item Bar", value = SettingDefinitions.ItemBar }, "general")
    panel:AddCategoryEntry({ text = "Context Menu"}, "general")
    panel:AddCategoryEntry({ text = "Objective", value = SettingDefinitions.Objective}, "general")

    -- My Trackers entries 
    _M:CreateTrackerEntries(panel)

    -- Contents entries
    panel:AddCategoryEntry({ text = "Quests"}, "contents")
    panel:AddCategoryEntry({ text = "World Quests"}, "contents")
    panel:AddCategoryEntry({ text = "Bonus objectives"}, "contents")
    panel:AddCategoryEntry({ text = "Scenario"}, "contents")
    panel:AddCategoryEntry({ text = "Mythic +"}, "contents")
    panel:AddCategoryEntry({ text = "Dungeon"}, "contents")
    panel:AddCategoryEntry({ text = "Achievements"}, "contents")
    panel:AddCategoryEntry({ text = "Torghast"}, "contents")
    panel:AddCategoryEntry({ text = "Quests"}, "contents")
    
    -- Refresh the panel for creating entries
    panel:Refresh()

    -- We select the first entry of 'general' category
    panel:SelectEntry("general", 1)

    -- We add a slight delay for giving some time the panel entries to be created
    -- on the first opening.
    for i = 1, 6 do 
      Next()
    end

    -- We makes the panel is closable with the 'Escape' key
    _G["SylingTracker_Options"] = panel 
    tinsert(UISpecialFrames, "SylingTracker_Options")

    SETTINGS_PANEL = panel 
  end

  SETTINGS_PANEL:Show()
end

function CreateTrackerEntries(self, panel)
  panel:AddCategoryEntry({
    text = "Main",
    id = "main",
    value = function()
      local settings = SettingDefinitions.Tracker.Acquire()
      settings.TrackerID = "main"
      return settings
    end
  }, "trackers")

  for trackerID, tracker in IterateTrackers(false) do 
    panel:AddCategoryEntry({
      text = trackerID:gsub("^%l", string.upper),
      id = trackerID,
      value = function()
        local settings = SettingDefinitions.Tracker.Acquire()
        settings.TrackerID = trackerID
        return settings
      end
    }, "trackers")
  end

  panel:AddCategoryEntry({ 
    text = "|A:tradeskills-icon-add:16:16|a |cff00ff00Create a tracker|r",
    value = SettingDefinitions.CreateTracker,
    styles = {
      marginTop = 10
    }
  }, "trackers")
end

__SystemEvent__()
function SylingTracker_TRACKER_CREATED(tracker)
  SETTINGS_PANEL:ClearEntries("trackers")
  _M:CreateTrackerEntries(SETTINGS_PANEL)
  SETTINGS_PANEL:Refresh()
  SETTINGS_PANEL:SelectEntryById("trackers", tracker.id)
end


__SystemEvent__()
function SylingTracker_TRACKER_DELETED(tracker)
  SETTINGS_PANEL:RemoveEntryById(tracker.id)
  SETTINGS_PANEL:SelectEntry("general", 1)
  SETTINGS_PANEL:Refresh("trackers")
end