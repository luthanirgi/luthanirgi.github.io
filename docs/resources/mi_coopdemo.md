# mi_coopdemo

A worked integration of [mi_coopminigames](mi_coopminigames.md). Four marked spots on the ground, a lobby that fills and counts down, one export call, and an optional payout on a team win.

Start it to see the co-op games running end to end, then read `client/main.lua` and `server/main.lua`: they are short on purpose, and they are the template for wiring the co-op games into a heist, a job, or anything else that gathers a party first.

## Install

```cfg
ensure mi_coopminigames
ensure mi_coopdemo
```

Needs ox_lib, ox_target, and mi_coopminigames. The reward path calls the core through a guarded `pcall`, so there is no hard core dependency: leave `reward.enabled` off and it never touches money at all.

## How the lobby runs

1. Players stand on the marked stations. One station is one seat.
2. Once `minPlayers` are standing, a `startDelay` countdown begins. More can still join while it runs, and a full set of stations launches immediately.
3. A game is picked at random from the `games` pool and dealt to everyone standing.
4. On a team win, `reward` pays out if it is enabled. Either way the stations lock for `cooldown` before the lobby reopens.

`GlobalState.coopdemoBusy` is true while a session is live, which is what stops a second lobby forming on top of the first.

## Config

The whole resource is one file, `shared/config/init.lua`:

```lua
return {
  -- Stations players stand on; N points => up to N players (2..6). Replace with coords in your world.
  points = {
    vec3(198.0, -932.0, 30.69),
    vec3(198.0, -938.0, 30.69),
    vec3(192.0, -932.0, 30.69),
    vec3(192.0, -938.0, 30.69),
  },

  minPlayers = 2,        -- stations filled before the countdown starts
  startDelay = 8000,     -- ms countdown after minPlayers is reached (full = launch now)
  difficulty = 'medium', -- easy | medium | hard | veryhard | expert | unbelievable

  -- Pool picked from at launch. Ids come from mi_coopminigames/shared/config/roster.lua, and the
  -- export rejects anything not in it. An empty table means "any game in the roster".
  games = { 'BlindSafecracker', 'SplitCipher', 'CoordinateLock', --[[ ... ]] },

  cooldown = 12000,      -- ms the stations stay locked after a game ends

  adminAce    = 'mi_coopdemo.admin', -- ace that may run /coopstart
  adminRadius = 20.0,                -- metres /coopstart reaches to scoop up nearby players

  marker = { type = 1, size = vec3(1.4, 1.4, 0.5), rgba = { 255, 59, 92, 120 } },

  -- Optional payout on a team win, paid via the core. Off by default and guarded.
  reward = { enabled = false, account = 'cash', amount = 500 },
}
```

Mind `minParty` when you edit the pool. `TwoKeyTurn` needs three players, so it is left out of the shipped list because this lobby opens at two. Add it if you raise `minPlayers` to 3 or more.

## Commands

| Command | Access | Does |
| --- | --- | --- |
| `/coopstart [game]` | `mi_coopdemo.admin` ace | Grabs yourself plus the nearest players within `adminRadius` and launches now, bypassing the stations |

The ace is checked on the server, not the client, so the command does nothing for a player without it. Grant it in `permissions.cfg`:

```cfg
add_ace group.admin mi_coopdemo.admin allow
```

## Statebags

| Statebag | Scope | Set when | Read by |
| --- | --- | --- | --- |
| `coopdemoBusy` | global (GlobalState) | True from the moment a session is dealt until the cooldown ends. | mi_coopdemo client (refuses a second lobby or a second `/coopstart` while one is running) |

See the [state reference](../mi_core/reference/state.md) for the core statebags and GlobalState.
