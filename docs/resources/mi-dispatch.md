# mi-dispatch

A dispatch / CAD system with a Patrol HUD and a Command Center console (React NUI). It fans automatic alerts (gunfire and more) and player service calls to on-duty job groups, never to everyone, and keeps net, db, and main load low. It provides `ps-dispatch`, `qs-dispatch`, and `cd_dispatch`, so existing resources that ping those keep working unchanged.

## Install

```cfg
ensure mi-dispatch
```

Depends on ox_lib, oxmysql and qbx_core or mi_core.

## Config

`shared/config/` splits into several files. `general.lua` holds the core settings below. `groups.lua` defines the job groups that share a call feed and the dispatcher permissions; `controls.lua` holds the keybinds, the console command, and the player service-call commands; `alerts.lua` defines the automatic alerts and their cooldowns; `apiKeys.lua` holds the FiveManage token and Discord webhook (both blank by default, fill them in yourself); `theme/palettes.lua` holds the colors. Two small weapon tables sit beside them: `weapons.lua` maps a weapon hash to the label shown in a shots-fired alert (an unlisted weapon just shows no label), and `blacklistedWeapons.lua` lists the non-lethal and throwable weapons that never raise an alert at all.

```lua
return {
    debug = false,
    phone = 'mi-phone',           -- phone provider for number lookups: mi-phone | qb | lb | qs | qs-pro | gks
    inventory = 'ox',
    notificationType = 'qb',     -- fallback notify style: qb | mythic
    palette = 'winter_blue',     -- active palette key (see shared/config/theme/palettes.lua), recolor here, no rebuild
    removeCallFromEveryone = true, -- deleting a call removes it for the whole group vs just the deleter
    attachAllUnitsInGroupToCall = false,
    attachAllUnitsInVehicleToCall = false,
    historyLimit = 50,           -- resolved calls the Command Center keeps in history (per client, in memory)
    defaultRemoveTime = 1000 * 60 * 10, -- default call lifetime (ms) when a call omits its own removeTime
    addCall = {                  -- server-side anti-abuse for the client-origin addCall path
        ratePerMinute = 20,      -- max client-origin calls per player per minute
        maxCoordDistance = 200.0,-- client coords must be within this many metres of the caller ped
        maxMessageLength = 200,
        maxTitleLength = 64,
    },
}
```

## Exports

Other resources raise calls through `addCall`. It is available on both the client and the server.

| Export | Signature | What it does |
| --- | --- | --- |
| `addCall` | `exports['mi-dispatch']:addCall(data)` | Raises a dispatch call to the groups named in `data.jobs`. Server origin is trusted; client origin is rate and distance checked. |
| `getPlayerData` | `exports['mi-dispatch']:getPlayerData()` | Client only. Returns the caller's local context (street, gender, heading, coords) for building a call. |
| `panggil` | `exports['mi-dispatch']:panggil(coords, data)` | Server only. Short helper that raises a Priority 1 police call at `coords` from `data.Title` / `data.Code` / `data.Message`. |

## Commands

| Command | Access | Does |
| --- | --- | --- |
| `/dispatch`, `/mdt` | everyone | Open the Command Center (CAD/MDT console). Content is shown for members of a dispatch group. |
| `/911` | everyone | Service call to the police (`police`, `doc`) at Priority 2 with code `10-67`. |
| `mid_toggleHud`, `mid_moveMode`, `mid_nextCall`, `mid_prevCall`, `mid_accept`, `mid_waypoint`, `mid_status`, `mid_panic` | on-duty units | Patrol HUD keybind commands (default keys F6, I, RIGHT, LEFT, UP, DOWN, END, O). Rebind in FiveM key settings. |
| `midispatch:debugcall` | everyone | Spawns a test call. Only registered when `general.debug = true`. |

Service-call commands come from `controls.serviceCalls`, which ships one entry (`911`) as a worked example. Add a key per dial code you want, naming the departments it pings, its radio code, its priority, the locale key for its title, and the confirmation the caller sees:

```lua
serviceCalls = {
    ['911'] = { jobs = { 'police', 'doc' }, code = '10-67', priority = 'Priority 2', title = 'call', notify = 'Message sent to the police department.' },
    ['311'] = { jobs = { 'ambulance' },     code = '10-52', priority = 'Priority 1', title = 'call', notify = 'Message sent to EMS.' },
}
```

## Statebags

mi-dispatch sets no statebag of its own; it watches the core `onduty` bag so a duty change re-evaluates dispatch-group membership without depending on a specific event name.

| Statebag | Scope | Set when | Read by |
| --- | --- | --- | --- |
| `onduty` | player | Set by mi_core at login and whenever duty or job changes. | mi-dispatch, which re-evaluates the player's dispatch-group membership on every change. |

See the [state reference](../mi_core/reference/state.md) for the core statebags and GlobalState.
