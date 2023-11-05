-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling               "SylingTracker.Contents.ProfessionRecipeView"           ""
-- ========================================================================= --
export {
  FromUIProperty            = Wow.FromUIProperty,  
}

__UIElement__()
class "ProfessionRecipeView" (function(_ENV)
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

    self.RecipeName = data.name
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  __Observable__()
  property "RecipeName" {
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
__ChildProperty__(ProfessionRecipeView, "Objectives")
class(tostring(ProfessionRecipeView) .. ".Objectives") { ObjectiveListView }

__UIElement__()
class "ProfessionRecipeListView" { ListView }
-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [ProfessionRecipeView] = {
    height = 1,
    -- clipChildren = true,
    autoAdjustHeight = true, 

    backdrop = { 
      bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
    },
    backdropColor = { r = 35/255, g = 40/255, b = 46/255, a = 0.73},
    
    Name = {
      text = FromUIProperty("RecipeName"),
      justifyV = "MIDDLE",
      mediaFont = FontType("DejaVuSansCondensed Bold", 10),
      location = {
        Anchor("TOP"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      }
    },

    [ProfessionRecipeView.Objectives] = {
      spacing = 5,

      location = {
        Anchor("TOPLEFT", 0, -5, "Name", "BOTTOMLEFT"),
        Anchor("TOPRIGHT", 0, -5, "Name", "BOTTOMRIGHT")
      }
    }
  },

  [ProfessionRecipeListView] = {
    viewClass = ProfessionRecipeView,
    indexed = false
  }
})
