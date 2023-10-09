-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling               "SylingTracker_Options.WidgetAttribute"                 ""
-- ========================================================================= --
export {
  newtable = Toolset.newtable
}

EVENTS = {}

local function RegisterWidgetForSystemEvent(widget, event)
  local t = EVENTS[event]
  if not t then 
    t = newtable(true, false)
    _M:RegisterEvent(event, function(...)
      for obj in pairs(t) do
        print(obj, t, obj.OnSystemEvent, obj.__isReleased) 
        if obj.OnSystemEvent and not obj.__isReleased then
          obj:OnSystemEvent(event, ...)
        end
      end
    end)

    EVENTS[event] = t 
  end

  if not t[widget] then 
    t[widget] = true 
  end
end

local function UnregisterSystemEvent(widget, event)
  local t = _Events[event]
  if t then 
    t[widget] = nil 
  end
end

--- IMPORTANT: All the widgets must include this Attribute.
class "__Widget__" (function(_ENV)
  extend "IAttachAttribute"

  function AttachAttribute(self, target, targettype, owner, name, stack)
    Attribute.IndependentCall(function()
      class(target)(function(_ENV)
        local recycleName = Namespace.GetNamespaceName(target):gsub("%.", "_") .. "%d"
        RECYCLER = Recycle(target, recycleName)
        USER_DATA = {}
        USER_HANDLERS = {}

        function Release(obj)
          -- Clean user data 
          local userData = USER_DATA[obj]
          if userData then 
            for k,v in pairs(userData) do 
              userData[k] = nil 
            end
          end

          -- Remove and clear the user handlers 
          local userHandlers = USER_HANDLERS[obj]
          if userHandlers then 
            for event, handler in pairs(userHandlers) do 
              obj[event] = obj[event] - handler 
              userHandlers[event] = nil 
            end
          end

          if obj.OnRelease then 
            obj:OnRelease()
          end

          obj:SetName(obj.__factoryName)
          obj.__isReleased = true 

          RECYCLER(obj)
        end

        __Arguments__ { Boolean/true, Any/nil }
        __Static__() function Acquire(isShown, parent)
          local obj = RECYCLER()
          obj.__factoryName = obj:GetName()
          obj.__isReleased  = nil

          if obj.OnAcquire then 
            obj:OnAcquire()
          end

          if isShown then 
            obj:Show()
          else 
            obj:Hide()
          end

          if parent then 
            obj:SetParent(parent)
          end

          return obj
        end

        __Arguments__ { String + Number, Any/nil}
        function SetUserData(self, id, value)
          local userData = USER_DATA[self]
          if not userData then 
            userData = {}
            USER_DATA[self] = userData
          end

          userData[id] = value 
        end

        __Arguments__ { String + Number }
        function GetUserData(self, id)
          return USER_DATA[self] and USER_DATA[self][id]
        end
        
        function SetUserHandler(self, event, handler)
          local userHandlers = USER_HANDLERS[self]
          if not userHandlers then 
            userHandlers = {}
            USER_HANDLERS[self] = userHandlers
          end

          local oldHandler = userHandlers[event]
          if oldHandler then 
            self[event] = self[event] - oldHandler
          end

          self[event] = self[event] + handler

          userHandlers[event] = handler
        end
        
        function GetUserHandler(self, event)
          local userHandlers = USER_HANDLERS[self]
          if not userHandlers then 
            return 
          end 

          return userHandlers[event]
        end
        
        __Iterator__()
        function IterateUserHandlers()
          local userHandlers = USER_HANDLERS[self]
          if userHandlers then 
            local yield = coroutine.yield

            for event, handler in pairs(userHandlers) do 
              yield(event, handler)
            end
          end
        end
        
        __Arguments__{ String }
        function RegisterSystemEvent(self, event)
          RegisterWidgetForSystemEvent(self, event)
        end
        
        __Arguments__ { String * 0}
        function RegisterSystemEvents(self, ...)
          for i = 1, select("#", ...) do 
            local event = select(i, ...)
            self:RegisterSystemEvent(event)
          end
        end
        
        __Arguments__ { String }
        function UnregisterSystemEvent(self, event)
          UnregisterWidgetForSystemEvent(self, event)
        end        

        __Arguments__ { String * 0}
        function UnregisterSystemEvents(self, ...)
          for i = 1, select("#", ...) do 
            local event = select(i, ...)
            self:UnregisterSystemEvent(event)
          end
        end
      end)
    end)
  end

  function __new(cls, ...)
    return { ... }, true 
  end
  
  function __call(self, other)
    tinsert(self, other)
    return self
  end  
end)
