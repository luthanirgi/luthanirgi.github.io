# mi-dealership

A vehicle dealership with a React NUI. Players browse a showroom, test drive, and buy vehicles from peds or zones; staff of a configured job can manage per-dealer stock and sell vehicles directly to a nearby customer. Bought cars are delivered stored into a garage when mi-garage is running, otherwise drive-away.

## Install

```cfg
ensure mi-dealership
```

Depends on ox_lib, oxmysql and qbx_core or mi_core.

It ships `server/migrate.lua`, so tables auto-create on first boot, no manual SQL import.

## Config

`shared/config/init.lua` holds the tunables below. Dealers, peds, blips, and allowed categories live in `Config.VehicleShops`; the stock catalog is in `vehicles.lua`; the framework bridge is in `bridge.lua`; and the palette is in `colors.lua` (pick one of the five presets). `Config.GiveKey`, `Config.SetFuel`, and `Config.HUD` are buyer-editable glue functions.

```lua
Config.TestDriveTime = 60000              -- test drive duration (ms)
Config.TeleportBackWhenTestFinishes = true
Config.WarpPedToTestVehicle = true
Config.BuyCooldown = 10000                -- spam guard between purchase requests (ms)
Config.DeliveryGarage = 'luxgarage'       -- garage a bought car is delivered into (via mi-garage)
Config.SellRange = 8.0                    -- sell-to-customer: how close (m) the target must be to the salesperson
Config.OfferTTL = 30000                   -- how long a pending sell offer stays valid (ms)
Config.KeysResource = 'mi-keys' -- vehicle-keys resource to grant keys, or false to disable
```

`Config.BlacklistedCategories` lists categories (class A/B/M/S variants by default) that the public buyer flow may never purchase; a client attempting to buy them is treated as exploiting.

## Exports

| Export | Signature | What it does |
| --- | --- | --- |
| `closeui` | `exports['mi-dealership']:closeui()` | Closes the dealership NUI (client). |

## Statebags

mi-dealership sets one player statebag so the HUD stays out of the way while a showroom or management NUI is open.

| Statebag | Scope | Set when | Read by |
| --- | --- | --- | --- |
| `hidehud` | player | Set true when a dealership or management NUI opens, cleared when it closes. Driven by the buyer-editable `Config.HUD` glue. | mi-hud (hides the whole HUD while true). |

See the [state reference](../mi_core/reference/state.md) for the core statebags and GlobalState.
