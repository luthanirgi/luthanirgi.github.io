# mi-clothing

mi-clothing is a quick clothing toggle menu shown as a side rail. It lets a player take individual clothing items and props (shirt, jacket, pants, shoes, bag, vest, mask, necklace, hat, glasses, ear, watch, bracelet) on or off, with an optional front camera and a per-item animation.

## Install

```cfg
ensure mi-clothing
```

Depends on ox_lib.

## Config

The general settings live in `shared/config/init.lua`. The per-model slot definitions (which drawable and texture count as "off" for each ped model) live in `shared/config/clothing.lua`, and the UI palette in `shared/config/colors.lua` (pick one of five presets).

```lua
splitTop = 0,            -- 0 merged Top, 1 separate Shirt/Jacket, 2 split for female ped only
disableKeybind = false,
defaultKey = 'K',
command = 'clothing',
commandHelpText = 'Toggle clothing menu',
useCamera = true,        -- front camera on open
useBlur = false,         -- only applies when useCamera
allowInVehicle = false,
showProps = true,        -- hat, glasses, ear, watch, bracelet
hairCommand = false,     -- enable the /hair [id] command
```

`shared/config/bridge.lua` names the resources this one reaches into. `medicalResource` is the medical script consulted before a clothing change (`qbx_medical` by default, which mi-ambulancejob provides; `false` disables the check). The call is guarded, so with no medical resource clothing stays usable. ox_lib and ox_inventory are used directly and are not bridged.

## Commands

| Command | Access | Does |
| --- | --- | --- |
| `/clothing` | everyone | Open or close the clothing menu (also bound to the `K` key by default). |
| `/pants`, `/jacket`, `/shoes`, `/bag`, `/vest`, `/mask`, `/necklace` | everyone | Toggle that clothing component on or off. |
| `/hat`, `/glasses`, `/ear`, `/watch`, `/bracelet` | everyone | Toggle that prop on or off (when `showProps = true`). |
| `/shirt` | everyone | Toggle the shirt on or off (registered when no custom shirt command is set). |
| `/hair [id]` | everyone | Set the hair drawable to `id` (only when `hairCommand = true`). |

The per-item command names come from `shared/config/clothing.lua` and can be changed there.
