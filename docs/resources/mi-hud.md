# mi-hud

Player HUD with status bars (health, armour, hunger, thirst, stress, stamina, voice), a vehicle speedometer, compass, minimap, and cinematic mode, plus built-in NOS and seatbelt/harness systems. Layouts are style-swappable (ten speedometers, ten status shapes, and so on) and each player's picks save per player.

## Install

```cfg
ensure mi-hud
```

Depends on ox_lib and qbx_core or mi_core.

## Config

The display settings live in `shared/config/hud.lua`. Colours are in `shared/config/colors.lua`, and the stress, compass, NOS, seatbelt, and blips modules sit beside it. Command names and the settings-menu keybind are in `shared/config/init.lua` (`Config.Commands`, `Config.Keybind`).

```lua
return {
    ClockType  = "24",             -- "12" or "24"
    DateFormat = "dd/mm/yyyy",     -- "dd/mm/yyyy", "mm/dd/yyyy", "yyyy/mm/dd"
    SpeedType  = "kmh",            -- "kmh" or "mph"
    Locale     = "en",             -- reads locales/<Locale>.json

    StressSystem        = true,
    ShowMapOnlyInTheCar = false,
    CompassSystem       = true,
    MinimapShape        = "circle", -- "square" or "circle"
    ServerLogoUrl       = "",       -- image URL, overrides the built-in "mi" monogram

    -- Server default styles (each player can override these in the HUD menu):
    Speedometer  = "halo",      -- halo, sector, forza, stack, led, digital, harc, ang, deck, rail
    InfoBlock    = "original",  -- original, line, logohero, iconrail, chips, moneyhero, twocol, ticker, pairs, cornerl
    HealthStyle  = "gradient",  -- gradient, flat, segmented, blocks, striped, thin, glow, capsule, ring, chevron
    StatusShape  = "circle",    -- circle, square, hexagon, bar, hairline, segment, dots, vertical, arc, tile
    CompassStyle = "tape",      -- tape, hairline, ribbon, rose, bracket, dots, blocks, split, arc, bar
}
```

`shared/config/bridge.lua` is the framework bridge. `core` points at `exports.qbx_core`, which mi_core answers to; repoint it (for example at `exports['qb-core']`) to run a different framework. ox_lib and ox_inventory are used directly and are not bridged.

## Exports

| Export | Signature | What it does |
| --- | --- | --- |
| compassitem | `exports['mi-hud']:compassitem(data, slot)` | ox_inventory item-use hook for the compass item; toggles the on-foot compass. |

## Commands

| Command | Access | Does |
| --- | --- | --- |
| `/hudmenu` | everyone | Opens the HUD settings menu (per-player layout and style choices). Name from `Config.Commands.menu`. |
| `/cinematic` | everyone | Toggles cinematic mode. |
| `/minimap` | everyone | Toggles the minimap (registered only when `Config.hud.ShowMapOnlyInTheCar` is false). |
| `/hidecompass` | everyone | Toggles the on-foot compass. |

## Keybinds

Registered with `lib.addKeybind`, so players rebind them under Settings, Key Bindings, FiveM. Default keys come from config.

| Keybind | Config default | Does |
| --- | --- | --- |
| `mi_seatbelt` | `Config.Seatbelt.key` | Buckle or unbuckle the seatbelt while in a vehicle. Skipped on motorcycles, cycles, and boats. |
| `mi_nosflame` | `Config.Nos.flameKey` | Hold to emit the nitrous exhaust flame (cosmetic, driver only). |
| `mi_nospurge` | `Config.Nos.purgeKey` | Hold to emit the nitrous purge steam (cosmetic, driver only). |

## Statebags

mi-hud publishes and reads a few player and vehicle statebags, so other resources react without an export.

| Statebag | Scope | Set by | Read by |
| --- | --- | --- | --- |
| `seatbelt` | player | mi-hud, on belt toggle | mi-hud (belt telltale, blocks the exit control while belted), and any resource checking if a player is belted |
| `harness` | player | mi-hud, when a race harness goes on or off | mi-hud (the speeding stress check uses a higher speed threshold with a harness on) |
| `hidehud` | player | any resource, with `LocalPlayer.state:set('hidehud', true, true)` | mi-hud, which hides the entire HUD while it is true |
| `_miNosFlame` | vehicle | mi-hud, while the flame key is held | mi-hud on every client that can see the vehicle, to render the flame |
| `_miNosPurge` | vehicle | mi-hud, while the purge key is held | mi-hud on every client that can see the vehicle, to render the purge |

mi-hud also reads the core `drunk` player bag and the `PlayerCount` GlobalState. See the [state reference](../mi_core/reference/state.md) for those.

## Events

The stress system runs on net events, so any resource adds or relieves stress without an export.

| Event | Direction | Purpose |
| --- | --- | --- |
| `hud:server:GainStress` | client to server | Add stress. Argument: amount (number). Skipped for police jobs when `Config.stress.disablePolice` is on, and while an anti-stress effect is active. |
| `hud:server:RelieveStress` | client to server | Remove stress. Argument: amount (number). |
| `hud:server:ActivateAntiStress` | client to server | Start an anti-stress effect (for example from a calming item). Argument: duration in minutes (number). |
| `hud:server:DeactivateAntiStress` | client to server | End the anti-stress effect early. |
| `seatbelt:client:ToggleSeatbelt` | local client event | Fired whenever the belt or harness is toggled, for resources that react to buckle state. |

## Items

| Item | Type | Does |
| --- | --- | --- |
| harness | ox_inventory useable item | Race harness, a stronger belt. Using it in a car attaches or removes the harness and spends durability on attach. Enable it and set the item name in `Config.Seatbelt.harness`. |
