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
  newtable = System.Toolset.newtable
}

interface "IObjectData" (function(_ENV)
  -----------------------------------------------------------------------------
  --                                Methods                                  --
  -----------------------------------------------------------------------------
  __Arguments__ { IObjectData/nil }
  function SetParent(self, parent)
    local oldParent = self:GetParent()

    if oldParent then 
      oldParent:RemoveChild(self)
    end

    if parent then 
      parent:AddChild(self)
    end

    self.__parent = parent
  end

  function GetParent(self)
    return self.__parent
  end

  __Arguments__ { IObjectData }
  function AddChild(self, child)
    self.Children[child] = true
  end

  __Arguments__ { IObjectData }
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

  function GetSerializedData(self)
    return Serialize(LuaFormatProvider{ ObjectTypeIgnored = true}, self)
  end
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

        self:NotifyChanges()
      end
    end
  }

  property "Children" {
    set = false,
    default = function() return newtable(true, false) end 
  }
end)
