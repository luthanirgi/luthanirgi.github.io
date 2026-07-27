# Jobs and gangs

Jobs and gangs share the same shape and the same calls. Anything shown here for jobs has a gang twin with the same arguments.

## Set a player's job

```lua
exports.mi_core:SetJob(source, 'police', 2)   -- job name, grade level
```

`SetJob` returns `true` on success. On failure it returns `false` and an error table telling you what went wrong, for example an unknown job or a grade that does not exist.

```lua
local ok, err = exports.mi_core:SetJob(source, 'police', 2)
if not ok then
    print(('could not set job: %s'):format(err.message))
end
```

The gang twin:

```lua
exports.mi_core:SetGang(source, 'ballas', 1)
```

## Duty

Toggle a player on or off duty. Duty drives paychecks and the on duty counts other resources read.

```lua
exports.mi_core:SetJobDuty(source, true)   -- on duty
exports.mi_core:SetJobDuty(source, false)  -- off duty
```

## Read who is on duty

mi_core keeps a live count of on duty players per job, cached so you can read it often without touching the database.

```lua
local police = exports.mi_core:GetDutyCountJob('police')
print(('%d police on duty'):format(police))
```

Count by type instead of by a single job:

```lua
local emsCount = exports.mi_core:GetDutyCountType('ems')
```

## Read the job catalogue

Jobs and gangs are defined in `shared/jobs.lua` and `shared/gangs.lua`. Read them at runtime from either side.

```lua
local police = exports.mi_core:GetJob('police')
print(police.label)
for level, grade in pairs(police.grades) do
    print(level, grade.name, grade.payment)
end
```

## Check membership and rank

On the server:

```lua
if exports.mi_core:HasPrimaryGroup(source, 'police') then
    -- their main job is police
end

if exports.mi_core:HasGroup(source, 'police') then
    -- they hold police, primary or not
end

if exports.mi_core:IsGradeBoss(source, 'job', 'police') then
    -- they are a boss grade
end
```

The same three checks exist on the client for the local player.

```lua
if exports.mi_core:HasPrimaryGroup('police') then
    -- client side, no source needed
end
```

## Broadcast to a job

Send an event to every player currently in a job, without looping sources yourself.

```lua
exports.mi_core:TriggerClientJob('police', 'dispatch:client:newCall', callData)
```

## Managing jobs at runtime

You can create and remove jobs from code, which is how admin menus and boss menus add roles on the fly.

```lua
exports.mi_core:CreateJob('taco', {
    label = 'Taco Stand',
    grades = {
        [0] = { name = 'Cook', payment = 50 },
        [1] = { name = 'Owner', payment = 100, isboss = true },
    },
})

exports.mi_core:RemoveJob('taco')
```

Next: turn on the optional [Donation refund](donation-refund.md) feature, or open the [Server exports](../reference/server-exports.md) reference.
