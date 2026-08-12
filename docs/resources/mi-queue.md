# mi-queue

Priority connection queue that replaces FiveM's hardcap: waiters are held on the connection deferral and ordered by priority power, higher power drains first, and cleared players keep their slot reserved while they download and load in. It also supports Tebex-purchased priority codes that players redeem in game, shown on a boarding-pass connecting card.

## Install

```cfg
ensure mi-queue
```

Depends on ox_lib and oxmysql.

Requires OneSync enabled. Import `sql/mi-queue.sql` once (it creates the donation-code tables used by Tebex redemption).

## Config

Edit `config.lua`. Permanent priority identifiers live in `data/priority.lua`.

```lua
-- Permanent, hand-managed priority (identifier -> power) lives in its own file.
Config.Priority = require 'data.priority'

-- Tebex tiers redeemable in-game (tier name -> power). A redeem grants this power for 30 days.
Config.Tiers = {
    Gold   = 6500,
    Silver = 4000,
    Bronze = 2500,
}

-- Temporary priority handed out on disconnect / while loading in, so a returning player gets
-- back quickly instead of starting at the back of the line.
Config.Grace = { enabled = true, power = 5, seconds = 30 }

Config.PriorityOnly   = false   -- true = only priority players may join (whitelist mode)
Config.MaxQueue       = 30      -- max non-priority waiters; extras are turned away with a cooldown
Config.RejectCooldown = 30      -- seconds a turned-away player must wait before retrying
Config.QueueTimeout   = 90      -- drop a waiter after N seconds without a heartbeat
Config.ConnectTimeout = 600     -- drop a cleared player still not loaded after N seconds
Config.JoinDelayMs    = 30000   -- after a restart, hold joins this long so the server settles
Config.ShowTempInCard = false   -- show how many waiters hold temporary priority

-- Player command to redeem a purchased code.
Config.RedeemCommand   = 'redeemqueue'
Config.RedeemCooldown  = 20                       -- seconds between redeem attempts per player
-- Server console command your Tebex package runs on purchase (must match your Tebex config).
Config.PurchaseCommand = 'purchase_queue_credit'

-- Presentation (convars set in server.cfg: mi:servername, sv_displayqueue, sv_debugqueue).
Config.Brand               = GetConvar('mi:servername', 'Mi Project')
Config.ShowQueueInHostname = GetConvar('sv_displayqueue', 'true') == 'true'
Config.Debug               = GetConvar('sv_debugqueue', 'false') == 'true'
Config.UseCard             = true   -- boarding-pass Adaptive Card; false = a plain one-line text update
```

`Config.buildCard` in the same file builds the Adaptive Card shown during the connection deferral. Blank `data/priority.lua` before packaging for sale, it holds your real donor identifiers.

## Exports

| Export | Signature | What it does |
| --- | --- | --- |
| AddPriority (server) | `exports['mi-queue']:AddPriority(id, power, seconds)` | Grants priority to an identifier. `power` defaults to 10. `seconds` present = temporary (auto-expires), absent = permanent. Returns a boolean. |
| RemovePriority (server) | `exports['mi-queue']:RemovePriority(id)` | Removes all priority for an identifier. |
| OnJoin (server) | `exports['mi-queue']:OnJoin(cb)` | Registers a join gate. `cb(src, done)` runs when a player clears the queue; call `done(reason)` with a string to block that player. |
| GetPlayerCount (server) | `exports['mi-queue']:GetPlayerCount()` | Current connected player count. |
| GetQueueSize (server) | `exports['mi-queue']:GetQueueSize()` | Current number of waiters in the queue. |

## Commands

| Command | Access | Does |
| --- | --- | --- |
| `/redeemqueue <code>` | everyone | Redeems a purchased Tebex priority code and grants the tier for 30 days. |
| `purchase_queue_credit <json>` | console / Tebex (restricted) | Inserts a purchased code for later redemption. Run by the Tebex package as the server console, not by players. |
