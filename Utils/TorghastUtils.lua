-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling               "SylingTracker.TorghastUtils"                           ""
-- ========================================================================= --
namespace                          "SLT"
-- ========================================================================= --
local GetMawPowerBorderAtlasBySpellID = C_Spell.GetMawPowerBorderAtlasBySpellID

class "Utils" (function(_ENV)
  class "Torghast" (function(_ENV)
    
    _AnimaPowerRarityCache = {}

    enum "AnimaPowerRarity" {
      UNKNOWN   = 0,
      COMMON    = 1,
      UNCOMMON  = 2,
      RARE      = 3,
      EPIC      = 4
    }

    __Arguments__ { Number }
    __Static__() function GetAnimaPowerRarity(spellID)
      local rarity = _AnimaPowerRarityCache[spellID]
      if rarity then 
        return rarity 
      end

      local borderColor = GetMawPowerBorderAtlasBySpellID(spellID)

      if borderColor == "jailerstower-animapowerlist-powerborder-white" then 
        rarity = AnimaPowerRarity.COMMON 
      elseif borderColor == "jailerstower-animapowerlist-powerborder-green" then 
        rarity = AnimaPowerRarity.UNCOMMON
      elseif borderColor == "jailerstower-animapowerlist-powerborder-blue" then 
        rarity = AnimaPowerRarity.RARE
      elseif borderColor == "jailerstower-animapowerlist-powerborder-purple" then 
        rarity = AnimaPowerRarity.EPIC 
      end
      
      if rarity then 
      -- Add in the cache for the next time only if the rarity has been found 
      _AnimaPowerRarityCache[spellID] = rarity
      else 
        rarity = AnimaPowerClass.UNKNOWN
      end

      return rarity
    end 
  end)
end)