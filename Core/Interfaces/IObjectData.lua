-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                   "SylingTracker.Core.IObjectData"                    ""
-- ========================================================================= --
import "System.Serialization"

export {
  newtable = System.Toolset.newtable,
  GetFeatures = Class.GetFeatures,
  GetObjectClass = Class.GetObjectClass,
  GetPropertyDefault = Property.GetDefault,

  IsObjectDataProperty = __ObjectDataProperty__.IsObjectDataProperty
}

-- InitData 
-- SetDataValue(self, key, value)

interface "IObjectData" (function(_ENV)
  -----------------------------------------------------------------------------
  --                                Events                                   --
  -----------------------------------------------------------------------------
  -- event "OnDataChanged"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  -- local function OnDataChangedHandler(self)
  --   local parent = self:GetParent()
  --   if parent then 
  --     parent.DataChanged = true 
  --   end
  -- end
  -----------------------------------------------------------------------------
  --                                Methods                                  --
  -----------------------------------------------------------------------------
  -- function GetData(self)
  --   return self.Data
  -- end

  __Arguments__ { IObjectData/nil }
  function SetParent(self, parent)
    local oldParent = self:GetParent()

    if oldParent then 
      oldParent:RemoveChild(self)
    end

    -- if not oldParent and parent then 
    --   self.OnDataChanged = self.OnDataChanged + OnDataChangedHandler
    -- elseif not parent and oldParent then 
    --   self.OnDataChanged = self.OnDataChanged - OnDataChangedHandler
    -- end

    if parent then 
      parent:AddChild(self)
    end

    self.__parent = parent
  end

  function GetParent(self)
    return self.__parent
  end


  __Arguments__ { ObjectData }
  function AddChild(self, child)
    self.Children[child] = true
  end

  __Arguments__ { ObjectData }
  function RemoveChild(self, child)
    self.Children[child] = nil
  end

  function ResetChanges(self)
    self.DataChanged = false 

    for child in pairs(self.Children) do 
      child:ResetChanges()
    end
  end

  __Abstract__()
  function NotifyChanges(self) end

  -- __Arguments__ { Any, Any/nil, Boolean/true }
  -- function SetDataValue(self, key, value, notify)
  --   self.Data[key] = value

  --   if notify then 
  --     self.DataChanged = true
  --   end
  -- end


  function GetSerializedData(self)
    return Serialize(LuaFormatProvider{ ObjectTypeIgnored = true}, self)
  end

  -- function InitData(self)
  --   local cls = GetObjectClass(self)
  --   print(Color.YELLOW .. "Init Data")

  --   for name, feature in GetFeatures(cls) do
  --     if IsObjectDataProperty(cls, name) then
  --       -- print(Color.RED .. "IsObjectDataProperty", name, cls, IsObjectDataProperty(cls, name))
  --       self:SetDataValue(name, GetPropertyDefault(feature), false)
  --     end
  --   end
  -- end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "DataChanged" {
    type = Boolean,
    default = false, 
    handler = function(self, new)
      if new then
        local parent = self:GetParent()
        if parent then 
          parent.DataChanged = true 
        end


        -- OnDataChanged(self, new)
        self:NotifyChanges()
      end
    end
  }

  -- property "Data" {
  --   default = function() return {} end 
  -- }

  property "Children" {
    set = false,
    default = function() return newtable(true, false) end 
  }
end)
