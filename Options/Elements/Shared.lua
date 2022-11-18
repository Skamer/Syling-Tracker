-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling              "SylingTracker.Options.Elements.Shared"                  ""
-- ========================================================================= --
_Events                           = {}

local function RegisterWidgetForSystemEvent(widget, event)
  local t = _Events[event]
  if not t then 
    t = Toolset.newtable(true, false)
    _M:RegisterEvent(event, function(...)
      for obj in pairs(t) do 
        if obj.OnSystemEvent and not obj.__isReleased then
          obj:OnSystemEvent(event, ...)
        end
      end
    end)

    _Events[event] = t
  end

  if not t[widget] then 
    t[widget] = true 
  end
end

local function UnregisterWidgetForSystemEvent(widget, event)
  local t = _Events[event]
  if t then 
    t[widget] = nil 
  end
end

--- IMPORTANT: All the Widgets must include this attribute.
class "__Widget__" (function(_ENV)
  extend "IAttachAttribute"

  function AttachAttribute(self, target, targettype, owner, name, stack)
    Attribute.IndependentCall(function()
      class(target)(function(_ENV)
        local recycleName = Namespace.GetNamespaceName(target):gsub("%.", "_") .. "%d"
        _Recycler = Recycle(target, recycleName)
        _FocusedWidget = nil
        _UserData = {}
        _UserHandlers = {}

        function Release(obj)

          --- Clear user data 
          local userData = _UserData[obj]
          if userData then 
            for k,v in pairs(userData) do 
              userData[k] = nil 
            end
          end

          --- Remove and clear the user handlers 
          local userHandlers = _UserHandlers[obj]
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

          _Recycler(obj)
        end

        __Arguments__ { Boolean/true, Any/nil}
        __Static__() function Acquire(isShown, parent)
          local obj = _Recycler()
          obj.__factoryName = obj:GetName()
          obj.__isReleased = nil

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
          local userData = _UserData[self]
          if not userData then 
            userData = {}
            _UserData[self] = userData
          end

          userData[id] = value 
        end

        __Arguments__ { String + Number }
        function GetUserData(self, id)
          return _UserData[self] and _UserData[self][id]
        end

        function SetUserHandler(self, event, handler)
          local userHandlers = _UserHandlers[self]
          if not userHandlers then 
            userHandlers = {}
            _UserHandlers[self] = userHandlers
          end

          local oldHandler = userHandlers[event]
          if oldHandler then 
            self[event] = self[event] - oldHandler
          end

          self[event] = self[event] + handler

          userHandlers[event] = handler
        end

        function GetUserHandler(self, event)
          local userHandlers = _UserHandlers[self]
          if not userHandlers then 
            return 
          end 

          return userHandlers[event]
        end

        __Iterator__()
        function IterateUserHandlers()
          local userHandlers = _UserHandlers[self]
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
            self:RegisterEvent(event)
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