# Compatibility

mi_core is your one framework. There is no second core resource, no shim, and nothing named qbx_core to ensure. This page is about how resources written for other frameworks still work.

> **🚫 One framework, one resource**
>
> You ensure `mi_core` and nothing else that calls itself a core. Never run the real `qbx_core` next to it.

## How each kind of resource connects

| A resource was written for | It reaches mi_core through | You install |
|---|---|---|
| mi_core | `exports.mi_core` | nothing extra |
| qbx_core | `exports.qbx_core`, answered by mi_core itself | nothing extra |
| qb-core | the qb layer inside mi_core | nothing extra |

Your own resources should call `exports.mi_core`. The rest is for resources you did not write.

## qbx_core resources answer to mi_core

A resource that calls `exports.qbx_core:GetPlayer(source)` just works. mi_core registers every one of its functions under the `qbx_core` name as well as its own, so the call resolves straight into mi_core.

This is not a separate resource forwarding the call. In FiveM, `exports(name, fn)` is sugar over a small event hook, and mi_core adds the same hook for the qbx_core name. One resource answers both names.

```lua
exports.mi_core:GetPlayer(source)    -- native
exports.qbx_core:GetPlayer(source)   -- same function, answered by mi_core
```

Events are the same. `QBCore:*` and `qbx_core:*` event names cross resources on their own, so nothing special is needed for them.

## qb-core resources answer to mi_core

The qb layer lives inside mi_core. It calls `provide 'qb-core'` and builds the classic core object, so qb resources find what they expect with nothing else to install.

```lua
local QBCore = exports['qb-core']:GetCoreObject()
local Player = QBCore.Functions.GetPlayer(source)
Player.Functions.AddMoney('bank', 250)
```

The `QBCore.Functions` table, `QBCore.Shared`, and the `QBCore:*` events are all present.

## The one thing to change: @qbx_core file imports

Some resources load a file straight from qbx_core in their manifest:

```lua
shared_script '@qbx_core/modules/playerdata.lua'
```

FiveM loads `@name/file` by the literal resource name, and there is no hook for that the way there is for exports. Since you do not run a qbx_core resource, point these at mi_core instead. The file is the same one, mi_core ships it.

```lua
shared_script '@mi_core/modules/playerdata.lua'
```

That is a one line change per resource. mi_core provides `@mi_core/modules/playerdata.lua` and `@mi_core/modules/lib.lua`.

## Differences from qbx_core

Names and signatures match qbx_core so resources drop in. A few things differ on purpose. This is the full list.

### Exports qbx_core has that mi_core does not

These were dropped. A resource that calls one fails loudly (`No such export ...`) rather than silently, so you notice and wire a replacement.

| Export | Side | Why it is gone |
|---|---|---|
| `IsPlayerBanned` | server | mi_core does not enforce bans on connect, txAdmin already does. Wire your own ban check if you need one. |
| `ExploitBan` | server | same. No built-in ban table. |
| `IsOptin` / `ToggleOptin` | server | admin report opt-in was not carried over. |
| `registerHook` / `removeHooks` | server | the core money-hook system was dropped. Note: `exports.ox_inventory:registerHook` is a different, unrelated system and still works. |

`SetField` exists as the method `QBCore.Functions.SetField`, but not as `exports.qbx_core:SetField`. Almost every caller uses the method, so this rarely matters.

### Exports mi_core adds that qbx_core does not

Extra surface, safe to ignore if you do not need it.

| Export | Side | What it does |
|---|---|---|
| `GetOfflinePlayerByCitizenId` | server | load an offline player straight by citizenid |
| `WaitForPlayerLoaded` | server | await a source becoming fully loaded |
| `GetAllDutyCounts` / `GetPlayersOnDuty` | server | O(1) duty tallies, see rule 8 in the [reference](reference/server-exports.md) |
| `GetPaycheck` / `AddPaycheck` / `WithdrawPaycheck` | server | the paycheck accrual pool |
| `IsValidSource` | server | is this source a real active player |
| `CheckRate` | server | a built-in per-source rate limiter |
| `RegisterSecurePlayer` / `ValidateTarget` / `FlagSuspicious` / `GetFlags` / `GetSecurePlayer` | server | the security layer, see [Server exports](reference/server-exports.md) |

### Signatures to watch

One real difference, on the client:

* **`GetJob` / `GetGang` (client)** return the LOCAL player's current job or gang table, with no argument. In qbx_core the client `GetJob(name)` looks a job definition up by name. If a client resource does `exports.qbx_core:GetJob('police')` expecting a definition, it gets the calling player's current job instead. Read a job or gang definition from `GetJobs()` / `GetGangs()` (plural) instead.

Everything else, `Notify`, `HasPermission`, `AddMoney`, `SetMetadata`, `SetJob`, and the rest, takes the same arguments as qbx_core.

## Load order

Anything that consumes the framework loads after it. There is no core to load between them.

```cfg
ensure oxmysql
ensure ox_lib
ensure ox_inventory
ensure mi_core
# your resources after this line
```
