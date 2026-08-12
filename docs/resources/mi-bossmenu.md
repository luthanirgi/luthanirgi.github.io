# mi-bossmenu

A boss menu for jobs and gangs with a React UI, plus persistent on-duty totals. Bosses hire, fire, set grades, and review employee duty time. Built for servers with large rosters: duty time is tallied in the database, not recomputed by walking the player list. The menu, a toggle-duty prompt, and a paycheck NPC all open through `ox_target`.

## Install

```cfg
ensure mi-bossmenu
```

Depends on ox_lib, ox_inventory, ox_target, oxmysql and qbx_core or mi_core.

It ships `server/migrate.lua`, so its tables auto-create on first boot, no manual SQL import.

Player, job and gang data come from the core through the framework bridge (`shared/config/bridge.lua`, `exports.qbx_core` by default). Prompts use `ox_target`; the paycheck uses `ox_inventory`. OneSync must be on.

## Config

Owner-editable settings live in `shared/config/*.lua`.

`shared/config/bossmenu.lua` lists every job and gang that has a boss zone. Each entry names a core job/gang, the grade needed to see the prompt, the sphere radius, and one or more coordinates (the server revalidates `isboss`). A `vec3(0, 0, 0)` coordinate is a stub, so a disabled location stays documented without spawning a zone:

```lua
gangs = {
    { name = 'godfathers', minGrade = 14, radius = 1.5,
      coords = { vec3(-291.44, -1774.64, 1110.18), vec3(1822.87, -2375.74, 148.58) } },
    { name = 'underground', minGrade = 3, radius = 1.5, coords = vec3(-834.40, -403.50, 31.64) },
    -- ...
},
jobs = {
    { name = 'police', minGrade = 4, radius = 1.5, coords = {
        vec3(140.61, -370.15, 49.98),   -- Mission Row
        vec3(1842.08, 3694.61, 38.05),  -- Sandy Shores
    } },
    -- ...
},
```

`shared/config/toggleduty.lua` sets the toggle-duty prompt and its per-job zones:

```lua
radius = 0.7,
icon   = 'fas fa-clipboard-check',
label  = 'Toggle Duty',
zones  = {
    { job = 'police', coords = { vec3(124.99, -364.95, 45.14), vec3(441.89, -979.39, 30.46) } },
    { job = 'ambulance', coords = { vec3(1910.56, 216.11, 179.02) } },
    -- ...
},
```

`shared/config/paycheck.lua` sets the paycheck NPC. The balance itself is owned by the core (accrued on duty, moved with its paycheck exports); change the pay rates in the core's job grades:

```lua
enabled = true,
ped = {
    model    = 'ig_tomcasino',
    coords   = vec4(-439.8397, 1107.6741, 329.7932, 343.8159),
    scenario = 'WORLD_HUMAN_CLIPBOARD',
},
targetRadius  = 1,
spawnDistance = 20.0,
moneyItem     = 'money',
```

Notifications and UI copy load from `locales/<locale>.json` (ships `en`), with one file feeding both the Lua notifications and the React UI.

## Statebags

mi-bossmenu does not set its own statebag. It keeps persistent on-duty totals by watching the core-owned `onduty` player bag: an `AddStateBagChangeHandler('onduty', ...)` opens a duty-time session when the bag turns true and closes it when the bag turns false.

| Statebag | Scope | Set when | Read by |
|---|---|---|---|
| `onduty` | player | the core sets it at login and whenever duty or job changes | mi-bossmenu (starts or ends a duty-time session on each change) |

See the [state reference](../mi_core/reference/state.md) for the core statebags and GlobalState.
