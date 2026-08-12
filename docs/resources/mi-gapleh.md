# mi-gapleh

Server-authoritative gaple (Indonesian dominoes) at world tables. Four chairs, seven tiles each, the remainder left as a dead pile. Players sit through ox_target, buy in with a chip item, and the engine resolves every placement, with an ante per round and a rake booked into mi-billing's ledger.

## Install

```cfg
ensure mi-gapleh
```

Depends on ox_lib, ox_inventory, ox_target and oxmysql.

No tables of its own, so there is nothing to import.

## Config

### Rules

`shared/config/rules.lua` is the file buyers actually tune:

```lua
seatCount        = 4,        -- chairs at a table (fixed by the chair layout)
minPlayers       = 2,        -- fewer than this and the table waits
handSize         = 7,        -- tiles dealt per participant; the remainder is the dead pile
turnMs           = 25000,    -- per-seat decision timer
maxTimeouts      = 3,        -- consecutive timeouts before the player is stood up
startCountdownMs = 4000,     -- delay from "enough players" to the deal
resultLingerMs   = 6000,     -- pause on the round result before the next deal
maxDistance      = 5.0,      -- walk further than this from the table and you auto-leave
targetDistance   = 2.5,      -- ox_target interaction distance
spawnDistance    = 30.0,     -- distance at which the prop and ped stream in
tableModel       = 'prop_table_03b',
dealerModel      = 's_m_y_casino_01',
```

One rule is deliberately not configurable: **the opener is always the highest double in play** (balak tertinggi), picked unconditionally by the engine at the deal.

`maxTimeouts` is what keeps a table alive. Three consecutive missed turns and the player is stood up, so an idle seat cannot hold a round hostage.

The table prop is deliberately a base-game model, the same one mi-capsa, mi-poker and mi-mahjong use. A streamed addon prop the buyer does not have never loads, so the table would never spawn and there would be nothing to interact with. `shared/config/chairs.lua` is measured against this prop, so swapping the model means re-measuring every chair.

### Tables

`shared/config/tables.lua` ships one representative table; duplicate the line to add more, keeping each `id` unique:

```lua
{ id = 1, pos = vec3(1980.4, 3054.1, 47.21), heading = 60.0, ante = 500 },
```

`ante` is the per-round stake, and the buy-in bounds in `shared/config/economy.lua` are multiples of it.

### Economy

`shared/config/economy.lua` holds the chip item, the society the rake lands in, the tax rate, and the buy-in range as multiples of the table's ante.

## Theming

Obsidian surfaces come from `shared/config/theme.lua`; the accent is picked in `shared/config/colors.lua` and applied at runtime, so recolouring needs no web rebuild:

```lua
local PALETTE = 'obsidian_rouge'
-- 'obsidian_rouge' | 'winter_blue' | 'monochrome' | 'twilight_amber' | 'ultramarine_navy'
```
