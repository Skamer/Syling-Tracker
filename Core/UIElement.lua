-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                  "SylingTracker.Core.UIElement"                       ""
-- ========================================================================= --
_Events                           = {}

local function RegisterFrameForSystemEvent(frame, event)
  local t = _Events[event]
  if not t then 
    t = Toolset.newtable(true, false)
    _M:RegisterEvent(event, function(...)
      for obj in pairs(t) do 
        if obj.OnSystemEvent and not obj:IsReleased() then
          obj:OnSystemEvent(event, ...)
        end
      end
    end)

    _Events[event] = t
  end

  if not t[frame] then 
    t[frame] = true 
  end
end

local function UnregisterFrameForSystemEvent(frame, event)
  local t = _Events[event]
  if t then 
    t[frame] = nil 
  end
end

--- All ui elements of the addon must include this attribute.
--- This attribute adds useful feature the ui element may need such as the 
--- recyclabe system, and the intergraton of system event.
---
--- The "OnRelease" method will be called when the object will be released.
--- The "OnAcquired" method will be called when the object will be acquired.
class "SLT.__UIElement__" (function(_ENV)
  extend "IAttachAttribute"

  _FACTORY_NAME       = System.Toolset.newtable(true, false)
  _ACQUIRED_ELEMENTS  = System.Toolset.newtable(true, false)
  
  --- As by default all ui elements wants to be persisted in the db, we track
  --- here only the elements don't want to be. 
  _NO_PERSISTENT_ELEMENTS = System.Toolset.newtable(true, false)

  function AttachAttribute(self, target, targettype, owner, name, stack)
    Attribute.IndependentCall(function()
      class(target)(function(_ENV)
        local recycleName = Namespace.GetNamespaceName(target):gsub("%.", "_") .. "%d"
        _Recycler = Recycle(target, recycleName)

        function Release(obj)
          if obj.OnRelease then 
            obj:OnRelease()
          end

          --- We restore the factory name in case where this been modified 
          obj:SetName(_FACTORY_NAME[obj])

          --- We remove the element from the list of element acquired 
          _ACQUIRED_ELEMENTS[obj] = nil

          _Recycler(obj)
        end

        __Static__() function Acquire()
          local obj = _Recycler()

          --- We keep the factory name for later, as this may be editer for 
          --- reason 
          _FACTORY_NAME[obj] = obj:GetName()

          --- We keep a list of elements acquired
          _ACQUIRED_ELEMENTS[obj] = true  

          if obj.OnAcquire then
            obj:OnAcquire()
          end

          return obj
        end

        function IsReleased(self)
          return _ACQUIRED_ELEMENTS[self] and true or false
        end

        --- The persistent is here to say to object if it will persist change 
        --- to db. In some case, we don't want it temporarly (for example during
        --- the first loading)
        __Arguments__ { Boolean/true}
        function SetPersistent(self, persistent)
          if persistent then 
            _NO_PERSISTENT_ELEMENTS[self] = nil 
          else 
            _NO_PERSISTENT_ELEMENTS[self] = true 
          end 
        end

        function IsPersistent(self)
          if _NO_PERSISTENT_ELEMENTS[self] then 
            return false 
          end

          return true
        end

        __Arguments__{ String }
        function RegisterSystemEvent(self, event)
          RegisterFrameForSystemEvent(self, event)
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
          UnregisterFrameForSystemEvent(self, event)
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