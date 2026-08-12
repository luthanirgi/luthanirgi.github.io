# mi_minigame

Forty single-player minigames behind one export. Any resource that needs a skill check calls `StartMinigame`, waits, and gets back true or false. All forty share one NUI, one difficulty scale, and one accent colour, so a lockpick in your robbery script and a hack in your heist script look like they belong to the same server.

## Try it

<div class="mi-demo" data-src="/demos/mi_minigame/?demo=1" data-title="mi_minigame playable demo" style="--mi-demo-h: 660px">
  <button type="button" class="mi-demo-cover">
    <span class="mi-demo-badge">Playable</span>
    <span class="mi-demo-play">Play all forty, right here</span>
    <span class="mi-demo-sub">This is the resource's real NUI build, the same files that run in game. Pick any game from the panel, change the palette and the difficulty, and play it again to see how the same game scales. Nothing installs and nothing is sent anywhere.</span>
    <span class="mi-demo-full"><a href="/demos/mi_minigame/?demo=1" target="_blank" rel="noopener">or open it fullscreen in a new tab</a></span>
  </button>
</div>

Keyboard games want the click first, since that is what hands the keys to the demo instead of the page.

## Install

```cfg
ensure mi_minigame
```

Depends on ox_lib.

Only ox_lib is needed. No database, no items, nothing to import.

## Using it

One client export. It blocks until the player finishes, so write it inline:

```lua
local ok = exports.mi_minigame:StartMinigame('Lockpick', 'hard')

if ok then
    -- they cracked it
else
    -- they failed or pressed ESC
end
```

| Argument | Type | What it is |
| --- | --- | --- |
| `game` | string | Exact id from the catalogue below, e.g. `Lockpick`, `CylinderAlign`, `AimLab` |
| `difficulty` | string | `easy`, `medium`, `hard`, `veryhard`, `expert`, or `unbelievable`. An unknown name falls back to `Config.defaultDifficulty` |
| `opts` | table | Optional. Overrides individual knobs for this one call, on top of the per-game tuning |

An unknown difficulty falls back rather than erroring, and the resource stopping mid-game resolves the call as a fail instead of stranding NUI focus on the player.

## The catalogue

Forty games in seven groups. The id is what you pass to `StartMinigame`.

| Group | Games |
| --- | --- |
| Locks and entry | `Lockpick`, `LockSpinner`, `KnobTurn`, `CylinderAlign`, `ShimSlide`, `KeycardSwipe` |
| Hacking and data | `HexDecrypt`, `WireCut`, `CircuitTrace`, `FrequencyMatch`, `BinaryFlip`, `PasswordReels`, `KeypadCrack`, `DataDownload` |
| Circuits and mechanical | `BreakerPuzzle`, `PipeJigsaw`, `VoltageBalance`, `FuseSequence`, `GearSync` |
| Memory and pattern | `SymbolMemory`, `PairMatch`, `ChimpGrid`, `PatternPath`, `SafeComboMemory` |
| Puzzle and logic | `MineSweeper`, `ArrowGridMaze`, `SlidePuzzle`, `LightsOut` |
| Reaction and timing | `AimLab`, `ArrowClicker`, `Balance`, `SweetSpot`, `ReactionTap`, `RhythmKeys` |
| Movement and dexterity | `PipeDodge`, `FlappyBird`, `SteadyHand`, `LaserDodge`, `TrackTarget`, `CraneGrab` |

## Config

`shared/config.lua` is the whole resource-wide surface:

```lua
Config = {}

-- Only the accent changes; the obsidian base is baked in. A custom { primary, primaryRgb } works too.
Config.palette  = 'winter_blue'
Config.palettes = {
    obsidian_rouge   = { primary = '#ff3b5c', primaryRgb = '255, 59, 92' },
    winter_blue      = { primary = '#38a6ff', primaryRgb = '56, 166, 255' },
    monochrome       = { primary = '#dfe2e8', primaryRgb = '223, 226, 232' },
    twilight_amber   = { primary = '#ffb020', primaryRgb = '255, 176, 32' },
    ultramarine_navy = { primary = '#4d6bff', primaryRgb = '77, 107, 255' },
}

Config.defaultDifficulty = 'medium' -- used when a caller passes none or an unknown one
Config.allowAbort        = true     -- ESC aborts the game and counts as a fail
Config.sounds            = true     -- tiny WebAudio blips, no asset files

-- The kit. The only way a player reaches the tester.
Config.item = {
    enabled = true,
    name    = 'minigame_kit',       -- must match the entry you paste into ox_inventory
    uses    = 10,                   -- launches per kit; the bar drops 100/uses each time
}

-- Staff way in, with no kit.
Config.adminCommand  = 'minigamedev'
Config.adminRestrict = 'group.admin'  -- ox_lib restricted takes the group principal
```

`shared/games.lua` is the per-game tuning: every game, every difficulty tier, one line each. Omit a game and it uses its built-in defaults; omit one value and only that value falls back. Times are in milliseconds.

```lua
Config.games = {
    -- pins = pins to set | speed = pick sweep | window = shear-line width (deg) | time = ms
    Lockpick = {
        easy         = { pins = 3, speed = 0.8, window = 26, time = 9000 },
        medium       = { pins = 3, speed = 1.0, window = 22, time = 8500 },
        hard         = { pins = 4, speed = 1.3, window = 17, time = 8000 },
        veryhard     = { pins = 5, speed = 1.6, window = 13, time = 7500 },
        expert       = { pins = 6, speed = 2.0, window = 10, time = 7000 },
        unbelievable = { pins = 7, speed = 2.4, window = 7,  time = 6500 },
    },
}
```

Both files are `escrow_ignore`d, so retuning and recolouring never needs a rebuild or an unlocked bundle.

## The kit

Players reach the tester by carrying an item, not by typing anything. Paste `setup/ox-items.lua` into `ox_inventory/data/items.lua` and drop `minigame_kit.png` into `ox_inventory/web/images/`.

Using the kit opens the browser of all forty games. One use is granted per use of the item and spent by the next game you launch, so opening the menu and backing out costs nothing. The durability bar drops by `100 / Config.item.uses` each launch, and the kit breaks and disappears when it empties.

A kit handed out with no metadata counts as full and shows no bar until its first launch. Give it as `AddItem(src, 'minigame_kit', 1, { durability = 100 })` if you want the bar full from the start.

The item is wired through ox_inventory's `server.export` hook, which this resource publishes as `useKit`. That is why the kit needs `consume = 0` in its item definition: without it the use goes to the framework's usable-item registry and the export is never called.

ox_inventory is optional. Without it the kit has no way to be used and the staff command still works, so the resource starts either way.

## Commands

| Command | Access | Does |
| --- | --- | --- |
| `/minigamedev` | staff (`Config.adminRestrict`) | Opens the same browser with no kit and no charge |

There is no player command. The old `/minigame` was a client-side `RegisterCommand`, and a client command cannot be permission-gated at all, so it was open to everyone on the server. The staff one is registered server side through `lib.addCommand`, which can be.

!!! note "It is the group principal, not the bare ace"
    `Config.adminRestrict` is `group.admin`, not `admin`, because that is what ox_lib's `restricted` checks. A bare ace there silently denies every real admin. (A direct `IsPlayerAceAllowed` wants the opposite; [mi_coopminigames](mi_coopminigames.md) makes one and so carries both strings.)

## Co-op

For games two or more players must solve together, see [mi_coopminigames](mi_coopminigames.md). The two are separate resources and neither depends on the other.
