# mi-racingsystem

Racing system with a React tablet UI: track creation, scheduled and manual competitions, time attack and practice ghosts, racing crews, and ELO ranking. It keeps the standard public race exports so existing callers keep working.

## Install

```cfg
ensure mi-racingsystem
```

Requires OneSync enabled. It ships server/migrate.lua, so tables auto-create on first boot, no manual SQL import.

## Config

Config is split across `shared/config/*.lua` and aggregated by `init.lua`. The framework core is repointed in `bridge.lua`; secrets (Discord webhooks, FiveManage token, extra admin identifiers) live in `server/apiKeys.lua`, never sent to clients. The most-edited settings:

```lua
-- shared/config/bridge.lua: the framework swap-point.
return { core = exports.qbx_core } -- e.g. exports['qb-core']
```

```lua
-- shared/config/shared.lua: cross-side tunables.
leaderboardMode = 'gap',        -- 'gap' (+03.542) or 'cp' (current checkpoint number)
practiceEnabled = true,         -- solo vs personal ghost replay
timeAttackEnabled = true,       -- solo vs champion ghost per track
```

```lua
-- shared/config/server.lua: competitions, rewards, restrictions, admin, crews (excerpt).
competitionMinMoneyPerMinute = 10,    -- prize pool per minute of race
competitionMaxMoneyPerMinute = 50,
competitionTicketItem = 'racingticket',   -- item reward for top finishers ('' disables)
prizeMoneyDistribution = 'NORMAL',    -- 'EVEN' | 'NORMAL' | 'TOP'
competitionSchedule = {               -- when the auto-generator runs (real server-machine time)
    { generationHour = 20, generationMinute = 0, startHour = 21, startMinute = 0 },
},
adminPrincipal = 'group.support',     -- ACE principal granted 'racing.admin' (false disables)
adminIdentifiers = {},                -- extra admin citizenids (blanked in the sale copy)
isTrackCreationRestricted = false,    -- true = only listed identifiers / a min rating can build tracks
isCompetitionCreationRestricted = false,
freezeDuration = 5,                   -- countdown seconds players are frozen before the start
phasingEnabled = true,                -- ghosting / no collisions during races
phasingMode = 'ALL',                  -- 'ALL' | 'COMPETITION' | 'NORMAL'
vehicleClasses = { 'B', 'A', 'S', 'S+', 'S++' },
crewCreateRequiredGang = 'underground', crewCreateRequiredGrade = 3, crewMaxMembers = 12,
-- (ELO rank tiers, daily-reward loot pool, and class luck weights are large tables in this file.)
```

```lua
-- shared/config/client.lua: checkpoints, sounds, 3D marker, track-creation keybinds (excerpt).
commandsEnabled = false,   -- enable the /racing command (disable if the tablet is an inventory item)
joinProximity = 120,       -- metres a player can see and join a 3D race-join prompt
joinKeybind = 51,          -- key to join a race (51 = E)
checkpointRadius = 5.0, checkpointHeight = 15.0, checkpointProximity = 25.0,
checkpointSoundEnabled = true, finishSoundEnabled = true, countdownSoundEnabled = true,
-- (The floating 3D route marker, checkpoint styles, and placeable track objects are also here.)
```

The palette is chosen in `shared/config/theme.lua` (`theme.resolve()` feeds the NUI CSS variables).

## Exports

| Export | Signature | What it does |
| --- | --- | --- |
| openRacingTablet (client) | `exports['mi-racingsystem']:openRacingTablet()` | Opens the racing tablet NUI for the calling player. |

The manifest also declares the race-control server exports (`startRaceByTrackId`, `joinRaceById`, `joinRaceByIdPassenger`, `leaveRaceByRaceId`, `getTrackStartCoordsById`, `onFinished`, `removeOnFinished`) for drop-in compatibility. The resource also provides `mi_racing`.

## Commands

| Command | Access | Does |
| --- | --- | --- |
| `/racing` | everyone | Opens the racing tablet. |
