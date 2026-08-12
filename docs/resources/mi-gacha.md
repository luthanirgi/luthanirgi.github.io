# mi-gacha

A Cover-Flow case-opening (gacha) resource with a React showroom NUI. Players spend a currency (an ox_inventory item or a core money account) or a key to open a case, watch the reel spin, and collect the won item. Won items are collect-only, unwanted items recycle into coupons that craft keys, and staff can rig a player's next rolls.

## Install

```cfg
ensure mi-gacha
```

Depends on ox_lib, ox_inventory, ox_target, and oxmysql. It ships no tables of its own, so there is nothing to import; its own state is in memory, and vehicle rewards are written straight into `player_vehicles`. The credits, coupon, and key items must exist in ox_inventory; a definition template ships in `setup/ox-items.lua`.

## Config

Owner-editable settings live in `shared/config/*.lua`, aggregated by `init.lua`.

`shared/config/init.lua`:

```lua
command  = 'gacha',           -- /gacha opens the showroom
theme    = 'winter_blue',     -- palette key from shared/palettes.lua, or a custom colour table
adminAce = 'mi-gacha.admin',  -- ace permission gating the rig console / panel / commands
recentMax = 15,               -- recent-wins ring buffer size
notableRarities = {           -- rarities shown in the recent-wins ticker + Discord log
    rare = true, mythical = true, legendary = true,
},
discord = {
    log   = '',  -- case-open / collect webhook (blank = disabled)
    audit = '',  -- rig audit webhook (blank = disabled)
},
```

`shared/config/currencies.lua` registers the currencies a case may cost, each resolving to an ox_inventory item or a core account:

```lua
cr    = { kind = 'item',    item = 'cr',      symbol = 'CR', label = 'Credits' },
money = { kind = 'account', account = 'cash', symbol = '$',  label = 'Cash' },
```

`shared/config/exchange.lua` (the coupon economy):

```lua
couponItem    = 'coupon',     -- earned by recycling case items at a drop-off NPC
keyItem       = 'gacha_key',  -- crafted from coupons; opens a case whose key matches
couponsPerKey = 10,           -- coupons consumed to craft one key
```

`shared/config/rig.lua` holds the rig master switch:

```lua
enabled     = false,  -- master switch for the rig feature (console + NUI panel + commands)
logTriggers = true,   -- audit-log to Discord whenever a rigged roll fires
```

`shared/config/grades.lua` is the points table the exchange runs on. An item's points come from its grade, taken from a recyclable's `grade` or a case item's `rarity`, and an unknown grade falls back to `defaultGrade`:

```lua
scrap     = { label = 'Scrap',     points = 1,  color = '#8a8f98' },
common    = { label = 'Common',    points = 2,  color = '#9aa0a8' },
uncommon  = { label = 'Uncommon',  points = 4,  color = '#7f9a6d' },
rare      = { label = 'Rare',      points = 8,  color = '#6d86ad' },
mythical  = { label = 'Mythical',  points = 16, color = '#9a7fb0' },
legendary = { label = 'Legendary', points = 34, color = '#cba063' },
```

`shared/config/keyexchange.lua` is the Key Exchange venue, where coupons become keys:

```lua
enabled          = true,          -- false = no blip, no ped, no target; command or event only
ped              = 'ig_andreas',  -- attendant model, or false to target the spot itself
spawnDistance    = 25.0,
interactDistance = 2.5,           -- ox_target reach, and the target radius when ped = false
label            = 'Key Exchange',
blip             = { sprite = 617, color = 2, scale = 0.8, label = 'Key Exchange' }, -- false for none
locations        = { vec4(-50.2327, 1911.1080, 195.7054, 97.1408) },
```

`shared/config/machines.lua` sets the in-world showroom locations (map blip plus a lazily-spawned ox_target attendant ped); leave `locations` empty to make it command-only. The large data tables are the rollable cases in `cases.lua` and the recyclable catalog in `recyclables.lua`.

## Commands

The `/gacha` name comes from `Config.command`. The rig commands require the `Config.adminAce` ace and only work when `Config.rig.enabled` is true.

| Command | Access | Does |
|---|---|---|
| `/gacha` | everyone | open the gacha showroom |
| `/gacharig <playerId> <item\|rarity> <target> [caseId] [uses]` | ace `mi-gacha.admin` | force a player's next rolls to an item or rarity |
| `/gacharigclear <playerId>` | ace `mi-gacha.admin` | clear a player's rig |
