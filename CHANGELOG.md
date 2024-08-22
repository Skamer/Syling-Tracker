## 2.4.3

**FIXES**

- Fixed a case where an error is triggered when accepting a quest.

---

# 2.4.2

**NEW**

- Added a way for changing the tracker size from the options.

**FIXES**

- Fixed an issue where the resizer isn't displayed when the tracker is unlocked after a loading.

---

## 2.4.1

- Finished the status bar for UIWidgets.

---

## 2.4.0

**NEW**

- Added the support of 4th affix for mythic +.
- Added the textures for The War Within dungeons.
- Added a new option for setting an offset for the position of tracker scrollbar.
- Added a new option for using the tracker height for the height of tracker scrollbar.
- Added a new option for changing the background and border for the item bar.
- Added a new option for changing the position of tracker minimize button.
- Added [ticket #90](https://github.com/Skamer/Syling-Tracker/issues/90) : the visibility rules for the item bar in the options.

**CHANGES**

- Reduced the size for item icon.
- Redesigned the sliders in the options.
- In the options, the settings concerning a position or a location will now use a new widget.
- In the options, the value of setting controls will now be sync.

**FIXES**

- Fixed an issue where sometimes the tracker will change its position when navigating in the options.
- Fixed an issue where the items in the item bar weren't in the correct location after locked the item bar.
- Fixed an issue where the world quest items and task items were not added in the item bar.
- Fixed a visual bug caused by POI buttons when scrolling the tracker.
- In the options, fixed an issue where the setting controls executed their callbacks without user events.

---

## 2.3.1

**NEW**

- Added TomTom integration as experimental feature (can be enabled from the options).

---

## 2.3.0

- Update the POI Buttons.

---

## 2.2.1

**FIXES**

- Fixed errors due a missing api function on wow live version.

---

## 2.2.0

**NEW**

- The Delve (new content from The War Within) is now fully supported.

**FIXES**

- Fixed an error lua sometimes triggered by tasks and causing the addon to be broken.
- Fixed the border which wasn't displayed when it should be for the scenario.

---

## 2.1.5

**FIXES**

- Fixed an issue where in some condition the quest distance updater could be run multiple times.

---

## 2.1.4

**FIXES**

- Fixed again an issue where the Blizzard objective tracker was displayed when not intended.

---

## 2.1.3

**FIXES**

- Fixed the Dungeon, Keystone (Mythic +) and Scenario were broken due by an api changes.

---

## 2.1.2

**NEW**

- Added an option for changing the anchor where the tracker is relatively positioned (by default: "BOTTOMLEFT").

**FIXES**

- Fixed an error was triggered when an auto quest was present at first loading.
- Fixed an error was triggered when an auto quest was clicked.

---

## 2.1.1

- Reupdate the toc number.

**FIXES**

- Fixed an issue where the Blizzard objective tracker was displayed when not intended.
- Testing a fix for an issue where there is sometimes a delay for displaying the context menu background.
- Testing a fix for an issue where there is sometimes a delay for displaying the thumb of sliders in the options.

---

## 2.1.0

- Updated for The War Within

---

## 2.0.8

- Bumped the toc version for 10.2.6

**FIXES**

- Fixed [ticket #89](https://github.com/Skamer/Syling-Tracker/issues/89) : an error lua at start.

---

## 2.0.7

- Bumped the toc version for 10.2.5

**FIXES**

- Fixed the ColorPicker for options.

---

## 2.0.6

**FIXES**

- Fixed an issue where the world quests wasn't removed when the player teleport out of the zone.
- Fixed an issue where the achievements wasn't updated.

---

## 2.0.5

**NEW**

- Added new slash commands: 'tshow' and 'resetpos'.

**FIXES**

- Fixed an case where sometimes the quests wasn't added in the right category.

---

## 2.0.4

**NEW**

- Added an option for hiding the minimize button for trackers.
- Added an option for disabling the quest POIs.
- Added options for changing the background, border and name colors for dungeon quests, raid quests and legendary quests.

**FIXES**

- Fixed an issue where the color picker wasn't loaded with the right color.
- Fixed an issue where the icon of expandable section wasn't correct at the first time.
- Fixed an issue where the mythic + timer could be reseted when the player leaves then re-enters in the instance.
- Fixed performance issue after a mythic + is finished.

---

## 2.0.3

- Re-added the death counter for the mythic +.
- The timers will now be updated every 0.5s (instead to be every frame) for reducing performance cost.

**FIXES**

- Fixed a case where an error is triggered in the options with the font settings.
- Fixed [ticket #81](https://github.com/Skamer/Syling-Tracker/issues/81) : an "script too long" error triggered during a Mythic +.

---

## 2.0.2

- Re-added the slash commands for tracker and item bar.

---

## 2.0.1

- Left clicking on the quest will open again the quest log for this one.
- The distance updater for quests will be disabled while the player is in instance.

**FIXES**

- Fixed a case where the text of objectives wasn't wrapped when using with some fonts and font sizes.

---

## 2.0.0

Welcome to the v2. The addon has been rewritten from scratch with a new core.

**NEW**

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

**CHANGES**

- Some tuning has been done in the visual for various elements.
