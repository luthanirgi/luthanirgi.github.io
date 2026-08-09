# Commands

mi_core ships a small set of commands. Staff commands are locked behind an ACE permission tier, shown in the Access column. Players without the tier never see the command.

The tiers run highest to lowest: `admin` > `mod` > `support` > `partner`. A higher tier passes every lower check, so an admin can run a mod command. See [setting up the groups](#setting-up-the-groups) below.

## Everyone

| Command | Does |
|---|---|
| `/id` | print your own server id |
| `/cash` | show your cash balance |
| `/bank` | show your bank balance |
| `/job` | show your current job |
| `/gang` | show your current gang |

## Staff (`group.mod`)

| Command | Does |
|---|---|
| `/tp [id]` or `/tp [x] [y] [z]` | teleport to a player, or to coordinates |
| `/tpm` | teleport to your map marker |
| `/bring [id]` | bring a player to you |
| `/dv [radius]` | delete the vehicle you are in, or nearby ones |
| `/reviveall` | revive every player |
| `/setjob [id] [job] [grade]` | set a player's primary job |
| `/setgang [id] [gang] [grade]` | set a player's gang |
| `/changejob [id] [job]` | switch a player to a job they hold |
| `/addjob [id] [job] [grade]` | grant a job |
| `/removejob [id] [job]` | revoke a job |

## Dangerous (`group.admin`)

| Command | Does |
|---|---|
| `/car [model]` | spawn a vehicle |
| `/openserver` | unlock the server |
| `/closeserver [reason]` | lock the server to the whitelist |
| `/logout` | unload the caller's character |
| `/deletechar [id]` | delete an online player's character |
| `/deletecharcitizen [citizenid]` | delete a character by citizenid |

## Console only (maintenance)

Run from the server console, not by players. Both are one-off cleanups.

| Command | Does |
|---|---|
| `cleanplayergroups` | purge `player_groups` rows for jobs or gangs that no longer exist |
| `convertjobs` | read the `players.job` and `players.gang` JSON columns and write them into `player_groups` |

## Setting up the groups

The staff commands check the short ace names `admin`, `mod`, `support`, and `partner`, not `group.admin`. Grant each tier its ace and put your staff in the matching principal, in `server.cfg` or `permissions.cfg`:

```cfg
# each tier gets its short ace
add_ace group.admin   admin   allow
add_ace group.mod     mod     allow
add_ace group.support support allow
add_ace group.partner partner allow

# higher tiers inherit lower ones
add_principal group.admin group.mod
add_principal group.mod   group.support

# put a person in a tier
add_principal identifier.fivem:1234567 group.admin
```
