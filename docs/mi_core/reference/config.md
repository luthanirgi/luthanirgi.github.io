# Config

All server-owner settings live in one file, `shared/config.lua`. It `return`s a plain table, so you edit values in place and restart. This file stays open and editable even when mi_core ships under escrow. Job and gang definitions live next to it in `shared/jobs.lua` and `shared/gangs.lua`.

Here is the whole file. Everything the core reads is on this page, nothing is hidden behind a table of key names.

```lua
-- mi_core - shared/config.lua - server-owner settings. Stays open/editable under escrow.
return {
    defaultSpawn = vec4(-1035.71, -2731.87, 12.86, 0.0),

    -- Pause-menu map title (top-left of the ESC map).
    pauseMapTitle = 'Mi Project',

    rules = {
        pvp                 = true,          -- friendly-fire on for loaded players
        locked              = false,         -- /closeserver whitelists-only; /openserver reopens
        lockedReason        = 'The server is currently closed.',
        whitelistPermission = 'admin',       -- ace group allowed in while locked
    },

    economy = {
        -- account -> starting amount. Add/remove accounts freely (e.g. crypto = 0, blackmoney = 0).
        accounts = { cash = 500, bank = 5000 },
        -- accounts that can never drop below 0.
        disallowNegative = { cash = true, crypto = true },
        paycheckIntervalMinutes = 7,
    },

    player = {
        hungerDecayRate = 4,
        thirstDecayRate = 5,
        bloodGroups = { 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-' },
        defaultLicences = { id = false, driver = false, weapon = false, hunting = false },
    },

    multichar = {
        defaultSlots = 3,
        deleteConfirm = true,
    },

    -- Items granted to a brand-new character (ox_inventory). { name, amount, metadata? }.
    spawnKit = {
        -- { name = 'phone', amount = 1 },
    },

    -- Rows wiped when a character is deleted, each as { table, column-holding-the-citizenid }.
    -- Deleting a character removes its row from every table here plus the players row, all in one
    -- transaction. Any table not present in your database is skipped, so unused lines are harmless.
    -- 'players' is always removed last (listing it here is optional, the delete handles it either way).
    characterCleanupTables = {
        { 'bank_accounts_new',        'id' },
        { 'playerskins',              'citizenid' },
        { 'player_mails',             'citizenid' },
        { 'player_outfits',           'citizenid' },
        { 'player_vehicles',          'citizenid' },
        { 'player_groups',            'citizenid' },
        { 'players',                  'citizenid' },
        { 'antitroll_time',           'identifier' },
        { 'bank_statements',          'citizenid' },
        { 'dx_camera',                'identifier' },
        { 'lunar_contracts_profiles', 'identifier' },
        { 'player_transactions',      'id' },
        { 'qbx_fishing',              'user_identifier' },
        { 'qbx_locker',               'user' },
        { 'racing_racers',            'identifier' },
        -- Phone tables live in mi-phone now (mi_phone_*). Add any you want wiped on delete, e.g:
        -- { 'mi_phone_numbers', 'citizenid' },
    },

    -- Optional: donation-asset refund on character delete. OFF by default. With it off, deleting a
    -- character wipes the characterCleanupTables rows above plus the players row. Turn it on for a
    -- server that wants players to
    -- carry donor assets (a whitelisted vehicle, a custom SIM, an owned house, a donation-ledger
    -- row) onto a NEW character after deleting the old one. Every table/column below names one of
    -- YOUR resources' tables; mi_core writes them straight into SQL (a bind `?` cannot stand in for
    -- a table or column name), so keep them to trusted values from THIS file only. The two
    -- bookkeeping tables mi_core owns are in sql/donation_refund.sql -- import that once when you
    -- enable this. See server/donation.lua for the logic. Full guide in the docs (Donation refund).
    donationRefund = {
        enabled = false,
        command = 'refunddonate', -- players run this on the NEW character to reclaim donor assets

        schema = {
            -- A vehicle counts as a donation when its model hash is listed in donationModels.
            vehicles = {
                table = 'player_vehicles',
                owner = 'citizenid',           -- column linking a vehicle to a character
                plate = 'plate',
                hash  = 'hash',
                resetOnTransfer = { 'glovebox', 'trunk' }, -- columns cleared when a car changes owner
                donationModels = {             -- add your donor vehicle model hashes here, e.g:
                    -- `issisp`, `schlafer`, `mesaxl`,
                },
            },
            -- A SIM counts as a donation when it does NOT match the normal system-number format
            -- (a systemPrefixes prefix + systemLength digits). Custom donor numbers fall outside it.
            sims = {
                table  = 'yphone_sim_cards',
                owner  = 'phone_imei',         -- column linking a SIM to a character
                number = 'sim_number',
                systemPrefixes = { '11', '22', '33', '44', '55', '66', '77', '88', '99', '21', '57', '89' },
                systemLength   = 6,            -- digit count after the 2-char prefix
            },
            houses = {
                table = 'house_owned',
                owner = 'owner',
            },
            donation = {                       -- a generic donation ledger keyed by character
                table = 'donation',
                owner = 'citizenid',
            },
            -- Owned by mi_core (sql/donation_refund.sql), keyed by license so a deleted character's
            -- donor assets can be reclaimed on a new character later. Leave these as-is.
            deletedAccounts = {
                table        = 'deleted_donation_accounts',
                license      = 'license2',
                oldCitizenid = 'old_citizenid',
                sim          = 'donation_sim',
            },
            claims = {
                table        = 'donation_claims',
                license      = 'license2',
                oldCitizenid = 'old_citizenid',
                newCitizenid = 'new_citizenid',
            },
        },
    },

    logging = { enabled = false },
}
```

## The sections, in short

* `defaultSpawn` and `pauseMapTitle`: where a character with no saved position spawns, and the label on the ESC map.
* `rules`: PvP on or off, and the locked-server settings. `whitelistPermission` is the ACE group that still gets in while the server is locked with `/closeserver`.
* `economy`: the accounts every character starts with, which accounts can never go negative, and how often paychecks pay out. Add an account by adding a key to `accounts` (for example `crypto = 0`).
* `player`: hunger and thirst decay rates, the blood groups a new character can roll, and which licences a new character starts with.
* `multichar`: character slots per player, and whether deleting a character asks for confirmation.
* `spawnKit`: ox_inventory items handed to a brand-new character. Empty by default.
* `characterCleanupTables`: every table row wiped when a character is deleted, alongside the `players` row, in one transaction. A table not in your database is skipped, so extra lines are harmless. Add a line for any resource that keys rows by citizenid or identifier.
* `donationRefund`: an optional feature, off by default. See the [Donation refund guide](../guides/donation-refund.md) for the full walkthrough.
* `logging`: turn core Discord logging on or off.

## Jobs and gangs

Job and gang definitions are their own files, `shared/jobs.lua` and `shared/gangs.lua`, each a table keyed by job or gang name with grades, labels, and pay. See the [Jobs and gangs guide](../guides/jobs-and-gangs.md).

## Convars

A few knobs live on convars so you can set them per server without editing files. mi_core reads the `mi:*` name first, then falls back to the `qbx:*` name, so an existing qbx server keeps working.

| Convar | Default | What it does |
|---|---|---|
| `mi:enablequeue` | `true` | connection queue on or off |
| `mi:enableVehiclePersistence` | `false` | keep spawned vehicles across restarts |
| `mi:bucketlockdownmode` | `inactive` | routing-bucket lockdown mode |
| `mi:motd` | empty | message shown on join |

Set one in `server.cfg`:

```cfg
setr mi:enablequeue true
```
