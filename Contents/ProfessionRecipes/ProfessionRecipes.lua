-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                  "SylingTracker.ProfessionRecipes"                    ""
-- ========================================================================= --
_Active                             = false
-- ========================================================================= --
export {
  -- Addon API 
  RegisterObservableContent           = API.RegisterObservableContent,

  -- WoW API & Utils
  GetCurrencyInfo                     = C_CurrencyInfo.GetCurrencyInfo,
  GetRecipesTracked                   = C_TradeSkillUI.GetRecipesTracked,
  GetRecipeSchematic                  = C_TradeSkillUI.GetRecipeSchematic,
  IsRecipeTracked                     = C_TradeSkillUI.IsRecipeTracked,
  IsReagentSlotBasicRequired          = ProfessionsUtil.IsReagentSlotBasicRequired,
  IsReagentSlotRequired               = ProfessionsUtil.IsReagentSlotRequired,
  IsReagentSlotModifyingRequired      = ProfessionsUtil.IsReagentSlotModifyingRequired,
  AccumulateReagentsInPossession      = ProfessionsUtil.AccumulateReagentsInPossession
}

PROFESSION_RECIPES_CONTENT_SUBJECT = RegisterObservableContent("professionRecipes", ProfessionRecipesContentSubject)

--- 'TRACKED_RECIPE_UPPDATE' event is triggered directly after loading so we don't need
--- PLAYER_ENTING_WORLD for fetching all recipes.
--- A recipe id can be used two times, one for the recraft and one for the normal one.
--- 'TRACKED_RECIPE_UPDATE' seems be triggered for each recipes and for each version of it
---
--- IMPORTANT: If there are the normal and the recraft version for a recipe id, during the first events, this seems 
--- the table returned for getting the recraft tracked doesn't include them. 

__ActiveOnEvents__ "TRACKED_RECIPE_UPDATE"
function BecomeActiveOn()
  return #GetRecipesTracked(true) > 0 or #GetRecipesTracked(false) > 0
end

function OnActive(self)
  self:LoadProfessionRecipes()
end

function LoadProfessionRecipes(self)
  local professionRecraftRecipe = GetRecipesTracked(true)
  for _, recipeID in ipairs(professionRecraftRecipe) do
    self:UpdateProfessionRecipe(recipeID, true)
  end

  local professionRecipes = GetRecipesTracked(false)
  for _, recipeID in ipairs(professionRecipes) do
    self:UpdateProfessionRecipe(recipeID, false)
  end 
end

function UpdateProfessionRecipe(self, recipeID, isRecraft)
  local recipeSchematic = GetRecipeSchematic(recipeID, isRecraft)

  local recipeData = isRecraft and PROFESSION_RECIPES_CONTENT_SUBJECT:AcquireRecraftRecipe(recipeID) or PROFESSION_RECIPES_CONTENT_SUBJECT:AcquireRecipe(recipeID)

  recipeData.recipeID = recipeID
  recipeData.name = isRecraft and PROFESSIONS_CRAFTING_FORM_RECRAFTING_HEADER:format(recipeSchematic.name) or recipeSchematic.name
  recipeData.icon = recipeSchematic.icon
  recipeData.outputItemID = recipeSchematic.outputItemID
  recipeData.quantityMax = recipeSchematic.quantityMax
  recipeData.quantityMin = recipeSchematic.quantityMin
  recipeData.isRecraft = recipeSchematic.isRecraft
  recipeData.recipeType = recipeSchematic.recipeType
  recipeData.hasCraftingOperationInfo = recipeSchematic.hasCraftingOperationInfo

  recipeData:StartObjectivesCounter()
  for slotIndex, reagentSlotSchematic in ipairs(recipeSchematic.reagentSlotSchematics) do
    if IsReagentSlotRequired(reagentSlotSchematic) then 
      local reagent = reagentSlotSchematic.reagents[1]
      local quantityRequired = reagentSlotSchematic.quantityRequired
      local quantity = AccumulateReagentsInPossession(reagentSlotSchematic.reagents)
      local name 

      if IsReagentSlotBasicRequired(reagentSlotSchematic) then 
        if reagent.itemID then 
          local item = Item:CreateFromItemID(reagent.itemID) 
          name = item:GetItemName()
        elseif reagent.currencyID then 
          local currencyInfo = GetCurrencyInfo(reagent.currencyID)
          if currencyInfo then 
            name = currencyInfo.name 
          end
        end
      elseif IsReagentSlotModifyingRequired(reagentSlotSchematic) then
        if reagentSlotSchematic.slotInfo then 
          name = reagentSlotSchematic.slotInfo.slotText 
        end
      end

      if name then 
        local text = PROFESSIONS_TRACKER_REAGENT_FORMAT:format(PROFESSIONS_TRACKER_REAGENT_COUNT_FORMAT:format(quantity, quantityRequired), name)
        local isCompleted = quantity >= quantityRequired

        local objectiveData = recipeData:AcquireObjective()
        objectiveData.isCompleted = isCompleted
        objectiveData.text = text
      end
    end
  end
  recipeData:StopObjectivesCounter()
end

__SystemEvent__()
function TRACKED_RECIPE_UPDATE(recipeID, tracked)
  if not tracked then 
    if not IsRecipeTracked(recipeID, false) then
      PROFESSION_RECIPES_CONTENT_SUBJECT.recipes[recipeID] = nil 
    end

    if not IsRecipeTracked(recipeID, true) then 
      PROFESSION_RECIPES_CONTENT_SUBJECT.recraftRecipes[recipeID] = nil 
    end
  else
    _M:LoadProfessionRecipes()
  end
end

__SystemEvent__ "CURRENCY_DISPLAY_UPDATE" "BAG_UPDATE_DELAYED"
function UPDATE_RECIPES()
  _M:LoadProfessionRecipes()
end
-- ========================================================================= --
-- Debug Utils Tools
-- ========================================================================= --
DebugTools.TrackData(PROFESSION_RECIPES_CONTENT_SUBJECT, "Profession Recipes Content Subject")