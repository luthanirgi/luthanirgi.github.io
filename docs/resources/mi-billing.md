# mi-billing

A billing tablet with a React UI. Company staff send bills to citizens, citizens pay or dispute them, and bosses see income, withdraw commission, run collections, and approve large force-payments. It is DB-cached for large player counts.

## Install

```cfg
ensure mi-billing
```

Depends on ox_lib, oxmysql and qbx_core or mi_core.

It ships `server/migrate.lua`, so its tables auto-create on first boot, no manual SQL import.

Player and money data come from the core through the framework bridge (`shared/config/bridge.lua`, `exports.qbx_core` by default). OneSync must be on.

## Config

Owner-editable settings live in `shared/config/*.lua`.

`shared/config/init.lua`:

```lua
command = 'billing',   -- chat command that opens the tablet
keybind = nil,         -- optional key mapping for that command

-- player-facing language. Loads locales/<locale>.json for the Lua
-- notifications and the UI copy. Ships 'en' and 'id'; missing keys fall
-- back to English, so a partial translation is safe.
locale = 'en',

maxBillDistance = 10.0,   -- how close the target must be to receive a bill

rateLimit = {
    read  = { 20, 10000 },   -- dashboard / list reads: 20 per 10s
    write = { 6,  10000 },   -- send / pay / cancel / withdraw: 6 per 10s
},

cache = {
    dashboardTtl  = 60000,   -- 60s
    billsTtl      = 30000,   -- 30s
    incomeTtl     = 60000,   -- 60s
    withdrawalTtl = 60000,   -- 60s
},

purgePaidAfterDays = 30,        -- delete settled bills after N days

shadowTaxRate = 5,              -- extra percent accrued to tax on taxed bills

forcePayApprovalThreshold = 300000,   -- force-pays above this need approval
```

`shared/config/jobs.lua` sets per-job billing rules. Each entry is built by the `job(commission, base, overrides)` helper, where `commission` is the percent the company keeps, `base` is the default grade list, and the optional third table restricts individual capabilities (`send`, `manage`/`forcePay`, `withdraw`, `view`, `collections`, `approve`):

```lua
police     = job(95, { '5' }, { forcePay = true, collections = true }),
mechanic   = job(95, { '3', '4' }),
government  = job(75, { '11', '12' }, {
    manage      = { '5', '6', '7', '8', '9', '10', '11', '12' },
    collections = true,
}),
```

A job must exist in this table for its staff to bill or for the export API to accept it.

UI colours are in `shared/config/theme.lua`. Pick one preset (`winter_blue` by default) from `obsidian_rouge`, `winter_blue`, `monochrome`, `twilight_amber`, `ultramarine_navy`. The palette is pushed to the NUI at runtime, so a re-skin needs no web rebuild.

## Exports

Server exports for other resources to raise bills and record income against a job.

| Export | Signature | What it does |
|---|---|---|
| `CreateBill` | `CreateBill(opts)` | issues a bill from a job to a player, optionally force-collecting it |
| `AddIncome` | `AddIncome(opts)` | books settled income into a job's withdrawable pool (nobody is billed) |
| `SetGovernmentTax` | `SetGovernmentTax(job, percent)` | overrides a job's government tax rate at runtime (`nil` clears it) |
| `GetJobIncome` | `GetJobIncome(job)` | returns a job's derived income totals |

`CreateBill(opts)` fields: `senderJob` (required, must be in `Config.Jobs`), `amount` (required, > 0), `paymentType` (`'cash'` or `'bank'`, required), `target` (required, server id number or citizenid string), and optional `force` (auto-collect), `senderName`, `description`, `tax` (percent override), `commission` (percent override). Returns `{ success = true, billId = N, paid = bool }` or `{ success = false, error = '...' }`.

```lua
local res = exports['mi-billing']:CreateBill({
    senderJob   = 'mechanic',
    target      = source,
    amount      = 1500,
    paymentType = 'bank',
    description = 'Engine repair',
})
```

`AddIncome(opts)` fields: `job` (required, in `Config.Jobs`), `amount` (required, non-zero, negative books an expense), and optional `description`, `byName`, `tax` (percent), `paymentType` (`'cash'` default or `'bank'`). Returns `{ success = true, billId = N }` or `{ success = false, error = '...' }`.

## Commands

| Command | Access | Does |
|---|---|---|
| `/billing` | everyone | opens the billing tablet (the UI itself gates each tab by the caller's job and grade) |

The command name comes from `Config.command`. Set `Config.keybind` to also bind a key.
