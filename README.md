# PsyNeuView Releases

Public distribution channel for [PsyNeuView](https://github.com/jonhanke-nam/PsyNeuView-MacApp) — the native macOS app for visual editing of PsyNeuLink computational models.

## Download

Visit the [download page](https://jonhanke-nam.github.io/PsyNeuView-releases/) or go directly to the [latest release](https://github.com/jonhanke-nam/PsyNeuView-MacApp/releases/latest).

## What's in this repo

This is a lightweight distribution repo. It contains:

- **`docs/index.html`** — Public download page (served via GitHub Pages)
- **`docs/appcast.xml`** — [Sparkle](https://sparkle-project.org/) auto-update feed, checked by the Mac app on launch

No source code lives here. The source is in the private [PsyNeuView-MacApp](https://github.com/jonhanke-nam/PsyNeuView-MacApp) repo.

## How auto-updates work

1. On launch, PsyNeuView checks `docs/appcast.xml` for new versions
2. If a new version is available, Sparkle shows an "Update Available" dialog
3. The user clicks "Install Update" — Sparkle downloads the DMG, replaces the app, and restarts
4. The appcast is updated automatically by the release script in the MacApp repo
