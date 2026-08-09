# mi-keys

mi-keys is vehicle keys, locks, hotwire, lockpick, ped-key robbery, vehicle search, and fake plates in one resource. Keys bind to a vehicle's identity plate, so a key keeps working after a cosmetic plate swap. Fake plates change only the visible plate, not the identity the key checks. It is low on the database (a per-character key store, or ox_inventory key items) and has no NUI.

Resources written for `qb-vehiclekeys`, `qbx-vehiclekeys`, `qbx_vehiclekeys`, `wasabi_carlock`, or `qbx_fakeplates` resolve to mi-keys through `provide`, so their `exports[...]` calls keep working with no edits.

## Install

```cfg
ensure mi-keys
```

Needs `ox_lib`, `ox_inventory`, and `qbx_core` (or mi_core), OneSync, game build 2372 or newer, and asset packs enabled. The bundled key audio (`dlc_vehiclekeys`) loads from the manifest, nothing to import.

## Config

Config is split under `shared/config/` (all buyer-editable, `escrow_ignore`d). The general switches live in `shared/config/main.lua`:

```lua
return {
    keyItems       = false, -- true = keys are ox_inventory items; false = per-character key store
    hotwire        = true,  -- allow hotwiring a keyless vehicle
    autoStart      = false, -- start the engine on entry when you already hold a key
    progressCircle = true,  -- circular progress (true) or the bar (false)

    keybind = {
        enable = true, -- register the engine/lock keys
        engine = 'M',  -- toggle the engine
        lock   = 'L',  -- toggle the vehicle lock
    },
}
```

The rest of `shared/config/`:

| File | Holds |
| --- | --- |
| `breakin.lua` | Lockpick tiers (rounds and timing windows), hotwire and search timings, and per-vehicle-class overrides (e.g. emergency vehicles). |
| `security.lua` | Vehicles that spawn locked, vehicles that never lock, sealed doors per model, and the admin ace. |
| `plates.lua` | Fake-plate character set, formatting, and which plates are allowed. |
| `loot.lua` | Rewards rolled on a successful vehicle search, and on a peaceful vs forced ped-key robbery. |

## Exports

Server, for the key store:

| Export | Signature | What it does |
| --- | --- | --- |
| addKey | `exports['mi-keys']:addKey(plate)` | Give the calling player a key to `plate`. |
| removeKey | `exports['mi-keys']:removeKey(plate)` | Remove the calling player's key to `plate`. |
| hasKey | `exports['mi-keys']:hasKey(plate)` | True if the player holds a key to `plate`. |
| hasEntityKey | `exports['mi-keys']:hasEntityKey(vehicle)` | True if the player holds a key to that vehicle entity. |
| clearKeys | `exports['mi-keys']:clearKeys(plate)` | Remove everyone's key to `plate`. |

Client:

| Export | Signature | What it does |
| --- | --- | --- |
| toggleEngine | `exports['mi-keys']:toggleEngine()` | Toggle the engine of the vehicle you are in (needs a key). |
| hasKey | `exports['mi-keys']:hasKey(plate)` | True if the local player holds a key to `plate` (O(1) local mirror check). |
| addKey | `exports['mi-keys']:addKey(plate)` | Grant the local player a key to `plate` optimistically and tell the server. |
| removeKey | `exports['mi-keys']:removeKey(plate)` | Drop the local player's key to `plate` and tell the server. |
| putOn | `exports['mi-keys']:putOn(vehicle, plate)` | Fit a fake plate onto `vehicle`. The server drives the progress and stays authoritative. |
| takeOff | `exports['mi-keys']:takeOff(vehicle)` | Remove the fake plate from `vehicle`. |
| itemUsage | `exports['mi-keys']:itemUsage(_, slot)` | ox_inventory item-use hook for the fakeplate item: fits the plate from `slot.metadata.plate` onto the nearest vehicle. |

## Commands

| Command | Access | Does |
| --- | --- | --- |
| `/addkey` | group.admin | Give a vehicle key to a player: pass a target id and plate, or run it while seated in a vehicle to key yourself. |
| `/givekeys` | player | Hand a key to a nearby player for the vehicle you are in (only registered when `keyItems = false`). |

## Statebags

mi-keys keeps a vehicle's lock, identity, and search state on the vehicle entity, so every client stays in sync with no extra events.

| Statebag | Scope | Set when | Read by |
| --- | --- | --- | --- |
| `vehicleLock` | vehicle | A vehicle is first seen (random spawn-lock roll), a key holder toggles the lock, or a lockpick, ped-key robbery, or dead-ped steal forces it open. Value is `{ lock = 1|2, sound? }` (1 unlocked, 2 locked). | mi-keys clients apply the door lock and play the lock or unlock beep. mi-policejob writes the same bag on a carjack. |
| `plate` | vehicle | Before any cosmetic plate change, the real plate is frozen here as the identity. | mi-keys resolves key ownership from the identity, so keys keep working after a fake-plate swap. |
| `searched` | vehicle | A vehicle search finishes. | mi-keys, to stop the same vehicle being searched or looted twice. |

See the [state reference](../mi_core/reference/state.md) for the core statebags and GlobalState.
