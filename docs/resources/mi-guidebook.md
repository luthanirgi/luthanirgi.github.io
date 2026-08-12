# mi-guidebook

An admin-editable in-game handbook rendered as a React NUI. Players browse a tree of categories and articles, admins edit it live, and each article body is fetched only when opened to keep the network light.

## Install

```cfg
ensure mi-guidebook
```

Depends on ox_lib, oxmysql and qbx_core or mi_core.

It ships server/migrate.lua, so tables auto-create on first boot, no manual SQL import.

## Config

Owner settings live in `shared/config/general.lua`. Theme palettes and locale strings sit in `shared/config/theme` and `shared/config/locales`.

`shared/config/permissions.lua` decides who may edit the handbook. It is checked server-side on every write, and reading stays open to everyone. The ace goes through the core's `HasPermission`, so use the short name, not `group.admin`:

```lua
return { ace = 'admin' }   -- grant with: add_ace group.editor admin allow
```

`shared/config/seed.lua` is the starter handbook, written to the database once while it is empty and then owned by whoever edits it in game. Content is markdown (`##`, `-`, `**bold**`, `>` callout). One category and one article ship as a worked example, copy them and add your own.

```lua
return {
    -- Command players type to open the handbook.
    command = 'guidebook',

    -- Keybind: a control key string (e.g. 'F7') to bind the command, or '' to disable.
    keybind = '',

    -- Theme preset key from shared/config/theme/palettes.lua.
    -- Override live with:  setr mi:guidebook_palette winter_blue
    palette = 'winter_blue',

    -- Anti-abuse caps enforced server-side on every admin write.
    maxCategories   = 40,     -- most categories the tree may hold
    maxArticles     = 200,    -- most articles across all categories
    maxContentChars = 20000,  -- longest a single article body may be
    maxTitleChars   = 80,     -- longest a category/article title may be

    -- When true, currently-open players are told (a tiny version ping, not the payload)
    -- to refetch on their next open after an admin edit. Off keeps network minimal.
    liveRefresh = false,
}
```

## Commands

| Command | Access | Does |
| --- | --- | --- |
| `/guidebook` | everyone | Opens the handbook NUI. The name comes from `Config.general.command` (default `guidebook`). |
