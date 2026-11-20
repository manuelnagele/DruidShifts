# DruidShifts

A WoW Forever addon that shows, for each druid form, how many times you can shift into it before you run out of mana.

- A row of form icons with a big number under each one. The form you're in is at full brightness.
- Number colors: red at 0, orange at 1, yellow at 2, white at 3 or more.
- When your current form hits 0, the number flashes, a raid-warning sound plays and a message appears on screen.

## Install

1. Download `DruidShifts.zip` from the [latest release](../../releases/latest).
2. Unzip it into the `Interface/AddOns/` folder of your **WoW Forever** installation (not Classic or Retail), so that you get `AddOns/DruidShifts/DruidShifts.toc`.
3. Restart the game or type `/reload`.

If the addon shows as "out of date" in the AddOns list, tick "Load out of date AddOns" for now.

## Commands

| Command | Effect |
|---|---|
| `/shifts unlock` | Shows a background so you can drag the frame |
| `/shifts lock` | Hides the background and makes the frame click-through |
| `/shifts reset` | Resets position and scale |
| `/shifts scale 1.5` | Changes the size (0.5 – 3) |
| `/shifts sound` | Turns the warning sound on or off |

## Testing checklist

This is an early prototype that hasn't been tested in-game yet. Please check these things:

1. Run `/console scriptErrors 1` once so Lua errors pop up. Copy any errors you see.
2. **Most important: do the numbers keep changing during combat?** WoW Forever can hide some values from addons in combat. If mana is hidden, the numbers freeze at their pre-combat values until combat ends.
3. Does each number match `current mana ÷ the form's mana cost` (shown in the spell tooltip)?
4. With the Natural Shapeshifter talent: is the reduced cost used?
5. Do the numbers keep updating while you're in Cat or Bear form?
6. Does the warning fire when you can't shift into your current form anymore?
7. Run `/dump select(4, GetBuildInfo())` and report the number it prints.

Open an [issue](../../issues) with what you find, or send it directly.
