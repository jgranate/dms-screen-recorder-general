import QtQuick
import Quickshell
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "recorder_general"

    Column {
        width: parent.width
        spacing: Theme.spacingM

        Column {
            width: parent.width; spacing: Theme.spacingXS
            StyledText { text: "Save Path"; font.pixelSize: Theme.fontSizeMedium; color: Theme.surfaceText }
            DankTextField {
                width: parent.width
                placeholderText: "~/Videos/Recordings"
                text: root.loadValue("savePath", "~/Videos/Recordings")
                onEditingFinished: root.saveValue("savePath", text)
            }
            StyledText { text: "Directory where recordings will be saved."; font.pixelSize: Theme.fontSizeSmall; color: Theme.surfaceVariantText }
        }

        Column {
            width: parent.width; spacing: Theme.spacingXS
            StyledText { text: "File Prefix"; font.pixelSize: Theme.fontSizeMedium; color: Theme.surfaceText }
            DankTextField {
                width: parent.width
                placeholderText: "record_{mode}"
                text: root.loadValue("filePrefix", "record_{mode}")
                onEditingFinished: root.saveValue("filePrefix", text)
            }
            StyledText { text: "Prefix for the filename. Use {mode} to include the recording type."; font.pixelSize: Theme.fontSizeSmall; color: Theme.surfaceVariantText }
        }

        DankToggle {
            width: parent.width
            text: "Show Label"
            description: "Show a text label next to the recording icon in the bar."
            checked: root.loadValue("showLabel", true)
            onToggled: isChecked => root.saveValue("showLabel", isChecked)
        }

        Column {
            width: parent.width; spacing: Theme.spacingXS
            visible: root.loadValue("showLabel", true)
            StyledText { text: "Pill Label Text"; font.pixelSize: Theme.fontSizeMedium; color: Theme.surfaceText }
            DankTextField {
                width: parent.width
                placeholderText: "REC"
                text: root.loadValue("pillLabel", "REC")
                onEditingFinished: root.saveValue("pillLabel", text)
            }
            StyledText { text: "Custom text for the bar label."; font.pixelSize: Theme.fontSizeSmall; color: Theme.surfaceVariantText }
        }

        DankToggle {
            width: parent.width
            text: "Show Notification"
            description: "Show a notification when recording is saved."
            checked: root.loadValue("showNotification", true)
            onToggled: isChecked => root.saveValue("showNotification", isChecked)
        }

        DankToggle {
            id: defaultFlagsToggle
            width: parent.width
            text: "Use Default Flags"
            description: "Default: -c libx264 -p preset=veryfast"
            checked: root.loadValue("useDefaultFlags", true)
            onToggled: isChecked => root.saveValue("useDefaultFlags", isChecked)
        }

        Column {
            width: parent.width; spacing: Theme.spacingXS
            visible: !root.loadValue("useDefaultFlags", true)
            StyledText { text: "Custom wf-recorder Flags"; font.pixelSize: Theme.fontSizeMedium; color: Theme.surfaceText }
            DankTextField {
                width: parent.width
                placeholderText: "-c libx264 -p preset=veryfast"
                text: root.loadValue("extraFlags", "-c libx264 -p preset=veryfast")
                onEditingFinished: root.saveValue("extraFlags", text)
            }
            StyledText { 
                text: "Example (Intel): -c h264_vaapi -d /dev/dri/renderD128 -p preset=veryfast"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
            }
        }

        Column {
            width: parent.width; spacing: Theme.spacingXS
            StyledText { text: "Timestamp Format"; font.pixelSize: Theme.fontSizeMedium; color: Theme.surfaceText }
            DankTextField {
                width: parent.width
                placeholderText: "%-d%b%y-%H%M-%S"
                text: root.loadValue("timestampFormat", "%-d%b%y-%H%M-%S")
                onEditingFinished: root.saveValue("timestampFormat", text)
            }
            
            StyledRect {
                width: parent.width; height: formatGrid.implicitHeight + Theme.spacingM; radius: 8
                color: Theme.withAlpha(Theme.surfaceContainerHighest, 0.5)
                Grid {
                    id: formatGrid
                    anchors.centerIn: parent; width: parent.width - Theme.spacingM; columns: 2; spacing: Theme.spacingS
                    Repeater {
                        model: [
                            { c: "%Y", d: "Year (2026)" }, { c: "%m", d: "Month (03)" },
                            { c: "%d", d: "Day (08)" }, { c: "%H", d: "Hour (22)" },
                            { c: "%M", d: "Min (15)" }, { c: "%S", d: "Sec (45)" }
                        ]
                        Row {
                            spacing: Theme.spacingS
                            StyledText { text: modelData.c; font.weight: Font.Bold; color: Theme.primary; font.pixelSize: Theme.fontSizeSmall }
                            StyledText { text: modelData.d; color: Theme.surfaceVariantText; font.pixelSize: Theme.fontSizeSmall }
                        }
                    }
                }
            }
        }
    }
}
