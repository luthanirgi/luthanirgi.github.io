# State: statebags and sync

mi_core publishes live player state on statebags and a few server-wide numbers on `GlobalState`. A statebag is replicated by the server, so any resource reads it with zero network cost and no export call. This is how a resource knows a player's job, duty, or login state without polling the core.

There are two ways state reaches you:

* **Statebags** for a value tied to one player (their job, whether they are on duty) or to the whole server (the player count).
* **PlayerData sync events** for the full player-data object, sent as small per-key deltas.

## Player statebags

Read with `Player(source).state.<key>` on the server, or `LocalPlayer.state.<key>` on the owning client. React to changes with `AddStateBagChangeHandler('<key>', ...)`.

| Statebag | Value | Set when | Read by |
|---|---|---|---|
| `citizenid` | string | login | resources that key off the character id from a statebag |
| `isLoggedIn` | boolean | `true` at login, `false` at logout | ox_inventory, mi-gps |
| `job` | the full job table | login, `SetJob`, `SetJobDuty` | read via PlayerData or the delta events, below |
| `onduty` | boolean | login, and whenever duty or job changes | mi-bossmenu, mi-dispatch, mi-policejob |
| `gang` | the full gang table | login, `SetGang` | read via PlayerData or the delta events |
| `paycheck` | number, the accrued paycheck balance | on accrual and on collect | the paycheck collectors |
| `drunk` | number 0 to 100 | on drink and decay | mi-hud |
| `loadInventory` | `true` | once, at login, after the player object exists | ox_inventory (this is its signal to register the player's inventory) |
| `instance` | number, the routing bucket | on `SetPlayerBucket` | bucket-aware resources |

Two of these are worth calling out because resources depend on them existing:

* **`onduty`.** qbx_core signals duty only through the `QBCore:Client:SetDuty` event, but several mi resources watch the bag directly (mi-bossmenu tracks duty-time sessions, mi-dispatch decides group membership). mi_core mirrors `job.onduty` into a discrete `onduty` bag so those keep working. If more than one resource needs to watch a piece of state, mi_core sets it as a bag even when qbx_core did not.
* **`loadInventory`.** ox_inventory's qbx bridge registers a player's inventory only inside `AddStateBagChangeHandler('loadInventory', ...)`. mi_core sets it once at login, after the player object exists, so the inventory sets up. Without it the player cannot open their inventory.

## GlobalState

Server-wide numbers, replicated to every client. Read with `GlobalState.<key>`.

| Key | Value | Read by |
|---|---|---|
| `PlayerCount` | loaded-player count | mi-hud |
| `PVPEnabled` | PvP on or off, from `rules.pvp` | any resource gating friendly fire |
| `dutyCounts` | `{ [job] = onDutyCount }` for every job | mi-jail |
| `_job:<name>` | on-duty count for one job, for example `GlobalState['_job:police']` | mi-ambulancejob, mi-damages, mi-drugs |

Use these for counts. Do not scan the player map to count on-duty players (see golden rule 8 on the [Server exports](server-exports.md) page). The counters are kept live with plus-or-minus-one bumps on login, duty toggle, job change, and logout.

## Resource statebags

Beyond the core, several mi resources publish their own statebags so the rest of the ecosystem can react to a feature with no export and no network round trip. Each resource's own page documents its bags. This is the combined map. Read them the same way: `Player(source).state.<key>` on the server or `LocalPlayer.state.<key>` on the owning client, and `AddStateBagChangeHandler('<key>', ...)` to react.

Player and vehicle bags:

| Statebag | Scope | Published by | Meaning |
|---|---|---|---|
| `hidehud` | player | any resource (menus, scripted scenes) | While true, mi-hud hides the whole HUD. Set it around a fullscreen NUI or a cutscene, then clear it. |
| `seatbelt` | player | mi-hud | Player is belted. |
| `harness` | player | mi-hud | Player has a race harness on. |
| `vehicleLock` | vehicle | mi-keys (also mi-robbery, mi-policejob) | Lock state of a vehicle. |
| `plate` | vehicle | mi-keys | The visible plate after a fake-plate swap (the key still checks the identity plate). |
| `mi_holster` | player | mi-holster | The player's holster and concealed-carry state. |
| `miJail` | player | mi-jail | Player is serving a sentence. |
| `miSedatedUntil` | player | mi-surgery | Timestamp until which a patient stays sedated. |
| `mcJobStyles` | player | mi-chat | The player's job style (label and color) for chat. |
| `stance` | player | mi-emotes | Current walk or crouch stance. |
| `isInEmote` | player | mi-emotes | Player is playing an emote. |
| `UICustoms` | player | mi-customsgarage | The customs menu is open (used to hold the HUD and camera). |
| `miShop` | player | mi-appearance | Player is inside a clothing shop. |
| `aliasId` | player | mi-allcards | Active fake-identity alias, if any. |
| `isDead` | player | mi-ambulancejob | Player is dead or downed (the medical death contract). |
| `isHandcuffed` | player | mi-policejob | Player is cuffed. Part of the restraint contract (`restraint`, `isBeingDragged`, `isBeingCarried`, `canUseWeapons`). |
| `gsr` | player | mi-policejob | Gunshot residue on the player, read when swabbing for evidence. |
| `miNewPlayer` | player | mi-newplayer | New player is under anti-troll protection. |
| `missing_<organ>` | player | mi-organs | Which organs are missing (for example `missing_kidney`). Read by mi_core needs, mi-hud stress, and medical resources. |
| `miNumber` | player | mi-phone | The player's active phone number. |
| `vehicleid` | vehicle | mi-garage | Database id of a persisted vehicle. Read by the ox_inventory bridge for the trunk and glovebox stash. |
| `persisted` | vehicle | mi-garage, mi_core | Marks a vehicle as saved (persisted) rather than temporary. |

Server-wide bags on `GlobalState`:

| Key | Published by | Meaning |
|---|---|---|
| `miDonateLimited` | mi-donate | Flags a limited-stock donation item. |

## PlayerData sync

When a player's data changes (money, metadata, a job field), the change reaches the owning client as a small delta, not the whole object. This keeps a hunger tick or a money change to about fifty bytes on the wire instead of the roughly two kilobytes of a full PlayerData copy.

What mi_core fires on a change:

* Server side, `QBCore:Player:SetPlayerData` as a local `TriggerEvent` with the whole `PlayerData`. For server resources that listen for it. It does not cross the network.
* To the owning client, the delta only: `qbx_core:client:onUpdatePlayerData(key, value)` for a top-level key, or `qbx_core:client:onSetMetaData(metadata, oldValue, value)` for a metadata branch.

On the client, mi_core applies the delta to its `PlayerData` in place, then re-broadcasts `QBCore:Player:SetPlayerData` locally (no network) so every resource and bridge that already hooks that event keeps firing exactly as before.

So there are two ways to react on the client, both valid:

```lua
-- 1. The classic way. Still works: mi_core re-broadcasts it locally after every delta.
RegisterNetEvent('QBCore:Player:SetPlayerData', function(data)
    -- data is the full, current PlayerData
end)

-- 2. The efficient way. React only to the key you care about.
RegisterNetEvent('qbx_core:client:onUpdatePlayerData', function(key, value)
    if key == 'job' then -- the job changed
    end
end)

RegisterNetEvent('qbx_core:client:onSetMetaData', function(meta, old, value)
    if meta == 'hunger' then -- hunger changed
    end
end)
```

Do not hook `AddEventHandler` for these on the client. They are net events, so use `RegisterNetEvent`.
