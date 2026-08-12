# ox_inventory

The mi build of ox_inventory. The plumbing is stock ox, so slots, item metadata, stashes, shops, vehicle storage, evidence and every export behave exactly as upstream and any resource written against ox_inventory keeps working. What changed is the presentation and the crafting: a Framed Cards layout, a palette you pick without rebuilding the web, crafting that runs while you walk away, and the backpack as a real third grid.

It stays open source under the GPL, the same licence as upstream ox_inventory.

## Install

```cfg
ensure ox_inventory
```

Depends on ox_lib and oxmysql, and needs OneSync. Load it after ox_lib and before the resources that use it.

Its tables come from upstream ox_inventory, so an existing install needs no migration.

## Layout

The UI is built from `.mi-card` sections, each with an elevated header bar carrying an icon chip, a title, a subtitle and a weight meter.

* **Left column** stacks the hotbar (slots 1 to 5), the pocket grid, and the backpack grid when one is open. The pocket hides slots 1 to 5 because those are the hotbar.
* **Right column** is the secondary inventory: a stash, a trunk, a shop, or the crafting bench.
* **Use / Give / amount** sit fixed at the bottom centre, outside the column wrapper.

Grids use a max height rather than a fixed one, so a short inventory like a backpack is only as tall as its rows. Rarity borders on slots are unchanged from stock.

## Crafting

Crafting is asynchronous and consumes nothing until you claim it.

1. Pick a recipe and a quantity, then press **CRAFT**. That queues one batch job with a single shared timer for the whole batch.
2. Walk away. The job lives in server memory keyed by the inventory owner, so it survives closing the bench and relogging.
3. Come back and press **CLAIM**. Ingredients are taken and items granted at that moment, one by one.

Because nothing is consumed at queue time, queueing can never lose items and a server restart costs you nothing but the timer. If you run out of space or ingredients partway through a claim, the remainder stays claimable instead of vanishing. Jobs can also be cancelled outright.

Two caps guard against abuse, in `modules/crafting/server.lua`:

```lua
local CRAFT_JOB_LIMIT   = 10    -- queued jobs per bench
local CRAFT_COUNT_LIMIT = 100   -- items per job
```

Recipes are defined in `data/crafting.lua`, per bench:

```lua
{
    name = "dongle",
    ingredients = { iron = 15 },
    duration = 20000,           -- ms per item; a batch of 5 waits 5 * this
    count = 1,
    metadata = { adminspawn = 'CIV' },
},
```

## Backpack

A backpack item shows as a summary card in the left column while it is closed. Opening it draws it as a real, draggable third grid in the left column, and dragging between pocket and backpack goes through the stock item-move path, so there is no separate move logic to trust.

One limitation worth knowing before you build around it: ox opens one secondary inventory at a time, so an open backpack and an open trunk are mutually exclusive. You cannot have both grids on screen at once.

## Theming

Colours come from `data/mi_theme.lua` and are pushed to the NUI at runtime, so recolouring never needs a web rebuild. Pick a preset with a convar in `server.cfg`:

```cfg
setr mi:inv_palette obsidian_rouge
# obsidian_rouge | winter_blue | monochrome | twilight_amber | ultramarine_navy
```

The default is `winter_blue`. For a custom look, edit the hexes of a preset in `data/mi_theme.lua` or add your own key and point the convar at it:

```lua
obsidian_rouge = {
    bg = '#0a0a0d', surface = '#16131a', slot = '#100e13', elevated = '#201b26',
    border = '#2a2630', primary = '#c0392b', primaryText = '#f2ecee',
    text = '#e8e6ea', textMuted = '#86838c',
},
```

Each role maps to a `--mi-*` CSS variable in the NUI. Any role you leave out falls back to the obsidian default baked into the build, so a partial palette still renders correctly.

## Config

The rest of the data files are stock ox and keep their upstream shape:

| File | Holds |
|---|---|
| `data/items.lua` | item definitions |
| `data/crafting.lua` | crafting benches and recipes |
| `data/shops.lua` | shops |
| `data/stashes.lua` | stashes |
| `data/vehicles.lua` | vehicle storage sizes |
| `data/weapons.lua` | weapons, ammo, components |
| `data/licenses.lua` | licences sold at shops |
| `data/evidence.lua` | evidence types |
| `data/animations.lua` | use animations |
| `data/mi_theme.lua` | the palette above |

Resources in the mi suite that add their own items ship a paste-in fragment at `<resource>/setup/ox-items.lua`. Paste those entries into `data/items.lua` and drop the matching PNGs into `web/images/`.

## Rebuilding the web UI

Only needed if you change the React source, not for recolouring:

```bash
cd ox_inventory/web
npm install
npm run build
```

The game loads `web/build`, so a UI change only ships after a rebuild.
