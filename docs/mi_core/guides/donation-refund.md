# Donation refund

Some servers let a player carry their donation assets to a new character after a delete. mi_core ships this as an optional feature. It is off by default, so a plain install just deletes a character cleanly.

When it is on, deleting a character preserves the assets that count as donations (whitelisted vehicles, a donation SIM, an owned house, a row in a donation ledger) and records them against the player's license. Later, on a new character, the player runs a command to claim those assets back.

## Turn it on

Open `shared/config.lua`, find the `donationRefund` block, and set `enabled` to `true`.

```lua
donationRefund = {
    enabled = true,
    command = 'refunddonasi',
    schema = { ... },   -- see below
},
```

Import the two tables mi_core owns for this feature. They are already in `sql/mi_core.sql`.

```
deleted_donation_accounts
donation_claims
```

## Point it at your tables

The feature reads from your own resources: your garage, your phone, your housing, your donation script. Every table and column name is config, because no two servers store these the same way. mi_core writes the table names straight into its queries, so keep them to trusted values in this file.

```lua
schema = {
    -- Donation vehicles are matched by hash against whitelistVehicles above.
    vehicles = {
        table = 'player_vehicles',
        owner = 'citizenid',
        plate = 'plate',
        hash  = 'hash',
        resetOnTransfer = { 'glovebox', 'trunk' },
    },
    sims = {
        table  = 'yphone_sim_cards',
        owner  = 'phone_imei',
        number = 'sim_number',
    },
    houses = {
        table = 'house_owned',
        owner = 'owner',
    },
    donation = {
        table = 'donation',
        owner = 'citizenid',
    },
    -- These two belong to mi_core and match sql/mi_core.sql.
    deletedAccounts = {
        table = 'deleted_donation_accounts',
        license = 'license2',
        oldCitizenid = 'old_citizenid',
        sim = 'donation_sim',
    },
    claims = {
        table = 'donation_claims',
        license = 'license2',
        oldCitizenid = 'old_citizenid',
        newCitizenid = 'new_citizenid',
    },
},
```

Change the `table` and column values to match your database. If your garage stores the owner in a column called `owner` instead of `citizenid`, set `vehicles.owner = 'owner'` and you are done. No core edits.

## Which vehicles count as donations

A vehicle counts as a donation when its model hash is in `whitelistVehicles` in the same config file. Fill that list with the hashes of the cars you gave to donors.

```lua
whitelistVehicles = {
    `issisp`,
    `schlafer`,
    -- ...
},
```

## Which SIMs count as donations

A SIM counts as a donation when it does not match the normal system number format. That format is defined by `phoneNumberPrefixes` and `phoneNumberLength`, which you already set for regular phone numbers. Custom donor numbers fall outside that pattern and are treated as donations.

## How a claim works

1. A player deletes a character. Their donation assets are preserved and logged against their license.
2. On a new character, the player runs `/refunddonasi`.
3. The feature moves the preserved vehicles, house, donation rows, and SIM to the new character.
4. The claim is recorded, so the same license cannot claim twice.

## If you leave it off

Nothing about deletion changes. mi_core removes the character's rows from every table in `characterCleanupTables` and deletes the player row, all in one transaction. The donation tables sit empty and harmless.
