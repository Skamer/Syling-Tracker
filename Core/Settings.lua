-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                  "SylingTracker.Core.Settings"                        ""
-- ========================================================================= --
namespace                          "SLT"
-- ========================================================================= --
class "Setting" (function(_ENV)
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "ID" {
    type = String 
  }

  property "Default" {
    type = Any
  }

  property "Func" {
    type = Callable + String
  }
  -----------------------------------------------------------------------------
  --                          Meta-Methods                                   --
  -----------------------------------------------------------------------------
  function __call(self, ...)
    if self.Func then 
      if type(self.Func) == "string" then 
        CallbackManager.Call(self.Func, ...)
      else 
        self.Func(...)
      end
    end
  end
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Arguments__ { String, Any, Variable.Optional(Callable + String) }
  function Setting(self, id, default, func)
    self.ID         = id
    self.Default    = default
    self.Func       = func
  end 
end)

class "Settings" (function(_ENV)
  SETTINGS = Dictionary()

  __Static__() function SelectCurrentProfile()
    -- Get the current profile for this character
    local dbUsed = Settings.GetCurrentProfile()

    if dbUsed == "spec" then
      Database.SelectRootSpec()
    elseif dbUsed == "char" then
      Database.SelectRootChar()
    else
      Database.SelectRoot()
    end
  end

  __Arguments__ { String }
  __Static__() function Get(setting)
    -- select the current profile (global, char or spec)
    Profiles.PrepareDatabase()

    if Database.SelectTable(false, "settings") then
      local value = Database.GetValue(setting)
      if value ~= nil then
        return value
      end
    end

    if SETTINGS[setting] then
      return SETTINGS[setting].Default
    end
  end

  __Arguments__ { String }
  __Static__() function Exists(setting)
      -- select the current profile (global, char or spec)
      Profiles.PrepareDatabase()

      if Database.SelectTable(false, "settings") then
        local value = Database.GetValue(setting)
        if value then
          return true
        end
      end
      return false
  end

  __Arguments__ { String, Variable.Optional(), Variable.Optional(Boolean, true), Variable.Optional(Boolean, true)}
  __Static__() function Set(setting, value, useHandler, passValue)
    -- select the current profile (global, char or spec)
    Profiles.PrepareDatabase()

    Database.SelectTable("settings")
    local oldValue = Database.GetValue(setting)
    local newValue = value
    local defaultValue = SETTINGS[setting] and SETTINGS[setting].Default

    if oldValue == nil then
      oldValue = defaultValue
    end

    if value and value == defaultValue then
      Database.SetValue(setting, nil)
    else
      Database.SetValue(setting, value)
    end

    if newValue == nil then
      newValue = defaultValue
    end

    if newValue ~= oldValue then
      -- TODO: Broadcast this changed to ISettingsListener 
      -- Frame:BroadcastSetting(setting, newValue, oldValue)
      Scorpio.FireSystemEvent("SLT_SETTING_CHANGED", setting, newValue, oldValue)
    end

    -- Call the handler if needed
    if useHandler then
      local opt = SETTINGS[setting]
      if opt then
        if passValue then
          opt(value)
        else
          opt()
        end
      end
    end
  end

  __Arguments__ { String, Any, Variable.Optional(Callable + String) }
  __Static__() function Register(setting, default, func)
    Settings.Register(Setting(setting, default, func))
  end

  __Arguments__ { Setting }
  __Static__() function Register(setting)
    SETTINGS[setting.ID] = setting
  end

  __Arguments__ { Variable.Optional(String, "global") }
  __Static__() function SelectProfile(profile)
    Database.SelectRoot()
    Database.SelectTable("dbUsed")

    local name, realm = UnitFullName("player")
    name = realm .. "-" .. name

    Database.SetValue(name, profile)
  end

  __Arguments__ { ClassType }
  __Static__() function GetCurrentProfile(self)
    Database.SelectRoot()
    if Database.SelectTable(false, "dbUsed") then
      local name  = UnitFullName("player")
      local realm = GetRealmName()
      name = realm .. "-" .. name
      local dbUsed = Database.GetValue(name)
      if dbUsed then
        return dbUsed
      end
    end
    return "global"
  end

  __Arguments__ { String }
  function ResetSetting(id)
    Settings.Set(id, nil)
  end
end)


__SystemEvent__()
function SLT_PROFILE_CHANGED(profile, oldProfile)
  local oldProfileData = DiffMap()
  Profiles.PrepareDatabase(oldProfile)

  if Database.SelectTable(false, "settings") then
    for k, v in Database:IterateTable() do
      oldProfileData:SetValue(k, v)
    end
  end

  local newProfileData = DiffMap()
  Profiles.PrepareDatabase(profile)

  if Database.SelectTable(false, "settings") then
    for k, v in Database.IterateTable() do
      newProfileData:SetValue(k, v)
    end
  end

  local diff = oldProfileData:Diff(newProfileData)
  for index, setting in ipairs(diff) do
    local value = Settings.Get(setting)
    -- if setting == "theme-selected" then
    --   Themes:Select(value, false)
    -- else
    --   Frame:BroadcastSetting(setting, value)
    -- end
  end
end


__SystemEvent__()
function SLT_COPY_PROFILE_PROCESS(sourceDB, destDB, destProfile)
  if sourceDB["settings"] then
    destDB["settings"] = sourceDB["settings"]
  end
end