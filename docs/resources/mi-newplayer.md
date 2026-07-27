# mi-newplayer

New-player anti-troll protection: a fresh character gets a timed window with no shooting, punching, or VDM damage, shown on a React Status Card HUD. It also includes a negative-balance weapon jammer and a diazepam sedation item for EMS and godfathers.

## Install

```cfg
ensure mi-newplayer
```

It ships server/migrate.lua, so tables auto-create on first boot, no manual SQL import.

## Config

Edit `shared/config.lua`.

```lua
return {
    -- Protection granted to a new character. Counts down while online (playtime, not wall-clock).
    protectionMinutes = 1441, -- ~24h of playtime

    hud = {
        title = 'New player protection',
        note = 'No guns \u{00b7} No fists \u{00b7} No VDM',
        -- Default spot. anchor = top-left | top-right | bottom-left | bottom-right; x/y = pixel gap.
        position = { anchor = 'bottom-right', x = 34, y = 30 },
    },

    -- Player command to move the Status Card HUD (drag mode; the spot is saved per client).
    hudMoveCommand = 'rookiehud',

    -- What protection disables, enforced on the protected player's own client.
    restrictions = {
        disableShooting = true,
        disablePunching = true,
        disablePunchDamage = true, -- other players' fists deal no damage to them
        disableVDMDamage = true,   -- reduces run-over damage taken
        allowDriveBy = false,
        weaponWhitelist = { `WEAPON_PETROLCAN`, `WEAPON_BATTLEAXE`, `WEAPON_CHAINSAW` },
    },

    -- Admin toggle command (grants if off, clears if on).
    command = {
        name = 'rookieprotect',
        ace = 'group.mod', -- ace permission required to run it
        help = 'Toggle new-player protection on a player',
    },

    -- While cash OR bank is negative, non-whitelisted weapons are auto-holstered.
    jammer = {
        enabled = true,
        weaponWhitelist = { `WEAPON_PETROLCAN`, `WEAPON_BATTLEAXE`, `WEAPON_CHAINSAW` },
    },

    -- Diazepam item: ambulance / godfathers can sedate a nearby player.
    diazepam = {
        item = 'diazepam',
        durationMinutes = 10,   -- how long the sedation lasts on the target
        radius = 10.0,          -- client selection radius (metres)
        maxDistance = 8.0,      -- server-validated apply distance (metres)
        cooldownSeconds = 30,   -- per-user cooldown between uses
        tokenTtlSeconds = 8,    -- how long the use-to-apply token stays valid
        allowedJobs = { ambulance = true, ambulance2 = true, doc = true },
        allowedGangs = { godfathers = true },
    },

    -- How often online protected players are batch-saved (minutes). Event-driven otherwise.
    saveIntervalMinutes = 15,

    -- NUI accent: a preset key, or a custom { primary = '#RRGGBB', primaryRgb = 'r, g, b' }.
    palette = 'winter_blue',
}
```

## Commands

| Command | Access | Does |
| --- | --- | --- |
| `/rookieprotect [id]` | group.mod (config `command.ace`) | Toggles new-player protection on a player, defaulting to yourself. Command name from `Config.command.name`. |
| `/savenewplayer` | group.admin | Force-saves all online protection times to the database. |
| `/rookiehud` | everyone | Enters drag mode to reposition the Status Card HUD, or reset it. Command name from `Config.hudMoveCommand`. |

## Statebags

The resource publishes one replicated player statebag so other resources can tell a protected character apart.

| Statebag | Scope | Set when | Read by |
| --- | --- | --- | --- |
| `miNewPlayer` | player | Set `true` while new-player protection is active (on grant and on character load), `false` when it expires or is toggled off. | Any resource that should exempt a protected character, for example anti-cheat, damage, and VDM systems. Read it with `Player(src).state.miNewPlayer` (server) or `LocalPlayer.state.miNewPlayer` (client). |

See the [state reference](../mi_core/reference/state.md) for the core statebags and GlobalState.
