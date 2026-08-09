# mi-garage

A React NUI garage. Players store and retrieve owned vehicles at garage points, officers run a police impound lot, and owners transfer, locate, and (for staff) administer vehicles. Vehicle mods and health persist across restarts.

## Install

```cfg
ensure mi-garage
```

Depends on ox_lib and oxmysql. It ships `server/migrate.lua`, so its tables auto-create on first boot, no manual SQL import.

## Config

Owner-editable settings live in `shared/config/*.lua`.

`shared/config/settings.lua`:

```lua
platePattern    = 'MI 1111',       -- random-plate mask: 1 = digit, A = letter, . = either
defaultDistance = 10.0,
defaultGarage   = 'luxgarage',     -- where givecar vehicles land when no garage is given

realtimeHealth  = true,            -- persist live vehicle health/props (also gates the persistence exports)

-- external vehicle-keys resource that gets addKey(plate) on take-out / admin spawn. Guarded,
-- so if it is not started the vehicle still spawns. Point it at your keys resource, or false to disable.
keysResource = 'mi-keys',

-- staff permission tiers (highest to lowest); the short ace names permissions.cfg grants.
permTiers = { 'admin', 'mod', 'support', 'partner' },

insurance = {
    default   = 350,
    onRecover = function(veh)
        SetVehicleEngineHealth(veh, 500.0)
        SetVehicleBodyHealth(veh, 500.0)
    end,
},

police = {
    holdMinutes = 60,          -- fallback hold (minutes) when a script seizes without naming one
    releaseFine = 2500,        -- fallback release fine when a seizure did not set its own
    -- /seize popup bounds. The officer picks hold and fine per seizure; the server clamps
    -- to these and never trusts the raw input.
    seize = {
        presets        = { 15, 30, 60, 180, 720 }, -- one-tap hold durations, in minutes
        minMinutes     = 5,
        maxMinutes     = 10080,    -- 7 days
        defaultMinutes = 60,
        defaultFine    = 2500,
        maxFine        = 50000,
    },
    jobs = { police = 0 },     -- jobs (name -> min grade) allowed at the Police Impound lot
},

transfer = { fee = 500, perClass = {}, cooldown = 5 },

fuel = {
    get = function(veh) return Entity(veh).state.fuel end,
    set = function(veh, v) Entity(veh).state.fuel = v end,
},

classes = { all = {...}, car = {...}, air = {15,16}, sea = {14}, rig = {...}, emergency = {18,19} },

-- per-member cap in a gang garage; first hit wins: entry.slots, limits[garageKey],
-- limits[gangName], then gangSlotDefault. One worked example, add your own gangs.
gangSlotLimits  = { godfathers = 10 },
gangSlotDefault = 2,
```

`shared/config/garages.lua` defines every garage location (label, type, coords, spawns, blip).

`shared/config/rentals.lua` is the job motor pool. A garage entry with `type = 'rental'` hands out fleet vehicles instead of the player's own: a rental never touches `player_vehicles`, it exists only while it is out, and returning it refunds `refund` of the deposit. The fleet a player sees is picked by their job, so one rental point can serve several services.

```lua
account        = 'bank',      -- account the deposit is taken from and refunded to
platePattern   = 'RENT1111',
refund         = 0.75,        -- share of the deposit paid back on return
maxActive      = 1,           -- vehicles one player may have on rent at once
returnAnywhere = true,        -- false = a rental must go back to the point it came from

jobs = {
    police = {
        label = 'Police motor pool',
        vehicles = {          -- grade is the MINIMUM job grade that may take the vehicle
            { model = 'police',  label = 'Cruiser',     deposit = 500, grade = 0 },
            { model = 'police2', label = 'Interceptor', deposit = 750, grade = 1 },
        },
    },
},
```

UI colours are in `shared/config/theme.lua` (`winter_blue` by default; presets `obsidian_rouge`, `winter_blue`, `monochrome`, `twilight_amber`, `ultramarine_navy`).

## Exports

The persistence exports (EnablePersistence, DisablePersistence, GetPlayerVehicle, GetVehicleIdByPlate, SaveVehicle) register only when realtime health is enabled.

| Export | Signature | What it does |
|---|---|---|
| `giveVehicle` | `giveVehicle(target, model, garage?, plate?)` | stores a vehicle for a player (server id or citizenid); returns the plate or false |
| `randomPlate` | `randomPlate(pattern?)` | returns a unique random plate for the given mask |
| `policeImpound` | `policeImpound(plate, minutes?)` | impounds a vehicle with a timed hold |
| `getAllGarages` | `getAllGarages()` | returns a list of every configured garage |
| `SaveVehicle` | `SaveVehicle(vehicle, options?)` | writes a spawned vehicle's props and state back to the database |
| `GetPlayerVehicle` | `GetPlayerVehicle(vehicleId, filters?)` | returns an owned vehicle row by id |
| `GetVehicleIdByPlate` | `GetVehicleIdByPlate(plate)` | returns the vehicleId for a plate |
| `EnablePersistence` | `EnablePersistence(vehicle)` | marks a vehicle to respawn when deleted |
| `DisablePersistence` | `DisablePersistence(vehicle)` | stops a vehicle from respawning |
| `isRentalPlate` | `isRentalPlate(plate)` | returns true if the plate is a live rental (for keys, insurance, dispatch) |
| `getGarages` (client) | `getGarages()` | returns the garages config table |
| `showGarageZone` (client) | `showGarageZone(data)` | creates an external `[E]` garage zone; returns its zoneId |
| `carSeizureDOJ` (client) | `carSeizureDOJ(data, slot)` | runs the DOJ (grade 9+) vehicle-seizure form flow |

## Commands

| Command | Access | Does |
|---|---|---|
| `/givecar <cid> <model> [plate] [garage]` | group.admin | grant a vehicle to a player (id or citizenid) |
| `/impoundveh <plate> [minutes]` | group.admin | police-impound a vehicle for a timed hold |
| `/resetimpound` | group.admin | clear the depot price on impounded stored vehicles |
| `/vehdata [serverid]` | group.support | open the admin vehicle panel for a player |
| `/toggleRealtimeHealth` | group.admin | toggle realtime vehicle health persistence |
| `/seize` | police job | seize the vehicle you are in (or the nearest within 5m) and set its impound hold and fine |

## Statebags

mi-garage publishes vehicle and player state so persistence, inventory, and staff tools can react without an export call.

| Statebag | Scope | Set when | Read by |
|---|---|---|---|
| `vehicleid` | vehicle | Set on a stored vehicle when it is spawned or saved, carrying its database row id. | mi-garage (persistence); ox_inventory (qbx bridge, to key the vehicle's trunk and glovebox stash) |
| `persisted` | vehicle | Set when a spawned vehicle is registered for realtime-health persistence, cleared when it is disabled. | mi-garage (respawns a persisted vehicle if it is deleted); also toggled by mi_core's EnablePersistence/DisablePersistence |
| `Garage` | player | Set to the current garage key when the player enters a garage zone (client), cleared on exit. | mi-garage server (authorizes store and retrieve at the player's current garage) and its NUI |
| `realtimeHealth` | global (GlobalState) | Set at boot from `Config.realtimeHealth`, flipped by `/toggleRealtimeHealth`. | mi-garage client and server (gates realtime health persistence and the persistence exports) |

See the [state reference](../mi_core/reference/state.md) for the core statebags and GlobalState.
