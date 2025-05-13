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
Syling                    "SylingTracker.Pets"                               ""
-- ========================================================================= --
_Active = false 
-- ========================================================================= --
export {
  RegisterObservableContent           = API.RegisterObservableContent,
  PetTracker                          = PetTracker
}

LibStub("LibPetJournal-2.0").RegisterCallback(_M, "PostPetListUpdated", function() 
  _M:FireSystemEvent("LPJ_PostPetListUpdated")
end)

local PETS_CONTENT_SUBJECT = RegisterObservableContent("pets", PetsContentSubject)

__ActiveOnEvents__ "LPJ_PostPetListUpdated" "ZONE_CHANGED_NEW_AREA"
function BecomeActiveOn(self, event, ...)
  local progress = PetTracker.Maps:GetCurrentProgress()
  return progress.total > 0
end

function OnActive(self)
  self:LoadAndUpdatePets()
end

function OnInactive(self)
  PETS_CONTENT_SUBJECT:ResetDataProperties()
end

__AsyncSingle__()
function LoadAndUpdatePets(self)
  PETS_CONTENT_SUBJECT:ClearPets() 
  PETS_CONTENT_SUBJECT:ClearOwnedByQualityInZone()

  local progress = PetTracker.Maps:GetCurrentProgress()

  PETS_CONTENT_SUBJECT.totalInZone = progress.total

  local ownedInZone = 0
  for quality = 0, PetTracker.Tracker:MaxQuality() do
    local ownedByQuality = 0
    
    for level = 0, PetTracker.MaxLevel do 
      for i, specie in ipairs(progress[quality][level] or {}) do 
        local source = specie:GetSourceIcon()
        if source then 
          local specieID = specie:GetSpecie()
          local petData = PETS_CONTENT_SUBJECT:AcquirePet(specieID)
          local name, icon = specie:GetInfo()

          petData.id = specie:GetID()
          petData.specieID = specieID 
          petData.name = name 
          petData.icon = icon 
          petData.quality = quality
          petData.level = level
          petData.sourceIcon = source

          -- quality == 0 means the missing pets so we don't include them for rarity owned count.
          if quality > 0 then 
            ownedByQuality = ownedByQuality + 1
            PETS_CONTENT_SUBJECT.ownedByQualityInZone[quality] = ownedByQuality
          end
        end
      end
    end

    ownedInZone = ownedInZone + ownedByQuality
  end

  PETS_CONTENT_SUBJECT.ownedInZone = ownedInZone
end

__SystemEvent__ "ZONE_CHANGED_NEW_AREA" "LPJ_PostPetListUpdated"
function Update()
  _M:LoadAndUpdatePets()
end
-- ========================================================================= --
-- Debug Utils Tools
-- ========================================================================= --
DebugTools.TrackData(PETS_CONTENT_SUBJECT, "Pets Content Subject")