# Events

mi_core keeps the qbx and qb event names, because they are the wire protocol that other resources already listen to. Names starting with `QBCore:` and `qbx_core:` are stable.

## Server events you listen to

| Event | Fires when | Arguments |
|---|---|---|
| `QBCore:Server:PlayerLoaded` | a character finishes loading | `player` |
| `QBCore:Server:OnPlayerUnload` | a character unloads | `source` |
| `qbx_core:server:playerLoggedOut` | a player logs out | `source` |
| `QBCore:Server:OnJobUpdate` | a player's job changes | `source, job` |
| `QBCore:Server:OnGangUpdate` | a player's gang changes | `source, gang` |
| `QBCore:Server:OnMoneyChange` | a balance changes | `source, account, amount, action, reason` |
| `qbx_core:server:onGroupUpdate` | a job or gang grade changes | `source, name, grade` |
| `qbx_core:server:onSetMetaData` | metadata changes | `key, oldValue, value, source` |
| `mi_core:security:flagged` | the security layer flags a source | `source, reason, count` |

```lua
AddEventHandler('QBCore:Server:OnMoneyChange', function(source, account, amount, action, reason)
    -- action is 'add', 'remove', or 'set'
end)
```

## Server events you trigger

| Event | Effect |
|---|---|
| `QBCore:ToggleDuty` | toggle the caller's duty |
| `qbx_core:UpdatePlayer` | drain hunger and thirst, arguments `didEat, didDrink` |
| `qbx_core:UpdatePlayerDrunk` | reduce drunk by an amount |
| `QBCore:Server:CloseServer` | lock the server, argument `reason` |
| `QBCore:Server:OpenServer` | unlock the server |

## Client events you listen to

| Event | Fires when | Arguments |
|---|---|---|
| `QBCore:Client:OnPlayerLoaded` | the local player is ready | |
| `QBCore:Client:OnPlayerUnload` | the local player unloads | |
| `QBCore:Player:SetPlayerData` | local player data changes | `data` |
| `QBCore:Client:OnJobUpdate` | local job changes | `job` |
| `QBCore:Client:OnGangUpdate` | local gang changes | `gang` |
| `qbx_core:client:playerLoggedOut` | the local player logs out | |
| `qbx_core:client:onUpdatePlayerData` | a top-level PlayerData key changed | `key, value` |
| `qbx_core:client:onSetMetaData` | a metadata branch changed | `metadata, oldValue, value` |
| `qbx_core:client:loadPlayerData` | full PlayerData (re)load | `data` |

The last three are the per-key deltas. PlayerData now syncs to the client as small deltas, not a full copy, and `QBCore:Player:SetPlayerData` is re-broadcast locally after each one so the classic listener still fires. The full contract, and which one to prefer, is on the [State page](state.md#playerdata-sync).

## A note on triggering versus exports

Prefer exports for actions that return a result, like money and jobs. Use events for reacting to things that happened. The events above are the ones the core itself owns. Your own resources add their own events on top.
