# luthanirgi.github.io

Documentation for **mi_core** and the **mi resources**, a FiveM ecosystem by Mamang Irgi.

The site is built with [MkDocs](https://www.mkdocs.org/) + [Material](https://squidfunk.github.io/mkdocs-material/), themed winter_blue. The same `docs/` folder also carries a `SUMMARY.md` so the space can be published with GitBook Git Sync if wanted.

- Store: [luthanirgi.tebex.io](https://luthanirgi.tebex.io/)
- Donate: [paypal.me/luthanirgi](https://paypal.me/luthanirgi)
- GitHub: [github.com/luthanirgi](https://github.com/luthanirgi)

## Preview locally

```bash
python -m mkdocs serve
```

Opens on http://localhost:8000. Live-reloads as you edit `docs/`.

## Build the static site

```bash
python -m mkdocs build
```

Writes the site to `site/` (served on GitHub Pages).

## Structure

```
mkdocs.yml              theme (winter_blue), the top Tebex/PayPal strip, and the nav
overrides/main.html     the top announcement bar (Tebex + PayPal)
docs/
  stylesheets/extra.css the winter_blue retint of Material's slate scheme
  README.md             landing page
  SUMMARY.md            GitBook navigation (MkDocs uses mkdocs.yml nav instead)
  mi_core/              overview, getting-started, guides, reference, compatibility
  resources/            one page per mi resource
```

## Add a page

1. Drop a Markdown file under `docs/` (use `README.md` for a section landing page).
2. Add it to the `nav:` in `mkdocs.yml`. If you also publish with GitBook, add the same line to `docs/SUMMARY.md`.

## Writing style

Keep it plain and direct. Short sentences, real code, no filler. No em-dashes and no spaced-hyphen asides (they read as AI): use commas, periods, parentheses, and colons instead. Write the way you would explain something to another developer sitting next to you.

## License

Documentation text on this site is free to reuse. The mi_core framework and the mi resources are commercial software, licensed under an End User License Agreement (each resource ships a `LICENSE` file). Some bundled third-party components keep their own licenses: `ox_lib` is LGPL-3.0, `ox_inventory` and `ox_target` stay under their upstream licenses, and a few GPL helper modules inside `mi_core` remain open and source-available under GPL-3.0 (kept readable through `escrow_ignore`).
