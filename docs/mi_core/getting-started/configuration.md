# Configuration

All server-owner settings live in one file, `shared/config.lua`. It `return`s a plain table, so you change a value and restart. Job and gang definitions sit next to it in `shared/jobs.lua` and `shared/gangs.lua`.

This page walks the settings you touch first. The whole file, every key, is on the [Config reference](../reference/config.md).

## Spawn and map title

```lua
defaultSpawn = vec4(-1035.71, -2731.87, 12.86, 0.0),  -- where a character with no saved position lands
pauseMapTitle = 'Mi Project',                          -- label at the top-left of the ESC map
```

## Economy

```lua
economy = {
    accounts = { cash = 500, bank = 5000 },   -- starting balances; add accounts freely (e.g. crypto = 0)
    disallowNegative = { cash = true, crypto = true }, -- accounts that can never drop below 0
    paycheckIntervalMinutes = 7,
},
```

Adding an account here also creates it on new characters. Removing one does not drop the column from the database, so old rows keep their value.

## Player needs and licences

```lua
player = {
    hungerDecayRate = 4,
    thirstDecayRate = 5,
    bloodGroups = { 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-' },
    defaultLicences = { id = false, driver = false, weapon = false, hunting = false },
},
```

## Rules

```lua
rules = {
    pvp                 = true,   -- friendly-fire on for loaded players
    locked              = false,  -- /closeserver locks to whitelist, /openserver reopens
    lockedReason        = 'The server is currently closed.',
    whitelistPermission = 'admin', -- ace group still allowed in while locked
},
```

## Character slots

```lua
multichar = {
    defaultSlots = 3,
    deleteConfirm = true,
},
```

## Cleanup on character delete

`characterCleanupTables` lists every table whose rows are wiped when a character is deleted, alongside the `players` row, in one transaction. A table not in your database is skipped, so extra lines are harmless. Add a line for any resource that keys rows by citizenid or identifier.

```lua
characterCleanupTables = {
    { 'player_vehicles', 'citizenid' },
    { 'player_groups',   'citizenid' },
    { 'players',         'citizenid' },
    -- ...one { table, id-column } per resource
},
```

## Convars over config

A few knobs live on convars so you can flip them per server without editing files. mi_core reads its own `mi:*` name first and falls back to the `qbx:*` name.

| Convar | Default | Effect |
|---|---|---|
| `mi:enablequeue` | `true` | connection queue on or off |
| `mi:enableVehiclePersistence` | `false` | keep vehicles between sessions |
| `mi:bucketlockdownmode` | `inactive` | routing-bucket entity lockdown |
| `mi:motd` | empty | message shown on join |

```cfg
setr mi:enablequeue true
setr mi:enableVehiclePersistence false
```

Next: see how existing resources connect in [Migrating](migrating.md), or start building in [Your first resource](../guides/first-resource.md). The full config file is on the [Config reference](../reference/config.md).
