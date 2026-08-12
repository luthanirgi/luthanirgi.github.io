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

Depends on ox_lib.

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
  allowAbort   = true,            -- ESC aborts, and counts as a team fail
  sounds       = true,

  -- The clock the party plays against, one row per tier. Longer is easier. It is pushed to every
  -- game as its `time`, so this is the one place that sets how long a co-op round lasts. The server
  -- backstop sits 30s past it and can never cut a game short.
  sessionMs = {
    easy = 600000, medium = 540000, hard = 480000,
    veryhard = 420000, expert = 360000, unbelievable = 300000,
  },

  -- The kit. The only way a player reaches the tester.
  item = {
    enabled = true,
    name    = 'coop_minigame_kit', -- must match the entry you paste into ox_inventory
    uses    = 8,                   -- rounds per kit; the bar drops 100/uses each time
  },

  -- Staff way in, with no kit. Two ace strings because they are checked by different things.
  adminCommand  = 'coopmgdev',
  adminRestrict = 'group.admin',  -- ox_lib restricted takes the group principal
  adminAce      = 'admin',        -- a direct IsPlayerAceAllowed takes the bare ace

  partyRadius = 25.0,             -- metres the tester reaches to scoop up nearby players
}
```

Per-game tuning is in `shared/config/games.lua`, one block per game per difficulty tier, same shape as [mi_minigame](mi_minigame.md). Both config files are `escrow_ignore`d, so retuning and recolouring needs no rebuild.

## The kit

Players reach the tester by carrying an item, not by typing anything. Paste `setup/ox-items.lua` into `ox_inventory/data/items.lua` and drop `coop_minigame_kit.png` into `ox_inventory/web/images/`.

Using the kit opens the roster. Picking a game gathers everyone standing within `partyRadius` and deals the round. **Only the op who starts it pays**, which is the point: one person brings the job and the rest just have to be there. A use is spent when a round is actually dealt, so browsing and backing out costs nothing.

Whether a round costs a kit is decided server side, never by the client, so firing the event by hand still pays and staff still do not.

A kit handed out with no metadata counts as full and shows no bar until its first round. Give it as `AddItem(src, 'coop_minigame_kit', 1, { durability = 100 })` if you want the bar full from the start.

ox_inventory is optional. Without it the kit has no way to be used and the staff command still works, so the resource starts either way.

## Commands

| Command | Access | Does |
| --- | --- | --- |
| `/coopmgdev` | staff (`adminRestrict`) | Opens the same roster with no kit and no charge |

There is no player command. The old `/coopmg` was a client-side `RegisterCommand`, and a client command cannot be permission-gated at all, so it was open to everyone whenever `devCommand` was left on. The staff one is registered server side through `lib.addCommand`, which can be.

The server rejects a bad party before dealing it and pushes the reason back to the tester, so a refusal says why instead of looking like nothing happened. A refused party is not charged.

!!! note "Two ace strings, on purpose"
    `adminRestrict` is the group principal (`group.admin`) because that is what ox_lib's `restricted` checks. `adminAce` is the bare ace (`admin`) because that is what a direct `IsPlayerAceAllowed` checks. Swapping them silently denies every real admin.

## How a session works

The server deals one session with a shared seed and a slot number per player, then waits. Each client renders its own slot from that seed, so what a player sees is derived locally and never carried over the wire. Only signals cross the network, never content: a relay forwards a value to the next or previous player in the ring, capped to primitives and one level of table, so no game can leak the answer to the person who is supposed to ask for it.

A session ends on a team win, a fail, an abort, or the server backstop, whichever comes first. The backstop sits 30 seconds past the tier's `sessionMs`, so it can only ever catch a session nothing else closed.
