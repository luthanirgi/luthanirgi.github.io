# mi-crutch

mi-crutch gives EMS a crutch and a wheelchair to assign to injured players. A medic picks a nearby patient from a menu (or uses a crutch or wheelchair item), the aid lasts a set number of minutes, and the wheelchair hands the player drivable keys through a swappable vehicle-keys integration.

## Install

```cfg
ensure mi-crutch
```

## Config

The settings live in `shared/config/init.lua`. The HUD palette lives in `shared/config/palettes.lua` (pick one of five presets).

```lua
-- EMS branches allowed to hand out a crutch / wheelchair. Staff (group.admin /
-- group.mod) may always assign.
Config.Jobs = { 'ambulance', 'ambulance2' }

Config.menuPosition = 'top-right'

-- Longest a medic may assign, in minutes.
Config.maxAssignTime = { crutch = 720, wheelchair = 720 }

-- Clear the crutch / wheelchair when the player dies.
Config.disableOnDeath = { crutch = true, wheelchair = true }

-- Useable items that open the "pick a patient" menu for a medic.
Config.usableCrutchItem = { enabled = true, item = 'crutch' }
Config.usableWheelchairItem = { enabled = true, item = 'wheelchair' }

-- Hand the player keys to the wheelchair "vehicle". Point this at YOUR
-- vehicle-keys resource, or set it to false to disable. Guarded at runtime: a
-- missing/renamed resource is a no-op.
Config.KeysResource = 'mi-keys' -- e.g. 'qb-vehiclekeys', 'wasabi_carlock', false

-- Give a crutch automatically after mi-ambulancejob revives someone.
Config.giveOnRevive = { enabled = true, minutes = 1 }
```

## Exports

| Export | Signature | What it does |
| --- | --- | --- |
| SetCrutchTime | `exports['mi-crutch']:SetCrutchTime(target, minutes)` | Server. Gives player `target` a crutch for `minutes`. Returns true on success. |
| SetChairTime | `exports['mi-crutch']:SetChairTime(target, minutes)` | Server. Gives player `target` a wheelchair for `minutes`. Returns true on success. |
| RemoveCrutch | `exports['mi-crutch']:RemoveCrutch(target)` | Server. Clears player `target`'s crutch. |
| RemoveChair | `exports['mi-crutch']:RemoveChair(target)` | Server. Clears player `target`'s wheelchair. |
| OpenCrutchMenu | `exports['mi-crutch']:OpenCrutchMenu()` | Client. Opens the "assign a crutch to a nearby patient" menu. |
| OpenChairMenu | `exports['mi-crutch']:OpenChairMenu()` | Client. Opens the "assign a wheelchair to a nearby patient" menu. |

## Commands

| Command | Access | Does |
| --- | --- | --- |
| `/removecrutch <id>` | `group.mod` | Clear a player's crutch. |
| `/removechair <id>` | `group.mod` | Clear a player's wheelchair. |
