# mi-holster

mi-holster shows the weapons and items a player is carrying on their body. Inventory weapons holster on the back or hip, and a few items (drugs, barrels, and the like) appear as in-hand carry props. Everything nearby players see is driven by one player statebag, so there are no networked entities to sync, no database, no NUI, and no server loops. Prop spawning is distance-gated, so entity churn stays bounded on a busy server.

It displays carried weapons on the player model, with a concealed-carry toggle and an optional melee-hide command.

## Install

```cfg
ensure mi-holster
```

Needs `ox_lib`, `ox_inventory`, and `qbx_core` (or mi_core), plus OneSync.

## Config

Config lives under `shared/config/` (buyer-editable, `escrow_ignore`d). The general switches are in `shared/config/settings.lua`:

```lua
return {
    -- Master feature switches.
    enableWeaponCarry = true, -- show inventory weapons on the player's body
    enableItemCarry   = true, -- show in-hand "carry" items (drugs, barrels, ... see carry.lua)

    -- Distance-gated prop spawning: only build props for players within renderDistance metres,
    -- rechecked every scanInterval ms. Keeps entity churn bounded on busy servers.
    renderDistance = 45.0,
    scanInterval   = 750,

    -- Concealed-carry: toggle a carried weapon out of view. With a weapon drawn it toggles that
    -- weapon; otherwise it opens a picker of worn weapons.
    concealCarry = {
        enable     = true,
        command    = 'concealcarry',
        restricted = false, -- true = needs ace 'command.<command>'
    },

    -- Optional command that hides melee weapons from the back. State is per client.
    meleeToggle = {
        enable     = true,
        command    = 'holstermelee',
        default    = false, -- start with melee hidden?
        restricted = false,
    },
}
```

The rest of `shared/config/`:

| File | Holds |
| --- | --- |
| `weapons.lua` | Placement profiles: which bone, offset, and rotation each weapon holsters at (back, hip, thigh). |
| `carry.lua` | The in-hand carry items and the prop each one shows. |
| `melee.lua` | Which weapons count as melee for the hide toggle. |
| `regions.lua` | Body regions used by the placement profiles. |

## Exports

Client:

| Export | Signature | What it does |
| --- | --- | --- |
| RefreshWeapons | `exports['mi-holster']:RefreshWeapons()` | Rebuild the local player's carry props (call after changing loadout outside ox_inventory). |
| SetHidden | `exports['mi-holster']:SetHidden(state)` | Hide (`true`) or show (`false`) all of the local player's carry props. |
| IsHidden | `exports['mi-holster']:IsHidden()` | True if the local player's props are currently hidden. |

## Commands

| Command | Access | Does |
| --- | --- | --- |
| `/concealcarry` | player (config) | Toggle the drawn or selected carried weapon out of view, or open a picker of worn weapons. |
| `/holstermelee` | player (config) | Toggle back-mounted melee weapons hidden or shown. |

## Statebags

mi-holster networks a single player statebag. Everything nearby players render is driven by it, so there are no networked entities and no server loops.

| Statebag | Scope | Set when | Read by |
| --- | --- | --- | --- |
| `mi_holster` | player (`player:<serverId>`) | The owning client publishes its loadout table whenever the loadout changes (draw or holster a weapon, conceal, melee toggle, inventory change). The server sets it to `false` on player load and clears it on disconnect. | Every mi-holster client within `renderDistance` builds or tears down that player's carry props from it. |

See the [state reference](../mi_core/reference/state.md) for the core statebags and GlobalState.
