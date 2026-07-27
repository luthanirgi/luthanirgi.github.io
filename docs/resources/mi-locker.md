# mi-locker

Rentable, premium (Tebex), and subscriber lockers backed by personal ox_inventory stashes, plus a police raid that opens a suspect's lockers by citizen id. Rentable lockers are location-bound, while premium and subscriber lockers open from any of their points.

## Install

```cfg
ensure mi-locker
```

It ships server/migrate.lua, so tables auto-create on first boot, no manual SQL import.

## Config

Edit `config.lua`. Locker locations live in `data/*.lua` and the palette in `data/theme.lua`.

```lua
Config = {}

-- Account rentals are charged from: 'cash' or 'bank'.
Config.currency = 'bank'

-- Rent duration bounds (days) a player may pick.
Config.rentDays = { min = 1, max = 30 }

-- How close (metres) a player must stand to a rentable locker to open it.
-- Premium and subscriber lockers ignore this and open from any of their points.
Config.openDistance = 5.0

-- Map blip sprite for locker locations.
Config.blipSprite = 473

-- Log a billing row when a "hotel" locker is rented.
Config.hotelBillingLog = true

-- Premium locker (Tebex): the player redeem command and per-player cooldown (seconds).
Config.redeemCommand  = 'redeemstash'
Config.redeemCooldown = 10

-- Console command your Tebex package runs on purchase (must match what Tebex sends).
Config.purchaseCommand = 'purchase_donate_stash'

-- Police raid: authorised members open a suspect's lockers by citizen id.
Config.Raid = {
    enabled = true,
    requireOnDuty = true, -- the raider must be clocked in on the job (gangs ignore this)
    groups = {            -- job OR gang name -> minimum grade
        police  = 2,
        bcso    = 2,
        sheriff = 2,
        fib     = 1,
    },
}

-- Pick a preset in data/theme.lua, or set a { primary, primaryRgb } table for custom.
Config.palette = 'winter_blue'
```

## Commands

| Command | Access | Does |
| --- | --- | --- |
| `/redeemstash <code>` | everyone | Redeems a purchased premium-locker code for extra locker days. Command name from `Config.redeemCommand`. |
| `purchase_donate_stash <json>` | server console (Tebex) | Tebex purchase hook: stores the code and duration for later redemption. Command name from `Config.purchaseCommand`. |
