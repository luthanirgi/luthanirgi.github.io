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

`shared/config/bridge.lua` is the framework bridge. `core` points at `exports.qbx_core`, which mi_core answers to; repoint it (for example at `exports['qb-core']`) to run a different framework. ox_lib and ox_inventory are used directly and are not bridged.

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
| `/adminchat <text>` | ace `support` | Staff admin channel. |
| `/pol <text>` | police or doc, on duty | Proximity radio for police and DOC, prefixed with the sender's callsign. |
| `/allpd <text>` | police | The same channel, server-wide instead of proximity. |

Everything below `/clearall` comes from `shared/config/commands.lua`, and the chat's own command suggestions are built from that same file, so a channel you add shows up in the suggestion list and one you delete stops being suggested. Four handler types are available:

```lua
return {
  -- nearby: proximity message on a channel (radius from Config.Distance; /me and /do honour Config.Anon)
  me     = { type = 'nearby', channel = 'me'  },
  ['do'] = { type = 'nearby', channel = 'do'  },
  oocl   = { type = 'nearby', channel = 'ooc' },

  -- announce: server-wide broadcast tagged by the sender's job or gang (rate-limited by Config.JoballCooldown)
  joball = { type = 'announce' },

  -- ace: staff-only channel behind an ace permission
  adminchat = { type = 'ace', ace = 'support', channel = 'admin' },

  -- jobNearby: proximity message to members of one or more jobs. Full field example:
  pol = {
    type       = 'jobNearby',
    job        = { 'police', 'doc' }, -- one job name, or a list of them
    onduty     = true,                -- require the sender to be on duty
    phoneEmote = true,                -- play the 'phone' emote while sending
    callsign   = true,                -- prefix the sender's callsign
    -- channel = 'police',            -- optional style key from channels.lua or jobs.lua
  },

  -- jobAll: like jobNearby, but reaches the whole job server-wide with no distance check
  allpd = { type = 'jobAll', job = 'police', callsign = true },
}
```

Add a `cmd.<name>` entry to `locales/en.json` to give a new channel its own help text in the suggestion list. Without one it falls back to a generic label rather than showing the raw key.

## Statebags

mi-chat publishes the job, gang, and channel style table on GlobalState, so its client (and any other resource) can color chat lines without a server round-trip.

| Statebag | Scope | Set when | Read by |
| --- | --- | --- | --- |
| `mcJobStyles` | global (GlobalState) | Published about 500 ms after the resource starts, and again whenever a boss saves a job color or icon. | mi-chat's client, which colors and icons job and gang chat lines. The value is `{ jobs, gangs, channels }`. |

See the [state reference](../mi_core/reference/state.md) for the core statebags and GlobalState.
