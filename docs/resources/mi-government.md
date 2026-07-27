# mi-government

A city government layer: citizen taxation (wealth, vehicle, property), per-job fiscal policy, a treasury view, community polls, and elections. It stores no money itself; tax bills, subsidies, and the treasury total route through mi-billing's ledger.

## Install

```cfg
ensure mi-government
```

Needs OneSync enabled. Tax bills, subsidies, and the treasury total go through mi-billing, so ensure mi-billing is running too. It ships `server/migrate.lua`, so its tables auto-create on first boot, no manual SQL import.

## Config

Owner-editable settings live in `shared/config/*.lua`.

`shared/config/access.lua` (who may do what, plus rate limits and cache TTLs):

```lua
viewGrade   = { '5','6','7','8','9','10','11','12' }, -- government grades that can read the console
manageGrade = { '11', '12' },                        -- grades that can change policy / pay subsidies
job = 'government',
rateLimit = { read = { 20, 10000 }, write = { 6, 10000 } }, -- per player, per 10s
cache = { treasuryTtl = 60000, financeTtl = 600000 },
drain = { intervalMs = 10000, perTick = 5 },         -- the server-wide tax drain timer
auditPurgeDays = 30,
```

`shared/config/tax.lua` (default citizen tax policy; a `mi_gov_policy` row overrides any of it):

```lua
maxBacklogPeriods = 2,       -- cap on elapsed periods billed at once
minTaxableMoney   = 500000,  -- below this (cash + bank) a citizen owes no vehicle/property tax
wealth   = { enabled = true, interval = 1209600, cap = 150000, tiers = { ... } }, -- 2-week wealth tax
vehicle  = { enabled = true, interval = 2592000, perUnit = 1500 },   -- monthly, per vehicle
property = { enabled = true, interval = 2592000, perUnit = 15000 },  -- monthly, per property
exempt    = {},        -- citizenids exempt from all citizen tax (manage via the exempt policy row)
exemptVip = true,      -- active VIPs are exempt
senderJob  = 'government',
senderName = 'Tax Department',
```

`shared/config/fiscal.lua` (per-job tax rate and subsidy; `default` covers any job with no row):

```lua
default   = { taxRate = 5, subsidy = 0 },
police    = { taxRate = 5, subsidy = 0 },
ambulance = { taxRate = 5, subsidy = 0 },
mechanic  = { taxRate = 5, subsidy = 0 },
```

`shared/config/civic.lua` (poll and election defaults):

```lua
poll = { maxOptions = 8, minOptions = 2, maxQuestionChars = 140,
         maxOptionChars = 60, maxMinutes = 60, defaultMinutes = 10 },
election = {
    office        = { job = 'government', grade = 12 }, -- winner takes this job and grade
    termDays      = 14,
    maxCandidates = 8,
    minCharacterAgeDays = 0,   -- 0 = any character may vote
},
```

UI colours are in `shared/config/theme.lua`, chosen with the `mi:government_palette` convar (`obsidian_rouge` default; also `winter_blue`, `monochrome`, `twilight_amber`, `ultramarine_navy`).

## Exports

Server exports for other resources. The money paths route through mi-billing.

| Export | Signature | What it does |
|---|---|---|
| `ReportIncome` | `ReportIncome(job, amount, opts?)` | books reported income for a job through mi-billing, taking the city's cut; returns `{ success, error?, billId? }` |
| `PaySubsidy` | `PaySubsidy(job, amount, opts?)` | pays a city subsidy to a job and books the matching city expense; returns `{ success, error? }` |
| `GetTreasury` | `GetTreasury()` | returns the city treasury snapshot (citizens, cash, bank, supply, brackets) |
| `IsExempt` | `IsExempt(citizenid)` | returns whether a citizen is on the tax-exempt policy list |

## Commands

| Command | Access | Does |
|---|---|---|
| `/cityhall` | government job | open the City Hall console (treasury, finance, policy; tabs gate by grade) |
| `/townhall` | everyone | open the citizen surface (polls and the election ballot) |
