-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                "SylingTracker.Keystone.AutoSlotKey"                   ""
-- ========================================================================= --
export {
  GetContainerNumSlots                = C_Container.GetContainerNumSlots,
  GetContainerItemInfo                = C_Container.GetContainerItemInfo,
  PickupContainerItem                 = C_Container.PickupContainerItem,
  CursorHasItem                       = CursorHasItem,
  SlotKeystone                        = C_ChallengeMode.SlotKeystone
}

__SystemEvent__()
function ADDON_LOADED(addonName)
  if addonName ~= "Blizzard_ChallengesUI" then return end 

  if ChallengesKeystoneFrame then 
    ChallengesKeystoneFrame:HookScript("OnShow", function()
      for bag = 0, NUM_BAG_FRAMES do 
        for slot = 1, GetContainerNumSlots(bag) do 
          local itemInfo = GetContainerItemInfo(bag, slot)
          if itemInfo and itemInfo.hyperlink:match("keystone") then
            PickupContainerItem(bag, slot)
            if CursorHasItem() then 
              SlotKeystone()
              break
            end
          end
        end
      end
    end)
  end
end