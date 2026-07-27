# mi-ambulancejob

mi-ambulancejob is the EMS job plus the death and last-stand engine and the React death/downed overlay. It handles multi-branch EMS revive and treat, hospital check-in, an AI-medic self-revive for when no medics respond, and stretchers. It answers to the names qbx_ambulancejob and qbx_medical (via `provide`), so run it instead of, not alongside, those resources.

## Install

```cfg
ensure mi-ambulancejob
```

Dependencies (ox_lib, ox_inventory, ox_target) are standard. The resource keeps no tables of its own, so there is no SQL to import. Because it provides qbx_ambulancejob and qbx_medical, do not also run those.

## Config

The config is merged from several modules under `shared/config/`. The knobs an owner changes:

Costs and timers (`shared.lua`, `client.lua`, `server.lua`):

```lua
-- shared.lua
checkInCost     = 100, -- price for the hospital check-in system
localdoctorCost = 450,

-- client.lua
useTarget          = true,
minForCheckIn      = 2,  -- on-duty medics (all branches) at/above which check-in is blocked
painkillerInterval = 60, -- minutes painkillers last
checkInHealTime    = 20, -- seconds to be healed by check-in
laststandTimer     = 300,
aiHealTimer        = 20, -- seconds before the hospital bed AI-heals you after check-in

-- server.lua
doctorCallCooldown = 1,    -- minutes between doctor calls
wipeInvOnRespawn   = true,
```

Death / last-stand tuning (`death.lua`):

```lua
return {
    deathTime = 300,              -- seconds dead before a player may respawn
    laststandReviveInterval = 30, -- seconds of last-stand before bleeding out to death
    voiceResource = 'pma-voice',  -- named + guarded; an absent/renamed voice resource is a no-op
}
```

EMS branches (`jobs.lua`). One entry runs a single-branch server; add more for many branches:

```lua
local jobs = {
    { name = 'ambulance',  label = 'EMS Center',  minGrade = 0 },
    { name = 'ambulance2', label = 'Roxwood EMS', minGrade = 0 },
}
-- specialKitJobs: non-EMS jobs allowed to use the `specialkit` medical item
specialKitJobs = { police = true, doc = true }
```

AI medic self-revive (`aimedic.lua`):

```lua
return {
    enabled            = true,
    minDownedMs        = 5 * 60 * 1000, -- must be down this long first (EMS present)
    minDownedOffdutyMs = 2 * 60 * 1000, -- shorter wait when EMS is off-duty
    callCooldown       = 300,           -- seconds between calls
    maxDoctorsOnline   = 9,             -- block the AI medic while more than this many EMS are on duty
    -- (doctor ped + CPR animation settings also live here)
}
```

Discord webhook (`apikeys.lua`, shipped blank):

```lua
return { deathWebhook = '' } -- '' disables Discord logging
```

Hospital and bed locations live in the `locations` table in `shared/config/shared.lua`.

## Exports

Server-side unless noted. This is the qbx_medical / qbx_ambulancejob surface other resources call.

| Export | Signature | What it does |
| --- | --- | --- |
| IsDead | `IsDead(src)` | True if the player is downed or dead (server) |
| Revive | `Revive(src)` | Revive a player |
| Heal | `Heal(src)` | Full heal (clears ailments, hunger, thirst) |
| HealPartially | `HealPartially(src)` | Remove minor injuries and stop light bleeding |
| CheckIn | `CheckIn(src, patientSrc, hospitalName)` | Send a patient to an open hospital bed |
| registerHook | `registerHook(event, cb)` | Register a hook (e.g. 'checkIn'), returns an id |
| removeHooks | `removeHooks(id)` | Remove hooks by id |
| createStretcher | `createStretcher(event, item, inventory, slot, data)` | ox_inventory item-use handler for the stretcher item. On the `usedItem` event it spawns a carryable stretcher prop next to the player. Bind it on the stretcher item; it is not meant to be called directly. |
| IsDead (client) | `IsDead()` | True if the local player is downed or dead |
| IsLaststand (client) | `IsLaststand()` | True if the local player is in last-stand |
| GetDeathTime / GetLaststandTime (client) | `()` | Remaining death / last-stand time |

Additional client exports back the death engine itself: `KillPlayer`, `StartLastStand`, `AllowRespawn`, `DisableRespawn`, `PlayDeadAnimation`, `IncrementDeathTime(seconds)`, `IncrementLaststandTime(seconds)`.

## Commands

| Command | Access | Does |
| --- | --- | --- |
| `/revive [id]` | `group.support` | Revive a player (self if no id) |
| `/kill [id]` | `group.support` | Kill a player (self if no id) |
| `/aheal [id]` | `group.mod` | Fully heal a player (self if no id) |
| `/heal` | everyone (EMS effect) | EMS: start treating a nearby player's wounds |
| `/stretcher` | everyone (EMS only) | Pick a nearby stretcher prop back into your inventory |
| `/pullems` | everyone (EMS only) | Pull nearby downed players to you |
| `/aimedic` | everyone | While downed, call an AI medic to self-revive (paid, cooldown, gated) |

## Statebags

The death engine and the stretcher system publish several replicated bags other resources read.

| Statebag | Scope | Set when | Read by |
| --- | --- | --- | --- |
| `isDead` | player | Set `true` when the player's death state becomes dead or last-stand, `false` otherwise. | Any resource checking if a player is down. Also backs the `IsDead` export. |
| `hasStretcher` | vehicle | Set to a stretcher prop's net id when a stretcher is attached to an ambulance, `nil` when detached. | The stretcher target and attach/detach logic across clients. |
| `movingStretcher` | player | Set to a stretcher prop's net id while a player carries a stretcher, `nil` when they place or drop it. | The stretcher target and carry logic across clients. |
| `ambulanceStretcherPlayer` | entity (stretcher prop) | Set to the server id of the player strapped to a stretcher prop, `false` or `nil` when empty. | The stretcher prop's carry and drop logic across clients. |

See the [state reference](../mi_core/reference/state.md) for the core statebags and GlobalState.
