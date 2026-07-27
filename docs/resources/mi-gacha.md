# mi-gacha

A Cover-Flow case-opening (gacha) resource with a React showroom NUI. Players spend a currency (an ox_inventory item or a core money account) or a key to open a case, watch the reel spin, and collect the won item. Won items are collect-only, unwanted items recycle into coupons that craft keys, and staff can rig a player's next rolls.

## Install

```cfg
ensure mi-gacha
```

Depends on ox_lib, ox_inventory, and ox_target. It uses no database (state is in memory), so nothing to import. The credits, coupon, and key items must exist in ox_inventory; a definition template ships in `setup/ox-items.lua`.

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

`shared/config/machines.lua` sets the in-world showroom locations (map blip plus a lazily-spawned ox_target attendant ped); leave `locations` empty to make it command-only. `shared/config/npcs.lua` sets the recycle drop-off NPC locations. The large data tables are the rollable cases in `cases.lua` and the recyclable catalog in `recyclables.lua`.

## Commands

The `/gacha` name comes from `Config.command`. The rig commands require the `Config.adminAce` ace and only work when `Config.rig.enabled` is true.

| Command | Access | Does |
|---|---|---|
| `/gacha` | everyone | open the gacha showroom |
| `/gacharig <playerId> <item\|rarity> <target> [caseId] [uses]` | ace `mi-gacha.admin` | force a player's next rolls to an item or rarity |
| `/gacharigclear <playerId>` | ace `mi-gacha.admin` | clear a player's rig |
