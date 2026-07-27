# mi_core

A FiveM core framework that runs the player and everything around them. One framework, built for scale, written to be read.

Jump to [Installation](getting-started/installation.md) or [browse the API](reference/server-exports.md).

## Why mi_core

* **One framework.** mi_core replaces qbx_core. You run one core, not two. Nothing to clash.
* **Built for 2000 players.** Cached lookups, batched writes, and a save pipeline that has run on a live server. Nothing here is theoretical.
* **One clean API.** Every framework function is a named export. Server side and client side read the same way, so you never guess.
* **Security that never false-bans.** The security layer rejects bad actions instead of banning. Suspicion is logged for a human to review, never acted on automatically.
* **Config you can actually read.** One file, plain values, and it stays editable under escrow. Server config never ships to clients.

## What is mi_core

mi_core is the framework that runs the player: identity, characters, money, jobs, gangs, metadata, saving, and the world around them. Your other resources talk to it through exports and events.

mi_core is its own framework. The layout, the API surface, and the naming are mi_core's own. Resources built for qbx or qb still connect, through compatibility layers, while the core underneath is a single clean framework.

## The framework you ensure

```cfg
ensure oxmysql
ensure ox_lib
ensure ox_inventory
ensure mi_core
```

That is the whole thing. There is no qbx_core resource to add. Resources written for qbx_core still work, because mi_core answers their exports under the qbx_core name itself. See [Compatibility](compatibility.md).

The Overextended resources the mi ecosystem builds on are stock. Use the official builds:

* `oxmysql`, [official release](https://github.com/overextended/oxmysql/releases).
* `ox_lib`, [official release](https://github.com/overextended/ox_lib/releases).
* `ox_inventory`, [official release](https://github.com/overextended/ox_inventory/releases).
* `ox_fuel`, [official release](https://github.com/overextended/ox_fuel/releases).
* `ox_doorlock`, [official release](https://github.com/overextended/ox_doorlock/releases).
* `ox_target`, [official release](https://github.com/overextended/ox_target/releases).

!!! warning "A brain is required"
    If you do not have one, do not use this.

## Where to go next

* New here? Read [Installation](getting-started/installation.md) then [Configuration](getting-started/configuration.md).
* Coming from qbx or qb? Read [Migrating](getting-started/migrating.md). Most servers change nothing.
* Building a resource? Keep the [Server exports](reference/server-exports.md) page open, or start with [Your first resource](guides/first-resource.md).
