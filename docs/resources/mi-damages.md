# mi-damages

An injury and damage system with a React EMR dossier NUI. It registers wounds per body part from weapon hits, runs a bleeding model, shows an injury HUD, and lets on-duty EMS treat wounds with items. State is in memory (no database); death and revive stay owned by mi-ambulancejob, and injuries clear automatically when a player is revived.

## Install

```cfg
ensure mi-damages
```

Depends on ox_lib, ox_inventory and ox_target.

## Config

`shared/config/init.lua` holds the tunables below. The weapon-to-wound mapping lives in `weapons.lua`, the framework and medical bridge in `bridge.lua` (repoint `core` / `medical` to run a different core), and the palette in `colors.lua` (pick one of the five presets). Player-facing copy lives in `locales/*.json` (set the language with `setr ox:locale <code>`).

```lua
Config.Jobs = { 'ambulance', 'ambulance2' } -- EMS branches allowed to examine and treat patients
Config.SelfTreatItem = 'painkillers'        -- item used for self-treatment
Config.HudKey = 'n'                         -- key to pin the injury HUD (rebindable in GTA settings)
Config.ReverseHud = true                    -- mirror the HUD / avatar horizontally
Config.HudSize = 100                        -- injury HUD zoom, percent
Config.DamageDetection = true               -- master switch for damage detection
Config.NewPlayerShield = true               -- skip registering wounds on mi-newplayer protected players
Config.EnableBleeding = true
Config.BleedingHitDamage = 1                -- base HP lost per bleeding tick
Config.BleedingMultiplier = 1              -- scales total bleed damage
Config.BleedingInterval = 60000            -- tick interval (ms)
Config.StopBleedingTime = 10               -- painkiller duration (minutes)
```

## Exports

Server exports, for mi-ambulancejob and any other resource that needs to read or clear injury state.

| Export | Signature | What it does |
| --- | --- | --- |
| `GetInjuries` | `exports['mi-damages']:GetInjuries(src)` | Returns the wound table for a player (parts to wounds), or an empty table. |
| `IsInjured` | `exports['mi-damages']:IsInjured(src)` | Returns true if the player has any wound. |
| `IsBleeding` | `exports['mi-damages']:IsBleeding(src)` | Returns true if any of the player's wounds is bleeding. |
| `ClearInjuries` | `exports['mi-damages']:ClearInjuries(src)` | Clears every wound on the player. |
| `ClearInjuryPart` | `exports['mi-damages']:ClearInjuryPart(src, part)` | Clears one body part (`head`, `body`, `larm`, ...). Returns false if the part is unknown or carried no wound. |
| `OpenTreatMenu` | `exports['mi-damages']:OpenTreatMenu(medicSrc)` | Opens the treat chart on a medic's client. |

## Commands

| Command | Access | Does |
| --- | --- | --- |
| `/injuryhud` | everyone | Toggles the injury HUD to always-on. |
