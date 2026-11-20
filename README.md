# DruidShifts

A WoW Classic Era addon that shows, for each druid form, how many times you can shift into it before you run out of mana.

- A row of form icons with a big number under each one. The form you're in is at full brightness.
- Number colors: red at 0, orange at 1, yellow at 2, white at 3 or more.
- When your current form hits 0, the number flashes, a raid-warning sound plays and a message appears on screen.

## Install

1. Download `DruidShifts.zip` from the [latest release](../../releases/latest).
2. Unzip it into `World of Warcraft/_classic_era_/Interface/AddOns/` so that you get `AddOns/DruidShifts/DruidShifts.toc`.
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
2. Does each number match `current mana ÷ the form's mana cost` (shown in the spell tooltip)?
3. With the Natural Shapeshifter talent: is the reduced cost used?
4. Do the numbers keep updating while you're in Cat or Bear form?
5. Does the warning fire when you can't shift into your current form anymore?
6. Run `/dump select(4, GetBuildInfo())` and report the number it prints.

Open an [issue](../../issues) with what you find, or send it directly.
