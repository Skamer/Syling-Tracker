-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                "SylingTracker.AutoQuestsContentView"                  ""
-- ========================================================================= --
__UIElement__()
class "AutoQuestsContentView" (function(_ENV)
  inherit "ContentView"
  -----------------------------------------------------------------------------
  --                                Methods                                  --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data, metadata)
    if data and data.autoQuests then
      Style[self].AutoQuests.visible = true
      local autoQuestsView = self:GetPropertyChild("AutoQuests")
      autoQuestsView:UpdateView(data.autoQuests, metadata)
    else
      Style[self].AutoQuests = NIL
    end
  end
end)

__ChildProperty__(AutoQuestsContentView, "AutoQuests")
__UIElement__()
class(tostring(AutoQuestsContentView) .. ".AutoQuests") { AutoQuestListView }
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [AutoQuestsContentView] = {
    Header = {
      visible = false 
    },

    [AutoQuestsContentView.AutoQuests] = {
      location = {
        Anchor("TOP"),
        Anchor("LEFT"),
        Anchor("RIGHT")      
      }
    }
  }
})