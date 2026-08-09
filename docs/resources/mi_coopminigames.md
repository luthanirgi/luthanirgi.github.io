# mi_coopminigames

Thirty minigames that two to six players solve together. Each player gets a different screen, and no screen holds enough to finish alone: one sees the dial, another sees the numbers, and they have to talk. The party either wins together or fails together.

The whole thing is one server export. Your resource decides who is in the party and why, calls it, and gets back a single true or false for the team.

## Try it

A co-op game is hard to judge from a screenshot, because the point is what each player *cannot* see. So the demo shows every seat at once. On a server each of these is a different person's monitor.

<div class="mi-demo wide" data-src="/demos/mi_coopminigames/?demo=1" data-title="mi_coopminigames playable demo" style="--mi-demo-h: 720px">
  <button type="button" class="mi-demo-cover">
    <span class="mi-demo-badge">Playable</span>
    <span class="mi-demo-play">Sit in every seat at once</span>
    <span class="mi-demo-sub">The real NUI build, running the real relay. You hold OP1 and the other seats are bots so a round can finish. Click a seat, or press its number, to move the keyboard there. Read the other panes and you will see why one player alone cannot solve any of these.</span>
    <span class="mi-demo-full"><a href="/demos/mi_coopminigames/?demo=1" target="_blank" rel="noopener">or open it fullscreen in a new tab</a></span>
  </button>
</div>

Six seats need a wide screen. On a laptop, open it fullscreen or drop the party to two.

## Install

```cfg
ensure mi_coopminigames
```

Only ox_lib is needed. There is no database and nothing to import.

[mi_coopdemo](mi_coopdemo.md) is a worked integration you can start next to it: four floor stations, a lobby, and one export call.

## Using it

`StartCoopMinigame` is server side and blocks until the round ends.

```lua
local ok, why = exports.mi_coopminigames:StartCoopMinigame({ src1, src2, src3 }, 'SplitCipher', 'hard')

if ok then
    -- the party cracked it
else
    -- they failed, aborted, or the call was refused; `why` says which
end
```

| Argument | Type | What it is |
| --- | --- | --- |
| `playerIds` | table | Array of server ids. Two to `maxParty`, no duplicates, all online and none already in a session |
| `game` | string | An id from the roster below |
| `opts` | string or table | Difficulty name, or a table of per-call knob overrides |

It fails closed and tells you why rather than dealing a round the party cannot win. `why` comes back as one of `bad arguments`, `party size out of range`, `unknown game`, `<game> needs N+ players`, `<game> takes at most N players`, or `a member is busy or listed twice`.

`GetCoopGames` returns the catalogue, so an integrator can pick a game that fits the party it actually has:

```lua
for _, g in ipairs(exports.mi_coopminigames:GetCoopGames()) do
    print(g.id, g.label, g.cat, g.minParty, g.maxParty)
end
```

## The roster

Thirty games in three families. Every entry takes 2 to 6 players except `TwoKeyTurn`, which needs 3: with only two there is nobody outside the pair to name the target.

| Family | What it demands | Games |
| --- | --- | --- |
| Briefing | You act blind while a teammate reads your page | `BlindSafecracker`, `SplitCipher`, `CoordinateLock`, `RadioSpellout`, `EliminationGrid`, `BlueprintDiff`, `DriftValve`, `ParcelRun`, `ColourConsensus`, `ColdRead` |
| Live Link | Continuous, real-time mutual dependence | `TugEquilibrium`, `MirrorMove`, `DeadReckoning`, `PulseCut`, `CrossPanel`, `DeadmanGate`, `RopeTeam`, `WeightTrim`, `CircuitWeave`, `HotPotato` |
| Lockstep | The moment, the order, the budget | `SyncHold`, `CountdownSlam`, `PressureBalance`, `BucketChain`, `FuseBoard`, `PowerBudget`, `SilentRun`, `CrankSync`, `TwoKeyTurn` (3+), `QuorumVote` |

`shared/config/roster.lua` is the one catalogue the server, the tester, and the NUI all agree on. Delete a line and that game disappears from the tester and is rejected at the export. Nothing else to change.

## Config

`shared/config/config.lua`:

```lua
return {
  palette = 'winter_blue',        -- or a custom { primary = , primaryRgb = }
  palettes = {
    obsidian_rouge   = { primary = '#ff3b5c', primaryRgb = '255, 59, 92' },
    winter_blue      = { primary = '#38a6ff', primaryRgb = '56, 166, 255' },
    monochrome       = { primary = '#dfe2e8', primaryRgb = '223, 226, 232' },
    twilight_amber   = { primary = '#ffb020', primaryRgb = '255, 176, 32' },
    ultramarine_navy = { primary = '#4d6bff', primaryRgb = '77, 107, 255' },
  },
  defaultDifficulty = 'medium',   -- easy | medium | hard | veryhard | expert | unbelievable
  maxParty     = 6,               -- hard cap on party size (the minimum is always 2)
  maxSessionMs = 300000,          -- server-side backstop timeout; the client runs the real game clock
  allowAbort   = true,            -- ESC aborts, and counts as a team fail
  sounds       = true,

  devCommand = true,              -- the /coopmg tester
  devAce     = false,             -- optional ace lock, e.g. 'mi_coopminigames.dev'; false = no ace
  devRadius  = 25.0,              -- metres the tester reaches to scoop up nearby players
}
```

!!! warning "Turn the tester off on a live server"
    `devCommand = true` with `devAce = false` means any player can run `/coopmg` and pull people near them into a round. Set `devCommand = false` before you open the server, or set `devAce` to an ace name and grant it only to your staff.

Per-game tuning is in `shared/config/games.lua`, one block per game per difficulty tier, same shape as [mi_minigame](mi_minigame.md). Both config files are `escrow_ignore`d, so retuning and recolouring needs no rebuild.

## Commands

| Command | Access | Does |
| --- | --- | --- |
| `/coopmg` | everyone, while `devCommand` is on | Browse the roster, pick a game and difficulty, then grab players within `devRadius` |
| `/coopmg <game> [ids...]` | everyone, while `devCommand` is on | Launch one game directly against the listed server ids |

The server rejects a bad party before dealing it and pushes the reason back to the tester, so a refusal says why instead of looking like nothing happened.

## How a session works

The server deals one session with a shared seed and a slot number per player, then waits. Each client renders its own slot from that seed, so what a player sees is derived locally and never carried over the wire. Only signals cross the network, never content: a relay forwards a value to the next or previous player in the ring, capped to primitives and one level of table, so no game can leak the answer to the person who is supposed to ask for it.

A session ends on a team win, a fail, an abort, or the `maxSessionMs` backstop, whichever comes first.
