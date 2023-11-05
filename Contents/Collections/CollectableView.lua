-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                 "SylingTracker.Contents.CollectableView"              ""
-- ========================================================================= --
export {
  FromUIProperty            = Wow.FromUIProperty,  
}

__UIElement__()
class "CollectableView" (function(_ENV)
  inherit "Frame" extend "IView"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data, ...)
    if data.objectives then 
      Style[self].Objectives.visible = true 
      local objectivesView = self:GetPropertyChild("Objectives")

      objectivesView:UpdateView(data.objectives, ...)
    end

    self.CollectableName = data.name
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  __Observable__()
  property "CollectableName" {
    type = String,
    default = ""
  }
  -----------------------------------------------------------------------------
  --                              Constructors                               --
  -----------------------------------------------------------------------------
  __Template__ {
    Name = FontString
  }
  function __ctor(self) end
end)

-- Optional Children for QuestView 
__ChildProperty__(CollectableView, "Objectives")
class(tostring(CollectableView) .. ".Objectives") { ObjectiveListView }

__UIElement__()
class "CollectableListView" { ListView }
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [CollectableView] = {
    autoAdjustHeight = true, 

    backdrop = { 
      bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
    },
    backdropColor = { r = 35/255, g = 40/255, b = 46/255, a = 0.73},
    
    Name = {
      text = FromUIProperty("CollectableName"),
      justifyV = "MIDDLE",
      mediaFont = FontType("DejaVuSansCondensed Bold", 10),
      location = {
        Anchor("TOP"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      }
    },

    [CollectableView.Objectives] = {
      spacing = 5,

      location = {
        Anchor("TOPLEFT", 0, -5, "Name", "BOTTOMLEFT"),
        Anchor("TOPRIGHT", 0, -5, "Name", "BOTTOMRIGHT")
      }
    }
  },

  [CollectableListView] = {
    viewClass = CollectableView,
    indexed = false
  }
})
