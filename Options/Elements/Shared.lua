-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling              "SylingTracker_Options.Elements.Shared"                  ""
-- ========================================================================= --
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

          _Recycler(obj)
        end

        __Static__() function Acquire()
          local obj = _Recycler()
          if obj.OnAcquire then 
            obj:OnAcquire()
          end

          return obj
        end

        function GainWidgetFocus(self)
          if _FocusedWidget and _FocusedWidget ~= self then 
            if _FocusedWidget.OnWidgetLoseFocus then 
              _FocusedWidget:OnWidgetLoseFocus()
            end
          end

          _FocusedWidget = self
        end


        function ClearWidgetFocus(self)
          if _FocusedWidget then
            if FocusedWidget.OnWidgetLoseFocus then 
              _FocusedWidget:OnWidgetLoseFocus()
            end

            _FocusedWidget = nil
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

struct "SUI.EntryData" {
  { name = "text", type = String},
  { name = "value", type = Any },
  { name = "widgetClass", type = IEntry },
  { name = "properties", type = Table },
}

interface "SUI.IEntry" (function(_ENV)
  require "Frame"
  
  __Abstract__()
  __Arguments__ { SUI.EntryData}
  function SetupFromEntryData(self, data) end  
end)

interface "SUI.IButtonEntry" (function(_ENV)
  require "Button" extend "SUI.IEntry"
end)
