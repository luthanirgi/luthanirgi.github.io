# mi-characters

A multi-character selection screen with a React UI, a camera scene over a posed ped, and a built-in weapon anti-cheat (magic-bullet, wall-magic and no-recoil/aimlock detection). Players pick, create or delete a character and spawn in.

## Install

```cfg
ensure mi-characters
```

It stores no tables of its own and ships no SQL. Character records come from the core through the framework bridge (`shared/config/bridge.lua`, `exports.qbx_core` by default); the preview reads the core's `players` and `playerskins` rows.

## Config

Owner-editable settings live in `shared/config/*.lua`.

`shared/config/init.lua`:

```lua
deleteOption = false,   -- allow deleting a character from the selector
half         = false,   -- half-body / half appearance mode
debounceMs   = 250,     -- guard between selection clicks
defaultSpawn = vec4(-1037.78, -2738.07, 20.17, 327.94),

-- anti-cheat
Test_Command           = false,   -- register /controltest (dev only)
Holster_Animation_Wait = 5000,
Default_Bucket         = 0,

Aimlock_Control_Weapon = "WEAPON_NORECOIL",
Magic_Control_Weapon   = "WEAPON_MAGIC",

Kick        = true,    -- kick on a confirmed detection
After_Event = false,   -- fire mi-characters:after-control instead of/after handling
```

`shared/config/scene.lua` holds the selection camera scene: the ped and camera coordinates, FOV, idle animation, and an anti-loiter geofence (`towerZone`) around the tower. Move the anchors together to relocate the whole scene.

`shared/config/anticheat.lua` holds the test-arena teleport spots the anti-cheat sends a suspect to for each detection stage. Relocate them to an isolated, hidden part of the map.

`server/apiKeys.lua` is server-only and buyer-editable (kept out of escrow). Set your anti-cheat Discord webhook there; leave it empty to disable Discord logging:

```lua
return {
    Webhook      = '',
    WebhookColor = 15158332,
}
```

UI colours are in `shared/config/colors.lua`. Pick one preset (`winter_blue` by default) from `obsidian_rouge`, `winter_blue`, `monochrome`, `twilight_amber`, `ultramarine_navy`. The palette is applied to the NUI at runtime, so a re-skin needs no web rebuild.

## Exports

| Export | Signature | What it does |
|---|---|---|
| `chooseCharacter` | `chooseCharacter()` | client export that opens the character selector (fetches the roster, sets up the scene, shows the UI). Called on logout and at startup, and available for a spawn manager to reopen selection. |

```lua
exports['mi-characters']:chooseCharacter()
```

## Commands

| Command | Access | Does |
|---|---|---|
| `/controltest` | everyone | runs the anti-cheat control test on yourself |

`/controltest` is only registered when `Config.Test_Command = true` (off by default), so it is a dev/testing command rather than a live one.
