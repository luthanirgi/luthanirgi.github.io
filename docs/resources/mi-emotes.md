# mi-emotes

An emote menu with a React NUI. Players run emotes, walk styles, facial expressions, scenarios, shared and synchronized dances, and prop emotes, driven by chat commands and keybinds. Its convar and event names keep the `scully_emotemenu:` prefix.

## Install

```cfg
ensure mi-emotes
```

Depends only on ox_lib. No database, so nothing to import.

## Config

Owner-editable settings live in `shared/config/*.lua`.

`shared/config/config.lua` reads convars (set them in `server.cfg` as `setr scully_emotemenu:<key> <value>`, or edit the defaults shown here):

```lua
menuPosition   = 'top-right',              -- on-screen menu position
menuCommands   = { 'em', 'emotemenu' },    -- commands that open the menu
menuKeybind    = 'F5',                     -- default key to open the menu
enableRadialMenu   = true,
enableEmotePreview = true,
enableEmoteBinds   = true,
emoteCommands  = { 'e', 'emote', 'eplay' },-- play / list emotes
emoteCancelKey = 'X',
walkCommands   = { 'w', 'walk' },          -- set / list walk styles
expressionCommands = { 'f', 'face' },      -- set / list facial expressions
preventWalkStyleAbuse      = true,
enableNSFWEmotes           = 'false',
enableGangEmotes           = false,
enableSocialMovementEmotes = false,
enableConsumableEmotes     = false,
enableSynchronizedEmotes   = false,
enableAnimalEmotes         = false,
enableWeaponBlock          = false,
enableAimShootBlock        = true,
enableEmotesInVehicles     = true,
emoteCooldown              = 500,          -- ms between emotes
enableEmotePlacement       = true,
enableAutoPtfx             = true,
ptfxKey                    = 'G',
handsUpKey                 = 'X',
stanceKey                  = 'LCONTROL',
useCrouchOnly              = false,
pointKey                   = 'B',
ragdollKey                 = false,        -- false disables the ragdoll keybind; set a key ('U') to enable
```

`shared/config/colors.lua` picks the NUI palette (`winter_blue` by default) from `obsidian_rouge`, `winter_blue`, `monochrome`, `twilight_amber`, `ultramarine_navy`. It is applied at runtime, so a re-skin needs no web rebuild.

`shared/config/bridge.lua` names the medical resource used to block emotes while dead or in last stand (`medicalResource = 'qbx_medical'`, or `false` to disable). The call is guarded, so with no medical resource the player is treated as alive.

## Exports

Client-side animation API for other resources.

| Export | Signature | What it does |
|---|---|---|
| `isInEmote` | `isInEmote()` | returns whether the player is currently in an emote |
| `getLastEmote` | `getLastEmote()` | returns the last played emote |
| `playEmote` | `playEmote(data, variation?)` | plays an emote from an emote data table |
| `cancelEmote` | `cancelEmote(skipReset?)` | stops the current emote |
| `playEmoteByCommand` | `playEmoteByCommand(command, variant?)` | plays an emote by its command name |
| `getCurrentWalk` | `getCurrentWalk()` | returns the active walk style |
| `setWalk` | `setWalk(name)` | sets a walk style |
| `ResetWalk` | `ResetWalk()` | clears the walk style |
| `resetWalk` | `resetWalk()` | lowercase alias of `ResetWalk`; both names are live |
| `setWalkByCommand` | `setWalkByCommand(command)` | sets a walk style by its command name |
| `getCurrentExpression` | `getCurrentExpression()` | returns the active facial expression |
| `setExpression` | `setExpression(name)` | sets a facial expression |
| `resetExpression` | `resetExpression()` | clears the facial expression |
| `setExpressionByCommand` | `setExpressionByCommand(command)` | sets an expression by its command name |
| `registerEmote` | `registerEmote(emote)` | registers a custom emote at runtime |
| `playRegisteredEmote` | `playRegisteredEmote(emote)` | plays a previously registered emote |
| `addEmoteToMenu` | `addEmoteToMenu(menu, data)` | adds one emote to a menu list |
| `addEmotesToMenu` | `addEmotesToMenu(menu, data)` | adds several emotes to a menu list |
| `getEmoteProps` | `getEmoteProps()` | returns the props attached to the current emote |
| `setLimitation` | `setLimitation(limited)` | enables or disables the emote limitation lock |
| `isLimited` | `isLimited()` | returns whether emotes are currently limited |
| `closeMenu` | `closeMenu()` | closes the emote menu |
| `toggleMenu` | `toggleMenu()` | opens or closes the emote menu |
| `previewEmoteByCommand` | `previewEmoteByCommand(command)` | previews an emote on a ghost ped |
| `stopEmotePreview` | `stopEmotePreview()` | stops the preview |
| `addEmoteMenuOption` | `addEmoteMenuOption(data)` | adds a custom option to the menu |
| `updateEmoteStatus` | `updateEmoteStatus()` | refreshes the menu's emote status |
| `customNotifyFn` | `customNotifyFn(fn)` | replaces the notify function used for emote messages |

One server export, for stopping a group dance from another resource:

| Export | Signature | What it does |
|---|---|---|
| `cancelJoinDance` | `exports['mi-emotes']:cancelJoinDance(source)` | Stops the player's group dance, clearing them as a follower and as the dance leader. |

## Commands

Command names come from the config above, so these are the defaults.

| Command | Access | Does |
|---|---|---|
| `/em`, `/emotemenu` | everyone | open the emote menu (default key F5) |
| `/e`, `/emote`, `/eplay` | everyone | play an emote by name, or open the emotes list |
| `/w`, `/walk` | everyone | set a walk style, or open the walk list |
| `/f`, `/face` | everyone | set a facial expression, or open the expression list |
| `/re` | group.admin | toggle the distance check on synchronized emote requests |
| `/canceljoindance` | everyone | leave a coordinated group dance (also `/cancelcoord`) |
| `/cancelcoord` | everyone | leave a coordinated group dance |
| `/+cancelanimation` | everyone | cancel the current animation (default key X) |

## Statebags

mi-emotes writes the player's current emote and dance state to player statebags. The emote bags are replicated to other clients; the join-dance bags stay client-local.

| Statebag | Scope | Set when | Read by |
|---|---|---|---|
| `isInEmote` | player | Set `true` when an emote starts, `false` when it ends or is cancelled. | mi-emotes, and any resource that gates actions while a player is animating. |
| `emoteProps` | player | Set to the prop list when an emote with props plays, cleared when it ends. | mi-emotes, which spawns and removes the props on every client. |
| `stance` | player | Set to the crouch/prone level when the stance key changes it. | mi-emotes, which applies the matching movement clipset. |
| `emoteCooldown` | player | Stamped with the game timer each time an emote plays. | mi-emotes, which rate-limits the next emote. |
| `joinDanceLeader` | player (client-local) | Set to the leader's server id when the player joins a group dance, cleared on leave. | mi-emotes, which follows the leader's dance. |
| `joinDanceIsLeader` | player (client-local) | Set `true` on the player leading a group dance, cleared when the dance ends. | mi-emotes. |

See the [state reference](../mi_core/reference/state.md) for the core statebags and GlobalState.
