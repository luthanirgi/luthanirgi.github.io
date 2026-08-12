# mi-housing

Property and apartment system with shells, IPL and MLO interiors, furniture, garages, and door-lock access, plus a React management dashboard and a CCTV camera view. Real-estate agents (separate jobs for houses and apartments) create and manage listings, and rent or sale commission routes to their society account.

## Install

```cfg
ensure mi-housing
```

Depends on ox_lib, ox_inventory and oxmysql.

## Config

Owner settings are split across `shared/config/*.lua`. The main switches, the real-estate jobs, and the CCTV settings are shown below. Property definitions (`houses.lua`) and the furniture catalog (`furniture.lua`) are large data tables, edited in place.

```lua
-- shared/config/init.lua, integrations + base switches
Config.Target    = "ox"
Config.Notify    = "ox"
Config.Radial    = "ox"
Config.Inventory = "ox"
Config.Context   = "ox"
Config.Logs      = "qb"

Config.AccessCanEditFurniture = true
Config.DebugMode              = false
Config.EnableLogs             = false
Config.DynamicDoors           = true

-- shared/config/job.lua, real-estate jobs (houses and apartments are separate qbx jobs)
Config.RealEstate = {
    homes = {
        job = 'realestate',       -- qbx job name (also add to mi-billing Config.Jobs)
        createGrade = 0,          -- min grade to create/manage houses via /bikinkos
        rentCommission = 20,      -- % of house rent paid to the company society
        saleCommission = 5,       -- % of a house SALE paid to the company society
    },
    apartments = {
        job = 'apartmentagent',   -- separate qbx job name
        createGrade = 0,
        rentCommission = 20,
        saleCommission = 5,
    },
}

-- shared/config/cctv.lua, camera view
Config.CCTV = {
    HeightAboveDoor = 1.5,
    FOV = 80.0,
    RotateSpeed = 0.3,
    MaxZoom = 30,
    MinZoom = 100,
}
```

`shared/config/bridge.lua` is the integration bridge: `core` points at `exports.qbx_core`, which mi_core answers to, and `banking` at your banking resource. Repoint either to run a different framework. ox_lib and ox_inventory are used directly and are not bridged.

`shared/config/colors.lua` is the NUI palette: set `PALETTE` to one of `obsidian_rouge`, `winter_blue`, `monochrome`, `twilight_amber`, or `ultramarine_navy`, or hand-edit one. It applies live, with no rebuild.

## Exports

Server:

| Export | Signature | What it does |
| --- | --- | --- |
| registerProperty | `exports['mi-housing']:registerProperty(propertyData)` -> id | Creates and persists a property, broadcasts it to clients, returns the new id. |
| registerApartment | `exports['mi-housing']:registerApartment(apartmentData)` -> id | Creates and persists an apartment building, returns the new id. |
| AddSociety | `exports['mi-housing']:AddSociety(job, amount)` | Deposits money into a job's society account (routes via mi-bank, qbx_management, Renewed-Banking, or qb-banking, whichever is running). |
| IsRealEstateAgent | `exports['mi-housing']:IsRealEstateAgent(src, kind?)` -> bool | Whether a player is a real-estate agent of kind `'homes'` or `'apartments'` (or either kind when `kind` is nil). |

Client:

| Export | Signature | What it does |
| --- | --- | --- |
| GetProperties | `exports['mi-housing']:GetProperties()` -> table | All loaded properties. |
| GetProperty | `exports['mi-housing']:GetProperty(property_id)` -> table | One property by id. |
| GetApartments | `exports['mi-housing']:GetApartments()` -> table | All loaded apartments. |
| GetApartment | `exports['mi-housing']:GetApartment(apartment_id)` -> table | One apartment by id. |
| GetShells | `exports['mi-housing']:GetShells()` -> table | The configured shell definitions. |
| GetShellData | `exports['mi-housing']:GetShellData(shellName)` -> table | One shell's config. |
| GetApartmentBlips | `exports['mi-housing']:GetApartmentBlips()` -> table | Active apartment blip handles. |
| ViewCCTV | `exports['mi-housing']:ViewCCTV(property)` | Enters the CCTV camera view for a property's installed cameras. |
| CreateTempShell | `exports['mi-housing']:CreateTempShell(shellName, position, rotation, leaveCb)` -> entity | Spawns a temporary interior shell and returns its entity. |
| DespawnTempShell | `exports['mi-housing']:DespawnTempShell(shellEntity)` | Removes a shell spawned by CreateTempShell. |

The bundled `client/freecam/` camera library also registers the standard freecam exports (`IsActive`, `SetActive`, `IsFrozen`, `SetFrozen`, `GetFov`, `SetFov`, `GetPosition`, `SetPosition`, `GetRotation`, `SetRotation`, `GetMatrix`, `GetTarget`, and the keyboard and gamepad control getters and setters). They drive the property-creator camera and are not part of the housing contract.

## Commands

| Command | Access | Does |
| --- | --- | --- |
| `/bikinkos` | group.admin or real-estate agent | Opens the create new property or apartment building flow. |
| `/manageproperty` | group.admin | Opens the property and apartment management dashboard. |
| `/setpropertygarage [property_id]` | everyone (property owner) | Sets that property's garage access point at your current position (run outside, optionally seated in a vehicle). |
| `/convertbcshousing` | server console only | One-off importer that reads the bcs_housing tables (`house`, `house_owned`) and writes them into the mi-housing tables. |
