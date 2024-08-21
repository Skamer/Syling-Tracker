-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                "SylingTracker.Data.ProfessionRecipesData"             ""
-- ========================================================================= --
__DataProperties__ {
  { name = "recipeID", type = Number },
  { name = "recipeType", type = Number},
  { name = "name", type = String},
  { name = "icon", type = Any },
  { name = "outputItemID", type = Number },
  { name = "quantityMax", type = Number },
  { name = "quantityMin", type = Number},
  { name = "isRecraft", type = Boolean },
  { name = "recipeType", type = Number},
  { name = "hasCraftingOperationInfo", type = Boolean},
  { name = "objectives", type = ObjectiveData, isArray = true, singularName = "objective"}
}
class "ProfessionRecipeData" { ObjectData }


__DataProperties__ {
  { name = "recraftRecipes", type = ProfessionRecipeData, isMap = true, singularName = "recraftRecipe"},
  { name = "recipes", type = ProfessionRecipeData, isMap = true, singularName = "recipe"}
}
class "ProfessionRecipesContentSubject" { ContentSubject }