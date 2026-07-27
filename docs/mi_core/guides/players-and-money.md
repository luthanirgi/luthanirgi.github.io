# Players and money

This guide covers the player object and the safe way to move money.

## The player object

`GetPlayer(source)` returns a table with two important parts.

```lua
local player = exports.mi_core:GetPlayer(source)

player.PlayerData   -- the data: identity, money, job, gang, metadata
player.Functions    -- convenience methods bound to this player
```

`PlayerData` is a snapshot you can read freely.

```lua
local data = player.PlayerData

data.citizenid          -- stable id for this character
data.name               -- account name
data.charinfo.firstname
data.charinfo.lastname
data.money.cash
data.money.bank
data.job.name
data.job.grade.level
data.job.onduty
data.gang.name
data.metadata.hunger
```

## Finding a player without a source

Sometimes you have a citizenid, a phone number, or a user id instead of a live source.

```lua
exports.mi_core:GetPlayerByCitizenId('ABC12345')
exports.mi_core:GetPlayerByPhone('0551234567')
exports.mi_core:GetPlayerByUserId(42)
```

For an offline character, load it by citizenid. This reads from the database and gives you a player object you can change and save.

```lua
local player = exports.mi_core:GetOfflinePlayer('ABC12345')
```

## Money

Four calls cover everything. Each takes a source or a citizenid as the first argument, so they work on online and offline players.

```lua
exports.mi_core:AddMoney(source, 'cash', 250, 'sold fish')
exports.mi_core:RemoveMoney(source, 'bank', 1000, 'bought a car')
exports.mi_core:SetMoney(source, 'crypto', 5, 'admin set')
local balance = exports.mi_core:GetMoney(source, 'bank')
```

They return `true` on success. `RemoveMoney` returns `false` when the player cannot afford it and the account is in `disallowNegative`, so you can rely on the result rather than checking the balance yourself.

```lua
if not exports.mi_core:RemoveMoney(source, 'bank', price, 'shop purchase') then
    exports.mi_core:Notify(source, 'Not enough money', 'error')
    return
end
-- payment went through, give the item
```

> **⚠️ Never write to money directly**
>
> Do not set `player.PlayerData.money.bank = 500` by hand. That skips the database write, the client update, and the money log. Always go through the four functions above.

## Metadata

Metadata is the flexible per character store: hunger, thirst, stress, licences, and anything your resources add.

```lua
local hunger = exports.mi_core:GetMetadata(source, 'hunger')
exports.mi_core:SetMetadata(source, 'hunger', 100)
```

Nested keys use a dot.

```lua
exports.mi_core:SetMetadata(source, 'licences.driver', true)
local hasDriver = exports.mi_core:GetMetadata(source, 'licences.driver')
```

`SetMetadata` saves and syncs, the same as the money functions.

## Reacting to a player loading

Run setup when a player is ready.

```lua
AddEventHandler('QBCore:Server:PlayerLoaded', function(player)
    print(('%s is ready'):format(player.PlayerData.name))
end)
```

Clean up when they leave.

```lua
AddEventHandler('qbx_core:server:playerLoggedOut', function(source)
    -- forget anything you cached for this source
end)
```

Next: [Jobs and gangs](jobs-and-gangs.md).
