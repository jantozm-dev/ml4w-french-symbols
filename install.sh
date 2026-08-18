#!/usr/bin/env bash
# install.sh — ml4w-french-symbols Quickshell widget installer
# Compatible with ML4W OS / any Quickshell + Hyprland setup
set -euo pipefail

QUICKSHELL_DIR="$HOME/.config/quickshell"
HYPRLAND_DIR="$HOME/.config/hypr"
SOURCES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "ml4w-french-symbols installer"
echo "----------------------------"

# --- Check dependencies ---
if ! command -v qs &>/dev/null; then
    echo "ERROR: Quickshell (qs) not found. Is it installed?"
    exit 1
fi

if ! command -v wl-copy &>/dev/null; then
    echo "WARNING: wl-copy not found. Clipboard copy will not work."
    echo "         Install it with: pacman -S wl-clipboard  (or dnf install wl-clipboard)"
fi

# --- 1. Copy SymbolsApp to Quickshell config ---
echo ""
echo "[1/4] Installing SymbolsApp..."
if [ ! -d "$QUICKSHELL_DIR" ]; then
    echo "ERROR: $QUICKSHELL_DIR does not exist. Is Quickshell configured?"
    exit 1
fi

cp -r "$SOURCES_DIR/quickshell/SymbolsApp" "$QUICKSHELL_DIR/"
echo "      Copied SymbolsApp/ to $QUICKSHELL_DIR/"

# --- 2. Patch shell.qml ---
echo ""
echo "[2/4] Patching shell.qml..."
SHELL_QML="$QUICKSHELL_DIR/shell.qml"
if [ ! -f "$SHELL_QML" ]; then
    echo "ERROR: $SHELL_QML not found."
    exit 1
fi

# Add import if missing
if ! grep -q '"SymbolsApp"' "$SHELL_QML"; then
    sed -i '/^import "CustomTheme"$/a import "SymbolsApp"' "$SHELL_QML"
    echo "      Added import statement"
else
    echo "      Import already present, skipping"
fi

# Add SymbolsWindow {} if missing
if ! grep -q 'SymbolsWindow {}' "$SHELL_QML"; then
    sed -i '/^}$/i\    SymbolsWindow {}' "$SHELL_QML"
    echo "      Added SymbolsWindow {}"
else
    echo "      SymbolsWindow {} already present, skipping"
fi

# --- 3. Patch Hyprland keybindings ---
echo ""
echo "[3/4] Adding keybinding..."
KEYBINDINGS_FILE="$HYPRLAND_DIR/conf/keybindings/default.lua"
if [ -f "$KEYBINDINGS_FILE" ]; then
    if ! grep -q 'symbols toggle' "$KEYBINDINGS_FILE"; then
        sed -i '/qs ipc call calendar toggle.*Open ML4W Calendar/a\hl.bind(mainMod .. " + CTRL + Y", hl.dsp.exec_cmd("qs ipc call symbols toggle"), { description = "Open French Symbols widget" })' "$KEYBINDINGS_FILE"
        echo "      Added Super+Ctrl+Y keybinding"
    else
        echo "      Keybinding already present, skipping"
    fi
else
    echo "      WARNING: $KEYBINDINGS_FILE not found. Add manually:"
    echo '      hl.bind(mainMod .. " + CTRL + Y", hl.dsp.exec_cmd("qs ipc call symbols toggle"), { description = "Open French Symbols widget" })'
fi

# --- 4. Patch Sidebar (add É button to top bar) ---
echo ""
echo "[4/4] Adding sidebar button..."
SIDEBAR_FILE="$QUICKSHELL_DIR/SidebarApp/SidebarWindow.qml"
if [ -f "$SIDEBAR_FILE" ]; then
    if ! grep -q 'qs ipc call symbols toggle' "$SIDEBAR_FILE"; then
        # Insert the É button after the screenshot ActionIcon block
        sed -i '/iconSrc: "..\/..\/shared\/icons\/screenshot.svg"/{
            N;N;N;N;a\
\
                ActionIcon {\
                    iconTxt: "É"\
                    onClicked: {\
                        root.isOpen = false\
                        Quickshell.execDetached(["bash", "-c", "qs ipc call symbols toggle"])\
                    }\
                }
        }' "$SIDEBAR_FILE"
        echo "      Added É button to sidebar top bar"
    else
        echo "      Sidebar button already present, skipping"
    fi
else
    echo "      WARNING: SidebarWindow.qml not found. Add the button manually:"
    cat <<'MANUAL'

   In ~/.config/quickshell/SidebarApp/SidebarWindow.qml, add after the
   screenshot ActionIcon:

                ActionIcon {
                    iconTxt: "É"
                    onClicked: {
                        root.isOpen = false
                        Quickshell.execDetached(["bash", "-c", "qs ipc call symbols toggle"])
                    }
                }
MANUAL
fi

echo ""
echo "Done! Restart Quickshell to load the widget:"
echo ""
echo "  pkill qs && qs &"
echo ""
echo "  Keybind: Super + Ctrl + Y"
echo "  IPC:     qs ipc call symbols toggle"
echo "  Sidebar: Click the É icon in the sidebar top bar"
