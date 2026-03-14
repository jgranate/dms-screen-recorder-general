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
    readonly property bool useDefaultGsrFlags: pluginData.useDefaultGsrFlags !== undefined ? pluginData.useDefaultGsrFlags : true
    readonly property string extraGsrFlags: useDefaultGsrFlags ? "-f 60 -q high -k h264" : (pluginData.extraGsrFlags || "-f 60 -q high -k h264")
    readonly property string timestampFormat: pluginData.timestampFormat || "%-d%b%y-%H%M-%S"
    readonly property bool showNotification: pluginData.showNotification !== undefined ? pluginData.showNotification : true

    property bool isNiri: Quickshell.env("XDG_CURRENT_DESKTOP") === "niri"

    function runMode(modeData) {
        const primaryHex = (Theme.primary || "#ff0000").toString();
        const surfaceHex = (Theme.surfaceContainerHighest || "#888888").toString();
        const slurpColors = `-B '${primaryHex}44' -b '${surfaceHex}66' -c '${primaryHex}ff' -w 2`;
        const modeName = modeData.prefix.replace("window_new", "window").replace("window_prev", "window");
        const actualPrefix = root.filePrefix.replace("{mode}", modeName);

        let script = `
            SAVE_DIR=$(eval echo "${root.savePath}")
            mkdir -p "$SAVE_DIR"
            TS=$(date +"${root.timestampFormat}")
            # Sanitize prefix to be safe for filenames
            PREFIX=$(echo "${actualPrefix}" | sed 's/[^a-zA-Z0-9_-]/_/g')
            FILE="$SAVE_DIR/\${PREFIX}_\$TS.mp4"
        `;

        if (modeData.prefix.startsWith("window")) {
            if (modeData.prefix === "window_new") {
                script += `rm -f ~/.cache/gsr-niri-token\n`;
            }
            script += `
                niri msg action set-dynamic-cast-window
                [ "${modeData.prefix}" = "window_new" ] && notify-send "Screen Recorder" "Please select your target and check 'Remember' to save it for future use." -i camera-video
                gpu-screen-recorder -w portal ${root.extraGsrFlags} -o "$FILE" -restore-portal-session yes -portal-session-token-filepath ~/.cache/gsr-niri-token
            `;
        } else {
            const fullSlurpCmd = `${modeData.cmd} ${slurpColors}`;
            script += `
                sleep 0.5
                GEOM=$(${fullSlurpCmd})
                [ -z "$GEOM" ] && exit 0
                wf-recorder -g "$GEOM" ${root.extraFlags} -f "$FILE"
            `;
        }

        script += `
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
        Quickshell.execDetached(["pkill", "-INT", "-f", "wf-recorder"]);
        Quickshell.execDetached(["pkill", "-INT", "-f", "gpu-screen-recorder"]);
        root.closePopout();
        // Delay status update slightly to let processes exit
        Qt.callLater(() => {
            checkProcess.running = false;
            checkProcess.running = true;
        });
    }

    Process {
        id: checkProcess
        command: ["sh", "-c", "pgrep -f [w]f-recorder || pgrep -f [g]pu-screen-recorder"]
        onExited: (exitCode) => root.isRecording = (exitCode === 0)
    }

    Timer {
        id: statusTimer
        interval: 500; repeat: true; running: true; triggeredOnStart: true
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

            // Use the root timer's status to drive shortcut state
            property bool canRecord: !root.isRecording

            Shortcut {
                id: sShortcut; enabled: parent.canRecord; sequence: "S"
                onActivated: if (parent.canRecord) runMode({cmd: "slurp", prefix: "selection"})
            }

            Shortcut {
                id: wShortcut; enabled: parent.canRecord; sequence: "W"
                onActivated: if (parent.canRecord) runMode({cmd: "", prefix: "window_prev"})
            }

            Shortcut {
                id: nShortcut; enabled: parent.canRecord; sequence: "N"
                onActivated: if (parent.canRecord) runMode({cmd: "", prefix: "window_new"})
            }

            Shortcut {
                id: enterShortcut; enabled: parent.canRecord; sequence: "Return"
                onActivated: if (parent.canRecord) runMode({cmd: "", prefix: "window_prev"})
            }

            Column {
                width: parent.width; spacing: Theme.spacingS

                Repeater {
                    model: [
                        { label: "election", shortcut: "S", icon: "fullscreen_exit", cmd: "slurp", prefix: "selection" },
                        { label: "indow/Monitor (Previous)", shortcut: "W", icon: "window", cmd: "", prefix: "window_prev" },
                        { label: "ew Selection", shortcut: "N", icon: "add_to_photos", cmd: "", prefix: "window_new" }
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
                    text: "Use keyboard shortcuts (S/W/N)"
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
    popoutHeight: 280
}
