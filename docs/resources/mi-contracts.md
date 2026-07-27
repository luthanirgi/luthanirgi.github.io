# mi-contracts

mi-contracts is a React NUI tablet for a contracts and jobs marketplace. Operators post contracts and missions to a board, members submit proof for review, and the tablet runs a Credits economy (an exchange, transfers, and a catalog with orders) backed one to one by an ox_inventory item.

## Install

```cfg
ensure mi-contracts
```

It ships `server/migrate.lua`, so tables auto-create on first boot, no manual SQL import.

## Config

The main settings live in `shared/config/settings.lua`. External secrets live in `config/apiKeys.lua` (the optional FiveManage token for screenshot uploads, blank by default, or set the `mi_contracts_fivemanage_token` convar). The UI palette lives in `shared/config/theme.lua` (pick one of five presets).

```lua
-- The tablet opens from the world access point (ox_target) or the exports
-- OpenTablet / OpenCoinVault. Leave OpenCommand empty to disable the chat command.
OpenCommand = '',
Keybind = '',
AccessKeyCommand = 'contractskey',     -- console/admin: mint access keys
ForgotCommand = 'contractsforgot',     -- in-game: reset your own password

-- Who counts as an operator (the leadership tier that assigns/reviews contracts
-- and runs the market). A player matches if ANY rule below applies. The internal
-- flag is named `Underground` for backward compatibility; the UI label is "Operator".
Underground = {
    gangs = {
        godfathers = { minGrade = 14, maxGrade = 17 },
    },
    jobs = {},
    aces = {},
},

-- Bootstrap the very first operator with no access key, then clear these.
BootstrapCitizenIds = {},
BootstrapUsernames = {},

-- Account credential rules
UsernameMinLength = 3,
UsernameMaxLength = 24,
PasswordMinLength = 4,
PasswordMaxLength = 64,

-- Input limits (the server clamps every field; more Max* limits follow in settings.lua)
MaxMissionNameLength = 120,
MaxMissionDescriptionLength = 2000,

-- Credits: the tablet currency, backed 1:1 by an ox_inventory item so members can
-- carry it out of the tablet (the exchange converts between the two). The item id is
-- kept as `black_coin` for economy/crafting compatibility; its inventory label is "Credits".
CoinItemName = 'black_coin',

-- World access point(s) for the Credit Exchange. A lazy ped spawns on proximity
-- and carries an ox_target option. Add more entries for more locations.
CoinVaultAccess = {
    { coords = vec4(342.1903, -1663.5967, 26.3240, 53.4863), radius = 1.75, drawDistance = 12.0, label = 'Credit Exchange' },
},

-- Device identity shown in the tablet header.
Locale = {
    tabletTitle = 'Contracts',
    tabletSubtitle = 'Jobs and market',
},
```

## Exports

Both exports are client-side.

| Export | Signature | What it does |
| --- | --- | --- |
| OpenTablet | `exports['mi-contracts']:OpenTablet()` | Opens the contracts tablet NUI for the player. |
| OpenCoinVault | `exports['mi-contracts']:OpenCoinVault()` | Opens the Credit Exchange view. |

## Commands

| Command | Access | Does |
| --- | --- | --- |
| `/contractskey [amount]` | `group.admin` | Mint Contracts access keys (default 1, max 20). |
| `/contractsforgot <username> <password>` | everyone | Reset your own tablet password (must match your citizen ID). |
