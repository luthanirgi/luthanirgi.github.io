# mi-capsa

Server-authoritative Capsa (Big Two) at world tables. Four seats, thirteen cards each, the whole deck dealt. Players sit through ox_target, buy in with a chip item, and every play is validated on the server, with a rake booked into mi-billing's ledger. The rules are data, not code: reorder the rank and suit tables and the hand comparator rebuilds itself on boot.

## Install

```cfg
ensure mi-capsa
```

Depends on ox_lib, ox_inventory, ox_target and oxmysql.

No tables of its own, so there is nothing to import.

## Config

`shared/config/init.lua` holds the table and economy settings:

```lua
chipItem    = 'chip',          -- ox_inventory currency item
society     = 'hotel',         -- rake destination; the job written into mi-billing's ledger
taxRate     = 0.05,            -- rake skimmed from what the winner actually collects
maxDistance = 5.0,             -- walk further than this from the table and you auto-leave
targetDistance = 2.5,          -- ox_target interaction distance
spawnDistance  = 30.0,         -- distance at which the table prop and ped stream in
tableModel  = 'prop_table_03b', -- base-game card table
dealerModel = 's_m_y_casino_01',
turnMs      = 20000,           -- per-seat decision timer
startCountdownMs = 4000,       -- delay from "enough players" to the deal
settleLingerMs   = 5000,       -- pause on the settlement panel before the next round
minBuyInX   = 40,              -- buy-in floor, as a multiple of the table's perCard stake
maxBuyInX   = 200,             -- buy-in ceiling
seatCount   = 4,               -- 13 * 4 is the whole deck
minPlayers  = 2,               -- rounds may start short-handed; undealt cards stay out of play
cageReclaimOnLoad = false,     -- turn on only once every chip on the server is an inventory item
```

The table prop is deliberately a base-game model. A streamed addon prop the buyer does not have never loads, so the table would never spawn and there would be nothing to interact with. `shared/config/chairs.lua` is measured against this prop, so swapping the model means re-measuring every chair.

### Rules

`shared/config/rules.lua` is the file that makes this Capsa rather than generic Big Two. Every ordering is data, and the comparator is rebuilt from it at boot:

```lua
-- Rank order, weakest first. Capsa runs 3 low and 2 high.
rankOrder = { '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A', '2' },

-- Suit order, weakest first. Default is Big Two: wajik < keriting < hati < sekop.
-- For the Indonesian house order, swap the first two: { 'c', 'd', 'h', 's' }.
suitOrder = { 'd', 'c', 'h', 's' },

startCard = '3d',              -- whoever holds it leads the round
mustIncludeStartCard = true,   -- and their opening play must actually contain it

-- Delete an entry to outlaw that shape entirely: it stops being a legal play,
-- it does not merely rank lower.
fiveCardKinds = { 'straight', 'flush', 'fullhouse', 'quads', 'straightflush' },
```

Card names are rank plus a suit letter, using the Indonesian suit names: `c` keriting (clubs), `d` wajik (diamonds), `h` hati (hearts), `s` sekop (spades). So `3d` is the three of diamonds.

With fewer than four players the start card may not be dealt at all. The engine falls back to the holder of the lowest card leading instead.

### Tables

`shared/config/tables.lua` ships one representative table; duplicate the line to add more, keeping each `id` unique:

```lua
{ id = 1, pos = vec3(343.1026, -1656.3739, 79.7510), heading = 138.4450, perCard = 500 },
```

`perCard` is what each card still in a loser's hand is worth at settlement, and it is also the unit the buy-in bounds multiply. At the default `perCard = 500` with `minBuyInX = 40` and `maxBuyInX = 200`, sitting down costs between 20,000 and 100,000.

## Theming

Obsidian surfaces come from `shared/config/theme.lua`; the accent is picked in `shared/config/colors.lua` and applied at runtime, so recolouring needs no web rebuild:

```lua
local PALETTE = 'obsidian_rouge'
-- 'obsidian_rouge' | 'winter_blue' | 'monochrome' | 'twilight_amber' | 'ultramarine_navy'
```

The framework bridge, for pointing the resource at a different core, is `shared/config/bridge.lua`.
