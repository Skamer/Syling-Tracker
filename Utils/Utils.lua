-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                 "SylingTracker.Utils"                                 ""
-- ========================================================================= --
namespace                          "SLT"
-- ========================================================================= --
GetBuildInfo = GetBuildInfo
clone = System.Toolset.clone

class "Utils" (function(_ENV)

  __Static__() function IsOnShadowlands()
    local _, _, _, interfaceVersion = GetBuildInfo()
    if interfaceVersion >= 90000 then
      return true
    end 

    return false
  end 

  __Static__() function MergeTable(t1, t2)
    for k, v in pairs(t2) do
        if (type(v) == "table") and (type(t1[k] or false) == "table") then
            MergeTable(t1[k], t2[k])
        else
            t1[k] = v
        end
    end
    return t1
  end


  -- __Static__() function ResetStyles(frame)
  --   for name, v in Style.GetCustomStyles(frame) do
  --     print("ResetStyles", name, v)
  --     Style[frame][name] = nil
  --   end 
  -- end


  __Static__() function ClearStyles(frame, stylesToClear)
    if not stylesToClear then 
      return 
    end
    
    for k in pairs(stylesToClear) do 
      Style[frame][k] = CLEAR
    end
  end

  __Static__() function ClearChildStyles(parent, child, stylesToClear)
    if not stylesToClear then 
      return 
    end
    
    for uiProp in pairs(stylesToClear) do 
      Style[frame][childProperty][uiProp] = CLEAR
    end 
  end 



  __Arguments__ { Frame }
  __Static__() function IsUsedAsBackdrop(frame)
      local prop = value:GetChildPropertyName()
      if prop and prop:match("^backdrop") then
        return true 
      end

      return false
  end

  __Iterator__()
  __Static__() function IterateFrameChildren(frame, includeHidden)
    local yield = coroutine.yield

    for childName, child in frame:GetChilds() do 
      local prop = child:GetChildPropertyName()
      if not (prop and prop:match("^backdrop")) then
        if child:IsShown() or (not child:IsShown() and includeHidden) then 
          yield(childName, child)
        end
      end
    end 
  end

   __Static__() function ResetStyles(frame, applyToChildren, log)

    if applyToChildren then 
      for _, child in IterateFrameChildren(frame) do 
        ResetStyles(child, applyToChildren)
      end
    end

    for name, v in Style.GetCustomStyles(frame) do
      if log then 
        print("Reset Props:", name, "With previous value", v)
      end
      Style[frame][name] = nil
    end 
  end 


  __Arguments__{ Frame }
  __Static__() function IterateChildren(frame)
    return frame:GetChilds():Filter(function(key, value) 
      -- local prop = value:GetChildPropertyName()
      -- if prop and prop:match("^backdrop") then
      --   return false
      -- end
      return true
    end):GetIterator()
  end


  __Static__() function DeepCopy(t)
    return clone(t, true)
  end

  __Static__() function ShalowCopy(t)
    return clone(t, false)
  end


  
  class "Instance" (function(_ENV)
     __Static__() function GetCurrentInstance()
      local mapID = C_Map.GetBestMapForUnit("player")
      if mapID then
        return EJ_GetInstanceForMap(mapID)
      end
    end
  end)
  
end)

class "DiffMap" (function(_ENV)
  -----------------------------------------------------------------------------
  --                             Methods                                     --
  -----------------------------------------------------------------------------
  __Arguments__ { String + Number, Variable.Optional() }
  function SetValue(self, key, value)
    self.values[key] = value
  end

  __Arguments__ { DiffMap, Variable.Optional(Boolean)}
  function Diff(self, other, ignoreTable)
    -- Get a complete keys list to iterate
    local keys = {}

    -- Start with the self object
    for index, key in self.values.Keys:ToList():GetIterator() do
        keys[key] = true
    end

    -- Then with the other object
    for index, key in other.values.Keys:ToList():GetIterator() do
      keys[key] = true
    end

    local changes = {}
    -- Check if there is changes
    for key in pairs(keys) do
      local valueA = self.values[key]
      local valueB = other.values[key]
      local valueChanged = true

      if valueA == nil and valueB == nil then
        valueChanged = false
      elseif valueA ~= nil and valueB ~= nil then
        local typeA = type(valueA)
        local typeB = type(valueB)

        if typeA == typeB then
          if not ignoreTable and typeA == "table" then
            if API:IsTableEqual(valueA, valueB, true) then
              valueChanged = false
            end
          elseif typeA == "string" or typeA == "number" or typeA == "boolean" then
            if valueA == valueB then
              valueChanged = false
            end
          end
        end
      end

      if valueChanged then
        tinsert(changes, key)
      end
    end

    -- Return changes
    return changes
  end
  ------------------------------------------------------------------------------
  --                            Constructors                                  --
  ------------------------------------------------------------------------------
  function DiffMap(self)
    self.values = Dictionary()
  end
end)
        
