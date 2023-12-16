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
class "__Recyclable__" (function(_ENV)
  extend "IAttachAttribute"

  function AttachAttribute(self, target, targetType, owner, name, stack)
    Attribute.IndependentCall(function()
      class(target) (function(_ENV)
        RECYCLER = Recycle(target, unpack(self))

        function Release(self)
          if self.OnRelease then 
            self:OnRelease()
          end

          RECYCLER(self)
        end

        __Static__() function Acquire()
          local obj = RECYCLER()

          if obj.OnAcquire then 
            obj:OnAcquire(false)
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