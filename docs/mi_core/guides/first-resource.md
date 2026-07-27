# Your first resource

You will build a small resource that adds a `/daily` command. When a player runs it, they get a cash reward once per session. It is tiny, but it touches the pieces you use every day: reading the player, changing money, and notifying them.

By the end you will know how to talk to mi_core from your own code.

## Set up the folder

Create `resources/[local]/daily/` with two files.

`fxmanifest.lua`

```lua
fx_version 'cerulean'
game 'gta5'

author 'you'
description 'A daily cash reward'
version '1.0.0'

shared_script '@ox_lib/init.lua'
server_script 'server.lua'
```

`server.lua`

```lua
-- we fill this in below
```

Add `ensure daily` to your `server.cfg` after `ensure mi_core`.

## Read the player

Every server side interaction starts by turning a `source` into a player object. That object holds the player's data and the functions that change it.

```lua
RegisterCommand('daily', function(source)
    local player = exports.mi_core:GetPlayer(source)
    if not player then return end

    print(('%s ran /daily'):format(player.PlayerData.name))
end)
```

`GetPlayer` returns `nil` if the source is not a loaded player, so the guard on the next line is not optional. Guarding here is the single most common thing you will do against the API.

## Pay them

Money changes go through `AddMoney`. It takes the account, the amount, and a reason string that shows up in your money logs.

```lua
RegisterCommand('daily', function(source)
    local player = exports.mi_core:GetPlayer(source)
    if not player then return end

    local ok = exports.mi_core:AddMoney(source, 'bank', 500, 'daily reward')
    if not ok then return end

    exports.mi_core:Notify(source, 'You claimed 500 to your bank', 'success')
end)
```

`AddMoney` returns `true` on success. It returns `false` if the account does not exist or the amount is invalid, which is why we check before notifying. The core writes the change to the database and updates the player's client for you.

## Make it once per session

Keep a small table of who already claimed. Clear it when a player drops so a reconnect can claim again.

```lua
local claimed = {}

RegisterCommand('daily', function(source)
    local player = exports.mi_core:GetPlayer(source)
    if not player then return end

    local cid = player.PlayerData.citizenid
    if claimed[cid] then
        exports.mi_core:Notify(source, 'You already claimed today', 'error')
        return
    end

    local ok = exports.mi_core:AddMoney(source, 'bank', 500, 'daily reward')
    if not ok then return end

    claimed[cid] = true
    exports.mi_core:Notify(source, 'You claimed 500 to your bank', 'success')
end)

AddEventHandler('qbx_core:server:playerLoggedOut', function(source)
    local player = exports.mi_core:GetPlayer(source)
    if player then claimed[player.PlayerData.citizenid] = nil end
end)
```

That is a complete, working resource. Restart the server, run `/daily`, and you get paid once.

## What you just used

| Call | What it did |
|---|---|
| `GetPlayer(source)` | turned a source into the player object |
| `player.PlayerData` | read the player's identity and state |
| `AddMoney(source, account, amount, reason)` | changed a balance and logged it |
| `Notify(source, text, type)` | showed the player a message |
| `qbx_core:server:playerLoggedOut` | ran cleanup when they left |

## Where to go from here

- Read [Players and money](players-and-money.md) for the rest of the player object and safe balance changes.
- The full list of calls is on [Server exports](../reference/server-exports.md).

> **💡 qbx and qb both work here**
>
> Every `exports.mi_core:*` call in this guide also works as `exports.qbx_core:*`, because mi_core answers both names, and the same actions are on `QBCore.Functions` for qb resources. Pick whichever your resource already uses.
