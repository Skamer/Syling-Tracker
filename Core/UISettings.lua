-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                   "SylingTracker.Core.UISettings"                     ""
-- ========================================================================= --
export { 
  EscapeSpecialRegexCharacter = Utils.EscapeSpecialRegexCharacter
}

SUBJECTS_ONLOAD_PROCESS_DONE  = false
UI_SETTINGS_DB_INDEX          = "uiSettings"
UI_SETTING_SUBJECTS           = {}

UI_SETTINGS_DB = nil

class "UISetting" (function(_ENV)
  -----------------------------------------------------------------------------
  --                                Methods                                  --
  -----------------------------------------------------------------------------
  __Arguments__ { UISetting }
  function AddChild(self, child)
    child.Parent = self 

    self.Children[child.id] = child
  end

  --- This function is called when its parent (include also grandparent, ...) has changed.
  ---
  --- @param fromParent the parent (or grandparent, ...) has a changed value 
  --- @param value the new parent (or grandparent, ...)  value
  --- 
  --- NOTE: A temporary variable fromParent.__previousResolvedSettings has created for this method 
  --- in case where checking are needed. 
  __Arguments__ { UISetting, Any/nil }
  function OnParentValueChanged(self, fromParent, value)

    -- In case where our parent hasn't the resposability of this setting, don't need 
    -- to continue. 
    if self.ResolvedSetting ~= fromParent.__previousResolvedSetting then 
      return 
    end

    self.__previousResolvedSetting = self.ResolvedSetting
    self.ResolvedSetting = fromParent.ResolvedSetting

    for _, child in pairs(self.Children) do 
      child:OnParentValueChanged(fromParent, value)
    end

    self.__previousResolvedSetting = nil 

    local subject = UI_SETTING_SUBJECTS[self.id]

    if subject then
      subject:OnNext(value)
    end
  end

  --- Set the value. If the value is nil, this fallback to default if there is one.
  --- If the value changes, this will notify the observers if needed. 
  ---
  --- @param value the value to set.
  ---
  __Arguments__ { Any/nil}
  function SetValue(self, value)
    local id = self.id
    
    local previousValue = UI_SETTINGS_DB[id]
    -- local previousValue = SavedVariables.Profile().Path(UI_SETTINGS_DB_INDEX).GetValue(id)
    if previousValue == nil then 
      previousValue = self.Default
    end

    local newValue = value 
    if newValue == nil then 
      newValue = self.Default 
    end

    -- If there no effective change in the value, don't continue.  
    if previousValue and newValue and previousValue == newValue then 
      return 
    end

    if value == nil then
      SavedVariables.Profile().Path(UI_SETTINGS_DB_INDEX).SetValue(id, nil)
      -- UI_SETTINGS_DB[id] = nil
    else
      SavedVariables.Profile().Path(UI_SETTINGS_DB_INDEX).SaveValue(id, value)
      -- UI_SETTINGS_DB[id] = value 
    end

    if not self.ResolvedSetting then
      return 
    end

    local resolvedValue, resolvedSetting 

    if value ~= nil then 
      resolvedValue, resolvedSetting = value, self 
    elseif self.Default then
      resolvedValue, resolvedSetting = self.Default, self 
    elseif self.Parent then 
      resolvedValue, resolvedSetting = self.Parent:GetValue()
    else
      resolvedValue, resolvedSetting = nil, self 
    end

    -- We keep the previous resolved setting in a temporary variable
    -- for the method 'OnParentValueChanged'. 
    self.__previousResolvedSetting = self.ResolvedSetting
    self.ResolvedSetting = resolvedSetting

    for _, child in pairs(self.Children) do 
      child:OnParentValueChanged(self, resolvedValue)
    end

    -- We remove the temporary variable as it's no longer needed.
    self.__previousResolvedSetting = nil

    -- We notify the observers if needed.
    local subject = UI_SETTING_SUBJECTS[id]
    if subject then
      subject:OnNext(resolvedValue)
    end

    _M:FireSystemEvent("SylingTracker_UI_SETTING_CHANGED", id, resolvedValue)
  end

  --- Get the value. By default, if there no value, this will get from parent side, 
  --- otherwise return nill if nothing has been found.
  ---
  --- @param includeParent is we should search parent side if needed ?
  --- @param includeDefault is we should include the default value if needed ?
  __Arguments__ { Boolean/true, Boolean/true}
  function GetValue(self, includeParent, includeDefault )
    local useCacheResolution = includeParent and includeDefault

    
    if useCacheResolution and self.ResolvedSetting and self.ResolvedSetting ~= self then
      return self.ResolvedSetting:GetValue(), self.ResolvedSetting
    end
    
    local value = SavedVariables.AbsPath(UI_SETTINGS_DB_INDEX).GetValue(self.id)
    -- local value = UI_SETTINGS_DB[self.id]
    -- print("Finished", GetTime() - START_TIME)
    -- print("Get Value", self.id)
    if value ~= nil then
      if useCacheResolution and not self.ResolvedSetting then 
        self.ResolvedSetting = self 
      end
      
      return value, useCacheResolution and self.ResolvedSetting
    end

    if includeDefault and self.Default ~= nil then
      if useCacheResolution and not self.ResolvedSetting then 
        self.ResolvedSetting = self 
      end
      
      return self.Default, useCacheResolution and self.ResolvedSetting
    end
    
    
    if includeParent and self.Parent then
      local value, resolvedSetting = self.Parent:GetValue(includeParent, includeDefault)
      
      if not self.ResolvedSetting and useCacheResolution then 
        self.ResolvedSetting = resolvedSetting
      end
      
      return value, useCacheResolution and self.ResolvedSetting
    end

  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "id" {
    type = String 
  }

  property "Default" {
    type = Any
  }

  property "Children" {
    type = Table,
    default = function() return System.Toolset.newtable(true, true) end 
  }

  property "Parent" {
    type = UISetting
  }

  property "ResolvedSetting" {
    type = UISetting
  }
end)
-------------------------------------------------------------------------------
--                             Enchance the API                              --
-------------------------------------------------------------------------------
UI_SETTINGS = {}

--- Get the value for a ui setting 
---
--- @param id the ui setting id 
__Arguments__ { String }
__Static__() function API.GetUISetting(id)
  local setting = UI_SETTINGS[id]

  if not setting then
    return 
  end

  return setting:GetValue()
end

--- Set the value for a ui setting 
---
--- @param id the ui setting to set the value
--- @param value the value to set 
__Arguments__ { String, Any/nil }
__Static__() function API.SetUISetting(id, value)
  local setting = UI_SETTINGS[id]

  if not setting then 
    return 
  end

  setting:SetValue(value)
end

--- Register an ui setting 
--- 
--- @param id the ui setting id to register 
--- @param default the default value 
--- @param parentID the parent id where the setting will inherit. 
__Arguments__ { String, Any/nil, String/nil }
__Static__() function API.RegisterUISetting(id, default, parentID)
  if UI_SETTINGS[id] then 
    error(("Trying to register an ui settings with an id ('%s') already used"):format(id))
  end

  local uiSetting = UISetting() 
  uiSetting.id = id 
  uiSetting.Default = default 

  local parent = parentID and UI_SETTINGS[parentID]

  if parent then 
    parent:AddChild(uiSetting)
  end

  UI_SETTINGS[id] = uiSetting
end

--- Generate settings
---
--- @param prefix
--- @param parentPrefix 
--- @param func 
__Arguments__ { String, String, Callable/nil }
__Static__() function API.GenerateUISettings(prefix, parentPrefix, func)
  local parrentPattern = "^" .. EscapeSpecialRegexCharacter(parentPrefix) .. "%.(.*)"
  local generatedSettings

  for parentID, parrentSetting in pairs(UI_SETTINGS) do 
    local suffix = string.match(parentID, parrentPattern)

    if suffix then 
      local setting = {}
      setting.id = prefix .. "." .. suffix
      setting.parentID = parentID

      if not generatedSettings then 
        generatedSettings = {}
      end

      generatedSettings[setting.id] = setting
    end
  end

  if func and generatedSettings then 
    func(generatedSettings)
  end

  if generatedSettings then 
    for id, info in pairs(generatedSettings) do
      API.RegisterUISetting(id, info.default, info.parentID)
    end
  end
end

__Arguments__ { String }
__Static__() function API.FromUISetting(id)
  return Observable(function(observer)
    local subject = UI_SETTING_SUBJECTS[id]

    if not subject then 
      subject = BehaviorSubject()
      UI_SETTING_SUBJECTS[id] = subject 
    end

    subject:Subscribe(observer)

    if SUBJECTS_ONLOAD_PROCESS_DONE then 
      local setting = UI_SETTINGS[id]
      if setting then
        local value = setting:GetValue()
        subject:OnNext(value)
      end
    end

    return subject
  end)
end

__Arguments__ { String * 0}
__Static__() function API.FromUISettings(...)
  local observable
  local useNext = false
  for i = 1, select("#", ...) do 
    local arg = select(i, ...)
    observable = observable and observable:CombineLatest(API.FromUISetting(arg)) or API.FromUISetting(arg)

    if i > 1 then 
      useNext = true
    end
  end

  if useNext then 
    return observable:Next()
  end

  return observable
end

function OnLoad(self)
  -- When the db is initialized, we read the ui settings and notify the observer
  UI_SETTINGS_DB = SavedVariables.Profile().GetValue(UI_SETTINGS_DB_INDEX) or {}

  for id, subject in pairs(UI_SETTING_SUBJECTS) do 
    local setting = UI_SETTINGS[id]
    if setting then
      local value = setting:GetValue()

      subject:OnNext(value)
    end
  end

  SUBJECTS_ONLOAD_PROCESS_DONE = true
end