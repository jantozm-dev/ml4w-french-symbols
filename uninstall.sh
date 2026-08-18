#!/usr/bin/env bash
# uninstall.sh — ml4w-french-symbols Quickshell widget uninstaller
set -euo pipefail

QUICKSHELL_DIR="$HOME/.config/quickshell"
HYPRLAND_DIR="$HOME/.config/hypr"

echo "ml4w-french-symbols uninstaller"
echo "-------------------------------"

# --- 1. Remove SymbolsApp folder ---
echo ""
echo "[1/4] Removing SymbolsApp..."
if [ -d "$QUICKSHELL_DIR/SymbolsApp" ]; then
    rm -rf "$QUICKSHELL_DIR/SymbolsApp"
    echo "      Removed $QUICKSHELL_DIR/SymbolsApp/"
else
    echo "      SymbolsApp/ not found, skipping"
fi

# --- 2. Patch shell.qml ---
echo ""
echo "[2/4] Cleaning shell.qml..."
SHELL_QML="$QUICKSHELL_DIR/shell.qml"
if [ -f "$SHELL_QML" ]; then
    # Remove import line
    if grep -q '"SymbolsApp"' "$SHELL_QML"; then
        sed -i '/import "SymbolsApp"/d' "$SHELL_QML"
        echo "      Removed import statement"
    else
        echo "      Import not found, skipping"
    fi
    # Remove SymbolsWindow {} line
    if grep -q 'SymbolsWindow {}' "$SHELL_QML"; then
        sed -i '/SymbolsWindow {}/d' "$SHELL_QML"
        echo "      Removed SymbolsWindow {}"
    else
        echo "      SymbolsWindow {} not found, skipping"
    fi
else
    echo "      $SHELL_QML not found, skipping"
fi

# --- 3. Patch Hyprland keybindings ---
echo ""
echo "[3/4] Removing keybinding..."
KEYBINDINGS_FILE="$HYPRLAND_DIR/conf/keybindings/default.lua"
if [ -f "$KEYBINDINGS_FILE" ]; then
    if grep -q 'symbols toggle' "$KEYBINDINGS_FILE"; then
        sed -i '/symbols toggle/d' "$KEYBINDINGS_FILE"
        echo "      Removed Super+Ctrl+Y keybinding"
    else
        echo "      Keybinding not found, skipping"
    fi
else
    echo "      $KEYBINDINGS_FILE not found, skipping"
fi

# --- 4. Patch Sidebar (remove É button) ---
echo ""
echo "[4/4] Removing sidebar button..."
SIDEBAR_FILE="$QUICKSHELL_DIR/SidebarApp/SidebarWindow.qml"
if [ -f "$SIDEBAR_FILE" ]; then
    if grep -q 'qs ipc call symbols toggle' "$SIDEBAR_FILE"; then
        # Remove the entire ActionIcon block that contains "É"
        sed -i '/iconTxt: "É"/{
            # Delete this line and the surrounding ActionIcon block
            N;N;N;N;N;N;N;N;N;/ActionIcon/d
        }' "$SIDEBAR_FILE"
        # Fallback: remove any remaining orphan lines
        sed -i '/iconTxt: "É"/d' "$SIDEBAR_FILE"
        echo "      Removed É button from sidebar"
    else
        echo "      Sidebar button not found, skipping"
    fi
else
    echo "      SidebarWindow.qml not found, skipping"
fi

echo ""
echo "Done! Restart Quickshell to apply changes:"
echo ""
echo "  pkill qs && qs &"
