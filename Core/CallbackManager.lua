-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                      "SylingTracker.Core.CallbackManager"             ""
-- ========================================================================= --
namespace                          "SLT"
-- ========================================================================= --
class "Callback" (function(_ENV)
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function __call(self, ...)
    self.func(...)
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "func" {
    type = Callable + String
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Arguments__{ Callable + String }
  function __ctor(self, func)
    self.func = func 
  end 
end)


class "ObjectMethodCallback" (function(_ENV)
  inherit "Callback"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function __call(self, ...)
    if type(self.func) == "string" then
      local f = self.obj[self.func]
      if f then
        f(self, ...)
      end
    else
      self.func(self.obj, ...)
    end    
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "obj" {
    type = Class + Table 
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Arguments__ { Class + Table, Callable + String }
  function ObjectMethodCallback(self, obj, func)
    self.obj = obj

    Super(self, func)
  end
end)

class "ObjectPropertyCallback" (function(_ENV)
  inherit "ObjectMethodCallback"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function __call(self, value)
    if self.obj[self.func] then
      self.obj[self.func] = value
    end
  end
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Arguments__ { Class + Table, String }
  function ObjectPropertyCallback(self, obj, property)
    Super(self, obj, property)
  end

end)


class "CallbackManager" (function(_ENV)
  CALLBACKS = Dictionary()
  CALLBACKS_GROUPS = Dictionary()
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  __Arguments__ { String, Callback, Variable.Rest(String) }
  __Static__() function Register(id, handler, ...)
    local numGroup = select("#", ...)
    for i = 1, numGroup do
      local groupName = select(i, ...)
      if not CALLBACKS_GROUPS[groupName] then
        local handlers = setmetatable( {}, { __mode = "v" })
        handlers[id] = handler
        CALLBACKS_GROUPS[groupName] = handlers
      else
        CALLBACKS_GROUPS[groupName][id] = handler
      end
    end

    CALLBACKS[id] = handler
  end

  __Arguments__ { Variable.Rest(String) }
  __Static__() function CallGroup(...)
    local numGroup = select("#", ...)
    for i = 1, numGroup do
      local groupName = select(i, ...)
      local handlers = CALLBACKS_GROUPS[groupName]
      if handlers then
        for id, handler in pairs(handlers) do
          handler()
        end
      end
    end
  end

  __Arguments__ { String, Variable.Rest()}
  __Static__() function Call(id, ...)
    local handler = CALLBACKS[id]
    if handler then
      handler(...)
    end
  end
end)





