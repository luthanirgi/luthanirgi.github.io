# mi-documents

mi-documents is an in character paperwork tablet with a React UI: players create documents from job templates, keep their own copies, and hand signed copies to nearby players. Documents are cached in memory so a busy server reads the database once, not once per open.

## Install

```cfg
ensure mi-documents
```

Needs OneSync enabled on the server. It ships server/migrate.lua, so tables auto-create on first boot, no manual SQL import.

## Config

```lua
local Config = {
    command          = 'docs',    -- chat command that opens the tablet
    keybind          = nil,       -- optional key mapping, e.g. 'F8'
    documentItemName = nil,       -- optional inventory item that opens it, e.g. 'wallet'

    maxGiveDistance  = 3.0,       -- max metres to hand a copy to another player

    rateLimit = {
        read  = { 30, 10000 },    -- templates, lists, body fetches (count, window ms)
        write = { 8,  10000 },    -- create, edit, delete, give, show
    },

    cache = {
        templatesTtl = 120000,    -- templates change rarely
        docsTtl      = 60000,     -- per-player list view
        bodyTtl      = 600000,    -- doc body is effectively immutable
    },

    jobLabels = {                 -- pretty names shown for issuer jobs
        ambulance  = 'Alta Hospital',
        ambulance2 = 'Roxwood Hospital',
    },

    paperProp = {                 -- prop used in the show-document animation
        name = 'prop_cd_paper_pile1',
        xRot = -130.0, yRot = -50.0, zRot = 0.0,
    },

    theme   = require 'shared.config.theme',    -- UI palette (5 presets in theme.lua)
    jobDocs = require 'shared.config.jobdocs',  -- per-job document templates
}
```

`shared/config/bridge.lua` is the framework bridge. `core` points at `exports.qbx_core`, which mi_core answers to; repoint it (for example at `exports['qb-core']`) to run a different framework. ox_lib and ox_inventory are used directly and are not bridged.

## Exports

| Export | Signature | What it does |
|---|---|---|
| `CreateDocument` | `exports['mi-documents']:CreateDocument(opts)` | Server-side. Issue a document to a player. `opts.target` is a server id or citizenid, `opts.name` is required; optional `recipient`, `issuer`, `fields`, `description`, `validUntil`, `isCopy`. Returns `{ success = true, id = number }` or `{ success = false, error = string }`. |

## Commands

| Command | Access | Does |
|---|---|---|
| `/docs` | everyone | open the document tablet (name set by `Config.command`) |
