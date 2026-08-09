# mi-scenes

Players spray 3D world text scenes using a sprayer item and clear them with a spray remover. Scenes are saved to the database and streamed to nearby players through a grid-cell spatial subscription, so only scenes in your area are drawn.

## Install

```cfg
ensure mi-scenes
```

It ships server/migrate.lua, so tables auto-create on first boot, no manual SQL import.

## Config

`shared/config/main.lua` holds the owner-editable behaviour:

```lua
return {
    MaxDistance = 25,          -- max distance that can be placed & viewed, passed to UI for view distance
    Log = false,               -- logs the scene creation and deletion with ox_lib logging
    MaxScenes = 5,             -- max scenes that can be placed per creator
    Radial = false,            -- add scene management to ox_lib radial menu | AdminOnly must be false
    AdminOnly = false,         -- only admins can create scenes
    AdminDeleteAll = true,     -- admins can delete other peoples scenes
    AceGroup = 'mod',          -- ace group required when AdminOnly/AdminDeleteAll is true
    EnableKeybind = false,     -- allow scenes menu to be opened via keybind
    Key = 'K',                 -- key used if EnableKeybind is true
    MaxDuration = 24,          -- max duration the scene can be set in hours
    NeverExpire = false,       -- offer a "never expire" option in the UI
    NeverExpireAdmin = true,   -- if true, only admins see the NeverExpire option
    CheckForCollisions = false,-- enable line-of-sight check before drawing a scene
    AuditInterval = 60,        -- minutes between expired-scene sweeps
    CellSize = 150,            -- grid cell size (game units) for spatial subscription
}
```

The UI palette is chosen in `shared/config/colors.lua` by setting `PALETTE` to one of `obsidian_rouge`, `winter_blue`, `monochrome`, `twilight_amber`, or `ultramarine_navy`. It applies at runtime, so a re-skin needs no web rebuild.

`shared/config/backgrounds.lua` is the list of background styles offered when a scene is created (`none`, the `Tall*` sizes, `Blood` through `Blood5`, `Brush`, `Chain`, the metals, the gradients, the note papers, and `Spray`). Trim it to the ones you want players choosing from.

`shared/config/bridge.lua` is the framework bridge. `core` points at `exports.qbx_core`, which mi_core answers to; repoint it (for example at `exports['qb-core']`) to run a different framework.
