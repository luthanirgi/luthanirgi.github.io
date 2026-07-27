# mi-chat

mi-chat replaces the default FiveM text chat with a React NUI that shows messages as bubbles with per-job and per-gang colors and icons. It adds anonymous local `/me` and `/do` actions drawn as floating 3D text, out-of-character channels, job radio channels, and an ace-gated admin channel.

## Install

```cfg
ensure mi-chat
```

## Config

The scalar settings live in `shared/config/init.lua`. Channels, job styles, and the command list live in their own files (`shared/config/channels.lua`, `jobs.lua`, `commands.lua`), and the UI palette in `shared/config/colors.lua` (pick one of five presets).

```lua
-- proximity (metres) for local commands
Distance = { me = 5.0, doo = 5.0, oocl = 5.0 },

JoballCooldown = 15,   -- seconds, server-wide announce
SubmitCooldown = 800,  -- ms, per-source chat/command rate-limit

-- /me and /do are anonymous: the sender's name is hidden (others identify the
-- actor by the floating 3D text above their head). Set a value to false to show
-- the character name instead.
Anon = {
    me = true,
    ['do'] = true,
},

-- Global OOC is an abuse risk, so it's off by default and /ooc stays local
-- proximity; set global = true to broadcast /oocg server-wide.
OOC = {
    global = false,
},

-- Gang identity styles (joball falls back here when a job has none).
-- Add entries as: gangname = { label = ..., color = '#hex', icon = 'lucide-name' }
Gangs = {},
```

## Exports

Both exports are client-side.

| Export | Signature | What it does |
| --- | --- | --- |
| addMessage | `exports['mi-chat']:addMessage(message)` | Adds a system line to the chat. Compatibility shim for the standard `chat:addMessage`. |
| send | `exports['mi-chat']:send(action, data)` | Low-level helper that pushes a raw `{action, data}` message to the chat NUI. |

## Commands

| Command | Access | Does |
| --- | --- | --- |
| `/me <text>` | everyone | Anonymous local action drawn as floating 3D text. |
| `/do <text>` | everyone | Anonymous local scene description as floating 3D text. |
| `/oocl <text>` | everyone | Local out-of-character message. |
| `/local <text>` | everyone | Local in-character message. |
| `/oocg <text>` | everyone | Global out-of-character message (broadcasts only when `OOC.global = true`). |
| `/mi_chat_settings` | everyone | Open the chat settings panel (also bound to a key). |
| `/clear` | everyone | Clear your own chat window. |
| `/clearall` | ace `command.clearall` | Clear every player's chat window. |
| `/joball <text>` | everyone | Server-wide announcement styled by your job or gang. |
| `/pol <text>` | police or doc, on duty | Police and DOC radio channel. |
| `/docchat <text>` | doc, on duty | DOC channel. |
| `/ems <text>` | ambulance, on duty | EMS channel. |
| `/ems2 <text>` | ambulance2, on duty | Second EMS branch channel. |
| `/npd <text>` | npdlaw | NPD Law channel. |
| `/doj <text>` | doj, on duty | DOJ channel. |
| `/411 <text>` | doj | DOJ-wide channel. |
| `/adminchat <text>` | ace `support` | Staff admin channel. |

The job, announce, and admin channel commands are defined in `shared/config/commands.lua` and can be renamed, removed, or repointed at other jobs.

## Statebags

mi-chat publishes the job, gang, and channel style table on GlobalState, so its client (and any other resource) can color chat lines without a server round-trip.

| Statebag | Scope | Set when | Read by |
| --- | --- | --- | --- |
| `mcJobStyles` | global (GlobalState) | Published about 500 ms after the resource starts, and again whenever a boss saves a job color or icon. | mi-chat's client, which colors and icons job and gang chat lines. The value is `{ jobs, gangs, channels }`. |

See the [state reference](../mi_core/reference/state.md) for the core statebags and GlobalState.
