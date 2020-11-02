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
      COMMON    = 0,
      UNCOMMON  = 1,
      RARE      = 2,
      EPIC      = 3
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
      
      -- Add in the cache for the next time
      _AnimaPowerRarityCache[spellID] = rarity 

      return rarity
    end 
  end)
end)