# mi-radio

A pma-voice radio system with a React handheld-device NUI. Channels can be gated by job, gang, or password, and the radio item drains a battery that recharges by combining a radiocell onto it in ox_inventory.

## Install

```cfg
ensure mi-radio
```

Depends on ox_lib, ox_inventory, pma-voice and qbx_core or mi_core.

Requires pma-voice (ensure it first) and OneSync enabled.

## Config

Edit `shared/config.lua`. The main owner tunables:

```lua
return {
    maxFrequency = 500.00, -- highest channel a player may tune to

    -- Member-list overlay: 'default' | 'always' | 'never'. When on, the server tells a
    -- channel's members who is on it (only that channel's members, never everyone).
    overlay = 'never',

    -- The radio inventory item + battery recharge (ox_inventory).
    item = {
        name = 'radio',
        batteryRecharge = 100,
        batteryReplaceThreshold = 20,
    },

    -- Battery drain (client ticks only while the radio is powered on, no idle loop).
    battery = {
        enabled = true,
        consume = 1,           -- drain per tick when on but not transmitting
        consumeOnChannel = 2,  -- drain per tick when on a channel
        depletionMinutes = 15, -- minutes between drains
    },

    -- NUI accent: a preset name below, or a custom { primary = '#RRGGBB', primaryRgb = 'r, g, b' }.
    palette = 'winter_blue', -- tactical_green | obsidian_rouge | winter_blue | twilight_amber | ultramarine_navy

    -- NUI screen layout (players may override it per character in radio settings).
    layout = 'command',      -- command | dispatch | milspec | minimal | seg

    -- names = { ... }      channel display names keyed by frequency (owner content)
    -- restricted = { ... } per-frequency job/gang gates and password channels
}
```

The `names` and `restricted` tables (channel labels, job/gang gates, and password channels) live in the same file and are owner content, edit them freely.

## Exports

| Export | Signature | What it does |
| --- | --- | --- |
| JoinRadio (client) | `exports['mi-radio']:JoinRadio(channel, password)` | Tunes to a frequency. The password is only needed for password-gated channels. |
| LeaveRadio (client) | `exports['mi-radio']:LeaveRadio()` | Disconnects from the current radio channel. |

## Commands

| Command | Access | Does |
| --- | --- | --- |
| `/resetradio` | everyone | Resets your saved radio UI settings (layout and position). |
