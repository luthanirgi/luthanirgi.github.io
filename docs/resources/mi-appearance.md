# mi-appearance

mi-appearance is a character appearance editor, export-compatible with illenium-appearance. It provides the customization NUI plus clothing, barber, tattoo, and plastic-surgeon shops, saved outfits, job and gang uniforms, and the HalfPed head/hands/pants module.

## Install

```cfg
ensure mi-appearance
```

Depends on ox_lib, ox_target, oxmysql and qbx_core or mi_core.

Dependencies (ox_lib, oxmysql, mi_core, ox_target) are standard. It ships `server/migrate.lua`, so its tables auto-create on first boot, no manual SQL import. It registers the illenium-appearance export names, so resources that call `exports['illenium-appearance']:*` keep working.

## Config

Main knobs (`shared/config/init.lua`):

```lua
Config.MaxOutfits         = 30
Config.ReloadSkinCooldown = 5000          -- ms between /reloadskin uses
Config.AdminGroup         = 'group.admin' -- admin commands and migrations
Config.PedMenuGroup       = 'group.admin' -- /pedmenu, /addped

-- Plastic surgeon payment.
Config.Surgeon = { payment = 'money', item = 'surgery_ticket' } -- 'money' | 'item'

-- How a player opens a shop (clothing / barber / tattoo / surgeon).
Config.Interaction = {
    method        = 'target', -- 'target' | 'sphere' | 'radial'
    radius        = 2.0,
    spawnDistance = 25.0,     -- the shop NPC only spawns within this many metres
    key           = 38,       -- 'sphere' only (38 = E)
    keyLabel      = 'E',
}

-- Job / gang uniforms.
Config.EnableJobOutfitsCommand = true
Config.PersistUniforms         = true  -- keep the last worn uniform across relogs
Config.BossManagedOutfits      = false -- bosses manage uniforms in-game (/bossmanagedoutfits)
```

Prices, charged server-side on save and only for the categories a player actually changed (`shared/config/init.lua`):

```lua
Config.Prices = {
    clothing = { top = 60, undershirt = 30, pants = 40, shoes = 30, mask = 25,
                 hands = 25, bag = 25, accessory = 20, armor = 50, decal = 15 },
    props    = { hat = 30, glasses = 20, earrings = 15, watch = 25, bracelet = 20 },
    barber   = { hair = 40, beard = 25, eyebrows = 20, eyeColor = 15,
                 makeUp = 15, blush = 10, lipstick = 10 },
    tattoo   = 100,  -- per tattoo applied
    surgeon  = 5000, -- flat fee if face structure or genetics changed
}
```

HalfPed command names and Discord (`shared/config/halfped.lua`):

```lua
return {
    Commands = {
        GiveHead = 'half', ResetHead = 'resethead', ManageHead = 'managehead',
        AdminHand = 'adminhands', AdminPants = 'adminpants',
        PlayerHand = 'sethand', PlayerPants = 'setpants',
    },
    Discord = { Enabled = false, Webhook = '', BotName = 'HalfPed Logs', Footer = 'mi-appearance HalfPed' },
}
```

Shop peds and locations, the donation blacklist, the tattoo catalogue, and static uniform sets live in `shops.lua`, `blacklist.lua`, `tattoos.lua`, and `outfits.lua`.

## Exports

Client-side, under the same names illenium-appearance uses, so existing calls resolve unchanged. Main entry points:

| Export | Signature | What it does |
| --- | --- | --- |
| startPlayerCustomization | `startPlayerCustomization(cb, sessionConfig)` | Open the customization editor; `cb` fires when the player finishes |
| setPlayerAppearance | `setPlayerAppearance(appearance)` | Apply a full saved appearance to the local player (restores health and armour around a model swap) |
| setPedAppearance | `setPedAppearance(ped, appearance)` | Apply an appearance to any ped |
| getPedAppearance | `getPedAppearance(ped)` | Read a ped's full appearance table |
| setPlayerModel / addPedModel | `(model)` | Set the local player's ped model |

The full illenium getter/setter family is also present: `getPedModel/Components/Props/HeadBlend/FaceFeatures/HeadOverlays/Hair` and `setPedHeadBlend/FaceFeatures/HeadOverlays/Hair/EyeColor/Component(s)/Prop(s)/Tattoos`.

## Commands

| Command | Access | Does |
| --- | --- | --- |
| `/pedmenu [id]` | `group.admin` (Config.PedMenuGroup) | Open the appearance editor on a player |
| `/addped [id] [model]` | `group.admin` | Set a player to a specific ped model |
| `/joboutfits` | everyone | Open your job uniforms |
| `/gangoutfits` | everyone | Open your gang uniforms |
| `/bossmanagedoutfits` | everyone (boss) | Manage job/gang uniforms (only when Config.BossManagedOutfits) |
| `/reloadskin` | everyone | Reapply your saved appearance |
| `/clearstuckprops` | everyone | Clear stuck attached props |
| `/half [id] [head] [name]` | everyone | HalfPed: apply a saved head/face to a player |
| `/resethead` | everyone | HalfPed: reset your head/face (60s cooldown) |
| `/managehead` | everyone | HalfPed: open head management |
| `/adminhands [id] [drawable] [texture]` | `admin` | HalfPed: set a player's hands |
| `/adminpants [id] [drawable] [texture]` | `admin` | HalfPed: set a player's pants |
| `/sethand` | everyone | HalfPed: reapply your hands |
| `/setpants` | everyone | HalfPed: reapply your pants |

HalfPed command names are configurable in `shared/config/halfped.lua`.

## Statebags

mi-appearance publishes one player statebag so the server and other resources can tell a player is inside an appearance shop.

| Statebag | Scope | Set when | Read by |
| --- | --- | --- | --- |
| `miShop` | player | Set to the shop type (`clothing`, `barber`, `tattoo`, or `surgeon`) when the player enters a shop, cleared to `nil` on leave. The server sets it, it is not trusted from the client. | mi-appearance server (prices a save by the shop the player is in); any resource wanting to know a player is customizing |

See the [state reference](../mi_core/reference/state.md) for the core statebags and GlobalState.

## Ped exports

These keep the **illenium-appearance export names**, so mi-appearance is a drop-in replacement: a resource already written against illenium-appearance keeps working without an edit.

Every one takes an optional ped as its first argument. Pass `0` or omit it and it acts on the local player, which is what you want almost every time.

### Readers

| Export | Returns |
|---|---|
| `getPedModel(ped)` | the ped's model |
| `getPedComponents(ped)` | every clothing component |
| `getPedProps(ped)` | every prop (hats, glasses, ears, watches) |
| `getPedHair(ped)` | hair style and colours |
| `getPedHeadBlend(ped)` | the parent and skin blend |
| `getPedFaceFeatures(ped)` | the face sliders |
| `getPedHeadOverlays(ped)` | overlays: beard, makeup, blemishes, ageing |
| `getPedAppearance(ped)` | all of the above in one table |

### Writers

| Export | Sets |
|---|---|
| `setPedComponent(ped, component)` | one clothing component |
| `setPedComponents(ped, components)` | a list of them in one call |
| `setPedProp(ped, prop)` | one prop |
| `setPedProps(ped, props)` | a list of props |
| `setPedHair(ped, hair)` | hair style and colours |
| `setPedHeadBlend(ped, headBlend)` | the parent and skin blend |
| `setPedFaceFeatures(ped, features)` | the face sliders |
| `setPedHeadOverlays(ped, overlays)` | the overlays |
| `setPedEyeColor(ped, index)` | eye colour |
| `setPedTattoos(ped, tattoos)` | the tattoo collection |
| `setPedAppearance(ped, appearance)` | everything above from one table |
| `setPlayerModel(model)` / `addPedModel(model)` | the player's model |
| `setPlayerAppearance(appearance)` | a full saved look on the local player |

`setPlayerAppearance` snapshots health and armour around the model swap and restores them afterwards, deliberately without healing a downed ped, so applying a saved look never quietly revives someone.

```lua
local look = exports['mi-appearance']:getPedAppearance()
exports['mi-appearance']:setPedAppearance(0, look)
```
