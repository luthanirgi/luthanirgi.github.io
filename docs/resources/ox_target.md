# ox_target

The mi build of ox_target. The targeting itself is stock ox, so `addBoxZone`, `addSphereZone`, `addEntity`, `addModel`, `addGlobalPlayer`, `addGlobalVehicle` and every other export behave exactly as upstream, and any resource that registers options keeps working unchanged. What changed is that the reticle and the options panel are recoloured from the same palette system the rest of the mi suite uses.

It stays open source under the MIT licence, the same as upstream ox_target.

## Install

```cfg
ensure ox_target
```

Depends on ox_lib. Load it after ox_lib and before the resources that register targets.

## Theming

The reticle and the options panel are recoloured without touching the web build. Pick a preset with a convar in `server.cfg`:

```cfg
setr mi:target_palette obsidian_rouge
# obsidian_rouge | winter_blue | monochrome | twilight_amber | ultramarine_navy
```

The default is `winter_blue`. The presets are plain hex tables in `data/theme.lua`, so a custom look means editing one of them or adding your own key and pointing the convar at it:

```lua
obsidian_rouge = {
    bg = '#0a0a0d', surface = '#16131c', slot = '#100e15', border = '#2a2431',
    primary = '#c0392b', primaryText = '#ffffff',
    text = '#ecebef', textMuted = '#8b8496',
},
```

If the convar names a preset that does not exist, it falls back to `obsidian_rouge` rather than rendering uncoloured.

Set it alongside the other two so every shared UI matches:

```cfg
setr mi:lib_palette    obsidian_rouge
setr mi:inv_palette    obsidian_rouge
setr mi:target_palette obsidian_rouge
```

## Config

Everything else is stock ox_target and keeps its upstream shape, including the interaction distance, the debug options, and the default player and vehicle options in `data/`.

## Rebuilding the web UI

Only needed if you change the React source, not for recolouring:

```bash
cd ox_target/web
npm install
npm run build
```
