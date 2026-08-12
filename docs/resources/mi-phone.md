# mi-phone

A React NUI smartphone for players, with switchable device models and a suite of apps (messages, bank, contacts, social, marketplace, garage, news, camera, and more). Numbers live on SIM items and each character's phone data persists in the database.

Underneath the apps sits a phone OS: a battery that drains whether the phone is in hand or in a pocket, cell coverage measured off tower positions, a lock screen with a PIN, a torch everyone around you can see, ringtones synthesised in the NUI, and voice calls handed to your voice resource. Payphones give anyone without a handset a way to place a call.

## Install

```cfg
ensure mi-phone
```

Depends on ox_lib, ox_inventory and qbx_core or mi_core.

It ships server/migrate.lua, so tables auto-create on first boot, no manual SQL import. The Gallery and Snapix camera is optional and needs the `screenshot-basic` resource; the phone runs fine without it, the camera just hides.

## Config

The main settings are in `shared/config` (`init.lua`):

```lua
Config.OpenItem = 'phone'            -- ox_inventory item that opens the phone
Config.OpenKey = 'F1'                -- toggle keybind (player-rebindable in FiveM settings)
Config.ModelSelection = 'free'       -- 'free' = switch model anytime; 'locked' = follows the item
Config.DefaultModel = 'one'          -- model when an item has no metadata.model
Config.Guards = { dead = true, cuffed = true, swimming = true }   -- block opening while true
Config.Anim = { dict = 'cellphone@', name = 'cellphone_text_read_base' }
Config.Share = { Radius = 8.0, MaxNearby = 8 }   -- share-my-number picker range and size
Config.Sim = { Item = 'phone_sim' }              -- SIM item carries metadata.number
Config.Media = {                     -- Gallery camera upload (FiveManage); token in server/apiKeys.lua
    Enabled = false, Endpoint = 'https://api.fivemanage.com/api/image',
    Field = 'file', Quality = 0.85,
},
Config.Scramble = { Item = 'gps_scrambler', Seconds = 180 },   -- hides own blip, sets miScrambled statebag
Config.Market = { PostFee = 50 },    -- money sink charged to list an item (0 disables)
Config.News = { PublishJobs = { ['media'] = 0 }, MaxTitle = 120, MaxBody = 4000 },   -- everyone reads
Config.AppStore = {                  -- System apps can never be uninstalled
    System  = { 'phone', 'messages', 'settings', 'appstore' },
    Default = { 'phone', 'messages', 'settings', 'appstore', 'bank', 'calculator', 'companies' },
    All     = { 'phone', 'messages', 'settings', 'appstore', 'bank', 'chirp', 'snapix',
                'shadow', 'facelink', 'garage', 'news', 'market', 'companies', 'calculator' },
},
Config.Snapix = { Camera = false, Webhook = '' },
Config.FaceLink = { VoiceHooks = false },   -- fire voiceStart/voiceEnd so you can bridge your voice resource
-- Config.Companies: directory of businesses (a shared dispatch line per job); edit freely
-- Config.GarageCoords: map a garage name to a vec2 so "Locate" drops a waypoint
```

Device identity and the in-hand prop are in `shared/config/devices.lua`:

```lua
Devices.order = { 'one', 'flip', 'fold', 'mini', 'max', 'active', 'classic' }   -- Settings picker order
-- each entry: { label = 'mi One', prop = 'prop_phone_ing' }
```

The system accent is picked in `shared/config/colors.lua` and applied at runtime, so recolouring needs no web rebuild:

```lua
local PALETTE = 'winter_blue'   -- --mi-accent is the phone's system tint across every app
-- 'obsidian_rouge' | 'winter_blue' | 'monochrome' | 'twilight_amber' | 'ultramarine_navy'
```

### The phone OS

Each part of the OS is its own file under `shared/config/`, so you tune one without reading the others.

`battery.lua`. Nothing ticks: the level is derived from how long ago it was last written, so it keeps draining while the phone is pocketed and while the player is logged out. With the defaults a full charge lasts about 2h45m pocketed, or about 1h30m with the screen on.

```lua
Enabled      = true,
Drain        = { Active = 55, Inactive = 100 }, -- seconds of real time per 1% lost
Start        = 100,   -- level a phone item starts life with
ShutdownAt   = 0,     -- at or below this the phone will not open
ChargingRate = 5,     -- percent per minute on a normal charger

Vehicle = {           -- charging from a car, needs the cable item in the bag
    Enabled = true, Item = 'usb_cable', Rate = 8,
    EngineRequired = true, MinEngineHealth = 300,
    Classes = { --[[ bikes, boats, aircraft and trains are false: no power outlet ]] },
},
```

`signal.lua`. Bars come from the distance to the nearest tower, and past the last `Range` entry there is no service at all. The shipped towers are positioned for coverage rather than tied to map props, so move them onto your own masts.

```lua
Enabled = true,
Debug   = false,  -- draws the towers as map blips; check this before you go live
Range   = { [4] = 300.0, [3] = 600.0, [2] = 800.0, [1] = 1600.0 }, -- metres per bar count
Require = { call = true, sms = true },  -- what no service blocks
Towers  = { vector3(-75.0, -818.0, 326.0), --[[ ... ]] },
```

!!! warning "A gap in the tower list is a stretch of map where nobody can call"
    Turn `Debug` on once and fly the map before release.

`voice.lua`. mi-phone carries no audio itself. It puts both parties into a channel on your voice resource and takes them out again.

```lua
System      = 'pma',   -- 'pma' | 'mumble' | 'salty' | 'toko'; only pma is implemented and tested,
                       -- the rest are one-line stubs in client/os/voice.lua for you to fill in
ChannelBase = 20000,   -- call channels are ChannelBase + callId; raise it if it collides with a radio
RingTimeout = 30,      -- seconds an unanswered call rings before it is logged as missed

Loudspeaker = { Enabled = true, Range = 5.0, UpdateInterval = 1000, MaxParticipants = 10 },
QuickReplies = { 'Can I call you back?', 'Text me instead.', "I'm busy right now." },
```

`payphone.lua`. A payphone is a line without a handset: it can call, it costs cash, and it has no SIM, no battery, and no signal check.

```lua
Enabled = true,
Props   = { 'prop_phonebox_01a', 'prop_phonebox_01b', 'prop_phonebox_02', 'prop_phonebox_04' },
Cost    = 25,    -- cash taken when the call is placed; 0 makes payphones free
Reach   = 3.0,   -- metres the server allows between player and booth
Booths  = { vector3(-1080.1, -247.2, 37.8), --[[ twelve shipped ]] },
```

The server cannot see client-side props, so a payphone call is only accepted within 1.5 m of a `Booths` entry. Add your own booths there, otherwise a client could claim any coordinate is a booth and get a free, item-less, coverage-less line.

`lock.lua` is the lock screen (`Length` 4 to 6, `MaxAttempts` 5, `LockoutSec` 60). The PIN is salted and hashed server-side, but that is roleplay obfuscation rather than cryptography, so players should not reuse a password they care about.

`audio.lua` is what the phone sounds like. Tones are synthesised in the NUI from named patterns, so the resource ships no audio files and no licence question; set `url` on an entry to play a real file instead. Four ringtones, two notification sounds, and a vibrate buzz, and nearby players hear all of it.

`flashlight.lua` is the torch (`Range` 18.0, `Brightness` 4.0, and a colour), visible to everyone around you rather than only to yourself.

`keybinds.lua` holds the defaults for `open` (F1), `flashlight` (B), `answer` (Y), and `decline` (U). Players rebind every one in the FiveM key settings. An empty string registers no bind at all, which also means it never appears there for a player to assign.

`limits.lua` is how hard one player may hit the server, plus how long a shared read stays cached. Raise the TTLs on a busy server, or set one to 0 to disable caching for that read.

```lua
cacheTtl  = { ['news:feed'] = 60000, ['market:feed'] = 45000,
              ['chirp:feed'] = 20000, ['snapix:feed'] = 20000 },

rateLimit = {  -- { max calls, window ms } per callback key
    read = { 30, 10000 }, write = { 8, 10000 }, call = { 6, 30000 },
    sms  = { 12, 30000 }, answer = { 20, 30000 }, speaker = { 45, 30000 },
    upload = { 4, 60000 },
},
```

`logs.lua` is Discord logging, off by default, with a webhook per kind (calls, messages, money, staff). Entries are batched and flushed together, so a busy server makes a handful of requests a minute rather than one per action. `FlushSec` is also the worst case for what a restart can lose: the flush attempted on shutdown usually does not survive the resource being torn down.

## Exports

Server exports for the phone-number identity system:

| Export | Signature | What it does |
| --- | --- | --- |
| `GetNumber` | `exports['mi-phone']:GetNumber(src)` | The player's current phone number (nil if none). |
| `ChangeNumber` | `exports['mi-phone']:ChangeNumber(src, newNumber)` | Change a player to an exact, pre-validated number, enforcing uniqueness. Returns `ok, err`. |
| `GenerateNumber` | `exports['mi-phone']:GenerateNumber()` | Mint a fresh, unused number. |
| `IsNumberOnline` | `exports['mi-phone']:IsNumberOnline(number)` | True if an online player currently holds that number. |
| `GetSourceByNumber` | `exports['mi-phone']:GetSourceByNumber(number)` | The server id holding a number (nil if offline). |
| `GetCitizenNumber` | `exports['mi-phone']:GetCitizenNumber(citizenid)` | Look up a citizen's number from the database. |

Client item-use exports, meant to be bound on the matching ox_inventory item:

| Export | Signature | What it does |
| --- | --- | --- |
| `useItem` | `exports['mi-phone']:useItem()` | Opens the phone (bind on the `phone` item). |
| `useSim` | `exports['mi-phone']:useSim()` | Opens the phone to Settings (bind on the `phone_sim` item). |
| `useGpsScrambler` | `exports['mi-phone']:useGpsScrambler()` | Starts the GPS scrambler (bind on the `gps_scrambler` item). |
| `useCable` | `exports['mi-phone']:useCable()` | Toggles charging while the player is sitting in a vehicle (bind on the charging cable item). Leaving the vehicle unplugs automatically. |

## Commands

| Command | Access | Does |
| --- | --- | --- |
| `mi-phone:givesim <playerId> [number]` | console/ace (restricted) | Give a player a `phone_sim` item carrying a custom 1 to 12 digit number, or a freshly minted one if omitted. Intended to run from the server console (for example on a Tebex purchase). |
| `mi-phone:restrict <playerId> <app>` | `admin` ace | Block one app for a player. The block persists on their device and is written to the staff log. |
| `mi-phone:unrestrict <playerId> <app>` | `admin` ace | Lift a block set by `mi-phone:restrict`. |

## Statebags

The phone publishes a few replicated player statebags other resources can read.

| Statebag | Scope | Set when | Read by |
| --- | --- | --- | --- |
| `miNumber` | player | Set to the player's phone number on character load and whenever the number changes. | Any resource that needs a player's phone number without calling an export. |
| `phoneOpen` | player | Set `true` while the phone UI is open, `false` when it closes. | Any resource that needs to know the phone is open, for example to avoid opening a conflicting UI. |
| `miScrambled` | player | Set `true` while the GPS scrambler item is running, `false` when it ends. | Any tracking or dispatch resource that should hide or ignore a scrambled player's location. |

See the [state reference](../mi_core/reference/state.md) for the core statebags and GlobalState.
