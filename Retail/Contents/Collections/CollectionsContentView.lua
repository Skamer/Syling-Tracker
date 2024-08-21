-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling             "SylingTracker.Contents.CollectionsContentView"           ""
-- ========================================================================= --
export {
  FromUISetting                       = API.FromUISetting,
  GenerateUISettings                  = API.GenerateUISettings,
}

__UIElement__()
class "CollectionsContentView" (function(_ENV)
  inherit "ContentView"
  -----------------------------------------------------------------------------
  --                                Methods                                  --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data, metadata)
    super.OnViewUpdate(self, data, metadata)

    if data and data.collections then 
        Style[self].Collections.visible = self.Expanded
        local collectionsListView = self:GetPropertyChild("Collections")
        collectionsListView:UpdateView(data.collections, metadata)    
    else 
        Style[self].Collections = NIL 
    end
  end

  
  function OnExpand(self)
    if self:GetPropertyChild("Collections") then 
      Style[self].Collections.visible = true 
    end
  end

  function OnCollapse(self)
    if self:GetPropertyChild("Collections") then 
      Style[self].Collections.visible = false 
    end
  end
end)

__ChildProperty__(CollectionsContentView, "Collections")
__UIElement__() class(tostring(CollectionsContentView) .. ".Collections") { CollectableListView }
-------------------------------------------------------------------------------
--                              UI Settings                                  --
-------------------------------------------------------------------------------
GenerateUISettings("collections", "content")
-------------------------------------------------------------------------------
--                              Observables                                  --
-------------------------------------------------------------------------------
function FromCollectablesLocation()
  return FromUISetting("collections.showHeader"):Map(function(visible)
    if visible then 
      return {
        Anchor("TOP", 0, -10, "Header", "BOTTOM"),
        Anchor("LEFT"),
        Anchor("RIGHT")        
      }
    end

    return {
        Anchor("TOP"),
        Anchor("LEFT"),
        Anchor("RIGHT")
    }
  end)
end
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [CollectionsContentView] = {

    Header = {
      visible                         = FromUISetting("collections.showHeader"),
      showBackground                  = FromUISetting("collections.header.showBackground"),
      showBorder                      = FromUISetting("collections.header.showBorder"),
      backdropColor                   = FromUISetting("collections.header.backgroundColor"),
      backdropBorderColor             = FromUISetting("collections.header.borderColor"),
      borderSize                      = FromUISetting("collections.header.borderSize"),

      Label = {
        mediaFont                     = FromUISetting("collections.header.label.mediaFont"),
        textColor                     = FromUISetting("collections.header.label.textColor"),
        justifyH                      = FromUISetting("collections.header.label.justifyH"),
        justifyV                      = FromUISetting("collections.header.label.justifyV"),
        textTransform                 = FromUISetting("collections.header.label.textTransform"),
      }
    },

    [CollectionsContentView.Collections] = {
      location = FromCollectablesLocation()
    }
  }
})