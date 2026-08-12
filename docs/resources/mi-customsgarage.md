# mi-customsgarage

A vehicle customs shop with a React NUI. A player sitting in a vehicle inside a shop zone can preview and apply mods, repair, and clean; the shop runs client-side with a single server pay endpoint and no database (mod persistence belongs to the garage resource).

## Install

```cfg
ensure mi-customsgarage
```

Depends on ox_lib.

## Config

`shared/config/settings.lua` holds the owner-editable tunables. Shop zones live in `locations.lua`, the modification tree in `catalog.lua`, and the palette in `theme.lua` (set `SELECTED` to one of the five presets or provide a `custom` table).

```lua
return {
    openKey = 'E',                 -- key to open the shop while sitting in a vehicle inside a shop zone
    chargePerMod = false,          -- false: pay once at checkout (cart). true: charge for every mod as applied
    account = 'cash',              -- money account the shop charges from
    repairItem = 'repair_kit',     -- item used by the repair flow (ox_inventory)
    cleaningItem = 'cleaning_kit', -- item used by the clean flow
    fallbackVehiclePrice = 2000,   -- base price when qbx_core has no price for the vehicle model
    adminAce = 'admin',            -- ace permission that unlocks the free admin shops (all options)
    maxCheckout = 100000000,       -- server-side cap: a single checkout above this is rejected as tampering
    fixCommand = { name = 'vfix', restricted = 'group.mod' }, -- instant vehicle fix command (restricted)

    -- Vehicle fuel writer (buyer-editable, multi-fuel aware). Repairs and prop-restores route
    -- through this so fuel persists on ox_fuel / statebag servers. Sets the native tank AND the
    -- statebag value; for cdn-fuel add its export inside.
    SetFuel = function(vehicle, level) ... end,
}
```

## Commands

| Command | Access | Does |
| --- | --- | --- |
| `/vfix` | `group.mod` | Instantly fixes the vehicle the caller is sitting in. Name and access come from `Config.fixCommand`. |

## Statebags

The shop publishes one replicated player statebag so the HUD and other resources can tell the customs menu is open. It drives the configured HUD bag (`Config.hudStatebag`, `hidehud` by default) the same way, and both are cleared if the player disconnects with the shop open.

| Statebag | Scope | Set when | Read by |
| --- | --- | --- | --- |
| `UICustoms` | player | `true` when the shop opens, `false` when it closes or the player disconnects | mi-hud and any resource that should pause while the player is in the customs shop |

See the [state reference](../mi_core/reference/state.md) for the core statebags and GlobalState.
