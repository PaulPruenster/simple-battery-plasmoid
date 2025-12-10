import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.core as PlasmaCore 

PlasmoidItem {
    id: main

    readonly property string batteryKey: "Battery"
    readonly property string batteryStateKey: "State"
    readonly property string batteryPercentKey: "Percent"
    readonly property string acAdapterKey: "AC Adapter"
    readonly property string acPluggedKey: "Plugged in"

    property QtObject pmSource: Plasma5Support.DataSource {
        id: pmSource
        engine: "powermanagement"
        connectedSources: [batteryKey, acAdapterKey]
        interval: 1000
    }

    // === 1. COMPACT REPRESENTATION (For your panel/taskbar) ===
    compactRepresentation: Item {
        Layout.minimumWidth: PlasmaCore.Units.iconSizes.small * 3
        Layout.minimumHeight: PlasmaCore.Units.iconSizes.small

        RowLayout {
            anchors.fill: parent
            spacing: 2

            Image {
                Layout.preferredWidth: PlasmaCore.Units.iconSizes.small
                Layout.preferredHeight: PlasmaCore.Units.iconSizes.small
                smooth: true
                fillMode: Image.PreserveAspectFit
                source: compactIconSource()
            }

            PlasmaComponents.Label {
                text: compactPercentText()
                font.pixelSize: Math.max(PlasmaCore.Theme.smallestFont.pixelSize, 8)
                horizontalAlignment: Text.AlignHCenter
            }
        }

        function compactPercentText() {
            var percent = pmSource.data[batteryKey] ? pmSource.data[batteryKey][batteryPercentKey] : 0
            return percent + "%"
        }

        function compactIconSource() {
            var isOnBattery = pmSource.data[acAdapterKey] && pmSource.data[acAdapterKey][acPluggedKey] == false
            var percent = pmSource.data[batteryKey] ? pmSource.data[batteryKey][batteryPercentKey] : 0

            var iconName = "battery_100"
            if (!isOnBattery) {
                iconName = "battery_charging"
            } else if (percent > 80) iconName = "battery_100"
            else if (percent > 60) iconName = "battery_80"
            else if (percent > 40) iconName = "battery_60"
            else if (percent > 20) iconName = "battery_40"
            else iconName = "battery_20"
            
            return "../icons/" + iconName + ".png"
        }
    }

    // === 2. FULL REPRESENTATION ===
    fullRepresentation: Item {
        Layout.minimumWidth: PlasmaCore.Units.iconSizes.medium * 5

        property bool isOnBattery: pmSource.data[acAdapterKey] && pmSource.data[acAdapterKey][acPluggedKey] == false
        property int batteryPercent: pmSource.data[batteryKey] ? pmSource.data[batteryKey][batteryPercentKey] : 0

        RowLayout {
            anchors.fill: parent

            Image {
                Layout.leftMargin: 10
                Layout.preferredWidth: 75
                Layout.preferredHeight: 75
                smooth: true
                fillMode: Image.PreserveAspectFit
                source: chooseBatteryIcon()
            }

            PlasmaComponents.Label {
                text: prettyPrintPercent()
                font.pixelSize: 25
                Layout.rightMargin: 10
            }
        }

        function prettyPrintPercent() {
            return batteryPercent + " %"
        }

        function chooseBatteryIcon() {
            var iconName = "battery_100"
            if (!isOnBattery) {
                iconName = "battery_charging"
            } else if (batteryPercent > 80) {
                iconName = "battery_100"
            } else if (batteryPercent > 60) {
                iconName = "battery_80"
            } else if (batteryPercent > 40) {
                iconName = "battery_60"
            } else if (batteryPercent > 20) {
                iconName = "battery_40"
            } else {
                iconName = "battery_20"
            }
            return "../icons/" + iconName + ".png"
        }
    }
}
