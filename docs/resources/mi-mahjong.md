# mi-mahjong

Server-authoritative riichi mahjong at world tables. Four seats, no bots, and the table will not start short. Players sit through ox_target, buy in with a chip item that converts to point sticks on the felt, and the engine handles draws, calls, riichi, dora and scoring, with a rake booked into mi-billing's ledger when a seat cashes out.

## Install

```cfg
ensure mi-mahjong
```

Depends on ox_lib, ox_inventory, ox_target and oxmysql.

It ships `server/migrate.lua`, so `mi_mahjong_players` auto-creates on first boot; importing `sql/install.sql` by hand is optional.

## Config

`shared/config/init.lua` holds the table and economy settings:

```lua
chipItem    = 'chip',          -- ox_inventory currency item
society     = 'hotel',         -- rake destination; the job written into mi-billing's ledger
taxRate     = 0.05,            -- rake skimmed from a seat's winnings when it cashes out
maxDistance = 5.0,             -- walk further than this from the table and you auto-leave
targetDistance = 2.5,
spawnDistance  = 30.0,
tableModel  = 'prop_table_03b', -- base-game card table
dealerModel = 's_m_y_casino_01',
seatCount   = 4,               -- mahjong is a four-hand game and will not start short
cageReclaimOnLoad = false,     -- turn on only once every chip on the server is an inventory item
```

The table prop is deliberately a base-game model. A streamed addon prop the buyer does not have never loads, so the table would never spawn and there would be nothing to interact with. `shared/config/chairs.lua` is measured against this prop, so swapping the model means re-measuring every chair.

### Rules

`shared/config/rules.lua` is the file buyers actually tune:

```lua
gameLength = 'tonpuusen',  -- East round only, 4 hands, roughly 15 minutes
                           -- 'hanchan' = East + South, 8 hands, roughly double

startPoints   = 25000,     -- point stick each seat starts a game with
pointsPerChip = 100,       -- conversion both ways; 25000 points = 250 chips

turnMs         = 15000,    -- per-turn decision timer; expiry discards the drawn tile
callWindowMs   = 4000,     -- how long others may claim a discard
resultLingerMs = 6000,     -- pause on the hand result before the next deal
startCountdownMs = 4000,   -- delay from "four seated" to the first deal

akaDora = true,            -- red fives (one per suit) count as a bonus han
uraDora = true,            -- riichi wins also read the under-indicators
kuitan  = true,            -- open tanyao scores; turn off for a stricter table
yakuman = true,            -- kokushi musou, suuankou and daisangen pay 32000/48000

tenpaiPayments = true,     -- noten penalty at an exhaustive draw
```

`gameLength` is the setting that decides whether this fits your server. Tonpuusen is the default because a hanchan holds four roleplay players at one table for roughly half an hour, which is a long time to ask of them.

### Tables

`shared/config/tables.lua` ships one representative table; duplicate the line to add more, keeping each `id` unique:

```lua
{ id = 1, pos = vec3(343.1026, -1656.3739, 79.7510), heading = 138.4450, buyIn = 250 },
```

`buyIn` is the chip cost to sit, and it converts to `rules.startPoints` on the felt. That separation is the point: raising `buyIn` raises the real stake per point without touching the scoring at all, so you can run a high-roller table and a casual one off identical rules.

### Stats

`mi_mahjong_players` persists per-player identity and records: games played, points and the rest of the running stats, keyed by identifier.

## Theming

Obsidian surfaces come from `shared/config/theme.lua`; the accent is picked in `shared/config/colors.lua` and applied at runtime, so recolouring needs no web rebuild:

```lua
local PALETTE = 'obsidian_rouge'
-- 'obsidian_rouge' | 'winter_blue' | 'monochrome' | 'twilight_amber' | 'ultramarine_navy'
```

The framework bridge, for pointing the resource at a different core, is `shared/config/bridge.lua`.
