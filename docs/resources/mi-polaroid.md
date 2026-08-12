# mi-polaroid

An in character camera. Players take a shot with a polaroid item, develop copies on a printer, keep prints in an album, and hold a photo up so everyone nearby sees it on screen. Photos are uploaded to an image host and stored as a URL, so the database stays small no matter how many pictures a server accumulates.

## Install

```cfg
ensure mi-polaroid
```

Depends on oxmysql, ox_lib, mi_core, ox_inventory, and `screenshot-basic` (the capture itself), plus OneSync. It ships `server/migrate.lua`, so `mi_polaroid_photos` auto-creates on first boot, no manual SQL import.

Paste the item definitions from `setup/ox-items.lua` into `ox_inventory/data/items.lua` and drop matching images into `ox_inventory/web/images/`. Two details in that file matter:

* `consume = 0` on the camera, printer, photo, and album. Without it ox_inventory destroys the item on use, and the use never reaches mi-polaroid at all.
* `durability = 100` on the camera and printer. That is what gives a fresh one its wear budget.

Set an upload token before anyone takes a picture, otherwise every capture fails to develop.

## Config

`shared/config/camera.lua` is capture behaviour and the server load limits:

```lua
return {
    aspect          = '16:9',   -- '16:9' | '1:1' viewfinder mask (the stored image stays full-frame)
    shutterCooldown = 3000,     -- ms between two captures by the same player
    photoQuota      = 200,      -- max stored photos per character (roll + albums)
    albumCapacity   = 60,       -- max photos inside one album

    -- The bar is printDuration MULTIPLIED by the number of copies, so a run of five
    -- takes five times a single print. Lower this if that drags.
    printDuration   = 8000,     -- ms progress bar for ONE copy
    deleteBatchMax  = 30,       -- most photos one bin action can throw away

    -- Wear, in durability percent per use. This is what limits a printer run: how many
    -- copies it has left in it, not an arbitrary number. Set either to 0 to last forever.
    wear = { camera = 1.0, printer = 2.0 },

    showDuration    = 5000,     -- ms the corkboard card stays up
    showRadius      = 8.0,      -- metres; the CLIENT resolves the audience
    showMaxAudience = 12,       -- hard cap on how many people one photo reaches

    -- Default spot for a shown photo, as a percentage of the screen. Each player can drag
    -- it elsewhere with the command below and their choice is stored on their own machine.
    cardPosition    = { x = 50, y = 72 },
    cardCommand     = 'polaroidpos',
    captionMax      = 120,      -- characters, enforced server-side

    -- Fetch sizes. Each row carries a photo the NUI will load, so a page is real network
    -- weight, not just JSON: keep them at what the screen actually shows.
    pageSize        = 10,       -- camera roll rows per fetch
    albumPageSize   = 12,       -- photos per album spread, and per album fetch

    rateLimit = {
        read   = { 30, 10000 }, -- roll/album paging: 30 per 10s
        write  = { 8,  10000 }, -- print, insert, eject, caption, delete, show
        upload = { 4,  60000 }, -- captures per minute; protects the image-host key
    },

    cacheTtl        = 60000,    -- ms a paged read stays cached per player
    blockInVehicle  = true,
}
```

`shared/config/upload.lua` is the image host. The token is read on the server only and handed to the client one capture at a time, so it is never cached client-side and never ships in the bundle.

```lua
return {
    provider = 'fivemanage',      -- 'fivemanage' | 'imgur' | 'custom'

    fivemanage = { token = '' },
    imgur      = { clientId = '' },

    custom = {
        url      = '',            -- e.g. 'https://cdn.example.com/upload'
        field    = 'image',
        headers  = {},            -- e.g. { ['Authorization'] = 'Bearer ...' }
        jsonPath = { 'url' },     -- where the URL sits in the response body
    },
}
```

`shared/config/items.lua` names the five inventory items, rename them if your inventory uses different keys:

```lua
return {
    camera  = 'polaroid',
    printer = 'printerpolaroid',
    paper   = 'paperpolaroid',
    photo   = 'photo',
    album   = 'album',
}
```

`shared/config/init.lua` also holds every player-facing string under `lang`, so the whole resource translates in one file. Colours are in `shared/config/theme.lua` (`obsidian_rouge` by default; presets `obsidian_rouge`, `winter_blue`, `monochrome`, `twilight_amber`, `ultramarine_navy`), pushed to the NUI at runtime with no rebuild. `shared/config/bridge.lua` points at the core if you run a different framework.

## How a photo travels

1. Using the camera opens the viewfinder. The shot is captured, uploaded to the host, and stored as a URL on the camera roll.
2. With no paper in the pocket, the shot stays on the roll instead of being lost.
3. Using the printer develops a roll entry into a `photo` item. One sheet of paper per copy, and the printer wears down per copy.
4. Using a photo holds it up: everyone within `showRadius` sees the card on screen for `showDuration`.
5. Using an album opens the spread. Only developed prints go in, up to `albumCapacity`.

## Exports

All four are ox_inventory use hooks, wired through the `server.export` entries in `setup/ox-items.lua`. There is nothing to call by hand.

| Export | Signature | What it does |
| --- | --- | --- |
| `useCamera` | `mi-polaroid.useCamera` | Opens the viewfinder and takes the shot |
| `usePrinter` | `mi-polaroid.usePrinter` | Opens the print run picker for the camera roll |
| `usePhoto` | `mi-polaroid.usePhoto` | Holds the print up to everyone nearby |
| `useAlbum` | `mi-polaroid.useAlbum` | Opens that album's spread |

## Commands

| Command | Access | Does |
| --- | --- | --- |
| `/polaroidpos` | everyone | Drag the shown-photo card to a new spot on your screen. The position is saved per player in KVP. |

The command name comes from `camera.cardCommand`.

## Database

One table, `mi_polaroid_photos`. A row is a URL, an owner, an optional album, a caption, and whether it has been developed, so a server with a hundred thousand photos still holds only a hundred thousand short rows.

## Photo expiry

`shared/config/expiry.lua` throws photos out once the image host has already dropped them. FiveManage keeps an upload for roughly a month; past that the URL answers with nothing, so the photo is a blank frame occupying a slot and a database row.

```lua
enabled = true,
days    = 30,               -- match your host's retention
on      = 'both',           -- 'album' | 'connect' | 'both'
loadedEvent = 'QBCore:Server:PlayerLoaded',
cooldown = 300000,          -- ms; a player is swept at most this often
notify  = true,             -- tell the player what went missing
```

`on` decides when the sweep runs. `album` costs one indexed query the moment a player opens an album or their camera roll. `connect` does it as they load in, using `loadedEvent`, which both qbx_core and qb-core fire, and nothing breaks if it never arrives. `both` is fine, because `cooldown` stops a second sweep from re-running the same query seconds later.

## Migrating from dx_camera

`shared/config/legacy.lua` covers the resource mi-polaroid replaces, in two independent parts.

**Metadata mirroring.** A printed photo also carries dx_camera's `metadata.photo = { img, date, msg }` block, so anything already reading that keeps finding the image. Turn it off once nothing does.

```lua
mirrorMetadata = true,
dateFormat     = '%Y/%m/%d',   -- how metadata.photo.date is written
```

**One-way import.** dx_camera kept one row per character with every photo in a JSON array. The first time that character opens an album here, those photos are copied across.

```lua
import = {
    enabled          = true,
    table            = 'dx_camera',
    identifierColumn = 'identifier',   -- holds the citizenid, or the license
    imagesColumn     = 'images',       -- JSON array of { date, img }
},
```

The old table is only ever read, never written or dropped, so rolling back to dx_camera stays possible after the import.
