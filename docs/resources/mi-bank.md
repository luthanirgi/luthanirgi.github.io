# mi-bank

A bank with a React UI. Players deposit, withdraw and transfer money, see recent statements, and (optionally) take loans. Jobs and gangs get shared office/society funds. It opens at bank blips and at ATM props.

## Install

```cfg
ensure mi-bank
```

Depends on ox_lib.

It ships `server/migrate.lua`, so its tables auto-create on first boot, no manual SQL import.

Money and player data come from the core through the framework bridge (`shared/config/bridge.lua`, `exports.qbx_core` by default). Bank and ATM prompts use `ox_target`.

## Config

The owner-editable settings live in `shared/config/*.lua`.

`shared/config/init.lua`:

```lua
-- recent statements shown per open (slim payload)
statementLimit = 5,

-- personal statement retention: clear bank_statements older than N days
statementCleanup = {
    enabled       = true,
    cron          = '0 5 * * *',   -- daily 05:00
    retentionDays = 3,
},

-- money guard: reject any single amount over this
maxAmount = 100000000,

-- office/society funds for jobs and gangs
society = { enabled = true },

-- ATM props that open the ATM screen, and the bank blip
atmModels = { 'prop_atm_01', 'prop_atm_02', 'prop_atm_03', 'prop_fleeca_atm', -1352984963 },
blipInfo  = { name = 'Bank', sprite = 108, color = 2, scale = 0.55 },

-- extra standalone ATM zones (vec3 list)
atmZones = { vec3(1282.3588, -2429.5552, 51.2833) },

-- in-memory cache TTLs in ms (GetGameTimer based)
cache = {
    statementsTtl = 300000,  -- 5 min
    societyTtl    = 60000,   -- 1 min
    loanTtl       = 60000,   -- 1 min
    officeLogTtl  = 60000,   -- 1 min
},
```

Bank blip/zone coordinates are the `vec3` list in `shared/config/locations.lua`.

Loans are off by default. Turn them on and set the plans in `shared/config/loan.lua`:

```lua
return {
    enabled   = false,
    minAmount = 1000,
    maxAmount = 100000,             -- fixed plafond
    plans     = {                   -- interest rises with the term
        { weeks = 4,  rate = 0.05 },
        { weeks = 8,  rate = 0.10 },
        { weeks = 12, rate = 0.18 },
    },
    weekSecs  = 7 * 24 * 60 * 60,   -- one installment cadence
    scanCron  = '0 4 * * *',        -- daily scan; per-loan due via next_due_ts
}
```

Office/society authorization is derived from the player object, not configured here: a boss job (`job.isboss == true`) wins, otherwise a bank-authorized gang grade (`gang.grades[grade].bankAuth == true`).

UI colours are in `shared/config/colors.lua`. Pick one preset (`winter_blue` by default) from `obsidian_rouge`, `winter_blue`, `monochrome`, `twilight_amber`, `ultramarine_navy`. The palette is applied to the NUI at runtime, so a re-skin needs no web rebuild.

## Exports

Server exports for reading and moving job/gang society (office) funds. `kind` is `'job'` or `'gang'`, `org` is the job or gang name.

| Export | Signature | What it does |
|---|---|---|
| `GetSociety` | `GetSociety(kind, org)` | returns the org's society balance (0 if missing) |
| `AddSociety` | `AddSociety(kind, org, amount, reason)` | adds `amount` to the org's fund, returns `true` on success |
| `RemoveSociety` | `RemoveSociety(kind, org, amount, reason)` | subtracts `amount` from the org's fund, returns `true` on success |

```lua
local balance = exports['mi-bank']:GetSociety('job', 'police')
exports['mi-bank']:AddSociety('gang', 'ballas', 5000, 'drug sale')
```
