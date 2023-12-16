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
  IterateTrackers               = SylingTracker.API.IterateTrackers,
  GetAddonVersion               = SylingTracker.Utils.GetAddonVersion
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
    panel:SetAddonVersion(GetAddonVersion())
    panel:SetAddonLogo(LOGO_WHITE)
    panel:InstantApplyStyle()
    
    --- Create categories
    panel:CreateCategory("general", "General")
    panel:CreateCategory("trackers", "My Trackers")
    panel:CreateCategory("contents", "Contents")
    -- panel:CreateCategory("advanced", "Advanced")
    -- panel:CreateCategory("userContents", "My Contents")

    panel:AddCategoryEntry({ text = "Settings", value = SettingDefinitions.General }, "general")
    -- panel:AddCategoryEntry({ text = "|cffabababMedia (NYI)|r"}, "general")
    panel:AddCategoryEntry({ text = "Item Bar", value = SettingDefinitions.ItemBar }, "general")
    -- panel:AddCategoryEntry({ text = "|cffabababContext Menu (NYI)|r"}, "general")
    panel:AddCategoryEntry({ text = "Objective", value = SettingDefinitions.Objective}, "general")

    -- My Trackers entries 
    _M:CreateTrackerEntries(panel)

    -- Contents entries
    panel:AddCategoryEntry({ text = "Quests", value = SettingDefinitions.Quests}, "contents")
    panel:AddCategoryEntry({ text = "Achievements", value = SettingDefinitions.Achievements}, "contents")

    -- Advanced entries 
    -- panel:AddCategoryEntry({ text = "|cffabababSkin (NYI)|r"}, "advanced")
    -- panel:AddCategoryEntry({ text = "|cffabababUI Settings (NYI)|r"}, "advanced")
    
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

  for trackerID in IterateTrackers(false) do
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
function SylingTracker_TRACKER_CREATED(trackerID)
  SETTINGS_PANEL:ClearEntries("trackers")
  _M:CreateTrackerEntries(SETTINGS_PANEL)
  SETTINGS_PANEL:Refresh()
  SETTINGS_PANEL:SelectEntryById("trackers", trackerID)
end


__SystemEvent__()
function SylingTracker_TRACKER_DELETED(trackerID)
  SETTINGS_PANEL:RemoveEntryById(trackerID)
  SETTINGS_PANEL:SelectEntry("general", 1)
  SETTINGS_PANEL:Refresh("trackers")
end

TEXT_TRANSFORM_ENTRIES = Array[Widgets.EntryData]()
TEXT_TRANSFORM_ENTRIES:Insert({ text = "NONE", value = "NONE"})
TEXT_TRANSFORM_ENTRIES:Insert({ text = "UPPERCASE", value = "UPPERCASE"})
TEXT_TRANSFORM_ENTRIES:Insert({ text = "lowercase", value = "LOWERCASE"})
_Parent.TEXT_TRANSFORM_ENTRIES = TEXT_TRANSFORM_ENTRIES

TEXT_JUSTIFY_H_ENTRIES = Array[Widgets.EntryData]()
TEXT_JUSTIFY_H_ENTRIES:Insert({ text = "LEFT", value = "LEFT"})
TEXT_JUSTIFY_H_ENTRIES:Insert({ text = "CENTER", value = "CENTER"})
TEXT_JUSTIFY_H_ENTRIES:Insert({ text = "RIGHT", value = "RIGHT"})
_Parent.TEXT_JUSTIFY_H_ENTRIES = TEXT_JUSTIFY_H_ENTRIES

TEXT_JUSTIFY_V_ENTRIES = Array[Widgets.EntryData]()
TEXT_JUSTIFY_V_ENTRIES:Insert({ text = "TOP", value = "TOP"})
TEXT_JUSTIFY_V_ENTRIES:Insert({ text = "MIDDLE", value = "MIDDLE"})
TEXT_JUSTIFY_V_ENTRIES:Insert({ text = "BOTTOM", value = "BOTTOM"})
_Parent.TEXT_JUSTIFY_V_ENTRIES = TEXT_JUSTIFY_V_ENTRIES