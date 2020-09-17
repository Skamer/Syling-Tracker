-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Scorpio                 "SylingTracker.Core.Database"                        ""
-- ========================================================================= --
namespace                          "SLT"
-- ========================================================================= --
DeepCopy = Utils.DeepCopy
ShalowCopy = Utils.ShalowCopy

class "Database" (function(_ENV)
  CURRENT_TABLE         = nil
  CURRENT_PARENT_TABLE  = nil
  CURRENT_LEVEL         = 0
  CURRENT_TABLE_NAME    = nil 
  CURRENT_DB            = nil 

  __Default__("global")
  enum "Type" {
    "global",
    "char",
    "spec"
  }

  class "Path" (function(_ENV)
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
    __Arguments__ { Database.Type }
    function SetRelativeDB(self, type)
      self.relativeDB = type
      return self
    end

    __Arguments__ { Variable.Rest(String + Number )}
    function Table(self, ...)
      self.path = { ... }
    end

  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
    property "relativeDB" { TYPE = Database.Type }
  end)

  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  __Arguments__{ Any, Variable.Optional() }
  __Static__() function SetValue(self, index, value)
    CURRENT_TABLE[index] = value
  end

  __Arguments__ { Any }
  __Static__() function GetValue(index)
    return CURRENT_TABLE[index]
  end

  __Static__() function IterateTable()
    return pairs(CURRENT_TABLE)
  end

  __Arguments__ { ClassType }
  __Static__() function Clean()
    local function ClearEmptyTables(t)
      for k,v in pairs(t) do
        if type(v) == "table" then
          ClearEmptyTables(v)
          if next(v) == nil then
            t[k] = nil
          end
        end
      end
    end

    -- NOTE: Important to use 'SylingTrackerDB' else if doesn't work
    ClearEmptyTables(SylingTrackerDB)
  end

  __Arguments__ { String, String }
  __Static__() function RenameAllTables(sourceName, destName)
    local function RenameTables(t)
      for k,v in pairs(t) do
        if k ~= sourceName and type(v) == "table" then
          RenameTables(v)
        elseif k == sourceName then
          local tb = t[k]
          t[destName] = tb
          t[k] = nil
        end
      end
    end

    RenameTables(EskaTrackerDB)
  end

  __Arguments__ { Variable.Rest(String) }
  __Static__() function MoveTable(self, ...)
    local copy = DeepCopy(CURRENT_TABLE)
    local oldTable = CURRENT_TABLE
    local tables = { ... }
    local destName = tables[#tables]
    tables[#tables] = nil

    Database.SelectRoot()

    if #tables > 0 then
      if Database.SelectTable(true, unpack(tables)) then
        Database.SetValue(destName, copy)
        wipe(oldTable)
      end
    end
  end

  __Arguments__ { String, String }
  __Static__() function RenameTable(sourceName, newName)
    local table = Database.GetCurrentTable()[sourceName]
    if table then
      Database.GetCurrentTable()[newName] = DeepCopy(table)
      Database.GetCurrentTable()[sourceName] = nil
      table = nil
    end
  end

  __Arguments__ { Path }
  __Static__() function GetCopyTable(sourcePath)
    local sourceDB
    if not sourcePath.path then
      if sourcePath.relativeDB == "global" then
        sourceDB = Database.GetRaw()
      elseif sourcePath.relativeDB == "char" then
        sourceDB = Database.GetRawChar()
      elseif sourcePath.relativeDB == "spec" then
        sourceDB = Database.GetRawSpec()
      end
    else
      if sourcePath.relativeDB == "GLOBAL" then
        Database.SelectRoot()
      elseif sourcePath.relativeDB == "CHAR" then
        Database.SelectRootChar()
      elseif sourcePath.relativeDB == "SPEC" then
        Database.SelectRootSpec()
      end

      Database.SelectTable(true, unpack(sourcePath.path))
      sourceDB = Database.GetCurrentTable()
    end

    return DeepCopy(sourceDB)
  end

  __Static__() function DeleteTable()
    wipe(CURRENT_TABLE)
    Database.SelectRoot()
  end

  __Arguments__{ Variable.Rest(String) }
  __Static__() function SelectTable(...)
    return Database.SelectTable(true, ...)
  end

  __Arguments__ { Boolean, Variable.Rest(String) }
  __Static__() function SelectTable(mustCreateTables, ...)
    local count = select("#", ...)

    if not CURRENT_TABLE then
      CURRENT_TABLE = Database.Get()
    end
    local tb = CURRENT_TABLE
    for i = 1, count do
      local indexTable = select(i, ...)
        if not tb[indexTable] then
          if mustCreateTables then
            tb[indexTable] = {}
          else
            return false
          end
        end

        if i > 1 then
          CURRENT_PARENT_TABLE = tb
        end

        tb = tb[indexTable]
        CURRENT_LEVEL = CURRENT_LEVEL + 1
        CURRENT_TABLE_NAME = indexTable
    end
    CURRENT_TABLE = tb

    return true
  end

  __Static__() function SelectRoot()
    CURRENT_TABLE = Database.Get()
    CURRENT_LEVEL = 0
    CURRENT_DB    = "global"
  end

  __Static__() function SelectRootChar()
    CURRENT_TABLE = Database.GetChar()
    CURRENT_LEVEL = 0
    CURRENT_DB    = "char"
  end

  __Static__() function SelectRootSpec()
    CURRENT_TABLE = Database.GetSpec()
    CURRENT_LEVEL = 0
    CURRENT_DB    = "spec"
  end

  __Arguments__ {  Number }
  __Static__() function SetVersion(version)
    if Database.Get() then
      Database.Get().dbVersion = version
    end
  end

  __Static__() function GetVersion()
    if Database.Get() then return Database.Get().dbVersion end
  end

  __Static__() function Get()
    return _DB
  end

  __Static__() function GetChar()
    return _DB.Char
  end

  __Static__() function GetSpec()
    return _DB.Char.Spec
  end

  __Arguments__ { ClassType }
  __Static__() function GetRaw()
    return SylingTrackerDB
  end

  __Static__() function GetRawChar(self)
    local name = GetRealmName() .. "-" .. UnitName("player")

    if Database.GetRaw().__ScorpioChars and Database.GetRaw().__ScorpioChars[name] then
      return Database.GetRaw().__ScorpioChars[name]
    end
  end

  __Static__() function GetRawSpec(self)
    local charDB =  Database.GetRawChar()
    if not charDB then
      return
    end

    local spec = GetSpecialization()
    if charDB.__ScorpioSpecs and charDB.__ScorpioSpecs[spec] then
      return charDB.__ScorpioSpecs[spec]
    end
  end

  __Static__() function GetCurrentTable(self)
    if CURRENT_TABLE == 0 then
      if CURRENT_DB == nil or CURRENT_DB == "global" then
        return Database.GetRaw()
      elseif CURRENT_DB == "char" then
        return Database.GetRawChar()
      elseif CURRENT_DB == "spec" then
        return Database.GetRawSpec()
      end
    end

    return CURRENT_TABLE
  end


end)