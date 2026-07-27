# mi-allcards

mi-allcards is an identity and documents system with a React wallet. It issues ID cards and licenses, runs vehicle registration (STNK) and a civil registry (marriage, divorce, household), supports fake IDs and disguises, and does real name changes. Built on qbx_core and kept low-DB for 2000 players.

## Install

```cfg
ensure mi-allcards
```

Dependencies (oxmysql, ox_lib, qbx_core, ox_inventory) are standard; `/onesync` is a server policy, not a resource to ensure. It ships server/migrate.lua, so its tables auto-create on first boot, no manual SQL import.

## Config

Top-level knobs (`shared/config/init.lua`):

```lua
local Config = {
    walletItem    = 'wallet', -- ox_inventory item that opens the wallet on use
    walletCommand = 'wallet', -- chat command to open the wallet
    walletKeybind = nil,      -- e.g. 'F7' (nil = no keybind)

    idCardSettings = {
        closeKey  = 'Backspace',
        autoClose = { status = false, time = 3000 },
    },

    rateLimit = {
        read  = { 30, 10000 }, -- wallet/list/tab fetches
        write = { 8, 10000 },  -- issue/renew/marry/forge/etc
    },

    cache = {
        walletTtl    = 30000, -- per-player wallet card list
        vehiclesTtl  = 60000, -- owned-vehicles lookup for STNK
        householdTtl = 60000, -- marriage/household lookups
    },
}
```

Civil registry and samsat (`shared/config/registry.lua`):

```lua
return {
    officeCoords    = vec3(-540.0, -204.0, 38.2), -- civil registry / samsat desk
    marriageJob     = 'government', -- '' = any nearby player may officiate
    samsatJob       = 'government', -- '' = self-serve vehicle registration
    maxGiveDistance = 3.0,
    divorceCommand  = 'divorce',
}
```

Name change (`shared/config/namechange.lua`). Consumes one item and rewrites real charinfo:

```lua
return {
    item = 'name_change', -- consumed only on a successful change

    fields = { -- set any to false to lock that field server-wide
        firstname = true, lastname = true, gender = true,
        birthdate = true, nationality = true,
    },

    badWords = { 'fart', 'bitch', 'fuck', 'kontol', 'nigger', 'admin', 'server' },

    logging = { webhook = '', username = 'mi-allcards Name Change' }, -- paste your own webhook
}
```

The card and license catalogue, badges, the photo booth, the fake-ID quiz, and disguise data live in the other `shared/config/*.lua` modules (`cards.lua`, `badges.lua`, `booth.lua`, `fakeid.lua`, `quiz.lua`), which are larger data tables.

## Exports

All server-side unless noted. Other resources verify cards, read identity, and issue documents through these.

| Export | Signature | What it does |
| --- | --- | --- |
| HasCard | `HasCard(src, cardType, opts)` | True if the player holds a valid card of that type. `opts.mustBeGenuine` rejects fakes |
| HasValidLicense | `HasValidLicense(src, licenseKey, opts)` | True if the player holds a valid license |
| GetCard | `GetCard(src, cardType, opts)` | The card metadata, or nil |
| GetMetaLicense | `GetMetaLicense(src, itemTable)` | Read a license item's metadata |
| CreateMetaLicense | `CreateMetaLicense(src, itemTable)` | Issue a real license item |
| CreateFakeMetaLicense | `CreateFakeMetaLicense(src, itemTable, fakeinfo)` | Issue a forged license |
| CreateIdCardFromMugshot / CreateCardFromMugshot | `(src, cardType, options)` | Issue an ID card using the player's mugshot |
| GetMaritalStatus | `GetMaritalStatus(src)` | Returns 'single', 'married', or 'divorced' |
| GetMaritalLabel | `GetMaritalLabel(src)` | Returns 'Single', 'Married', or 'Divorced' |
| GetSpouse | `GetSpouse(src)` | The player's married partner |
| GetHousehold | `GetHousehold(src)` | The player's household record |
| IssueStnk | `IssueStnk(src, plate)` | Issue a vehicle registration (STNK) for a plate |
| GetEffectiveIdentity | `GetEffectiveIdentity(src)` | The identity a disguised player currently presents |
| IsDisguised | `IsDisguised(src)` | True while a disguise persona is active |
| SetDisguise | `SetDisguise(src, persona)` | Apply a disguise persona |
| GetDisplayName (client) | `GetDisplayName(serverId)` | The effective display name for a player (honours disguise) |

## Commands

| Command | Access | Does |
| --- | --- | --- |
| `/wallet` | everyone | Open the ID wallet UI |
| `/divorce` | everyone | File for divorce from the civil registry |

Both command names are configurable (`Config.walletCommand`, `Config.registry.divorceCommand`).

## Statebags

The resource publishes two replicated player statebags, one for disguises and one for the ID booth.

| Statebag | Scope | Set when | Read by |
| --- | --- | --- | --- |
| `aliasId` | player | Set to `{ name, cid }` when a disguise persona is applied (`SetDisguise`), cleared to `nil` when the disguise is removed. | Any resource that should show a disguised player's presented name and fake id instead of their real identity. |
| `inIdCardZone` | player | Set `true` while the player stands in the ID card booth zone, `false` on exit. | Any resource that gates an action to the ID booth area. |

See the [state reference](../mi_core/reference/state.md) for the core statebags and GlobalState.
