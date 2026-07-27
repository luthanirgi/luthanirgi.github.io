# mi-jail

Prison system with jail, PD lockup, and community service, run from a React Warden Console (the Prison MDT). It includes group work details, commissary crafting, cell search, escape methods, and ankle-monitor/GPS trackers, with each sentence stored as an absolute expiry that is pushed to the client once and counted down locally.

## Install

```cfg
ensure mi-jail
```

It ships server/migrate.lua, so tables auto-create on first boot, no manual SQL import.

## Config

Edit `shared/config.lua`. The main owner tunables:

```lua
return {
    debug = false,

    -- Currency item used inside prison (commissary / ped trades).
    commissaryItem = 'jail_cigarette',
    -- Item that opens the Prison MDT for officers.
    mdtItem = 'prison_mdt',

    -- Keep counting the sentence while the player is offline?
    -- false (default) freezes remaining time on disconnect and resumes on join.
    passTimeOffline = { jail = false, lockup = false, service = false },

    -- Take the player's items on jail and hold them until they reclaim.
    takeItems = { jail = false, lockup = false, service = false },
    itemsToNotReturn = {}, -- [itemName] = true, confiscated for good

    -- ACE group treated as admin (the only teleport path).
    adminAce = 'group.admin',

    -- Jobs allowed per officer action, written as job = minimum grade.
    police = {
        jail    = { police = 0, doc = 0, doj = 0 }, -- jail / lockup / assign service
        adjust  = { police = 0, doc = 0 },          -- shorten / extend a sentence
        release = { police = 3, doc = 3 },          -- release early
        mdt     = { police = 0, doc = 0, doj = 0 }, -- open the Warden console
    },

    -- Theme: a preset key, or a custom { primary = '#RRGGBB', primaryRgb = 'r, g, b' }.
    palette = 'winter_blue',

    -- Community service: a sentence served outside prison (collect trash bags).
    service = {
        enable = true,
        defaultBags = 15,       -- quota the officer modal starts on
        timeCapMinutes = 45,    -- safety cap before release
        collectSeconds = 5,     -- progress-bar duration per bag
        supervisorJobs = { 'police', 'doc' }, -- who gets the "left the zone" alert
        strayRadius = 60.0,     -- metres before a stray alert fires
    },

    -- Cell search (server rolls the loot; cooldown enforced server-side).
    search = { cooldownMinutes = 5, findChance = 50 },

    -- Escape methods, each validated server-side (item held, min police online).
    escape = {
        enable = true,
        alertJobs = { 'police', 'doc' }, -- who receives the jailbreak dispatch
    },

    -- Trackers: police ankle monitor (job-scoped) + badside GPS tracker (owner-scoped).
    trackers = {
        enable = true,
        relaySeconds = 5, -- how often an owner's client refreshes positions
        maxPerOwner = 8,  -- targets one owner may track at once
        fitDistance = 3.0,
    },

    -- Discord log toggles (the webhook url lives in server/apiKeys.lua).
    log = { jail = true, release = true, escape = true, service = true },

    -- Prison and lockup geography, work-detail spots, commissary recipes, escape
    -- points, mission peds and the jail uniform also live in this file.
}
```

## Exports

| Export | Signature | What it does |
| --- | --- | --- |
| IsJailed (server) | `exports['mi-jail']:IsJailed(cid)` | Returns true if that citizen id is currently jailed. |
| GetSentence (server) | `exports['mi-jail']:GetSentence(cid)` | Returns `{ type, remaining, service }` for a jailed citizen id, or nil. |
| JailPlayer (server) | `exports['mi-jail']:JailPlayer(targetSrc, opts)` | Jails a player. `opts` = `{ type, minutes, reason, jailedBy }`. |
| ReleasePlayer (server) | `exports['mi-jail']:ReleasePlayer(cid, reason)` | Releases a jailed citizen id. |
| IsTracked (server) | `exports['mi-jail']:IsTracked(cid, side)` | True if the citizen id carries a tracker on `side` ('police' or 'badside'). |
| openWardenMdt (client) | `exports['mi-jail']:openWardenMdt()` | Opens the Warden console NUI with the current inmate roster. |

## Commands

| Command | Access | Does |
| --- | --- | --- |
| `/jail [id] [minutes] [reason]` | police/doc/doj (config `police.jail`) | Jails a player and sends them to prison. |
| `/lockup [id] [minutes]` | police/doc/doj (config `police.jail`) | Puts a player in a PD holding cell for a short sentence. |
| `/unjail [id]` | police/doc grade 3 (config `police.release`) | Releases a jailed player early. |
| `/jailmenu` | everyone (F6) | Opens the inmate prison terminal while serving a sentence. |
| `/jailmdt` | everyone | Opens the Warden console; the roster only returns to authorised officers. |
| `/trackers` | everyone | Opens the tracker UI for your side (police monitors or badside GPS). |

## Statebags

mi-jail publishes one player statebag and reads one core `GlobalState` counter.

| Statebag | Scope | Set when | Read by |
| --- | --- | --- | --- |
| `miJail` | player | set on jail or lockup to `{ type, exp }` (the sentence type and its absolute expiry), cleared on release | the sentenced player's own client (drives the local countdown) and any resource checking jail status |
| `dutyCounts` | global | the core keeps per-job on-duty counts live | mi-jail (the escape gate counts on-duty officers before allowing a break) |

See the [state reference](../mi_core/reference/state.md) for the core statebags and GlobalState.
