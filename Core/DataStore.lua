-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                   "SylingTracker.Core.DataStore"                      ""
-- ========================================================================= --
import                      "SylingTracker.Utils"

class "DataStore" (function(_ENV)
  inherit "NavTable"
  -----------------------------------------------------------------------------
  --                               Events                                    --
  -----------------------------------------------------------------------------
  --- the event if triggered when 'Flush', 'ForceFlush' and 'SecureFlush' are 
  --- called
  event "OnDataFlushed"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function OnFlush(self)
    self:OnDataFlushed()
  end

  --- Notify the listeners the data has been updated. 
  --- This methods can be called multiple times in short time, resulting a 
  --- one call. 
  function Flush(self)
    if not self.__pendingFlush then 
      self.__pendingFlush = true 

      Scorpio.Delay(0.1, function()
        self:OnFlush()
        self.__pendingFlush = nil
      end)
    end
  end

  --- Similar to 'Flush' method except there no protection for avoiding to prevent 
  --- multiple calls in short time.
  function ForceFlush(self)
    self:OnFlush()
  end

  --- Similar to 'Flush' method, except the notification will be delayed until the 
  --- player leaves the combat.
  function SecureFlush(self)
    if not self.__pendingFlush then 
      self.__pendingFlush = true 

      Scorpio.Delay(0.1, function()
        NoCombat()
        self:OnFlush()
        self.__pendingFlush = nil 
      end)
    end
  end
end)
-------------------------------------------------------------------------------
-- Extending the API                                                         --
-------------------------------------------------------------------------------
DATA_STORES                           = {}
DATA_STORE_SUBJECTS                   = {}

--- Create and register a datastore 
---
--- @param id the datastore id.
--- @param cls the class of the datastore.
__Arguments__ { String, (-DataStore)/DataStore }
__Static__() function API.CreateDataStore(id, cls)

  if DATA_STORES[id] then 
    error(("This id '%s' to create a datastore is already used"):format(id))
  end


  local datastore = cls()

  datastore.OnDataFlushed = function()
    local subject = DATA_STORE_SUBJECTS[id]

    if subject then 
      subject:OnNext(datastore:GetData())
    end
  end

  DATA_STORES[id] = datastore

  return datastore
end

--- Get the datastore object
---
--- @param id the datastore id.
__Arguments__ { String }
__Static__() function API.GetDatastore(id)
  return DATA_STORES[id]
end


--- Create an observable could be used by the style properties. 
--- This observable will notify the property when data been pushed.
---
--- @param id the datastore id where the observable will be created. 
__Arguments__ { String }
__Static__() function API.FromDataStore(id)
  local datastore = DATA_STORES[id]
  return Obserable(function(observer)
    local subject = DATA_STORE_SUBJECTS[id]

    if not subject then 
      subject = BehaviorSubject()
      DATA_STORE_SUBJECTS[id] = subject
    end

    subject:Subscribe(observer)

    if datastore then 
      subject:OnNext(datastore:GetData())
    end

    return subject
  end)
end