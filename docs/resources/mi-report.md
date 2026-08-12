# mi-report

A live player and admin report system with a React console, built for low network, DB, and main-thread cost. Players file reports and chat with staff in real time; admins reply, close, teleport to the reporter, and use an optional staff chat.

## Install

```cfg
ensure mi-report
```

Depends on ox_lib, oxmysql and qbx_core or mi_core.

It ships server/migrate.lua, so tables auto-create on first boot, no manual SQL import.

## Config

The owner tunables are split across `shared/config/`:

```lua
-- general.lua
command = 'report',        -- /report opens the UI
keybind = '',              -- optional RegisterKeyMapping key, '' to disable
palette = 'winter_blue',   -- one of shared/config/theme/palettes.lua keys

-- permissions.lua
acePermission = 'support',    -- IsPlayerAceAllowed(src, this) grants admin access
groups = { 'admin', 'mod' },  -- qbx permission groups also treated as admin

-- actions.lua
enableTeleport = true,
teleportCommand = 'goto %s',  -- %s = target server id, run via ExecuteCommand
allowClearCommand = true,     -- expose /clearreports
clearCommandAce = 'group.admin',

-- notifications.lua
notifyAdminsOnNewReport = true,
notifyAdminsOnPlayerMessage = true,
notifyPlayerOnAdminReply = true,

-- performance.lua
flushInterval = 15000,     -- ms between DB flushes while dirty
adminEventDebounce = 800,  -- ms to coalesce rowBump/stats events to admins
previewLength = 60,        -- chars of last message shown in the list preview
virtualizeThreshold = 30,  -- NUI virtualizes the list beyond this many rows
dbChunkSize = 50,          -- rows per batched flush chunk
staffChatHistory = 50,     -- staff-chat scrollback kept in memory

-- staffchat.lua
enabled = true,
seedMessage = 'Welcome to Staff Chat',

-- apiKeys.lua (blank before packaging)
discordWebhook = '',
```

## Commands

| Command | Access | Does |
| --- | --- | --- |
| `/report` | everyone | Opens the report console (command name set by config `general.command`). |
| `/clearreports` | group.admin (config `actions.clearCommandAce`) | Clears all reports. Only registered when `actions.allowClearCommand` is true. |
