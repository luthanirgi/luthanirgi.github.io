# mi-surgery

Medics use ox_target on a patient to run hospital procedures: diagnostics (MRI, X-ray, CT, ultrasound), treatments, and organ operations. Each procedure is played as a surgical minigame in a vitals-theatre NUI where the patient's heart rate, blood volume, and SpO2 are the difficulty. It ships 51 surgical minigames.

## Install

```cfg
ensure mi-surgery
```

## Config

`shared/config/settings.lua` holds the behaviour (server-owner editable, no rebuild needed):

```lua
return {
    requireDiagnosis = true,      -- a finding must be revealed by a scan before it can be treated
    diagnosisValidFor = 30 * 60,  -- seconds a scan's findings stay revealed (absolute epoch, lazy check)
    defaultDifficulty = 'medium', -- easy | medium | hard | veryhard | expert | unbelievable
    allowAbort = true,            -- surgeon may press ESC to abandon (counts as a failure, still bleeds)
    sounds = true,                -- NUI sound effects (WebAudio blips, no asset files)

    vitals = {
        enabled = true,        -- the vitals shell IS the difficulty; off = plain pass/fail on minigames
        stageAttempts = 3,     -- tries per stage before the procedure is lost (every retry still bleeds)
        bloodLitres = 5.0,     -- starting volume
        bleedPerFail = 0.55,   -- litres lost per failed stage
        bleedPerSecond = 0.02, -- passive loss while an incision is open
        fatalBelow = 2.0,      -- flatline threshold, litres
        hrResting = 74,        -- bpm the patient idles at
        hrPerFail = 22,        -- bpm spike per failed stage
        hrDecayPerSecond = 3,  -- bpm the spike settles back by, per second
        hrFatal = 200,         -- flatline threshold, bpm
        spo2Start = 98,        -- %
        spo2PerFail = 4,       -- % lost per failed stage
        spo2Fatal = 78,        -- flatline threshold, %
        sedatedFactor = 0.45,  -- spikes and bleeds multiplied by this while anaesthetised
    },

    sedationLasts = 8 * 60,    -- seconds of sedation from a successful `anesthesia` procedure
    procedureCooldown = 3,     -- seconds a surgeon waits between procedures (anti-spam)
    maxDistance = 3.0,         -- max metres surgeon-to-patient (re-checked server-side on every apply)

    gate = {
        needsPatientDown = { treatment = true, organ = true }, -- kinds needing the patient incapacitated
        allowWhenDowned = true,     -- dead or last stand (read from mi-ambulancejob, guarded)
        allowWhenRestrained = true, -- handcuffed / restrained
        allowWhenSedated = true,    -- anaesthetised by this resource
        restrainedStatebags = { 'isHandcuffed', 'handcuffed', 'isCuffed' }, -- statebags meaning "restrained"
    },
}
```

`shared/config/access.lua` sets who may operate. Each table is a `job or gang name -> minimum grade` map, and the same table drives both the ox_target options and the server-side authorisation:

```lua
return {
    diagnosticians = {   -- may run MRI, X-ray, CT, ultrasound
        ambulance = 0,
        ambulance2 = 0,
    },
    surgeons = {         -- may run incision, extraction, grafting, closure
        ambulance = 2,
        ambulance2 = 2,
    },
    organSurgeons = {    -- may run harvest / transplant (ignored while mi-organs is running)
        ambulance = 3,
        godfathers = 0,  -- black-market harvesters
    },
}
```

The UI palette lives in `shared/config/palettes.lua`. The procedure registry, scan findings, and minigame overrides are in `shared/config/procedures.lua`, `findings.lua`, and `games.lua`.

## Exports

| Export | Signature | What it does |
| --- | --- | --- |
| `RunProcedure` | `RunProcedure(procId, opts)` | Runs a full procedure on a patient and blocks until it settles. `procId` is a key of `shared/config/procedures.lua`; `opts` is `{ target = serverId, part = 'body'|nil, difficulty = 'hard'|nil }`. The server authorises the start and owns the outcome. Returns `boolean` success. |
| `StartSurgicalMinigame` | `StartSurgicalMinigame(name, opts)` | Runs one surgical minigame with no patient and no server round-trip, for anything that just wants a medical skill check. `name` is a minigame name; `opts` is a difficulty string or `{ difficulty = }`. Returns `boolean` success. |

## Statebags

mi-surgery marks a sedated patient on a player statebag, stored as an absolute epoch so the sedation survives a resource restart and any resource can check it.

| Statebag | Scope | Set when | Read by |
| --- | --- | --- | --- |
| `miSedatedUntil` | player | Set on the patient when a successful `anesthesia` procedure sedates them. The value is a Unix timestamp; sedation has ended once `os.time()` passes it. | mi-surgery's own gate (`gate.allowWhenSedated`), and any resource that wants to know a patient is anaesthetised. |

See the [state reference](../mi_core/reference/state.md) for the core statebags and GlobalState.
