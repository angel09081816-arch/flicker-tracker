# Flicker Role Tracker

A private Roblox exploit GUI for Flicker that shows actual role assignments using local game data and detected client-side values.

> **Warning:** This is intended for private/trusted environments only. Do not use on public servers.

## Files
- `tracker.lua` — main exploit script for the Flicker role viewer.
- `replicated-storage.lua` — helper script from the decompiled Flicker client, used to improve role detection logic.

## Usage
1. Open your exploit executor.
2. Run the following loadstring:

```lua
local source = game:HttpGet("https://raw.githubusercontent.com/angel09081816-arch/flicker-tracker/main/tracker.lua")
local fn = loadstring or load
assert(fn(source))()
```

> For Delta Executor mobile, use the same loader in the executor entry field and tap Execute.

3. Use the GUI:
   - Click `Scan` to detect roles.
   - Toggle `Auto` to refresh every 3 seconds.
   - The `Players` tab shows player names and detected role values.
   - The `Live Scan` tab shows live player data.
   - The `Roles` tab shows the active Flicker role list from GameData.

## What it does
- Uses `GameData` from `DataController` when available to read the active Flicker role list.
- Normalizes detected role names using Flicker's `RoleInfo` data.
- Falls back to scanning player values, ReplicatedStorage objects, and PlayerGui text.

## Notes
- This script is best used in games where Flicker stores role data locally in `ReplicatedStorage` and `GameData`.
- If the game hides roles entirely server-side, the tool may not detect them.

## Want better accuracy?
If you want the script to be even more accurate, the following decompiled Flicker modules are the most useful:
- `RoleInfo`
- `DataController`
- `Common.Network`
- `MainController`
- `Interface`
- `Modules.Frame`
- `Modules.Button`
- `Modules.Tabs`

Providing those will let the tracker match Flicker role data more precisely.
