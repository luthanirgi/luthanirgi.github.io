# mi-spawnselector

A React spawn selector shown when a character loads. The player picks a city, job, EMS, or VIP spawn point, their last saved location, or an owned property. It registers as `qbx_spawn`.

## Install

```cfg
ensure mi-spawnselector
```

Depends on ox_lib and qbx_core or mi_core.

It declares `provide 'qbx_spawn'`, so run it in place of qbx_spawn (do not run both).

## Config

`configs/client.lua` is the server-owner config. Edit it with no web rebuild needed:

```lua
return {
    -- Palette: obsidian_rouge | winter_blue | monochrome | twilight_amber | ultramarine_navy
    theme = 'winter_blue',

    server = { name = 'MI ROLEPLAY', subtitle = 'Choose where to begin' },

    settings = {
        allowLastLocation = true,      -- offer a "Last location" pin
        allowProperties = true,        -- offer owned properties (needs mi-housing running)
        deadForcesLastLocation = true, -- if downed/laststand, spawn at last location with no choice
    },

    -- Spawn points. category = 'city' | 'job' | 'ems' | 'vip' (drives the list colour + icon).
    -- groups = list of job names allowed (false = everyone). vip = true gates to metadata.isvip.
    spawns = {
        { label = 'Airport', category = 'city', description = 'Los Santos International', groups = false, coords = vec4(-1037.78, -2738.07, 20.17, 327.94) },
        { label = 'MRPD', category = 'job', description = 'Mission Row Police Dept', groups = { 'police', 'doc' }, coords = vec4(435.60, -973.97, 30.72, 88.29) },
        { label = 'Carnaval', category = 'vip', description = 'Members only', vip = true, groups = false, coords = vec4(-1595.49, -1012.53, 13.02, 227.46) },
        -- ...add more spawn points here
    },
}
```
