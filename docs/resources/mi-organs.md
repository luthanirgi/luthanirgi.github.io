# mi-organs

Black-market organ harvesting and transplants. A downed or restrained victim can have organs cut out with the right tool through ox_target, the organs become inventory items, surgeons transplant them back, and harvested organs sell at a black-market fence.

## Install

```cfg
ensure mi-organs
```

Depends on ox_lib, ox_inventory and ox_target.

State lives in player metadata, so there are no database tables to import.

## Config

The organ registry (`shared/config/organs.lua`) defines each organ's harvest tool, duration, item, and metadata keys. The metadata key names are a live cross-resource contract (read by mi_core, mi-hud, and mi-ambulancejob), so edit values, not key names.

```lua
-- shared/config/organs.lua (the organ registry)
heart = {                        -- unsided, removing it is lethal
    label = 'Heart', tool = 'surgical_scissors', seconds = 60,
    item = 'human_heart', key = 'missing_heart',
    lethal = true, blocksRevive = true,   -- victim cannot be revived until transplanted back
},
kidney = {                       -- sided (left/right)
    label = 'Kidney', tool = 'surgical_scissors', seconds = 60,
    item = 'human_kidney', sided = true,
    counterKey = 'missing_kidney',
    leftKey = 'missing_left_kidney', rightKey = 'missing_right_kidney',
},
-- liver, eye, hand, and fingers follow the same shape (fingers use max = 5, requiresHand = true)
```

Who may operate, and the gate that requires a victim to be incapacitated:

```lua
-- shared/config/access.lua
surgeons = {          -- job or gang name -> minimum grade (harvest and transplant)
    ambulance = 0,    -- EMS: transplants
    godfathers = 0,   -- black-market harvesters
},
examiners = {         -- who may read a patient's medical report
    ambulance = 0,
},
gate = {              -- the victim must be incapacitated to be harvested
    allowWhenDowned = true,       -- dead or in last stand (read from mi-ambulancejob, guarded)
    allowWhenRestrained = true,   -- handcuffed or restrained
    restrainedStatebags = { 'isHandcuffed', 'handcuffed', 'isCuffed' },  -- first present wins
},
restoreSeconds = 60,       -- transplant-back duration (no incapacitation needed)
operationCooldown = 5,     -- seconds a surgeon waits between operations
maxLabelLength = 32,       -- max length of the donor label typed onto an organ
```

The black-market fence (set `enabled = false` to ship no ped and drive selling from your own resource through the export):

```lua
-- shared/config/market.lua
enabled = true,
ped = {                    -- edit coords for your map (placeholder near Cypress Flats)
    model = 's_m_y_dealer_01',
    coords = vec4(970.14, -2160.32, 30.52, 175.0),
    scenario = 'WORLD_HUMAN_DRUG_DEALER',
    blip = false,          -- set a sprite id to show one
},
sellers = { godfathers = 0 },   -- job/gang -> min grade; {} lets anyone sell
prices = {                 -- payout per item (keys are the organ item names)
    human_heart = 25000, human_liver = 15000, human_kidney = 12000,
    human_eyes = 8000, severed_hand = 5000, severed_finger = 1200,
},
payTo = 'cash',            -- 'cash' (ox_inventory money item) or 'bank'
haggle = { min = 0.85, max = 1.15 },   -- server-rolled price multiplier per sale
```

The surgery NUI colours are picked in `shared/config/palettes.lua` and applied at runtime, so re-skinning needs no web rebuild:

```lua
local PALETTE = 'winter_blue'
-- 'obsidian_rouge' | 'winter_blue' | 'monochrome' | 'twilight_amber' | 'ultramarine_navy'
```

## Exports

| Export | Signature | What it does |
| --- | --- | --- |
| `SellOrgans` | `exports['mi-organs']:SellOrgans(src)` | Sells every harvested organ the player is carrying at the fence. The price is rolled server-side and each stack must carry valid-organ metadata (a spawned or duped plain item is worth nothing). Returns `sold, total`. |

## Statebags

Each organ's `missing_*` key is mirrored from player metadata onto a replicated player statebag, so injury effects survive a relog and other resources read organ state without an export.

| Statebag | Scope | Set when | Read by |
| --- | --- | --- | --- |
| `missing_<organ>` (for example `missing_heart`, `missing_kidney`, `missing_left_kidney`, `missing_right_kidney`, `missing_liver`, `missing_eyes`) | player | On character load, on resource restart, and whenever an organ is harvested or transplanted back. The key names come from the organ registry in `shared/config/organs.lua`. | mi_core (`missing_kidney` and `missing_liver` drive the thirst and hunger debuffs), mi-hud (`missing_eyes` raises stress), mi-ambulancejob (`missing_heart` blocks reviving), and this resource's own UI and harvest checks. |

See the [state reference](../mi_core/reference/state.md) for the core statebags and GlobalState.
