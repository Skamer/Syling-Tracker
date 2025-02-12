# 2.6.7

###### NEW

- Added [ticket #120](https://github.com/Skamer/Syling-Tracker/issues/120): a way for showing the tooltip when mouseover a quest.
- Added ruRU locales.

---

## 2.6.6

###### FIXES

- Fixed [ticket #128](https://github.com/Skamer/Syling-Tracker/issues/128): the activities were not added after being tracked.

---

## 2.6.5

- Added a temporary command for [ticket #121](https://github.com/Skamer/Syling-Tracker/issues/121): `/slt showMapForQuestDetails value` (value can be true, false or nil).

---

## 2.6.4

##### Cataclysm

###### FIXES

- Fixed [ticket #126](https://github.com/Skamer/Syling-Tracker/issues/126) : an AutoQuest error.

---

## 2.6.3

###### NEW

- Added [ticket #88](https://github.com/Skamer/Syling-Tracker/issues/88) : options for the auto quests popup.

---

## 2.6.2

###### NEW

- Added [ticket #117](https://github.com/Skamer/Syling-Tracker/issues/117) : a way for changing the horizontal alignment for quest names in the options.

###### FIXES

- Fixed an issue where sometimes the tab content could become blank in the options.
- Fixed an issue where the font of an element would be unexpectedly be changed when navigating in its options.

---

## 2.6.1

- Added zhCN locales.

---

## 2.6.0

- Added the localization support.

---

## 2.5.8

- Bumped the toc version for 11.0.5

##### Vanilla

###### FIXES

- Fixed the quests loading.

---

## 2.5.7

###### NEW

- In Mythic +, the key will now be automatically sloted.

###### FIXES

- Updated the Mythic + timer for matching the behavior of Blizzard timer: the death players will no longer advance the timer when the key is depleted.

---

## 2.5.6

###### FIXES

- Fixed an issue where the timer wasn't correctly advanced on death players for Mythic + (level 7 and above).

---

## 2.5.5

##### Vanilla

###### FIXES

- Fixed [ticket #112](https://github.com/Skamer/Syling-Tracker/issues/112): an error lua triggered by quests with tags.

##### Cataclysm

###### FIXES

- Fixed [ticket #113](https://github.com/Skamer/Syling-Tracker/issues/113): the minimize button on tracker and content headers weren't visible.

---

## 2.5.4

###### FIXES

- In Mythic +, the percentage value will now redisplay a precise value.

---

## 2.5.3

##### Cataclysm

###### FIXES

- Trying a fix for [ticket #110](https://github.com/Skamer/Syling-Tracker/issues/110) : the auto quests were not working.

---

## 2.5.2

- Updated the addon internal api.

---

## 2.5.1

##### Cataclysm

###### FIXES

- Fixed [ticket #109](https://github.com/Skamer/Syling-Tracker/issues/109) : an error lua with tag.

---

## 2.5.0

- Restructured the addon to be able handling multiple game versions.
- The addon now supports Classic Vanilla and Cataclysm (lot of work remain to be done but the base features should be here and working).

###### FIXES

- Fixed the context menu action "Show Details" for the quests.

---

## 2.4.5

###### FIXES

- Fixed an issue where the timer of some events isn't updated.

---

## 2.4.4

###### FIXES

- Fixed an issue where the delve content isn't removed after leaving it.

---

## 2.4.3

###### FIXES

- Fixed a case where an error is triggered when accepting a quest.
- Fixed an error lua in the options when selecting the tracker category.

---

## 2.4.2

###### NEW

- Added a way for changing the tracker size from the options.

###### FIXES

- Fixed an issue where the resizer isn't displayed when the tracker is unlocked after a loading.

---

## 2.4.1

- Finished the status bar for UIWidgets.

---

## 2.4.0

###### NEW

- Added the support of 4th affix for mythic +.
- Added the textures for The War Within dungeons.
- Added a new option for setting an offset for the position of tracker scrollbar.
- Added a new option for using the tracker height for the height of tracker scrollbar.
- Added a new option for changing the background and border for the item bar.
- Added a new option for changing the position of tracker minimize button.
- Added [ticket #90](https://github.com/Skamer/Syling-Tracker/issues/90) : the visibility rules for the item bar in the options.

###### CHANGES

- Reduced the size for item icon.
- Redesigned the sliders in the options.
- In the options, the settings concerning a position or a location will now use a new widget.
- In the options, the value of setting controls will now be sync.

###### FIXES

- Fixed an issue where sometimes the tracker will change its position when navigating in the options.
- Fixed an issue where the items in the item bar weren't in the correct location after locked the item bar.
- Fixed an issue where the world quest items and task items were not added in the item bar.
- Fixed a visual bug caused by POI buttons when scrolling the tracker.
- In the options, fixed an issue where the setting controls executed their callbacks without user events.

---

## 2.3.1

###### NEW

- Added TomTom integration as experimental feature (can be enabled from the options).

---

## 2.3.0

- Update the POI Buttons.

---

## 2.2.1

###### FIXES

- Fixed errors due a missing api function on wow live version.

---

## 2.2.0

###### NEW

- The Delve (new content from The War Within) is now fully supported.

###### FIXES

- Fixed an error lua sometimes triggered by tasks and causing the addon to be broken.
- Fixed the border which wasn't displayed when it should be for the scenario.

---

## 2.1.5

###### FIXES

- Fixed an issue where in some condition the quest distance updater could be run multiple times.

---

## 2.1.4

###### FIXES

- Fixed again an issue where the Blizzard objective tracker was displayed when not intended.

---

## 2.1.3

###### FIXES

- Fixed the Dungeon, Keystone (Mythic +) and Scenario were broken due by an api changes.

---

## 2.1.2

###### NEW

- Added an option for changing the anchor where the tracker is relatively positioned (by default: "BOTTOMLEFT").

###### FIXES

- Fixed an error was triggered when an auto quest was present at first loading.
- Fixed an error was triggered when an auto quest was clicked.

---

## 2.1.1

- Reupdate the toc number.

###### FIXES

- Fixed an issue where the Blizzard objective tracker was displayed when not intended.
- Testing a fix for an issue where there is sometimes a delay for displaying the context menu background.
- Testing a fix for an issue where there is sometimes a delay for displaying the thumb of sliders in the options.

---

## 2.1.0

- Updated for The War Within

---

## 2.0.8

- Bumped the toc version for 10.2.6

###### FIXES

- Fixed [ticket #89](https://github.com/Skamer/Syling-Tracker/issues/89) : an error lua at start.

---

## 2.0.7

- Bumped the toc version for 10.2.5

###### FIXES

- Fixed the ColorPicker for options.

---

## 2.0.6

###### FIXES

- Fixed an issue where the world quests wasn't removed when the player teleport out of the zone.
- Fixed an issue where the achievements wasn't updated.

---

## 2.0.5

###### NEW

- Added new slash commands: 'tshow' and 'resetpos'.

###### FIXES

- Fixed an case where sometimes the quests wasn't added in the right category.

---

## 2.0.4

###### NEW

- Added an option for hiding the minimize button for trackers.
- Added an option for disabling the quest POIs.
- Added options for changing the background, border and name colors for dungeon quests, raid quests and legendary quests.

###### FIXES

- Fixed an issue where the color picker wasn't loaded with the right color.
- Fixed an issue where the icon of expandable section wasn't correct at the first time.
- Fixed an issue where the mythic + timer could be reseted when the player leaves then re-enters in the instance.
- Fixed performance issue after a mythic + is finished.

---

## 2.0.3

- Re-added the death counter for the mythic +.
- The timers will now be updated every 0.5s (instead to be every frame) for reducing performance cost.

###### FIXES

- Fixed a case where an error is triggered in the options with the font settings.
- Fixed [ticket #81](https://github.com/Skamer/Syling-Tracker/issues/81) : an "script too long" error triggered during a Mythic +.

---

## 2.0.2

- Re-added the slash commands for tracker and item bar.

---

## 2.0.1

- Left clicking on the quest will open again the quest log for this one.
- The distance updater for quests will be disabled while the player is in instance.

###### FIXES

- Fixed a case where the text of objectives wasn't wrapped when using with some fonts and font sizes.

---

## 2.0.0

Welcome to the v2. The addon has been rewritten from scratch with a new core.

###### NEW

- New contents: Collections, Recipe Tracker and Activities.
- Implemented POI icons.
- The Item Bar has been completely redevelopped. The row count, column count, item size, orientation, padding and margin can be changed from the options.
- The Mythic + module has been redone : new visual, and now supports the addon Mythic Dungeon Tools for displaying the pull percent.
- The trackers can now be minimized from a button.
- The contents can now be minimized.
- The tracker can be automatically hidden if no content is inside.
- Partial support of Widgets
- The scenario now display widgets if needed : this should display the timer of some events.
- Lot of new options have been added.

###### CHANGES

- Some tuning has been done in the visual for various elements.
