-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                      "SylingTracker.KeystoneData"                     ""
-- ========================================================================= --
__DataProperties__{
  { name = "affixID", type = Number },
  { name = "name", type = String },
  { name = "description", type = String },
  { name = "texture", type = Any }
}
class "AffixData" { ObjectData }

__DataProperties__ {
  { name = "name", type = String},
  { name = "level", type = Number},
  { name = "objectives", type = ObjectiveData, isArray = true, singularName = "objective"},
  { name = "affixes", type = AffixData, isArray = true, singularName = "affix"},
  { name = "textureFileID", type = Number},
  { name = "started", type = Boolean, default = false},
  { name = "completed", type = Boolean, default = false},
  { name = "startTime", type = Number },
  { name = "timeLimit", type = Number},
  { name = "enemyForcesQuantity", type = Number, default = 0 },
  { name = "enemyForcesTotalQuantity", type = Number, default = 0},
  { name = "enemyForcesPendingQuantity", type = Number, default = 0},
  { name = "deathCount", type = Number, default = 0}
}
class "KeystoneContentSubject" { ContentSubject }

-- TODO: 
-- rezTimer
-- rezCount
-- bloodlustTimer

