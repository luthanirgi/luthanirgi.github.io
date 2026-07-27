# Client exports

Call these as `exports.mi_core:Name(...)` on the client. They act on the local player, so most take no source.

## Player

| Export | Signature | Returns |
|---|---|---|
| `GetPlayerData` | `()` | the local player's data |
| `HasPrimaryGroup` | `(name)` | is this their primary job or gang |
| `HasGroup` | `(name)` | do they hold this job or gang |
| `GetGroups` | `()` | the local player's jobs and gangs |
| `Notify` | `(text, type?, duration?, ...)` | show a notification |
| `chooseCharacter` | `()` | open character selection, handled by mi-characters |

## Jobs and gangs

| Export | Signature | Returns |
|---|---|---|
| `GetJobs` | `()` | the full job catalogue (definitions) |
| `GetGangs` | `()` | the full gang catalogue (definitions) |
| `GetJob` | `()` | the local player's current job |
| `GetGang` | `()` | the local player's current gang |

Note the difference from qbx_core: here the singular client `GetJob` and `GetGang` take no argument and return the local player's current job or gang. To read a job or gang definition by name, index the catalogue from `GetJobs()` or `GetGangs()`. See [Compatibility](../compatibility.md#signatures-to-watch).

The catalogue stays in sync. When the server changes a job, the client copy updates on its own.

## World data

| Export | Signature | Returns |
|---|---|---|
| `GetVehiclesByName` | `(key?)` | vehicle data by spawn name |
| `GetVehiclesByHash` | `(key?)` | vehicle data by hash |
| `GetVehiclesByCategory` | `()` | vehicles grouped by category |
| `GetWeapons` | `(key?)` | weapon data |
| `GetLocations` | `()` | shared locations |

## Reading player data as it changes

The local data table updates through an event. Listen if you keep your own copy.

```lua
RegisterNetEvent('QBCore:Player:SetPlayerData', function(data)
    -- data is the fresh player data
end)
```
