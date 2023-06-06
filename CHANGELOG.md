# 1.2.4

**CHANGES**

- The quests now use waypoints and will be added as objectives, helping the player to navigate to the quest area.
- Improved the part where the player must be notified when a quest just needs to be turned in, an objective will be used to clearly indicate this case.

---

## 1.2.3

**FIXES**

- Fixed [ticket #72](https://github.com/Skamer/Syling-Tracker/issues/72) : where the quest popups were no longer displayed after the first one.

---

## 1.2.2

- bumped the version for 10.1.0

**FIXES**

- Fixed an issue where the quest module was broken when a quest with a tag was accepted.

---

## 1.2.1

- bumped the toc version for 10.0.7

---

## 1.2.0

- bumped the toc version for 10.0.5

**NEW**

- Added the visibility rules for trackers in the options, allowing to say if the tracker must be hidden or shown depending of instance, group size and macro conditional.

**CHANGES**

- Changed the way on how the Blizzard objective tracker is replaced, so the addon will no longer taint it.

**FIXES**

- Fixed an error lua when a player has died in mythic + .

---

## 1.1.1

**FIXES**

- The item bar is now fixed, and will now display the item cooldown.
- The resizer should now be correctly hidden if the tracker is locked after a reload or the first login.

---

## 1.1.0

- Bumped the toc version for 10.0.2

**NEW**

- Added new slash commands: `/slt show` `/slt hide` `/slt toggle` `/slt lock` `/slt unlock` and `/slt tlock` ([more details here](https://github.com/Skamer/Syling-Tracker/issues/62#issuecomment-1312482626))
- OPTIONS: Added options for changing the tracker scaling, its background and its borders.
- OPTIONS: Added an option for changing the thumb color of the tracker scroll bar.
- OPTIONS: The escape key will now close the options panel.

---

## 1.0.2

**FIXES**

- Fixed an issue where the locked setting of trackers wasn't persisted.
- Fixed a case where the tracker scaling is incorrect after creating one.
- OPTIONS: Fixed an issue where the behavior of "show scroll bar" checkbox may be retrieved on others checkbox.

**CHANGES**

- The trackers created will now be positioned on the center of the screen (instead to be to the right) and will be unlocked by default.

---

## 1.0.1

**FIXES**

- OPTIONS: Fixed an issue where the settings controls no longer works after leaving the "Create a tracker" category.

---

## 1.0.0

You can look my [post](https://github.com/Skamer/Syling-Tracker/discussions/60) about this update.

- Bumped the toc version for dragonflight.

**NEW**

- Added the options panel: this can be opened in typing `/slt` or clicking on the addon minimap icon.
- Added the multi-tracker system: you can now create trackers, and choose which contents are tracked.

**CHANGES**

- Changed the tracker scrollbar
