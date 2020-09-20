-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                  "SylingTracker.Core.Recyclable"                      ""
-- ========================================================================= --
namespace                          "SLT"
-- ========================================================================= --

--- __Recyclable will create a Recycle object for this class.
-- The "OnRelease" method will be called when the object will released. 
-- The "OnAcquire" method will be called when the object will be acquired.
class "__Recyclable__"(function(_ENV)
  extend "IAttachAttribute"

  function AttachAttribute(self, target, targettype, owner, name, stack)
    Attribute.IndependentCall(function()
      class(target) (function(_ENV)
        _Recycler = Recycle(target, unpack(self))
        
        function Release(obj)
          if obj.OnRelease then 
            obj:OnRelease()
          end 

          _Recycler(obj)
        end

        __Static__() function Acquire()
          local obj = _Recycler()
          if obj.OnAcquire then 
            obj:OnAcquire() 
          end

          return obj 
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