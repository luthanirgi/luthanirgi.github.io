# Installation

This page gets mi_core running on a fresh or existing server.

> **🚫 Run one framework, never two**
>
> mi_core replaces qbx_core. Do not run the real `qbx_core` next to it. Two frameworks both try to own the player, the same events, and the same exports, and they will clash. On an mi_core server the only framework you ensure is `mi_core`.

## Requirements

| Dependency | Version | Notes |
|---|---|---|
| FiveM server | recent artifact | OneSync Infinity must be on |
| oxmysql | latest | database access |
| ox_lib | latest stock | no custom edits needed |
| ox_inventory | latest | `setr inventory:framework qbx` |

mi_core checks these at boot and stops the server with a clear message if something is missing, so you are never left guessing.

## Step 1: drop in the resources

Place these in your resources folder:

- `mi_core`, the framework.
- `ox_lib`, stock from the [official releases](https://github.com/overextended/ox_lib/releases).
- `ox_inventory`, your inventory.

That is the whole framework. There is no second core resource to add.

## Step 2: import the database

Import `sql/mi_core.sql` once. It creates the tables mi_core owns: `users`, `players`, and `player_groups`.

```bash
mysql -u root -p your_database < mi_core/sql/mi_core.sql
```

If you use HeidiSQL or phpMyAdmin, open the file and run it against your schema.

## Step 3: set the convars

Add these to `server.cfg` before you ensure the resources:

```cfg
setr inventory:framework qbx
set onesync on
set mysql_connection_string "mysql://user:pass@localhost/your_database?charset=utf8mb4"
```

## Step 4: order the ensures

Load order matters. oxmysql and ox_lib come first, then mi_core, then everything else.

```cfg
ensure oxmysql
ensure ox_lib
ensure ox_inventory
ensure mi_core
# your jobs, shops, and everything else after this line
```

Notice there is no `ensure qbx_core`. On an mi_core server you do not run qbx_core at all.

## Step 5: start and check

Start the server. A healthy boot prints one line:

```
mi_core 2026.1.0 started
```

If the server quits during boot, read the message it printed. It names the exact dependency or convar that is wrong.

## Running resources built for qbx_core

They work as they are. mi_core answers the `exports.qbx_core` calls itself, so a resource written for qbx_core needs no changes and no extra resource. The one exception is a resource that loads a file with `@qbx_core/...` in its manifest. Point that single line at `@mi_core/...` instead, since files load by resource name. See [Compatibility](../compatibility.md).

For your own resources, call `exports.mi_core` directly.

## What you get

Once mi_core is running you have:

- The full player object with money, jobs, gangs, and metadata.
- Exports on `mi_core` for every framework function.

Next, tune the [Configuration](configuration.md), or skip ahead and [write your first resource](../guides/first-resource.md).
