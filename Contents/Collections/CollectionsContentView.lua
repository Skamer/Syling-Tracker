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
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [CollectionsContentView] = {
    [CollectionsContentView.Collections] = {
      location = {
        Anchor("TOP", 0, -10, "Header", "BOTTOM"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      }
    }
  }
})