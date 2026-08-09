# mi-redeem

A redeem-code system with a React admin dashboard. Players redeem a code with `/redeem` for item, money, or vehicle rewards; admins create, edit, revoke, and bulk-generate codes from the dashboard.

## Install

```cfg
ensure mi-redeem
```

It ships server/migrate.lua, so tables auto-create on first boot, no manual SQL import.

## Config

Edit `shared/config/settings.lua`:

```lua
return {
    commands = {
        redeem = 'redeem',        -- player: /redeem <code>
        admin  = 'redeemadmin',   -- admin: opens the dashboard
    },
    adminAce = 'group.admin',        -- ace permission required for admin actions
    redeemCooldown = 5,              -- seconds between a player's redeem attempts
    vehicleGarage = 'premiumgarage', -- where vehicle rewards are parked
    bulk = {
        maxPerBatch = 500,           -- hard cap on codes created in one bulk generate
        codeLength = 6,              -- random body length for auto-generated codes
    },
}
```

Reward kinds (item, money with cash/bank accounts, vehicle) are in `shared/config/rewards.lua`. The NUI palette is in `shared/config/theme.lua` (obsidian_rouge | winter_blue | monochrome | twilight_amber | ultramarine_navy). Optional Discord webhooks (`codeCreated`, `codeRedeemed`) are in `config/apiKeys.lua`, blank by default. Every player-facing line the resource can print is in `shared/config/strings.lua`, so translating it is one file.

## Exports

| Export | Signature | What it does |
| --- | --- | --- |
| CreateCode (server) | `exports['mi-redeem']:CreateCode(def)` | Creates a redeem code from another resource. `def` = `{ code, rewards, label?, maxUses?, expiresAt?, createdBy? }`. Returns `ok, codeOrError`. |

## Commands

| Command | Access | Does |
| --- | --- | --- |
| `/redeem <code>` | everyone | Redeems a code for its rewards (command name set by config `commands.redeem`). |
| `/redeemadmin` | group.admin (config `adminAce`) | Opens the redeem admin dashboard (command name set by config `commands.admin`). |
