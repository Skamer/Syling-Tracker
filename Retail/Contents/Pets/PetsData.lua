

-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
if not C_AddOns.IsAddOnLoaded("PetTracker") then return end
-- ========================================================================= --
Syling                   "SylingTracker.Data.PetsData"                       ""
-- ========================================================================= --
__DataProperties__ {
  { name = "specieID", type = Number},
  { name = "name", type = String },
  { name = "icon", type = Any}, 
  { name = "level", type = Number},
  { name = "quality", type = Number},
  { name = "sourceIcon", type = Any },
}
class "PetData" { ObjectData}

__DataProperties__ {
  { name = "pets", type = PetData, isMap = true, singularName = "pet" },
  { name = "progress", type = Any},
  { name = "totalInZone", type = Number},
  { name = "ownedInZone", type = Number },
  { name = "ownedByQualityInZone", type = Number, isMap = true } 

}
class "PetsContentSubject" { ContentSubject }