# ox_lib

The mi build of ox_lib. Every module is stock ox, so `lib.callback`, `lib.points`, `lib.zones`, `lib.progressBar`, `lib.notify`, `lib.registerContext`, the locale system and the rest of the API behave exactly as upstream, and any resource written against ox_lib keeps working unchanged. What changed is that its NUI is themed by the same palette system the rest of the mi suite uses, plus one added helper.

It stays open source under the LGPL, the same licence as upstream ox_lib.

## Install

```cfg
ensure ox_lib
```

No resource dependencies, but it needs OneSync. Load it first, before everything that requires it.

Resources require it the standard way, in their `fxmanifest.lua`:

```lua
shared_script '@ox_lib/init.lua'
```

## Theming

The menus, dialogs, notifications, progress bars and context menus that ox_lib draws are recoloured from a palette chosen in config, pushed as `--mi-*` CSS variables when the NUI initialises. No web rebuild is needed to change colours.

Pick a preset with a convar in `server.cfg`:

```cfg
setr mi:lib_palette obsidian_rouge
# obsidian_rouge | winter_blue | monochrome | twilight_amber | ultramarine_navy
```

The default is `winter_blue`. The presets live in `resource/interface/client/theme.lua`, and a fully custom look is a matter of editing the hexes there or adding your own key:

```lua
obsidian_rouge = {
    bg = '#0a0a0d', surface = '#16131a', slot = '#100e13', elevated = '#201b26',
    border = '#2a2630', primary = '#c0392b', primaryText = '#f2ecee',
    text = '#e8e6ea', textMuted = '#86838c',
},
```

Roles you leave out fall back to the CSS defaults baked into the build, so a partial palette still renders correctly.

Because ox_inventory and ox_target carry the same five presets under their own convars, setting all three to the same key gives one consistent look across every shared UI on the server:

```cfg
setr mi:lib_palette    obsidian_rouge
setr mi:inv_palette    obsidian_rouge
setr mi:target_palette obsidian_rouge
```

## Reading the palette from Lua

The chosen palette is exposed so your own resources can match it without duplicating the hexes:

```lua
local theme = lib.getMiTheme()
print(theme.primary)     --> '#c0392b' when the convar is obsidian_rouge
```

It returns the table for whatever `mi:lib_palette` is set to, falling back to `obsidian_rouge` if the convar names a preset that does not exist.

## Rebuilding the web UI

Only needed if you change the React source, not for recolouring:

```bash
cd ox_lib/web
npm install
npm run build
```
