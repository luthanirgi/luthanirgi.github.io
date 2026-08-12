# mi-donate

mi-donate is a donation store where players spend donation credits (CR) on vehicles, items, battlepass tiers, money packs, and plate or phone-number customizations. Credits are funded by Tebex purchases (redeemed as codes) or granted by admins, and balances persist in the database.

## Install

```cfg
ensure mi-donate
```

Depends on ox_lib, ox_inventory, oxmysql and qbx_core or mi_core.

It ships server/migrate.lua, so tables auto-create on first boot, no manual SQL import.

## Config

```lua
local Config = {
    OpenMenuCommand = 'donate',   -- command that opens the store
    BuyCooldownMs   = 1000,       -- per-player minimum gap between purchases
    UseTebex        = true,       -- show the Tebex buy-credit packages

    -- Vehicle delivery
    DefaultGarage = 'premiumgarage',
    GiveAddKeys   = true,
    KeysResource  = 'mi-keys', -- vehicle-keys resource, or false to disable

    -- Plate / phone-number customize limits
    MinCharForPlate       = 1,
    MaxCharForPlate       = 8,
    MinCharForPhoneNumber = 4,
    MaxCharForPhoneNumber = 7,

    -- Tebex credit packages shown in the Buy Credit modal
    BuyCredits = {
        { title = '50 CR',  link = 'https://mi-rp.tebex.io/package/7046808' },
        { title = '100 CR', link = 'https://mi-rp.tebex.io/package/7046806' },
        { title = '250 CR', link = 'https://mi-rp.tebex.io/package/7046803', extraCredit = 'Hot Package' },
        { title = '450 CR', link = 'https://mi-rp.tebex.io/package/7046802' },
    },

    -- Admin licenses that ignore limited-stock caps
    ExcludedLicenses = { 'license2:...' },

    -- Owner-defined store rows (commented examples ship blank)
    Customize = { --[[ { base = 'plate', label = 'Custom Plate', price = 250, image = '' } ]] },
    Money     = { --[[ { label = '$100,000', account = 'bank', amount = 100000, price = 50, image = '' } ]] },

    -- Large tables live in their own files (buyer-editable, no rebuild)
    Battlepass = require 'shared.config.battlepass',
    Vehicles   = require 'shared.config.vehicles',
    Items      = require 'shared.config.items',
    colors     = require 'shared.config.colors',  -- NUI palette
}
```

`Config.KeysResource` names the vehicle-keys resource used on delivery. It is guarded, so a missing or renamed resource is a no-op instead of an error.

`shared/config/bridge.lua` is the framework bridge. `core` points at `exports.qbx_core`, which mi_core answers to; repoint it (for example at `exports['qb-core']`) to run a different framework. ox_lib and ox_inventory are used directly and are not bridged.

## Exports

| Export | Signature | What it does |
|---|---|---|
| `getCredit` | `exports['mi-donate']:getCredit(citizenid)` | Server-side. Return a citizen's donation credit balance (number). |
| `addCredit` | `exports['mi-donate']:addCredit(citizenid, amount)` | Server-side. Add credits to a citizen and return the new balance. |

## Commands

| Command | Access | Does |
|---|---|---|
| `/donate` | everyone | open the donation store |
| `/givecredit [id] [amount]` | `group.admin` | grant donation credits to a player |
| `/climit [vehicle]` | `group.admin`, console only | print how many of a vehicle model are owned server-wide versus its stock cap |
| `purchase_donate_credit [json]` | console only | add a redeemable donation code and credits to the pool (called by Tebex on purchase) |

## Statebags

mi-donate publishes limited-stock counts on a global statebag, so every client sees live availability without a fetch.

| Statebag | Scope | Set when | Read by |
| --- | --- | --- | --- |
| `miDonateLimited` | GlobalState | Recomputed on boot and whenever a limited-stock item is reserved or purchased. Value is a map of `{ itemKey = remainingCount }`. | The mi-donate store NUI shows remaining stock. Any resource can read the global for limited-stock counts. |

See the [state reference](../mi_core/reference/state.md) for the core statebags and GlobalState.
