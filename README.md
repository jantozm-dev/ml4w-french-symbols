# ml4w-french-symbols

A Quickshell widget for ML4W OS that lets you click-to-copy French special characters and typographic symbols.

Slides in from the left edge of the screen, matching the ML4W Material You design language (gradient borders, glass panels, shadow blur, Fira Sans Semibold).

![screenshot](screenshot.png)

## Features

- 50 French symbols: accented letters, ligatures, guillemets, dashes, apostrophes, and more
- Click any symbol to copy it to your clipboard via `wl-copy`
- Visual "copie!" feedback toast on copy
- Scrollable 5-column grid with hover effects
- Slides in from the left with 350ms `OutQuint` easing
- Click outside or press Escape to dismiss
- Fully themed from your Matugen/wallpaper-generated colors

## Requirements

- [Quickshell](https://quickshell.outfoxxed.me/) with the ML4W dotfiles shell
- `wl-clipboard` (for `wl-copy`)
- Hyprland (for `HyprlandFocusGrab` click-outside-to-close)

## Install

### One-liner

```bash
git clone https://github.com/YOUR_USERNAME/ml4w-french-symbols.git /tmp/ml4w-french-symbols && bash /tmp/ml4w-french-symbols/install.sh
```

### Manual

1. Copy `quickshell/SymbolsApp/` into your Quickshell config:

   ```bash
   cp -r quickshell/SymbolsApp ~/.config/quickshell/
   ```

2. Add the import and widget instance to `~/.config/quickshell/shell.qml`:

   ```qml
   import "CustomTheme"
   import "SymbolsApp"        # <-- add this

   ShellRoot {
       // ... existing windows ...
       DockLoader {}
       SymbolsWindow {}       # <-- add this
   }
   ```

3. Add a keybinding in `~/.config/hypr/conf/keybindings/default.lua`:

   ```lua
   hl.bind(mainMod .. " + CTRL + Y", hl.dsp.exec_cmd("qs ipc call symbols toggle"), { description = "Open French Symbols widget" })
   ```

4. Restart Quickshell:

   ```bash
   pkill qs && qs &
   ```

## Usage

| Method | Command |
|--------|---------|
| Keybind | `Super + Ctrl + Y` |
| IPC | `qs ipc call symbols toggle` |
| IPC (open) | `qs ipc call symbols open` |
| IPC (close) | `qs ipc call symbols close` |
| Dismiss | Click outside or press `Escape` |

## Symbols included

| Category | Symbols |
|----------|---------|
| Accents aigus | é É |
| Accents graves | è à ù È À Ù |
| Accents circonflexes | ê â û î ô Ê Â Û Î Ô |
| Trema | ë ü ï Ë Ü Ï |
| Cedille | ç Ç |
| Ligatures | œ æ Œ Æ |
| Guillemets | « » ‹ › ‛ „ |
| Tirets | – — |
| Apostrophes | ' ' ' |
| Points | … • · |
| Exposants | ² 3 |
| Divers | € ° µ ± |

## License

MIT
