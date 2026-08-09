# mi-robbery

A unified robbery and heist system covering bank and jewelry heists (Fleeca, Paleto, Roxwood, Pacific City, Pacific Roxwood, Vangelico, Maze Bank) plus supermarket, ATM, cash exchange, cargo container, laundromart, bobcat, armored truck, vehicle boosting, and a fence pawnshop. A server-wide tiered reservation engine caps how many heists of each tier run at once, checks police on duty, and enforces per-tier cooldowns.

## Install

```cfg
ensure mi-robbery
```

No database: active-heist state lives in GlobalState, so there is nothing to import. Hard dependencies are ox_lib and ox_inventory only. Everything else is optional and wired through config (a dispatch resource, ox_doorlock or qb-doorlock, a vehicle-keys resource, [mi_minigame](mi_minigame.md) for the skill checks, and [mi_coopminigames](mi_coopminigames.md) for the Maze Bank co-op stages).

## Config

Edit `shared/config/init.lua` for the global engine settings:

```lua
return {
    debug = { enable = false },
    BypassCombinationCheck = false, -- true = ignore the tier-combination caps (testing)

    framework = 'qb',   -- 'qb' = qbx_core / mi_core (exports.qbx_core namespace); 'esx' = ESX
    inventory = 'ox_inventory',
    doorlock = 'ox',    -- 'ox' (ox_doorlock) or 'qb'
    notify_title = 'Robbery',
    notify_position = 'center-right',
    notify_system = 'ox',

    -- Vehicle-keys resource for boosted/stolen cars. Point at yours, or set false to disable.
    KeysResource = 'mi-keys', -- e.g. 'qb-vehiclekeys', 'wasabi_carlock', false

    RobberyTiers = { small = 'small', medium = 'medium', large = 'large' },

    -- Which mix of active heists (by tier) is allowed at once, server-wide.
    AllowedActiveCombinations = {
        { small = 1, medium = 1, large = 1 },
    },

    MaxActiveRobberies = 5,
    ActiveRobberyTimeout = 3600,        -- seconds of inactivity before a slot is reclaimed
    ActiveRobberyWatchdogInterval = 60, -- how often (seconds) the watchdog scans
    PoliceJob = 'police',
    MaxHackAttempts = 5,
}
```

Each location's coordinates, loot, cop requirement, and cooldown live in its own `shared/config/<heist>.lua` (fleeca, paleto, roxwood, pacificcity, pacificroxwood, vangelico, mazebank, supermarket, atmrobbery, boosting, truck, container, cashexchange, laundromart, bobcat, pawnshop). The Discord log webhook is in `server/apiKeys.lua` (blank before packaging), and the items to add to ox_inventory are listed in `shared/items.lua`.

`shared/config/minigames.lua` decides which mi_minigame games each heist rolls from and how hard they run:

```lua
return {
    enable   = true,           -- false = every heist plays `fallback` instead of rolling
    fallback = 'ArrowClicker', -- used when rolling is off, or a heist has no pool below
    noRepeat = true,           -- never roll the same game twice in a row for one heist

    difficulty = { small = 'hard', medium = 'veryhard', large = 'expert' },
    defaultDifficulty = 'hard', -- heist not listed in `tiers`

    tiers = {                   -- the tier each heist reserves under, server-side
        atmrobbery = 'small', boosting = 'small', supermarket = 'small',
        bobcat = 'medium', cashexchange = 'medium', container = 'medium',
    },
}
```

### Maze Bank

`shared/config/mazebank.lua` is the largest location and the only one built around a party. It runs in two halves:

* **Solo stage.** Six ground-floor security terminals, each wanting a `hack_usb`. Any `RequiredSoloPoints` of them (4 by default) opens the co-op half, and surplus terminals go inert once the quota is met.
* **Three co-op stages, strictly sequential.** Each is a lobby of stations on the floor: members take a station, a countdown arms once `minParty` claim one, and the stage runs a co-op minigame drawn from its `games` pool. Every member pays `requiredItem`, so stage 3 charges four `gold_keycard` from a full party. If `minParty` is never reached, the lobby disbands itself at `lobbyTimeout` and releases the stations.

```lua
return {
    label  = 'Maze Bank Heist',
    type   = 'mazebank',
    coords = vector3(-1305.92, -802.38, 17.58),
    size   = 60,
    enabled = true,

    minCops  = 0,
    Cooldown = 7200,
    HackTime = 3,

    RequiredSoloPoints = 4,  -- of the six solo points; set to 6 to require all
    CompletionBonus = { chance = 40, item = 'gold_keycard', count = 1 }, -- rolled once everything is empty

    soloPoints = {
        [1] = { coords = vector4(-1305.92, -802.38, 17.58, 0.0), requiredItem = 'hack_usb' },
        -- ... six in total
    },

    coopStages = {
        [1] = {
            label = 'Security Shutter',
            doorName = '',              -- optional ox_doorlock name opened on success; '' is skipped
            requiredItem = 'silver_keycard',
            minParty = 3,               -- clamped to 2..#stations
            startDelay = 15,            -- seconds the countdown runs once minParty is reached
            lobbyTimeout = 120,         -- seconds from the first claim before the lobby disbands
            games = { 'SplitCipher', 'CoordinateLock', 'BlueprintDiff', 'EliminationGrid', 'ColourConsensus' },
            stations = { [1] = vector4(-1308.74, -811.84, 17.58, 0.0), --[[ ... ]] },
        },
        -- [2] Stairwell Lockdown (thermite), [3] Vault Handshake (gold_keycard, minParty 4)
    },

    trollys = { --[[ twelve cash trolleys in the vault ]] },
    lockers = { --[[ ... ]] },
}
```

!!! note "Set the trolley headings before you go live"
    Every `.w` in the shipped file is `0.0`, because the points were captured as `vec3`. The trolley props and the grab and drill synchronized scenes read `.w`, so until you tune them in game all twelve trolleys face the same way.

## Exports

All are server exports, called as `exports['mi-robbery']:Name(...)`. They are the tiered reservation, cop-gating, cooldown, hack-attempt, and Discord-logging engine.

| Export | Signature | What it does |
| --- | --- | --- |
| BeginHeistReservation | `BeginHeistReservation(src, name, tier, minCops, cooldownSeconds)` | Full start gate: checks the tier cooldown, cop count, and slot combination, reserves the slot, then arms the tier cooldown. Returns true if the heist may start. |
| TryReserveHeist | `TryReserveHeist(src, name, tier, minCops)` | Reserves a heist slot if cops and the tier combination allow it (no cooldown handling). |
| ReleaseHeistReservation | `ReleaseHeistReservation(name, tier)` | Frees a heist slot and clears that tier's cooldown. |
| AddActiveRobbery | `AddActiveRobbery(name, tier, minCops)` | Registers an active heist slot (lower level than TryReserveHeist). |
| RemoveActiveRobbery | `RemoveActiveRobbery(name, tier)` | Removes an active heist slot. |
| IsHeistActive | `IsHeistActive(name, tier)` | True if that heist is reserved and the current mix is valid; also refreshes its activity timestamp. |
| CanStartRobberyOfType | `CanStartRobberyOfType(tier)` | True if one more heist of this tier would still fit the allowed combinations. |
| IsCurrentCombinationValid | `IsCurrentCombinationValid()` | True if the set of active heists is within the allowed combinations. |
| ResetTieredActiveRobberies | `ResetTieredActiveRobberies()` | Clears every active slot and all tier cooldowns. |
| EnsureEnoughCops | `EnsureEnoughCops(src, minCops)` | True if enough police are on duty; notifies src if not. |
| GetAvailableCops | `GetAvailableCops()` | Police on duty minus cop slots already occupied by active heists. |
| GetOccupiedCops | `GetOccupiedCops()` | Cop slots currently held by active heists. |
| SetTierCooldown | `SetTierCooldown(tier, durationSeconds)` | Sets a tier's global cooldown end time. |
| GetTierCooldown | `GetTierCooldown(tier)` | Seconds remaining on a tier's cooldown (0 if none). |
| IsTierGloballyBlocked | `IsTierGloballyBlocked(src, tier)` | True if the tier is on cooldown; notifies src with the time remaining. |
| FormatCooldownHMS | `FormatCooldownHMS(totalSeconds)` | Formats seconds as HH:MM:SS. |
| HandleHackFailure | `HandleHackFailure(src, actionKey, requiredItem, requiredCount)` | Counts a failed hack; at MaxHackAttempts it confiscates the item and resets. Returns true when the cap is hit. |
| ResetHackAttempts | `ResetHackAttempts(src, actionKey)` | Clears a player's hack-failure counter (one action, or all if actionKey is omitted). |
| GetHackAttempts | `GetHackAttempts(src, actionKey)` | Current hack-failure count for that action. |
| SendRobberyLog | `SendRobberyLog(heistName, eventType, message)` | Posts a Discord embed (eventType: start, loot, finish, or info). |
| LogRobberyStart | `LogRobberyStart(heistName, src, extra)` | Logs a heist start with player name, source, and identifier. |
| LogRobberyLoot | `LogRobberyLoot(heistName, src, lootDesc, items)` | Logs looted items. |
| LogRobberyFinish | `LogRobberyFinish(heistName, src, message)` | Logs a heist finish. |
| LogPawnshopSale | `LogPawnshopSale(src, item, amount, label, payout)` | Logs a fence sale. |
| LogPawnshopBuy | `LogPawnshopBuy(src, item, amount, label, cost)` | Logs a pawnshop purchase. |

## Commands

| Command | Access | Does |
| --- | --- | --- |
| `/clearrobberies` | group.admin | Force-clears all active robbery slots (admin recovery). |
| `/resetfleeca [i]`, `/resetpaleto`, `/resetroxwood`, `/resetpacificcity`, `/resetpacificroxwood`, `/resetvang`, `/resetmazebank`, `/resetcontainer`, `/resetcashex`, `/resetbobcat`, `/resetlaundro`, `/resetallsupermarket` | police job | Resets that heist's props and active state so it can be run again (some take a location index argument). |

## Statebags

mi-robbery publishes vehicle and ped state during the armored-truck and boosting jobs so clients and the vehicle-lock system can react.

| Statebag | Scope | Set when | Read by |
| --- | --- | --- | --- |
| `isRobberyTruck` | vehicle | Set on the armored truck when the truck heist spawns it (server). | mi-robbery client (adds the plant-explosive target on the truck) |
| `heistId` | vehicle | Set on the armored truck alongside `isRobberyTruck`, carrying the heist id. | mi-robbery (ties truck actions to the running heist) |
| `isTruckGuard` | ped | Set on each armored-truck guard ped as it spawns (server). | mi-robbery client (arms guard combat AI and its relationship group) |
| `vehicleLock` | vehicle | Set on a boost-target vehicle: locked (`2`) when it spawns, unlocked (`1`) after a successful hack (client). | mi-keys, mi-policejob, and the delete-vehicle guard (the shared vehicle-lock contract) |

See the [state reference](../mi_core/reference/state.md) for the core statebags and GlobalState.
