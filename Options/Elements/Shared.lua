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

        function Release(obj)
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