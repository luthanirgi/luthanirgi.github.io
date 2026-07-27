# mi-poker

Server-authoritative Texas Hold'em poker built for scale. Players sit at casino tables through ox_target, buy in with a chip item, and play hands that are dealt and resolved entirely on the server, with a configurable rake skimmed to a society account.

## Install

```cfg
ensure mi-poker
```

It creates its `mi_poker_players` table automatically on first boot, no manual SQL import.

## Config

The gameplay knobs are in `shared/config` (`init.lua`):

```lua
chipItem    = 'chip',          -- ox_inventory currency item
society     = 'hotel',         -- rake destination (qbx society)
taxRate     = 0.07,            -- rake skimmed from each pot
maxDistance = 5.0,             -- must stay within this of the table or auto-leave
targetDistance = 2.5,          -- ox_target interaction distance
spawnDistance  = 30.0,         -- distance at which the table prop and ped spawn for the client
tableModel  = 'pokerasztal',   -- poker table prop
dealerModel = 's_m_y_casino_01',
turnMs      = 25000,           -- per-seat decision timer
startCountdownMs = 4000,       -- delay from "enough players" to the deal
minBuyInBB  = 20,              -- min buy-in = 20 * big blind
maxBuyInBB  = 100,             -- max buy-in = 100 * big blind
seatCount   = 5,
showdownLingerMs = 4000,       -- pause on the result before the next hand
cageReclaimOnLoad = false,     -- keep off until legacy chip values are migrated to items
```

Table locations are in `shared/config/tables.lua` (24 tables across the casino floor and basement):

```lua
{ id = 1, pos = vec3(343.10, -1656.37, 79.75), heading = 138.44, blind = 500 },   -- blind = big blind
{ id = 5, pos = vec3(322.77, -1655.81, 79.75), heading = 49.42,  blind = 2500 },
```

Obsidian surfaces and text come from `shared/config/theme.lua`; the accent and gold signature are picked in `shared/config/colors.lua` and applied at runtime, so recolouring needs no web rebuild:

```lua
local PALETTE = 'winter_blue'
-- 'obsidian_rouge' | 'winter_blue' | 'monochrome' | 'twilight_amber' | 'ultramarine_navy'
```

Per-chair sit positions are in `shared/config/chairs.lua`, and the framework bridge (repoint the core for a different framework) is in `shared/config/bridge.lua`.
