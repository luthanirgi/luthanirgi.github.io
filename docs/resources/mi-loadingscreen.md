# mi-loadingscreen

Cinematic React loading screen with a selectable palette, a background (solid, image, slideshow, or video), a music player, and tabs for a showcase gallery, tips, rules, keybinds, changelog, credits, and socials. It uses manual shutdown, so it stays up until mi_core/mi-characters take it down.

## Install

```cfg
ensure mi-loadingscreen
```

## Config

Edit `config.lua`. No web rebuild is needed. It ships with three built-in SVG backdrops, so it looks complete with zero external assets.

```lua
Config = {
    -- Palette: obsidian_rouge | winter_blue | monochrome | twilight_amber | ultramarine_navy
    theme = 'winter_blue',

    server = {
        name = 'MI ROLEPLAY',
        tagline = 'Connecting to the city',
        logo = '', -- optional badge image; empty shows initials from the name
    },

    -- Background. type = 'solid' | 'image' | 'slideshow' | 'video'.
    background = {
        type = 'slideshow',
        image = 'bg/city-01.svg',   -- for type 'image'
        images = { 'bg/city-01.svg', 'bg/city-02.svg', 'bg/city-03.svg' }, -- for 'slideshow'
        video = '',                 -- for type 'video': a link or a direct mp4/webm
        slideshowInterval = 10000,  -- ms between slides
        dim = 0.42,                 -- 0..1 darkening over the media so text stays readable
    },

    music = {
        enabled = true,
        autoplay = true,
        volume = 0.4, -- 0..1 starting volume
        tracks = {
            { title = 'Night Shift', artist = 'MI Radio', src = '', cover = '' }, -- add src to make it audible
        },
    },

    -- News / gallery card (bottom-left). Each item is { title, text, image }.
    showcase = { enabled = true, autoAdvance = 8000 },

    -- Rotating one-liners shown above the bottom bar.
    tips = { 'Press F1 to open the interaction menu.' },
    tipInterval = 6000,

    rules = { 'No RDM or VDM. Give people a reason.' },          -- Rules tab
    keybinds = { { key = 'F1', action = 'Interaction menu' } },  -- Keybinds tab
    updates = { { tag = 'Latest', title = 'Season launch', notes = { 'New downtown apartments' } } }, -- changelog tab
    credits = { { role = 'Founder', name = 'Mamang Irgi' } },    -- Credits tab
    socials = { { label = 'discord.gg/miroleplay', icon = 'discord' } }, -- icon: discord|instagram|tiktok|youtube|x|store|globe
}
```
