# mi-scenetool

A builder tool for placing GTA synchronized scenes and capturing their coordinates. Browse 1506 catalogued scenes, play one live and looping in the world, move it into position with the keyboard, and press Enter to get a paste-ready Lua block holding the world transform of every ped and object in it.

This is a tool for whoever builds your map and your jobs, not a player-facing resource. Nothing about it touches the economy or the database.

## Install

```cfg
ensure mi-scenetool
```

Depends on ox_lib.

Only ox_lib is needed. There is no database, no inventory item, and no NUI the player ever sees.

## Config

`shared/config/main.lua`:

```lua
return {
    command    = 'scenetool',
    restricted = 'group.admin', -- lib.addCommand gate

    -- Cycled per actor slot. Scenes go up to 9 actors; the list wraps, so any length works.
    actorModels = {
        'mp_m_freemode_01',
        'mp_f_freemode_01',
        'a_m_y_genstreet_02',
        'a_f_y_business_02',
    },

    -- Some scenes are written for an animal. Matched on the scene name.
    animalModel   = 'a_c_rottweiler',
    animalKeyword = 'with dog',

    step    = { ultra = 0.01, fine = 0.05, coarse = 0.25 },
    yawStep = 2.0,

    spawnDistance = 3.0, -- how far in front of you a scene first appears
    precision     = 4,   -- decimal places in the emitted snippet

    -- The catalogue's deltaZ values are offsets from a ped-root anchor about a metre above
    -- the ground, not from the ground itself. Scenes are placed at groundZ + this + deltaZ.
    -- Raise it if scenes sit low across the board, lower it if they float.
    sceneAnchorHeight = 1.0,
}
```

NUI colours are in `shared/config/palettes.lua` (one of the five presets). Both config files sit outside the escrow boundary and stay editable.

## Using it

`/scenetool` opens the browser. The rail lists every scene, type to search, click a category chip to narrow, click a star to favourite.

| Key | Action |
| --- | --- |
| ↑ ↓ | Walk the list. Whatever you land on is acted out in the world straight away, so you can hold the key and watch the catalogue go by. |
| Enter | Place the scene you are on |

The preview waits for the selection to settle before it spawns, so running down the list does not try to load every scene you pass through. **Bring here** re-anchors the running preview to where you are standing now; it moves the scene rather than restarting it, so the animation carries on in front of you.

**Play and place** hands the keyboard to the scene:

| Key | Action |
| --- | --- |
| ↑ ↓ ← → | Move, relative to where the camera is facing |
| PageUp / PageDown | Raise / lower |
| Q / E | Rotate the whole scene |
| Shift / Alt | Coarse (0.25) / ultra-fine (0.01) step, instead of the default 0.05 |
| G | Snap to ground |
| Space | Pause the animation to capture an exact pose |
| Enter | Capture, prints to F8 and copies to the clipboard |
| Backspace | Cancel |

Movement applies one step per frame while a key is held, so tap for precision and hold for travel. A single tap is always exactly one step whatever your framerate.

## Output

Each capture gives both absolute world coordinates and offsets relative to the scene origin:

```lua
-- Pimp demands money  ·  Aggressive interaction  ·  phase 0.42
{
    scene  = { dict = "mini@prostitutespimp_demands_money", name = "Pimp demands money",
               category = "Aggressive interaction", phase = 0.420 },
    origin = vec4(150.2300, -1040.1100, 29.3700, 342.0000),
    peds = {
        { model  = "mp_m_freemode_01",
          anim   = { dict = "mini@prostitutespimp_demands_money", clip = "pimp_demands_money_pimp" },
          coords = vec4(150.5100, -1040.4400, 29.3700, 341.2000),
          offset = vec4(0.1200, -0.4400, 0.0000, 359.2000) },
    },
    objects = {
        { model  = "prop_cash_pile_02",
          anim   = { dict = "mini@prostitutespimp_demands_money", clip = "pimp_demands_money_cash" },
          coords = vec4(150.4400, -1040.0200, 29.9400, 12.0000),
          offset = vec4(0.2100, 0.0900, 0.5700, 30.0000) },
    },
}
```

Use `coords` to spawn at that exact spot. Use `offset` if you want to re-anchor the whole tableau somewhere else later: offsets are relative to `origin`, so they stay valid when the scene moves.

Transforms are read at the phase showing on screen when you press Enter, so pausing with Space first lets you pick an exact pose. The phase is emitted alongside so the capture is reproducible.

## Commands

| Command | Access | Does |
| --- | --- | --- |
| `/scenetool` | group.admin | Opens the scene browser |

Both the name and the permission come from `shared/config/main.lua`.

## What to expect from the catalogue

`data/scenes.json` is third-party data and is not perfectly clean:

* 40 scenes have no actors (object-only setpieces), and 407 have no objects.
* 5 object records carry an animation but no model (scene ids 248 and 524 to 527). Those props are skipped rather than spawned.
* The largest cast is 9 actors. `actorModels` wraps, so models repeat on big scenes. That is expected.
* `deltaZ` is an offset, not a height. It was authored against an anchor at the player entity's Z, roughly a metre above the ground, which is why `-1` appears on 541 of the 1506 scenes and `0` on another 332. Scenes are placed at `groundZ + sceneAnchorHeight + deltaZ`. With the default `sceneAnchorHeight = 1.0` the `-1` group lands exactly on the ground and the `0` group a metre above it, which is what those values were written to mean.
* About 120 scenes still end up below ground, because their `deltaZ` is genuinely large and negative (36 sit at `-3.98`). Those were authored for elevated anchors, rooftops and vehicles, and PageUp is faster than inferring the right height from the data.

## Credits

The scene catalogue in `data/scenes.json` is derived from the MIT-licensed "Synchronised Scenes Tester" by D7mad, sourced from the Scene Director animation lists on GTA5-Mods. See the resource's `LICENSE`.
