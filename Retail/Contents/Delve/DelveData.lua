-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                 "SylingTracker.Contents.DelveData"                    ""
-- ========================================================================= --
__DataProperties__{
    { name = "modifierID", type = Number },
    { name = "name", type = String },
    { name = "description", type = String},
    { name = "texture", type = Any }
}
class "DelveModifierData" { ObjectData }

__DataProperties__ {
    { name = "name", type = String },
    { name = "tierText", type = String},
    { name = "tierTooltipSpellID", type = Number},
    { name = "isCompleted", type = Boolean},
    { name = "modifiersCount", type = Number },
    { name = "modifiers", type = DelveModifierData, isArray = true, singularName = "modifier"},
    { name = "objectives", type = ObjectiveData, isArray = true, singularName = "objective"},
    { name = "numCriteria", type = Number},
    { name = "showRevives", type = Boolean},
    { name = "reviveText", type = String}, 
    { name = "reviveTooltip", type = String},
    { name = "showReward", type = Boolean},
    { name = "hasEarnedReward", type = Boolean},
    { name = "hasUnearnedReward", type = Boolean},
    { name = "earnedRewardTooltip", type = String},
    { name = "unearnedRewardTooltip", type = String},
}
class "DelveContentSubject" { ContentSubject }