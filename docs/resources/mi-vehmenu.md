# mi-vehmenu

An in-vehicle React console for controlling the car you are sitting in: doors, windows, seat swaps, engine, blinkers and hazards, and the interior light. The engine toggle is gated behind a vehicle keys resource so only players with the key can start it.

## Install

```cfg
ensure mi-vehmenu
```

## Config

`shared/config/init.lua` is the config aggregator:

```lua
local Config = {
    Debug = false,
    CommandName = 'vehmenu',          -- command that opens the menu (keep the name so player habits work)

    Keybind = {
        enabled = false,              -- open via command / radial only
        key = 'Y',
    },

    -- Allow servers to hide whole groups.
    Controls = {
        doors = true,
        windows = true,
        seats = true,
        engine = true,
        blinkers = true,
        interiorLight = true,
    },

    Translation = require 'shared.config.translation', -- English-only player copy
    colors = require 'shared.config.colors',           -- UI palette, applied at runtime (no rebuild)
}

-- Engine key gate. The keys resource is named here (never hardcoded) and is guarded + fail-open:
-- if it is absent or errors, the engine is NOT locked.
Config.KeysResource = 'mi-keys' -- e.g. 'qb-vehiclekeys', 'wasabi_carlock', false (disable gating)
```

The UI palette is chosen in `shared/config/colors.lua` by setting `PALETTE` to one of `obsidian_rouge`, `winter_blue`, `monochrome`, `twilight_amber`, or `ultramarine_navy`.

## Exports

| Export | Signature | What it does |
| --- | --- | --- |
| `Open` | `exports['mi-vehmenu']:Open()` | Opens the vehicle console for the player's current vehicle. Does nothing if the player is not in one. |

## Commands

| Command | Access | Does |
| --- | --- | --- |
| `/vehmenu` | everyone | Opens the vehicle console for the vehicle you are in. The name is set by `Config.CommandName`. |
