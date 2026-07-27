# mi-phone

A React NUI smartphone for players, with switchable device models and a suite of apps (messages, bank, contacts, social, marketplace, garage, news, camera, and more). Numbers live on SIM items and each character's phone data persists in the database.

## Install

```cfg
ensure mi-phone
```

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

## Commands

| Command | Access | Does |
| --- | --- | --- |
| `mi-phone:givesim <playerId> [number]` | console/ace (restricted) | Give a player a `phone_sim` item carrying a custom 1 to 12 digit number, or a freshly minted one if omitted. Intended to run from the server console (for example on a Tebex purchase). |

## Statebags

The phone publishes a few replicated player statebags other resources can read.

| Statebag | Scope | Set when | Read by |
| --- | --- | --- | --- |
| `miNumber` | player | Set to the player's phone number on character load and whenever the number changes. | Any resource that needs a player's phone number without calling an export. |
| `phoneOpen` | player | Set `true` while the phone UI is open, `false` when it closes. | Any resource that needs to know the phone is open, for example to avoid opening a conflicting UI. |
| `miScrambled` | player | Set `true` while the GPS scrambler item is running, `false` when it ends. | Any tracking or dispatch resource that should hide or ignore a scrambled player's location. |

See the [state reference](../mi_core/reference/state.md) for the core statebags and GlobalState.
