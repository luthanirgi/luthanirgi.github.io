# mi-pawnshop

A React NUI marketplace pawn shop. Players sell items to and buy them back from an appraiser ped, with unit prices that shift on the shop's own stock, and an optional government terminal that books export and import through mi-billing.

## Install

```cfg
ensure mi-pawnshop
```

It ships server/migrate.lua, so tables auto-create on first boot, no manual SQL import.

## Config

The main settings live in `shared/config/settings.lua`:

```lua
location = {                       -- shop and appraiser ped (spawns on proximity)
    ped = 'ig_andreas',
    coords = vec4(-423.0828, 1217.9211, 325.7586, 258.2451),
    interactDistance = 2.5,
    spawnDistance = 20.0,
    blip = { sprite = 431, color = 5, scale = 0.7, shortRange = true },
},
pricing = {                        -- unit price = base x multiplier, keyed on shop stock
    stockCap = 500000,
    tiers = {                      -- checked top to bottom, first match wins
        { name = 'scarce', maxStock = 5000,   mult = 2.0 },
        { name = 'low',    maxStock = 20000,  mult = 1.5 },
        { name = 'glut',   minStock = 200000, mult = 0.5 },
    },
    baseName = 'base', baseMult = 1.0,   -- fallthrough when no tier matches
},
trade = {
    maxDistance = 10.0,   -- server rejects a trade made beyond this from the shop
    bankMoney = false,    -- true = pay sell proceeds to bank instead of cash
},
persist = {
    flushDebounceMs = 120000,   -- batch the stock write-back this long after the last trade
},
government = {            -- optional terminal; income routed to mi-billing (skipped if it is not running)
    enabled = true,
    job = 'government',
    minGrade = 12,
    payoutDivisor = 2,   -- export income = floor(value / payoutDivisor); import costs full value
},
```

The list of tradeable items is in `shared/config/catalog.lua` and player-facing text is in `shared/config/strings.lua`; both are buyer-editable. The NUI palette is picked in `shared/config/theme.lua` and applied at runtime, so recolouring needs no web rebuild:

```lua
local PALETTE = 'winter_blue'
-- obsidian_rouge | winter_blue | monochrome | twilight_amber | ultramarine_navy
```

The government log webhook lives in `config/apiKeys.lua` (server-only, buyer-editable, blank by default).
