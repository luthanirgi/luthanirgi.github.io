# mi-elevator

mi-elevator turns fixed map points into multi-floor lifts opened through ox_target, with a React floor-picker NUI. Access can be gated per lift and per floor by job or gang grade and by inventory items.

## Install

```cfg
ensure mi-elevator
```

## Config

General settings live in `shared/config/settings.lua`:

```lua
return {
    defaultLocale = 'en',   -- fallback locale; switch with `setr ox:locale id`
    targetRadius  = 1.5,    -- ox_target sphere radius (metres) per interaction point

    -- How a ride plays out on the client
    travel = {
        useFade    = true,   -- black-screen fade over the teleport
        fadeTime   = 500,    -- ms for fade out / in
        playAnim   = true,   -- play the elevator idle animation during the ride
        travelTime = 1200,   -- ms the ride takes (also the NUI cab-glide duration)
        anim       = { dict = 'anim@apt_trans@elevator', clip = 'elev_1' },
    },

    -- Optional arrival bell (needs InteractSound started; guarded)
    sound = { enabled = false, name = 'LiftSoundBellRing', volume = 0.4 },
}
```

Lifts themselves are defined in `shared/config/elevators.lua`. Each entry looks like:

```lua
{
    label = 'Police HQ', sublabel = 'Staff only',
    access = { groups = { police = 0 } },       -- omit for a public lift
    locations = { vec3(x, y, z), ... },          -- ox_target points that open the lift
    floors = {                                   -- ordered, top floor is index 1
        { label = 'Chief Office', sub = 'Command', coords = vec4(x, y, z, heading),
          access = { groups = { police = 3 } } },-- optional, locks this one floor
        { label = 'Lobby', sub = 'Reception', coords = vec4(x, y, z, heading) },
    },
}
```

Access options: `groups` maps a job or gang to a minimum grade, `items` lists required items, `mode` is `'or'` or `'and'` for how groups and items combine, `anyItem = true` accepts any one listed item, and `consume = true` spends the item on each ride.
