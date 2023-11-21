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
  FromUIProperty                      = Wow.FromUIProperty,  
  FromBackdrop                        = Frame.FromBackdrop
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
    height                            = 1,
    autoAdjustHeight                  = true, 
    backdrop                          = FromBackdrop(),
    showBackground                    = true,
    showBorder                        = true,
    backdropColor                     =  Color(35/255, 40/255, 46/255, 0.73),
    backdropBorderColor               = Color(0, 0, 0, 0.4),
    borderSize                        = 1,
    
    Name = {
      text                            = FromUIProperty("RecipeName"),
      justifyV                        = "MIDDLE",
      mediaFont                       = FontType("DejaVuSansCondensed Bold", 10),
      location                        = {
                                        Anchor("TOP"),
                                        Anchor("LEFT"),
                                        Anchor("RIGHT")
                                      }
    },

    [ProfessionRecipeView.Objectives] = {
      spacing = 5,
      location                        = {
                                        Anchor("TOPLEFT", 0, -5, "Name", "BOTTOMLEFT"),
                                        Anchor("TOPRIGHT", 0, -5, "Name", "BOTTOMRIGHT")
                                      }
    }
  },

  [ProfessionRecipeListView] = {
    viewClass                         = ProfessionRecipeView,
    indexed                           = false
  }
})
