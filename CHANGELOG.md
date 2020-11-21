# 0.5.1

**CHANGES**

- The objectives text for scenario will now prepend the min and max quantity.

**FIXES**

- Fixed a case in scenario where sometimes the objectives of previous stage weren't correctly removed.

---

## 0.5.0

**NEW**

- The helper window is now available throught the "Help" action in the context menu, and will give a Wowhead link for a quest or a achievement.
- The campaign quests are now separated of other quests and displayed in their own header : "Campaign".

**CHANGES**

- Added the tooltip for quest items in the item bar.

**FIXES**

- Fixed an issue where the progress bar wasn't updated for an dungeon.

---

## 0.4.3

**FIXES**

- Fixed [ticket #26](https://github.com/Skamer/Syling-Tracker/issues/26) : an error lua for tasks and world quests.
- Fixed an issue where some tasks could be displayed even if the player wasn't in their areas and preventing the content to work correctly.

---

## 0.4.2

**FIXES**

- Fixed [ticket #16](https://github.com/Skamer/Syling-Tracker/issues/16) : an issue where the progress text wasn't updated in the scenerio.
- Fixed the displaying order for some contents (e.g, the achievements will no longer be shown before the dungeon).

---

## 0.4.1

**NEW**

- Added a new slash command for setting the scroll sensibility : `/slt scrollstep x` where x is a number (by default: 15).

**FIXES**

- Fixed [ticket #24](https://github.com/Skamer/Syling-Tracker/issues/24) : an issue where sometimes the dungeon content had not the right height.

---

## 0.4.0

**NEW**

- Torghast is now fully supported
- Added a new slash command `/slt qcat` to toggle the displaying of categories for quests.
- Added a new slash command `/slt minimap` to toggle the minimap icon.

**CHANGES**

- The world quests, tasks and bonus tasks will now display a Context Menu by a Right-Clicking.
- Changed the "Help" action name to "Help (NYI)" as this is not yet implemented.

**FIXES**

- Fixed [ticket #15](https://github.com/Skamer/Syling-Tracker/issues/15) : an issue where some icons were upside down ([PR #17](https://github.com/Skamer/Syling-Tracker/pull/17), thanks to @TheSumm).
- Fixed [ticket #12](https://github.com/Skamer/Syling-Tracker/issues/12) : an error lua.
- Fixed [ticket #21](https://github.com/Skamer/Syling-Tracker/issues/21) : an issue where the Context Menu caused sometimes taint errors.
- Fixed some actions of Context Menu for the achievements and quests
- Fixed an issue where sometimes the tasks and bonus tasks were not displayed.

---

## 0.3.7

**FIXES**

- Fixed [ticket #10](https://github.com/Skamer/Syling-Tracker/issues/10) : a case where the quests are not automatically watched.

---

## 0.3.6

**FIXES**

- Readded the command "/slt toggle".

---

## 0.3.5

**NEW**

- A slash command `/slt toggle` has been added for showing/hiding the Tracker and the Item Bar ([PR #11](https://github.com/Skamer/Syling-Tracker/pull/11), thanks to @TheSumm)

**FIXES**

- Fixed an issue where the tracker displayed the quests the more furthest in first.

---

## 0.3.4

**FIXES**

- Fixed an issue where the world quests were added in the quests tracker once completed.
- Fixed a case where the quest wasn't updated correctly.

---

## 0.3.3

**FIXES**

Lot of bugs related to quests have been fixed:

- Resolved an issue where the quest wasn't automatically watched when taking it.
- Fixed an issue where the sorting of quests by distance wasn't done immediately when taking a quest.
- Fixed an issue where the quest catagories weren't correctly clean up and triggering errors when removing their last quest.
- Fixed an issue where in some case the quests categories had not the right name.
- Fixed an error when the player unwatching, abandoning or turning in the last quest.

---

## 0.3.2

**FIXES**

- Fixed [ticket #6](https://github.com/Skamer/Syling-Tracker/issues/6) : LUA errors when opening the world map.

---

## 0.3.x

Welcome to Shadowlands prepatch

---

## 0.2.0

**NEW**

- Added an item bar which gives you a quick access to your quest items.

**CHANGES**

- The progress bar will now be hidden once the objective has been completed for quests, tasks and world quests.
- The context menu will now choose the best side for avoiding to go out of screen.

**FIXES**

- Fix an issue where the progress of tasks wasn't updated.

---

## 0.1.5

**FIXES**

- Fixed [ticket #3](https://github.com/Skamer/Syling-Tracker/issues/3) : an issue where the progress of world quests was not updating.
- Fixed a case where the objectives text was blank.

---

## 0.1.4

**FIXES**

- Fixed [ticket #2](https://github.com/Skamer/Syling-Tracker/issues/2) : an important error when a category has been removed.
- Fixed [ticket #2](https://github.com/Skamer/Syling-Tracker/issues/2) : an error relative to Database.Clean.

---

## 0.1.3

**FIXES**

- Fixed an issue where the things related to Blizzard objective tracker wasn't added.
