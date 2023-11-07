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

--- __UIElements__ attribute adds useful features such as the reyclable system
-- and the integration of system event. 
-- 
-- The "OnRelease" method will be called when the object will be released.
-- The "OnAcquired" method will be called when the object will be acuiqred.
--
EVENTS                              = {}

local function RegisterFrameForSystemEvent(frame, event)
  local t = EVENTS[event]
  if not t then 
    t = Toolset.newtable(true, false)
    _M:RegisterEvent(event, function(...)
      for obj in pairs(t) do
        if obj.OnSystemEvent then
          obj:OnSystemEvent(event, ...)
        end
      end
    end)

    EVENTS[event] = t
  end

  if not t[frame] then 
    t[frame] = true 
  end
end

local function UnregisterFrameForSystemEvent(frame, event)
  local t = EVENTS[event]
  if t then 
    t[frame] = nil 
  end
end

interface "IChildPropertyHookRelease" (function(_ENV)
  local function OnParentChanged(self, parent, oparent)
    -- if the metatable of parent isn't not a class, this says this is the 
    -- Scorpio Recycle holdar, saying the frame has been released.
    -- We skip if the frame has been acquired by the __UIElement__ system.
    if not self:IsAcquired() and not Class.Validate(getmetatable(parent)) then
      self:Release(true, self:IsAcquired() )
    end
  end

  function __init(self)
    self.OnParentChanged = self.OnParentChanged + OnParentChanged
  end
end)

class "__UIElement__" (function(_ENV)
  extend "IAttachAttribute" "IInitAttribute"

  FACTORY_NAME      = System.Toolset.newtable(true, false)
  ACQUIRED_ELEMENTS = System.Toolset.newtable(true, false)

  function InitDefinition(self, target)
    Class.AddExtend(target, IChildPropertyHookRelease)
  end

  function AttachAttribute(self, target, targetType, owner, name, stack)
    Attribute.IndependentCall(function()
      class(target)(function(_ENV)
        local recycleName = Namespace.GetNamespaceName(target):gsub("%.", "_") .. "%d"
        RECYCLER = Recycle(target, recycleName)

        __Arguments__ { Boolean/false }
        function Release(obj, isChildProperty)

          -- The recycling of child property is handled by Scorpio, but sometimes 
          -- we need to be notified for clearing some variables so we also call 
          -- this method.
          if obj.OnRelease then 
            obj:OnRelease(isChildProperty)
          end

          -- In case of child property, we don't continue as Scorpio will take 
          -- all the release stuff. 
          if isChildProperty then 
            return 
          end

          obj:SetID(0)
          obj:Hide()
          obj:ClearAllPoints()
          obj:SetParent()

          -- We restore the factory name in case where it has been modified 
          obj:SetName(FACTORY_NAME[obj])

          -- We remove the element from the list of element acquired 
          ACQUIRED_ELEMENTS[obj] = nil 

          RECYCLER(obj)
        end

        __Static__() function Acquire()
          local obj = RECYCLER()

          -- We keep the factory name for later, as the may be modified for some
          -- reasons 
          FACTORY_NAME[obj] = obj:GetName()

          -- We keep a list of elements acquired 
          ACQUIRED_ELEMENTS[obj] = true 

          if obj.OnAcquire then
            obj:OnAcquire(false)
          end

          return obj 
        end

        function IsReleased(self)
          if ACQUIRED_ELEMENTS[self] then 
            return false 
          end

          return true 
        end

        function IsAcquired(self)
          return ACQUIRED_ELEMENTS[self]
        end

        --- Register the System Event for the frame 
        -- The frame must implement the method "OnSystemEvent" to be notified
        -- the events 
        __Arguments__{ String }
        function RegisterSystemEvent(self, event)
          RegisterFrameForSystemEvent(self, event)
        end

        --- Register multiple events 
        __Arguments__ { String * 0}
        function RegisterSystemEvents(self, ...)
          for i = 1, select("#", ...) do 
            local event = select(i, ...)
            self:RegisterEvent(event)
          end
        end

        --- Unregister the System Event for the frame 
        __Arguments__ { String }
        function UnregisterSystemEvent(self, event)
          UnregisterFrameForSystemEvent(self, event)
        end

        --- Unregister multiple events 
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
