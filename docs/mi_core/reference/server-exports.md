# Server exports

Call these as `exports.mi_core:Name(...)` on the server. mi_core answers the same names on `exports.qbx_core` too, so qbx resources reach them with no changes.

Most calls that act on a player take a first argument that is either a live `source` or a `citizenid` string, so the same function works on online and offline players.

## Players

| Export | Signature | Returns |
|---|---|---|
| `GetPlayer` | `(source)` | player object or nil |
| `GetPlayerByCitizenId` | `(citizenid)` | player object or nil |
| `GetPlayerByUserId` | `(userId)` | player object or nil |
| `GetPlayerByPhone` | `(number)` | player object or nil |
| `GetOfflinePlayer` | `(citizenid)` | player object loaded from the database |
| `GetPlayersData` | `()` | array of every online player's data |
| `GetQBPlayers` | `()` | map of source to player object |
| `GetSlimQBPlayers` | `()` | lightweight source to identity map |
| `SearchPlayers` | `(filters)` | citizenids matching the filters |
| `GetSource` | `(citizenid)` | source for a loaded citizenid |
| `GetUserId` | `(source)` | account user id |
| `Login` | `(source, citizenid?, newData?)` | load or create a character |
| `Logout` | `(source)` | unload the current character |
| `DeleteCharacter` | `(citizenid)` | delete a character |

## Money

| Export | Signature | Returns |
|---|---|---|
| `AddMoney` | `(source, account, amount, reason?)` | true on success |
| `RemoveMoney` | `(source, account, amount, reason?)` | true on success |
| `SetMoney` | `(source, account, amount, reason?)` | true on success |
| `GetMoney` | `(source, account)` | balance or false |

`RemoveMoney` returns false when the account is in `disallowNegative` and the player cannot afford it. Read the return value rather than the balance.

## Player data and metadata

| Export | Signature | Notes |
|---|---|---|
| `SetPlayerData` | `(source, key, value, noSave?)` | set a top level field |
| `UpdatePlayerData` | `(source, key, value)` | set and sync to the client |
| `SetMetadata` | `(source, key, value)` | dotted keys allowed, saves and syncs |
| `GetMetadata` | `(source, key)` | dotted keys allowed |
| `SetCharInfo` | `(source, key, value)` | update character info |
| `Save` | `(source, key?)` | write to the database now |
| `SaveOffline` | `(playerData)` | save an offline player object |
| `GenerateUniqueIdentifier` | `(type)` | new unique citizenid, phone, account, and so on |

## Jobs and gangs

| Export | Signature | Returns |
|---|---|---|
| `SetJob` | `(source, jobName, grade?)` | true, or false and an error |
| `SetJobDuty` | `(source, onDuty)` | |
| `SetPlayerPrimaryJob` | `(citizenid, jobName)` | true, or false and an error |
| `AddPlayerToJob` | `(citizenid, jobName, grade?)` | true, or false and an error |
| `RemovePlayerFromJob` | `(citizenid, jobName)` | true, or false and an error |
| `SetGang` | `(source, gangName, grade?)` | true, or false and an error |
| `SetPlayerPrimaryGang` | `(citizenid, gangName)` | true, or false and an error |
| `AddPlayerToGang` | `(citizenid, gangName, grade?)` | true, or false and an error |
| `RemovePlayerFromGang` | `(citizenid, gangName)` | true, or false and an error |
| `HasPrimaryGroup` | `(source, name)` | boolean |
| `HasGroup` | `(source, name)` | boolean |
| `GetGroups` | `(source)` | the player's jobs and gangs |
| `IsGradeBoss` | `(source, type, name)` | boolean |
| `GetGroupMembers` | `(name, type)` | members of a job or gang |

### Managing the catalogue

| Export | Signature |
|---|---|
| `CreateJob` | `(name, data)` |
| `CreateJobs` | `(map)` |
| `RemoveJob` | `(name)` |
| `CreateGangs` | `(map)` |
| `RemoveGang` | `(name)` |
| `GetJobs` / `GetGangs` | `()` |
| `GetJob` / `GetGang` | `(name)` |
| `UpsertJobData` / `UpsertGangData` | `(name, data)` |
| `UpsertJobGrade` / `UpsertGangGrade` | `(name, grade, data)` |
| `RemoveJobGrade` / `RemoveGangGrade` | `(name, grade)` |

## Duty and rosters

| Export | Signature | Returns |
|---|---|---|
| `GetDutyCountJob` | `(jobName)` | on duty count, cached |
| `GetDutyCountType` | `(type)` | on duty count by type |
| `GetJobPlayers` | `(jobName)` | sources in a job |
| `GetGangPlayers` | `(gangName)` | sources in a gang |
| `GetAdminPlayers` | `()` | online admin sources |
| `TriggerClientJob` | `(jobName, event, ...)` | fire a client event to a job |
| `TriggerClientGang` | `(gangName, event, ...)` | fire a client event to a gang |
| `TriggerClientAdmin` | `(event, ...)` | fire a client event to admins |

## Routing buckets

| Export | Signature |
|---|---|
| `SetPlayerBucket` | `(source, bucket)` |
| `SetEntityBucket` | `(entity, bucket)` |
| `GetPlayersInBucket` | `(bucket)` |
| `GetEntitiesInBucket` | `(bucket)` |
| `GetBucketObjects` | `()` |

## Permissions

| Export | Signature | Returns |
|---|---|---|
| `IsWhitelisted` | `(source)` | boolean |
| `HasPermission` | `(source, permission)` | boolean |
| `GetPermission` | `(source)` | the player's permission groups |
| `AddPermission` | `(source, permission)` | |
| `RemovePermission` | `(source, permission)` | |

`HasPermission` accepts a single ace name or a list of them, and returns true if any is allowed. The admin report opt-in exports (`IsOptin`, `ToggleOptin`) from qbx_core are not carried over, see [Compatibility](../compatibility.md).

## Items

| Export | Signature |
|---|---|
| `CreateUseableItem` | `(name, callback)` |
| `CanUseItem` | `(name)` |

## Security

Server authoritative checks. They reject bad actions. They never ban. See [why mi_core](../README.md#why-mi_core) for the philosophy.

| Export | Signature | Returns |
|---|---|---|
| `IsValidSource` | `(source)` | is this a real active player |
| `ValidateTarget` | `(source, targetId, maxDist?)` | validate an event arg target |
| `CheckRate` | `(source, key, max, windowMs)` | true when allowed |
| `RegisterSecurePlayer` | `(source)` | |
| `GetSecurePlayer` | `(source)` | |
| `FlagSuspicious` | `(source, reason)` | log only, fires `mi_core:security:flagged` |
| `GetFlags` | `(source)` | accumulated flags |

## World and vehicles

| Export | Signature | Returns |
|---|---|---|
| `GetVehiclesByName` | `(key?)` | vehicle data by spawn name |
| `GetVehiclesByHash` | `(key?)` | vehicle data by hash |
| `GetVehiclesByCategory` | `()` | vehicles grouped by category |
| `GetWeapons` | `(key?)` | weapon data |
| `GetLocations` | `()` | shared locations |
| `CreateSessionId` | `()` | new session id |
| `GetVehicleClass` | `(model)` | vehicle class |
| `DeleteVehicle` | `(netId)` | delete a vehicle |
| `EnablePersistence` | `(vehicle)` | keep this vehicle across sessions |
| `DisablePersistence` | `(vehicle)` | stop persisting this vehicle |

## Notifications and version

| Export | Signature |
|---|---|
| `Notify` | `(source, text, type?, duration?, ...)` |
| `GetCoreVersion` | `()` |
