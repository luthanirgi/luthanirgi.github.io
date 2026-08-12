# Resources

The resources that run on top of [mi_core](../mi_core/README.md). Each has its own page: what it does, how to install it, its config shown as Lua, and the exports, events, and commands it exposes.

Every resource assumes mi_core is already running. Load them after it in `server.cfg`.

## Foundation

The three ox resources the suite is built on, kept open source under their upstream licences. The plumbing is stock ox; the presentation is themed by the same palette system as the rest of the suite.

* [ox_lib](ox_lib.md) shared library and themed NUI, load it first
* [ox_inventory](ox_inventory.md) slot inventory, Framed Cards layout, async crafting
* [ox_target](ox_target.md) targeting with a themed reticle and options panel

## Interface

* [mi-hud](mi-hud.md) speedometer, status, minimap, and info HUD
* [mi-chat](mi-chat.md) chat with bubbles and job colors
* [mi-radio](mi-radio.md) tactical radio HUD
* [mi-gps](mi-gps.md) GPS and dispatch waypoints
* [mi-loadingscreen](mi-loadingscreen.md) React loading screen
* [mi-spawnselector](mi-spawnselector.md) spawn point selector
* [mi-guidebook](mi-guidebook.md) admin-editable handbook
* [mi-vehmenu](mi-vehmenu.md) vehicle menu
* [mi-scenes](mi-scenes.md) 3D world text
* [mi-advers](mi-advers.md) billboards and screens
* [mi-polaroid](mi-polaroid.md) in character camera, prints, and albums

## Player

* [mi-characters](mi-characters.md) multichar selection
* [mi-appearance](mi-appearance.md) character appearance
* [mi-clothing](mi-clothing.md) clothing menu
* [mi-allcards](mi-allcards.md) licenses and ID cards
* [mi-documents](mi-documents.md) documents
* [mi-phone](mi-phone.md) phone
* [mi-emotes](mi-emotes.md) emotes
* [mi-holster](mi-holster.md) visual weapon and item carry
* [mi-donate](mi-donate.md) donation store
* [mi-newplayer](mi-newplayer.md) new-player protection

## Economy and business

* [mi-bank](mi-bank.md) bank and society funds
* [mi-billing](mi-billing.md) billing and invoices
* [mi-bossmenu](mi-bossmenu.md) boss and gang management
* [mi-government](mi-government.md) tax, fiscal policy, treasury
* [mi-pawnshop](mi-pawnshop.md) pawn marketplace
* [mi-dealership](mi-dealership.md) vehicle dealership
* [mi-customsgarage](mi-customsgarage.md) vehicle customs
* [mi-garage](mi-garage.md) garages
* [mi-locker](mi-locker.md) rentable stashes
* [mi-contracts](mi-contracts.md) contracts and missions
* [mi-gacha](mi-gacha.md) gacha showroom
* [mi-poker](mi-poker.md) poker
* [mi-racingsystem](mi-racingsystem.md) racing system
* [mi-redeem](mi-redeem.md) redeem codes

## Jobs and world

* [mi-policejob](mi-policejob.md) police job
* [mi-ambulancejob](mi-ambulancejob.md) EMS and death
* [mi-damages](mi-damages.md) injury dossier
* [mi-organs](mi-organs.md) organs
* [mi-surgery](mi-surgery.md) surgery
* [mi-crutch](mi-crutch.md) crutch
* [mi-drugs](mi-drugs.md) drugs
* [mi-robbery](mi-robbery.md) robberies
* [mi-keys](mi-keys.md) vehicle keys, locks, and fake plates
* [mi-jail](mi-jail.md) jail and community service
* [mi-dispatch](mi-dispatch.md) dispatch
* [mi-report](mi-report.md) player reports
* [mi-housing](mi-housing.md) housing
* [mi-elevator](mi-elevator.md) elevators
* [mi-queue](mi-queue.md) connection queue

## Minigames

* [mi_minigame](mi_minigame.md) forty single-player minigames behind one export
* [mi_coopminigames](mi_coopminigames.md) thirty minigames for two to six players
* [mi_coopdemo](mi_coopdemo.md) a worked integration of the co-op games

## Tools

* [mi-scenetool](mi-scenetool.md) place synchronized scenes and capture their coordinates
