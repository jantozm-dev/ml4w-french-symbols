import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import qs.CustomTheme

PanelWindow {
    id: root

    // --- WAYLAND CONFIGURATION ---
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: WlrLayershell.Ignore

    implicitWidth: 480
    color: "transparent"

    anchors {
        left: true
        top: true
        bottom: true
    }

    margins {
        top: 52
        bottom: 0
    }

    // --- CLICK OUTSIDE TO CLOSE ---
    HyprlandFocusGrab {
        windows: [root]
        active: root.isOpen
        onCleared: {
            if (root.isOpen) {
                root.isOpen = false
            }
        }
    }

    // --- ESCAPE KEY LISTENER ---
    Shortcut {
        sequence: "Escape"
        onActivated: {
            if (root.isOpen) {
                root.isOpen = false
            }
        }
    }

    // --- ANIMATION LOGIC ---
    property bool isOpen: false
    visible: isOpen || slideAnim.running

    margins { left: root.currentMargin }
    property real currentMargin: isOpen ? 0 : -530

    Behavior on currentMargin {
        NumberAnimation {
            id: slideAnim
            duration: 350
            easing.type: Easing.OutQuint
        }
    }

    IpcHandler {
        target: "symbols"
        function toggle(): void { root.isOpen = !root.isOpen }
        function open(): void { root.isOpen = true }
        function close(): void { root.isOpen = false }
        function isOpen(): bool { return root.isOpen }
    }

    // --- CLIPBOARD PROCESS ---
    Process {
        id: clipboardProc
        running: false
    }

    property string lastCopied: ""
    property bool showFeedback: false

    function copyToClipboard(text) {
        clipboardProc.command = ["bash", "-c", "echo -n '" + text.replace(/'/g, "'\\''") + "' | wl-copy"]
        clipboardProc.running = true
        lastCopied = text
        showFeedback = true
        feedbackTimer.restart()
    }

    Timer {
        id: feedbackTimer
        interval: 1200
        onTriggered: root.showFeedback = false
    }

    // --- SYMBOL DATA ---
    property var symbols: [
        { char: "é", name: "e aigu" },
        { char: "è", name: "e grave" },
        { char: "ê", name: "e circonflexe" },
        { char: "ë", name: "e trema" },
        { char: "à", name: "a grave" },
        { char: "â", name: "a circonflexe" },
        { char: "ù", name: "u grave" },
        { char: "û", name: "u circonflexe" },
        { char: "ü", name: "u trema" },
        { char: "î", name: "i circonflexe" },
        { char: "ï", name: "i trema" },
        { char: "ô", name: "o circonflexe" },
        { char: "ç", name: "cedille" },
        { char: "œ", name: "o-e ligature" },
        { char: "æ", name: "a-e ligature" },
        { char: "É", name: "E aigu" },
        { char: "È", name: "E grave" },
        { char: "Ê", name: "E circonflexe" },
        { char: "Ë", name: "E trema" },
        { char: "À", name: "A grave" },
        { char: "Â", name: "A circonflexe" },
        { char: "Ù", name: "U grave" },
        { char: "Û", name: "U circonflexe" },
        { char: "Ü", name: "U trema" },
        { char: "Î", name: "I circonflexe" },
        { char: "Ï", name: "I trema" },
        { char: "Ô", name: "O circonflexe" },
        { char: "Ç", name: "Cedille" },
        { char: "Œ", name: "O-E ligature" },
        { char: "Æ", name: "A-E ligature" },
        { char: "«", name: "guillemet ouvrant" },
        { char: "»", name: "guillemet fermant" },
        { char: "‹", name: "guillemet simple ouvrant" },
        { char: "›", name: "guillemet simple fermant" },
        { char: "‛", name: "guillemet bas ouvrant" },
        { char: "‟", name: "guillemet bas fermant" },
        { char: "–", name: "tiret en-dash" },
        { char: "—", name: "tiret em-dash" },
        { char: "…", name: "points de suspension" },
        { char: "'", name: "apostrophe typographique" },
        { char: "'", name: "apostrophe ouvrante" },
        { char: "'", name: "apostrophe fermante" },
        { char: "•", name: "bullet" },
        { char: "·", name: "middle dot" },
        { char: "²", name: "exposant 2" },
        { char: "³", name: "exposant 3" },
        { char: "€", name: "euro" },
        { char: "°", name: "degre" },
        { char: "µ", name: "mu" },
        { char: "±", name: "plus-moins" },
    ]

    // ==========================================
    // MAIN PANEL BACKGROUND
    // ==========================================
    Item {
        anchors.fill: parent
        anchors.margins: 20

        RectangularShadow {
            id: shadow
            anchors.fill: mainBgRect
            radius: mainBgRect.radius
            blur: 15
            color: Qt.rgba(Theme.shadow.r, Theme.shadow.g, Theme.shadow.b, 0.4)
        }

        Rectangle {
            id: mainBgRect
            anchors.fill: parent
            radius: 10
            opacity: 0.95

            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: Theme.primary }
                GradientStop { position: 1.0; color: Theme.on_primary }
            }

            Rectangle {
                anchors.fill: parent
                anchors.margins: 2
                radius: parent.radius - anchors.margins
                color: Theme.background
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            // --- HEADER ---
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Text {
                    text: "Symboles Francais"
                    color: Theme.primary
                    font.family: Theme.fontFamily
                    font.pixelSize: 18
                    font.bold: true
                }

                Item { Layout.fillWidth: true }

                // Copy feedback
                Rectangle {
                    visible: root.showFeedback
                    radius: 8
                    color: Theme.primary
                    implicitWidth: feedbackText.implicitWidth + 20
                    implicitHeight: 28

                    Text {
                        id: feedbackText
                        anchors.centerIn: parent
                        text: root.lastCopied + " copie!"
                        color: Theme.background
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                    }

                    Behavior on opacity {
                        NumberAnimation { duration: 150 }
                    }
                }

                Text {
                    text: root.symbols.length + " symboles"
                    color: Theme.on_background
                    opacity: 0.5
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                }
            }

            Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Theme.primary; opacity: 0.3 }

            // --- SYMBOL GRID ---
            ScrollView {
                id: scrollView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                    interactive: true
                    contentItem: Rectangle {
                        implicitWidth: 6; radius: 3; color: Theme.primary
                        opacity: parent.pressed ? 1.0 : (parent.active ? 0.8 : 0.4)
                    }
                }

                GridView {
                    id: symbolGrid
                    width: scrollView.width
                    cellWidth: symbolGrid.width / 5
                    cellHeight: 72
                    model: root.symbols
                    interactive: false

                    delegate: Item {
                        width: symbolGrid.cellWidth
                        height: symbolGrid.cellHeight

                        property string symChar: modelData.char
                        property string symName: modelData.name

                        Rectangle {
                            id: symbolBtn
                            anchors.fill: parent
                            anchors.margins: 4
                            radius: 10
                            color: symbolMouse.containsMouse ? Theme.primary : "transparent"
                            border.color: Theme.primary
                            border.width: 1

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 2

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: symChar
                                    font.family: "serif"
                                    font.pixelSize: 24
                                    color: symbolMouse.containsMouse ? Theme.background : Theme.primary
                                    font.bold: true
                                }

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: symName
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 9
                                    color: symbolMouse.containsMouse ? Theme.background : Theme.on_background
                                    opacity: symbolMouse.containsMouse ? 0.9 : 0.5
                                    maximumLineCount: 1
                                    elide: Text.ElideRight
                                    Layout.maximumWidth: symbolGrid.cellWidth - 12
                                }
                            }

                            MouseArea {
                                id: symbolMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.copyToClipboard(symChar)
                                }
                            }

                            Behavior on color {
                                ColorAnimation { duration: 120 }
                            }
                        }
                    }
                }
            }
        }
    }
}
