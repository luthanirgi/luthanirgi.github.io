# mi-advers

mi-advers is a digital signage system. It manages world billboards (static image ads swapped onto existing map props via texture-replace) and screens (video, stream, browser page, or image played on spawned TV props via render-target). Staff drive everything from one React control dashboard.

## Install

```cfg
ensure mi-advers
```

All dependencies (ox_lib, ox_target, oxmysql, qbx_core) are standard. It ships server/migrate.lua, so its tables auto-create on first boot, no manual SQL import.

## Config

Top-level knobs (`shared/config/init.lua`):

```lua
local Config = {
    -- NUI theme: a preset key from shared/palettes.lua ('obsidian_rouge', 'winter_blue',
    -- 'monochrome', 'twilight_amber', 'ultramarine_navy') or your own colour table.
    theme = 'winter_blue',

    -- Command that opens the central Advertising Control dashboard.
    command     = 'advers',
    commandHelp = 'Open the mi-advers control dashboard',
    commandAce  = 'group.admin', -- ace/group allowed to run it; '' = unrestricted

    -- Anti-spam on content changes: max `count` changes per `windowMs` per player.
    rateLimit = { count = 5, windowMs = 3000 },
}
```

Who may manage displays (`shared/config/access.lua`). A display may override this with its own `access` table:

```lua
return {
    jobs       = { media = 4 }, -- job name -> minimum grade level
    gangs      = {},            -- gang name -> minimum grade level
    citizenids = {},            -- [citizenid] = true
    aces       = {},            -- [ace string] = true (IsPlayerAceAllowed, server-side)
}
```

What content displays may show (`shared/config/content.lua`, re-validated server-side on every change):

```lua
return {
    allowAny = false, -- true = accept any https host (still staff-gated + banned-word checked)

    imageHosts = {    -- hosts allowed for images when allowAny = false
        ['r2.fivemanage.com'] = true,
        ['i.postimg.cc']      = true,
        ['ibb.co']            = true,
    },

    allowYouTube     = true,
    allowTwitch      = true,
    allowDirectVideo = true, -- direct .mp4 / .webm / .m3u8 links (any host)
    allowBrowser     = true, -- arbitrary web pages (any host)

    bannedWords = {}, -- reject any URL containing one of these (case-insensitive substring)
}
```

Every managed billboard and screen is listed in `shared/config/displays.lua`. Each entry has a stable `id`, a `kind` of `billboard` or `screen`, coords, and the prop/target data. Adjust those to your map.

## Commands

| Command | Access | Does |
| --- | --- | --- |
| `/advers` | `group.admin` (Config.commandAce) | Open the mi-advers control dashboard |

The command name and its ace/group are both set in `shared/config/init.lua`.
