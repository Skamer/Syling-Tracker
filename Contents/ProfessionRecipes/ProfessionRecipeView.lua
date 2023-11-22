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
  FromBackdrop                        = Frame.FromBackdrop,
  ContextMenu_Show                    = API.ContextMenu_Show
}

__UIElement__()
class "ProfessionRecipeView" (function(_ENV)
  inherit "Button" extend "IView"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnClickHandler(self, mouseButton)
    local contextMenuPattern  = self.ContextMenuPattern
    local recipeID            = self.RecipeID
    local isRecraft           = self.IsRecraft

    if mouseButton == "RightButton" then
      if contextMenuPattern and recipeID then
        ContextMenu_Show(contextMenuPattern, self, recipeID, isRecraft)
      end
    end
  end
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
    self.RecipeID = data.recipeID
    self.IsRecraft = data.isRecraft
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  __Observable__()
  property "RecipeName" {
    type = String,
    default = ""
  }

  property "RecipeID" {
    type = Number
  }

  property "IsRecraft" {
    type = Boolean,
    default = false
  }

  property "ContextMenuPattern" {
    type = String,
    default = "recipe"
  }
  -----------------------------------------------------------------------------
  --                              Constructors                               --
  -----------------------------------------------------------------------------
  __Template__ {
    Name = FontString
  }
  function __ctor(self) 
    self.OnClick = self.OnClick + OnClickHandler
  end
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
    registerForClicks                 = { "LeftButtonDown", "RightButtonDown" },
    backdrop                          = FromBackdrop(),
    showBackground                    = true,
    showBorder                        = true,
    backdropColor                     = Color(35/255, 40/255, 46/255, 0.73),
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
