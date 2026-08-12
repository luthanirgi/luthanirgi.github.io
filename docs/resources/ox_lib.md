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

## Exports added on top of stock ox_lib

The library API (`lib.callback`, `lib.points`, `lib.zones`, `lib.progressBar`, `lib.notify`, `lib.registerContext`, `lib.locale` and the rest) is unchanged, so [the upstream documentation](https://overextended.dev/ox_lib) applies as written. What this build adds is a handful of plain exports.

**Shared scratch state**, server-authoritative and mirrored to clients:

```lua
exports.ox_lib:setState('heist_active', true)     -- server
local v = exports.ox_lib:getState('heist_active')  -- server or client
```

The server holds the table and pushes changes down; on the client, `getState()` with no key returns the whole table rather than one entry. Clearing a key server-side fires `ox_lib:state:remove`.

**Per-source secure data**, a server-only table keyed by player source, for anything you do not want on a statebag:

```lua
exports.ox_lib:setSecurePlayer(src, data)
local data = exports.ox_lib:getSecurePlayer(src)
```

**Withdrawal callback registry**, client side, with `GlobalState.withdrawal_cb` and `GlobalState.processingWithdrawal` as the shared flags:

```lua
exports.ox_lib:setWithdrawal(key, value)
exports.ox_lib:getWithdrawal(key)      -- omit the key for the whole table
exports.ox_lib:resetWithdrawal(key)    -- omit the key to clear all of them
```

**Locale lookup** for resources that want a translated string without pulling in the whole locale module:

```lua
exports.ox_lib:getLocale('some_key')
```

## Commands

| Command | Does |
|---|---|
| `/ox_lib` | library info |
| `/zone` | zone debug drawing |
| `/cancelprogress` | cancel the active progress bar |
| `/savepersistence` | force a persistence save instead of waiting for the interval |
| `/persiststatus` | report what persistence currently holds |
| `/persistdebug` | verbose persistence logging |

## Rebuilding the web UI

Only needed if you change the React source, not for recolouring:

```bash
cd ox_lib/web
npm install
npm run build
```
