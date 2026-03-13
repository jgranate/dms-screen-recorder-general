import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    layerNamespacePlugin: "recorder_general"
    property bool isRecording: false

    readonly property string savePath: pluginData.savePath || "~/Videos/Recordings"
    readonly property string filePrefix: pluginData.filePrefix || "record_{mode}"
    readonly property string pillLabel: pluginData.pillLabel || "REC"
    readonly property bool showLabel: pluginData.showLabel !== undefined ? pluginData.showLabel : true
    readonly property bool useDefaultFlags: pluginData.useDefaultFlags !== undefined ? pluginData.useDefaultFlags : true
    readonly property string extraFlags: useDefaultFlags ? "-c libx264 -p preset=veryfast" : (pluginData.extraFlags || "-c libx264 -p preset=veryfast")
    readonly property string timestampFormat: pluginData.timestampFormat || "%-d%b%y-%H%M-%S"
    readonly property bool showNotification: pluginData.showNotification !== undefined ? pluginData.showNotification : true

    function runMode(modeData) {
        const primaryHex = (Theme.primary || "#ff0000").toString();
        const surfaceHex = (Theme.surfaceContainerHighest || "#888888").toString();
        const slurpColors = `-B '${primaryHex}44' -b '${surfaceHex}66' -c '${primaryHex}ff' -w 2`;
        const fullSlurpCmd = `${modeData.cmd} ${slurpColors}`;
        const actualPrefix = root.filePrefix.replace("{mode}", modeData.prefix);

        const script = `
            sleep 0.5
            GEOM=$(${fullSlurpCmd})
            [ -z "$GEOM" ] && exit 0
            SAVE_DIR=$(eval echo "${root.savePath}")
            mkdir -p "$SAVE_DIR"
            TS=$(date +"${root.timestampFormat}")
            FILE="$SAVE_DIR/${actualPrefix}_$TS.mp4"
            wf-recorder -g "$GEOM" ${root.extraFlags} -f "$FILE"
            if [ "${root.showNotification}" = "true" ]; then
                dms notify "Recording Saved" "File: $(basename "$FILE")" --file "$FILE" --icon camera-video
            fi
        `;
        
        Quickshell.execDetached(["sh", "-c", script]);
        root.isRecording = true;
        root.closePopout();
        statusTimer.restart();
    }

    function stopRecording() {
        Quickshell.execDetached(["pkill", "-INT", "wf-recorder"]);
        root.closePopout();
        Qt.callLater(() => {
            checkProcess.running = false;
            checkProcess.running = true;
        });
    }

    Process {
        id: checkProcess
        command: ["pgrep", "wf-recorder"]
        onExited: (exitCode) => root.isRecording = (exitCode === 0)
    }

    Timer {
        id: statusTimer
        interval: 300; repeat: true; running: true; triggeredOnStart: true
        onTriggered: {
            checkProcess.running = false;
            checkProcess.running = true;
        }
    }

    pillClickAction: isRecording ? stopRecording : null

    horizontalBarPill: Component {
        Row {
            spacing: root.showLabel ? Theme.spacingS : 0
            Rectangle {
                width: 14; height: 14; radius: 7
                color: root.isRecording ? (Theme.primary || "red") : (Theme.widgetIconColor || "gray")
                anchors.verticalCenter: parent.verticalCenter
                SequentialAnimation on opacity {
                    running: root.isRecording; loops: Animation.Infinite
                    NumberAnimation { from: 1.0; to: 0.3; duration: 500; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 0.3; to: 1.0; duration: 500; easing.type: Easing.InOutSine }
                }
            }
            StyledText {
                visible: root.showLabel
                text: root.pillLabel
                color: root.isRecording ? (Theme.primary || "red") : (Theme.widgetTextColor || "white")
                font.weight: root.isRecording ? Font.Black : Font.Normal
                font.pixelSize: Theme.fontSizeSmall
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    verticalBarPill: Component {
        Rectangle {
            width: 16; height: 16; radius: 8
            color: root.isRecording ? (Theme.primary || "red") : (Theme.widgetIconColor || "gray")
            anchors.horizontalCenter: parent.horizontalCenter
            SequentialAnimation on opacity {
                running: root.isRecording; loops: Animation.Infinite
                NumberAnimation { from: 1.0; to: 0.2; duration: 500; easing.type: Easing.InOutSine }
                NumberAnimation { from: 0.2; to: 1.0; duration: 500; easing.type: Easing.InOutSine }
            }
        }
    }

    popoutContent: Component {
        PopoutComponent {
            headerText: "Screen Recorder"
            detailsText: "Select recording mode"
            showCloseButton: true

            Timer {
                interval: 300; running: true
                onTriggered: {
                    sShortcut.enabled = !root.isRecording;
                    mShortcut.enabled = !root.isRecording;
                }
            }

            Shortcut {
                id: sShortcut; enabled: false; sequence: "S"
                onActivated: if (!root.isRecording) runMode({cmd: "slurp", prefix: "selection"})
            }

            Shortcut {
                id: mShortcut; enabled: false; sequence: "M"
                onActivated: if (!root.isRecording) runMode({cmd: "slurp -o", prefix: "monitor"})
            }

            Column {
                width: parent.width; spacing: Theme.spacingS

                Repeater {
                    model: [
                        { label: "election", shortcut: "S", icon: "fullscreen_exit", cmd: "slurp", prefix: "selection" },
                        { label: "onitor", shortcut: "M", icon: "monitor", cmd: "slurp -o", prefix: "monitor" }
                    ]
                    delegate: StyledRect {
                        width: parent.width; height: 50; radius: Theme.cornerRadius
                        color: menuMouse.containsMouse ? (Theme.surfaceContainerHighest || "lightgray") : (Theme.surfaceContainerHigh || "gray")
                        Row {
                            anchors.fill: parent; anchors.leftMargin: Theme.spacingM; spacing: Theme.spacingM
                            DankIcon { name: modelData.icon; size: 24; anchors.verticalCenter: parent.verticalCenter }
                            Row {
                                anchors.verticalCenter: parent.verticalCenter
                                StyledText { text: modelData.shortcut; font.weight: Font.Black; color: Theme.primary; font.pixelSize: Theme.fontSizeMedium }
                                StyledText { text: modelData.label; font.pixelSize: Theme.fontSizeMedium; color: Theme.surfaceText }
                            }
                        }
                        MouseArea { id: menuMouse; anchors.fill: parent; hoverEnabled: true; onClicked: runMode(modelData) }
                    }
                }

                StyledText {
                    text: "Use keyboard shortcuts (S/M)"
                    font.pixelSize: Theme.fontSizeSmall - 2
                    color: Theme.surfaceVariantText
                    horizontalAlignment: Text.AlignHCenter
                    width: parent.width
                    topPadding: Theme.spacingXS
                }
            }
        }
    }

    popoutWidth: 280
    popoutHeight: 220
}
