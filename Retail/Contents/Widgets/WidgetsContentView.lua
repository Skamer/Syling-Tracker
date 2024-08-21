-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling               "SylingTracker.Contents.WidgetsContentView"             ""
-- ========================================================================= --
OBJECTIVE_TRACKER_WIDGET_SET_ID = C_UIWidgetManager.GetObjectiveTrackerWidgetSetID()

__UIElement__()
class "WidgetsContentView"(function(_ENV)
  inherit "ContentView"
  -----------------------------------------------------------------------------
  --                                Methods                                  --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data, metadata)
    -- We don't call super.OnViewUpdate as we need to override the behavior for 
    -- setting the header text.
    self.ContentName = GetRealZoneText()
  end

  function OnExpand(self)
    Style[self].Widgets.visible  = true
  end

  function OnCollapse(self)
    Style[self].Widgets.visible  = false
  end
  -----------------------------------------------------------------------------
  --                              Constructors                               --
  -----------------------------------------------------------------------------
  __Template__{
    Widgets = UIWidgets
  }
  function __ctor(self) end
end)
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [WidgetsContentView] = {
    Widgets = {
      widgetSetID = OBJECTIVE_TRACKER_WIDGET_SET_ID,
      location = {
        Anchor("TOP", 0, -10, "Header", "BOTTOM"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      }
    }
  }
})