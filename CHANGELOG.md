# 2.0.8

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
