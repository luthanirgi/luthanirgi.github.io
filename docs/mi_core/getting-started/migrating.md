# Migrating from qbx or qb

For most servers this page is short, because the answer is that your resources barely change.

## Resources written for qbx_core

The exports and events keep working with no edits. mi_core answers the `exports.qbx_core` calls itself, under the same names, so this all resolves with nothing extra installed:

```lua
exports.qbx_core:GetPlayer(source)
TriggerEvent('QBCore:Server:OnPlayerLoaded')
local playerData = exports.qbx_core:GetPlayerData()
```

The one thing to change is a file import. If a manifest loads a file from qbx_core, point it at mi_core instead, because files load by resource name and you do not run a qbx_core resource.

```lua
-- before
shared_script '@qbx_core/modules/playerdata.lua'
-- after
shared_script '@mi_core/modules/playerdata.lua'
```

mi_core ships that file, so it is a one line swap per resource.

## Resources written for qb-core

They keep working too. mi_core has a qb layer that calls `provide 'qb-core'` and exposes the classic `QBCore` object.

```lua
local QBCore = exports['qb-core']:GetCoreObject()
local Player = QBCore.Functions.GetPlayer(source)
Player.Functions.AddMoney('cash', 500)
```

The `QBCore.Functions.*` table, the shared data, and the `QBCore:*` events are all present.

## What actually changed

The changes are internal. They matter if you read mi_core source or write directly against it, not if you consume it through the qbx or qb interface.

- The core lives under `core/`, organized by domain, instead of a flat `server/` and `client/`.
- Framework functions register on an internal `Mi.api` registry, then get emitted as exports under both the mi_core and qbx_core names.
- Config keys were renamed to say what they do. If a resource reads mi_core config keys directly, which is rare, update those names.
- The built in ban table was removed. If you called `IsPlayerBanned`, wire your own ban check or use txAdmin.

## Moving a resource onto mi_core directly

Optional. If you want a resource to call mi_core by name, swap the export target:

```lua
-- before
exports.qbx_core:GetPlayer(source)
-- after
exports.mi_core:GetPlayer(source)
```

The function signatures are identical, so this is a find and replace. There is no rush. Both names hit the same function.

## Checklist

- [ ] `mi_core` is ensured. There is no qbx_core resource.
- [ ] `sql/mi_core.sql` imported once.
- [ ] Any `@qbx_core/...` file import repointed to `@mi_core/...`.
- [ ] Old qbx and qb resources load after mi_core.
- [ ] If you used the core ban table, you have a replacement.

That is the whole migration for a normal server.
