# Reference

The exact surface, grouped so you can scan it.

- [Server exports](server-exports.md) is every function on `exports.mi_core` server side.
- [Client exports](client-exports.md) is the client surface for the local player.
- [Events](events.md) lists the events you can listen to and trigger.
- [Commands](commands.md) is the built in staff commands.
- [Config keys](config.md) maps every setting to the file it lives in.

Every server export also answers on `exports.qbx_core`, because mi_core registers both names, and the common ones are on the `QBCore` object for qb resources. The signatures are the same across all three.
