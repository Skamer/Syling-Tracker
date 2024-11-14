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
  L                             = _Locale,
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
    panel:SetTitle("Syling Tracker " .. L.OPTIONS)
    panel:EnableMouse(true)
    panel:SetAddonVersion(GetAddonVersion())
    panel:SetAddonLogo(LOGO_WHITE)
    panel:InstantApplyStyle()
    
    --- Create categories
    panel:CreateCategory("general", L.GENERAL)
    panel:CreateCategory("trackers", L.MY_TRACKERS)
    panel:CreateCategory("contents", L.CONTENTS)
    -- panel:CreateCategory("advanced", "Advanced")
    -- panel:CreateCategory("userContents", "My Contents")

    panel:AddCategoryEntry({ text = L.SETTINGS, value = SettingDefinitions.General }, "general")
    -- panel:AddCategoryEntry({ text = "|cffabababMedia (NYI)|r"}, "general")
    panel:AddCategoryEntry({ text = L.ITEM_BAR, value = SettingDefinitions.ItemBar }, "general")
    -- panel:AddCategoryEntry({ text = "|cffabababContext Menu (NYI)|r"}, "general")
    panel:AddCategoryEntry({ text = L.OBJECTIVE, value = SettingDefinitions.Objective}, "general")

    -- My Trackers entries 
    _M:CreateTrackerEntries(panel)

    -- Contents entries
    panel:AddCategoryEntry({ text = L.AUTO_QUESTS, value = SettingDefinitions.AutoQuests}, "contents")
    panel:AddCategoryEntry({ text = L.QUESTS, value = SettingDefinitions.Quests}, "contents")
    panel:AddCategoryEntry({ text = L.TASKS, value = SettingDefinitions.Tasks}, "contents")
    -- panel:AddCategoryEntry({ text = "World Quests"}, "contents")
    -- panel:AddCategoryEntry({ text = "Bonus objectives"}, "contents")
    panel:AddCategoryEntry({ text = L.SCENARIO, value = SettingDefinitions.Scenario}, "contents")
    panel:AddCategoryEntry({ text = Color.GRAY .. L.KEYSTONE .. " (NYI)"}, "contents")
    panel:AddCategoryEntry({ text = L.DUNGEON, value = SettingDefinitions.Dungeon}, "contents")
    panel:AddCategoryEntry({ text = L.ACHIEVEMENTS, value = SettingDefinitions.Achievements}, "contents")
    panel:AddCategoryEntry({ text = L.PROFESSION, value = SettingDefinitions.Profession}, "contents")
    panel:AddCategoryEntry({ text = L.ACTIVITIES, value = SettingDefinitions.Activities}, "contents")
    panel:AddCategoryEntry({ text = L.COLLECTIONS, value = SettingDefinitions.Collections}, "contents")
    -- panel:AddCategoryEntry({ text = "Torghast"}, "contents")
    -- panel:AddCategoryEntry({ text = "Quests"}, "contents")

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
    text = ("|A:tradeskills-icon-add:16:16|a |cff00ff00%s|r"):format(L.TRACKER_CREATE),
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
TEXT_TRANSFORM_ENTRIES:Insert({ text = L.NONE, value = "NONE"})
TEXT_TRANSFORM_ENTRIES:Insert({ text = L.TEXT_TRANSFORM_UPPERCASE, value = "UPPERCASE"})
TEXT_TRANSFORM_ENTRIES:Insert({ text = L.TEXT_TRANSFORM_LOWERCASE, value = "LOWERCASE"})
_Parent.TEXT_TRANSFORM_ENTRIES = TEXT_TRANSFORM_ENTRIES

TEXT_JUSTIFY_H_ENTRIES = Array[Widgets.EntryData]()
TEXT_JUSTIFY_H_ENTRIES:Insert({ text = L.TEXT_JUSITFY_H_LEFT, value = "LEFT"})
TEXT_JUSTIFY_H_ENTRIES:Insert({ text = L.TEXT_JUSITFY_H_CENTER, value = "CENTER"})
TEXT_JUSTIFY_H_ENTRIES:Insert({ text = L.TEXT_JUSITFY_H_RIGHT, value = "RIGHT"})
_Parent.TEXT_JUSTIFY_H_ENTRIES = TEXT_JUSTIFY_H_ENTRIES

TEXT_JUSTIFY_V_ENTRIES = Array[Widgets.EntryData]()
TEXT_JUSTIFY_V_ENTRIES:Insert({ text = L.TEXT_JUSITFY_V_TOP, value = "TOP"})
TEXT_JUSTIFY_V_ENTRIES:Insert({ text = L.TEXT_JUSITFY_V_MIDDLE, value = "MIDDLE"})
TEXT_JUSTIFY_V_ENTRIES:Insert({ text = L.TEXT_JUSITFY_V_BOTTOM, value = "BOTTOM"})
_Parent.TEXT_JUSTIFY_V_ENTRIES = TEXT_JUSTIFY_V_ENTRIES