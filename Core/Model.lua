-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                   "SylingTracker.Core.Model"                          ""
-- ========================================================================= --
namespace                          "SLT"
-- ========================================================================= --
WipeTable = System.Toolset.wipe
-------------------------------------------------------------------------------
--                              Helpers Functions                            --
-------------------------------------------------------------------------------
local function RemoveNilDataFromTable(t)
  for k, v in pairs(t) do 
    if type(v) == "table" then 
      RemoveNilDataFromTable(v)
    elseif type(v) == "string" and v == Model.NIL_DATA then 
      t[k] = nil 
    end
  end
end


local function MergeTable(t1, t2)
  for k, v in pairs(t2) do
        if (type(v) == "table") and (type(t1[k] or false) == "table") then
            MergeTable(t1[k], t2[k])
        else
          if type(v) == "string" and v == Model.NIL_DATA then
            t1[k] = nil 
          else 
            if type(v) == "table" then 
              RemoveNilDataFromTable(v)
            end 
            t1[k] = v
          end
        end
    end
  return t1
end

class "Model" (function(_ENV)
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  -- REVIEW: The view should not be updated if it's not active, but when the
  -- view become active, it should get a refresh
  __Arguments__{ IView }
  function AddView(self, view)

    self.views:Insert(view)
    local data = self:GetData() 
    if data then 
      view:UpdateView(data)
    end
  end

  __Arguments__ { IView }
  function RemoveView(self, view)
    self.views:Remove(view)
  end

  __Arguments__ { Table, Variable.Rest(String + Number)}
  function SetData(self, data, ...)
    local count = select("#", ...)
    if count == 0 then 
      self:ClearData()
      self.data:Update(data)
    else
      local currentTable = self.data 
      for i = 1, count do 
        local key = select(i, ...)
        if count == i then 
          currentTable[key] = data
        else 
          local t = currentTable[key]
          if not t then 
            t = {}
            currentTable[key] = t
          end 

          currentTable = t 
        end 
      end 
    end 
  end

  __Arguments__ { Table, Variable.Rest(String + Number) }
  function AddData(self, data, ...)
    local count = select("#", ...)
    if count == 0 then 
      MergeTable(self.data, data)
    else 
      local currentTable = self.data
      for i = 1, count do 
        local key = select(i, ...)
        local t = currentTable[key]
        if not t then 
          t = {}
          currentTable[key] = t
        end

        currentTable = t
      end

      MergeTable(currentTable, data)
    end 
  end

  __Arguments__ { Variable.Rest(String + Number )}
  function RemoveData(self, ...)
    local count = select("#", ...)
    if count == 0 then 
      return 
    end 

    local currentTable = self.data
    for i = 1, count do 
      local key = select(i, ...)
      local t = currentTable[key]
      if not t then 
        return 
      end
      
      if i == count then 
        currentTable[key] = nil
        return 
      end

      currentTable = t
    end
  end 

  function ClearData(self)
    WipeTable(self.data)
  end


  function RefreshViews(self)
    for index, views in self.views:GetIterator() do 
      views:UpdateView(self:GetData(), self)
    end 
  end

  function Flush(self)
    if not self._pendingFlush then 
      self._pendingFlush = true 

      Scorpio.Delay(0.1, function()
        self:OnFlush() 
        self._pendingFlush = nil 
      end)
    end
  end

  function OnFlush(self)
    self:RefreshViews()
  end

  function ForceFlush(self) 
    self:OnFlush()
  end

  function SecureFlush(self)
    if not self._pendingFlush then
      self._pendingFlush = true 

      Scorpio.Delay(0.1, function()
        NoCombat()
        self:OnFlush()
        self._pendingFlush = nil 
      end)
    end
  end

  function GetData(self) return self.data end 
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "id" {
    type = Number + String,
  }
  
  property "views" { 
    set = false, 
    default = function() return Array[IView]() end 
  }

  property "data" {
    type = Table,
    default = function() return {} end
  }

  __Static__() property "NIL_DATA" {
    type = String,
    default = "NIL_DATA"
  }
end)

_Models = {}

class "API" (function(_ENV)

  __Static__()
  function RegisterModel(modelClass, modelId)
    local model = modelClass()
    model.id = modelId

    _Models[modelId] = model 
    return model
  end 
end)

__SlashCmd__ "mdl"
function TestMDl()
  for id, model in pairs(_Models) do 
    print(id, model, model:GetData())
  end 
end 
