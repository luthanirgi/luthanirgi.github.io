# mi-drugs

mi-drugs is a Schedule I style drug operation: grow plants, process them at placeable stations, and mix products through an effects engine where a better mix makes a stronger, more valuable high. Finished product is sold to street buyers or in bulk and paid out as dirty cash.

## Install

```cfg
ensure mi-drugs
```

Depends on ox_lib, ox_inventory, ox_target, oxmysql and qbx_core or mi_core.

It ships server/migrate.lua, so tables auto-create on first boot, no manual SQL import.

## Config

```lua
Config.DebugMode = false
Config.ImageFormat = 'nui://ox_inventory/web/images/%s.png' -- item image source for the NUI

-- Theme: one of obsidian_rouge | winter_blue | monochrome | twilight_amber |
-- ultramarine_navy, or a table of --mi-* overrides. Pushed to the plant NUI on open.
Config.theme = 'winter_blue'

Config.economy = { moneyItem = 'black_money' }   -- drug sales pay out this item
Config.PoliceJobs = { 'police' }                 -- on-duty count read from GlobalState
Config.dispatch = { enabled = true, resource = 'mi-dispatch' } -- guarded, skipped if not started

Config.Controls = { interact = 38, remove = 246 } -- E, Y
Config.DisablePtfx = false        -- disable particle effects
Config.ShowEquipmentName = false  -- show the station name in the target UI

-- Growth and decay tuning plus the water/fertilizer items
Config.PlantSettings = {
    waterDecayRate      = 0.2,       -- water lost per minute (0-100 scale)
    fertilizerDecayRate = 0.1,       -- fertilizer lost per minute
    streamDistance      = 100.0,     -- client spawn/despawn radius (no network)
    dbSaveInterval      = 1800000,   -- batched water/fertilizer flush (ms)
    removeLamps         = true,      -- remove attached lamps when a plant is removed
}

Config.StationSettings = { qualityFloor = 0.5 }  -- minigame yield floor (1.0 = always full)

-- Consumable drugs: item -> use animation, high duration and cooldown (seconds)
Config.Drugs = {
    weed    = { anim = 'smoke', time = 60, cooldown = 30 },
    cocaine = { anim = 'sniff', time = 45, cooldown = 30 },
    meth    = { anim = 'sniff', time = 60, cooldown = 45 },
    opium   = { anim = 'pill',  time = 90, cooldown = 60 },
}

Config.mixSettings = {
    maxEffects = 8,  -- most effects a single product can carry
    packaging  = { baggy = 1.0, jar = 1.12, brick = 1.28 }, -- tier -> sale multiplier
}

-- Discord webhook for drug logs. Leave blank in the repo.
Config.apiKeys = { webhook = '', webhookColor = 15158332 }
```

The large data tables live in their own `shared/config/*.lua` files and are buyer-editable without a rebuild: `plants`, `stations`, `stationfx`, `selling`, `effects`, `additives`, `products`, `reactions`, `buyers`, and `bulk`.
