-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                  "SylingTracker.Utils.Instance"                       ""
-- ========================================================================= --
INSTANCE_TEXTURE_FILES_ID = {
  -- Classic instances
  [36] = 337488, -- Deadmines
  [33] = 340687 , -- Shadowfang Keep
  [34] = 340688, -- The Stockade
  [43] = 340702, -- Wailing Caverns
  [47] = 340684, -- Razorfen Kraul
  [48] = 340655, -- Blackfathom Deeps
  [70] = 340697, -- Uldaman
  [90] = 340665, -- Gnomeregan
  [109] = 340690, -- The Temple of Atal'hakkar
  [129] = 340683, -- Razorfen Downs
  [209] = 340704, -- Zul'Farra
  [229] = 340657, -- Lower Blackrock Spire
  [230] = 340656, -- Blackrock Depths
  [329] = 340689, -- Stratholme
  [349] = 340677,  -- Maraudon
  [389] = 340682, -- Ragefire Chasm
  [429] = 340663, -- Dire Maul
  [1001] = 649960, -- Scarlet Halls
  [1004] = 340685, -- Scarlet Monastery
  [1007] = 649961, -- Scholomance

  -- TBC instances
  [269] = 340660, -- The Black Morass
  [540] = 337491, -- The Shattered Halls
  [542] = 337491, -- The Blood Furnace
  [543] = 337491, -- Hellfire Ramparts
  [545] = 340662, -- The Steam vault
  [546] = 340662, -- The Under bog
  [547] = 340662, -- The Slave Pens
  [552] = 340692, -- The Arcatraz
  [553] = 340692, -- The Botanica
  [554] = 340692, -- The Mechanar
  [555] = 340653, -- Shadow Labyrinth
  [556] = 340653, -- Sethekk Halls
  [557] = 340653, -- Mana-Tombs
  [558] = 340653, -- Auchenai Crypts
  [560] = 340660, -- Old Hillsbrad Foothill
  [585] = 340675, -- Magisters's Terrace

  -- WotLK instances
  [574] = 340699, -- Utgarde Keep
  [575] = 340700, -- Utgarde Pinnacle
  [576] = 340694, -- The Nexus
  [578] = 340695, -- The Oculus
  [595] = 340689, -- The Culling Of Stratholme
  [599] = 340670, -- Halls Of Stone
  [600] = 340664, -- DrakTharon Keep
  [601] = 340654, -- Azjol Nerub
  [602] = 340668, -- Halls of Lightning
  [604] = 340667, -- Gundrak
  [608] = 340696, -- The Violet Hold
  [619] = 340648, -- Ahn'kahet
  [632] = 340693, -- The Forge Of Souls
  [650] = 340651, -- Trial of the Champion
  [658] = 340681, -- Pit Of Saron
  [668] = 340669, -- Halls Of Reflection

  -- Cataclysm instances
  [568] = 340703, -- Zul Aman
  [643] = 460620, -- Throne of the Tides
  [644] = 460616, -- Halls Of Origination
  [645] = 460614, -- Blackrock Caverns
  [657] = 460619, -- Vortex Pinnacle
  [670] = 460615, -- Grim Batol
  [725] = 460618, -- Stonecore
  [755] = 466904, -- Lost City
  [859] = 340705, -- Zul Gurub
  [938] = 575267, -- End Time
  [939] = 575271, -- Well Of Eternity
  [940] = 575269, -- Hour Of Twilight

  -- MoP instances
  [959] = 649962, -- Shado Pan Monastery
  [960] = 656587, -- Temple of the Jade Serpent
  [961] = 649965, -- Stormstout Brewery
  [962] = 649955, -- Gate Of The Setting Sun
  [994] = 656586, -- Mogushan Palace
  [1011] = 876949, -- Siege Of Niuzao Temple

  -- WoD instances
  [1175] = 1042044, -- Bloodmaul Slag Mines
  [1176] = 1042048, -- Shadowmoon Burial Grounds
  [1182] = 1042042, -- Auchindoun
  [1195] = 1060550, -- Iron Docks
  [1208] = 1042046, -- Grimrail Depot
  [1209] = 1042049, -- Skyreach
  [1279] = 1060549, -- The Everbloom
  [1358] = 1042050, -- Upper Blackrock Spire

  -- Legion instances
  [1456] = 1498165, -- Eye of Azshara
  [1458] = 1450578, -- Neltharions Lair
  [1466] = 1411861, -- Darkheart Thicket
  [1477] = 1498166, -- Halls of Valor
  [1492] = 1411862, -- Maw of Souls Trash
  [1493] = 1411864, -- Vault of the Wardens
  [1501] = 1411859, -- Black Rook Hold
  [1516] = 1411863, -- The Arcway
  [1544] = 1498163, -- Assault on Violet Hold
  [1571] = 1498164, -- Court of Stars
  [1651] = 340674, -- Karazhan
  [1677] = 1616923, -- Cathedral of Eternal Night
  [1753] = 1718219, -- Seat of the Triumvirate

  -- BFA instances
  [1594] = 2179225, -- The MOTHERLODE!!
  [1754] = 1778895, -- Freehold
  [1762] = 2179221, -- King's Rest
  [1763] = 1778894, -- Ataldazar
  [1771] = 2179227, -- Tol Dagor
  [1822] = 2179223, -- Siege of Boralus
  [1862] = 2179233, -- Waycrest Manor
  [1864] = 2179222, -- Shrine of the Storm
  [1877] = 2179224, -- Temple of Sethraliss
  [2097] = 3025284, -- Operation: Mechagon

  -- Shadowlands instances
  [2284] = 3759946, -- Sanguine Depths
  [2285] = 3759947, -- Spires of Ascension 
  [2286] = 3759944, -- The Necrotic Wake
  [2287] = 3759942, -- Halls of Atonement
  [2289] = 3759945, -- Plaguefall 
  [2290] = 3759943, -- Mists of Tirna Scithe
  [2291] = 3759949, -- De Other Side 
  [2293] = 3759948, -- Theater Of Pain
  [2441] = 4329242, -- Tazavesh

  -- Dragonflight instances
  [2451] = 4880613, -- Uldaman: Legacy of Tyr
  [2519] = 4880619, -- Neltharus
  [2520] = 4880615, -- Brackenhide Hollow
  [2526] = 4880621, -- Algeth'ar Academy 
  [2515] = 4880614, -- The Azure Vault
  [2516] = 4878194, -- The Nokhud Offensive
  [2521] = 4880618, -- Ruby Life Pools
  [2527] = 4880617, -- Halls of Infusion
  [2579] = 5221805, -- Dawn of the Infinite
}

__Arguments__{ Number/0}
function GetInstanceTextureFileID(mapID)
  local fileID = INSTANCE_TEXTURE_FILES_ID[mapID]
  
  if fileID then 
    return fileID
  end

  return 337493 -- random dungeons
end

-- Export the functions in Utils
Utils.GetInstanceTextureFileID = GetInstanceTextureFileID