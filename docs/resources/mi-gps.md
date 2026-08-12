# mi-gps

Duty unit tracker for service jobs. It draws job-scoped world blips (who can see whom is set per job) and publishes the on-duty unit feed (positions, callsigns, vehicle state) that mi-dispatch reuses for its map.

## Install

```cfg
ensure mi-gps
```

Depends on ox_lib and qbx_core or mi_core. It has no database of its own, so there is nothing to import.

## Config

Owner settings live in `shared/config/init.lua`; the jobs list is in `shared/config/jobs.lua`. Config uses the module-return pattern (consumers do `local Config = require 'shared.config'`). The per-vehicle-class sprite map (`Config.Sprite`) is internal data and is omitted here.

```lua
-- shared/config/init.lua
selfBlip = true,        -- classic arrow / job blip for the local player
blipCone = true,        -- draw the FOV cone on unit blips
RefreshTimeout = 5000,  -- ms between unit position broadcasts
SirenSprite = 42,

Jobs = require 'shared.config.jobs',

-- shared/config/jobs.lua: jobs shown on the duty map, and which jobs each may see.
return {
    ['police'] = {
        blip   = { sprite = 1, color = 38 },
        canSee = { ['police'] = true, ['doc'] = true },
    },
    ['ambulance'] = {
        blip   = { sprite = 1, color = 1 },
        canSee = { ['ambulance'] = true },
    },
    -- ... more jobs
}
```

## Exports

| Export | Signature | What it does |
| --- | --- | --- |
| GetUnits | `exports['mi-gps']:GetUnits()` (client) | Returns the on-duty roster with last known positions: an array of `{ src, job, grade, name, callsign, veh, x, y, z }`. mi-dispatch reads this instead of streaming unit positions a second time. |

## Commands

| Command | Access | Does |
| --- | --- | --- |
| `/department [1-3]` | police / doc, on duty | Sets your department tag and blip colour: 1 = LSSD, 2 = LSPD, 3 = SAST. |
| `/callsign [callsign]` | police / doc, on duty | Sets the callsign shown next to your name on the duty map. |

## Statebags

mi-gps sets no statebag of its own; it watches the core `isLoggedIn` player bag so it only starts drawing blips and processing the unit roster once the player has loaded.

| Statebag | Scope | Set when | Read by |
| --- | --- | --- | --- |
| `isLoggedIn` | player | Set by mi_core when the player finishes loading (cleared on logout). | mi-gps, which ignores the duty-unit roster until the player is logged in. |

See the [state reference](../mi_core/reference/state.md) for the core statebags and GlobalState.
