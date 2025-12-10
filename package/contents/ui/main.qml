import QtQuick 2.15
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as P5Support
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.20 as Kirigami

PlasmoidItem {
    id: main

    readonly property string batteryKey: "Battery"
    readonly property string batteryStateKey: "State"
    readonly property string batteryPercentKey: "Percent"
    readonly property string acAdapterKey: "AC Adapter"
    readonly property string acPluggedKey: "Plugged in"

    property int batteryPercent: 0
    property bool isCharging: false
    property bool isPluggedIn: false

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    P5Support.DataSource {
        id: pmSource
        engine: "powermanagement"
        connectedSources: ["Battery", "AC Adapter"]
        interval: 1000
        
        onDataChanged: {
            console.log("Battery data:", JSON.stringify(data["Battery"]));
            console.log("AC Adapter data:", JSON.stringify(data["AC Adapter"]));
            
            // Get battery percentage
            if (data["Battery"] && data["Battery"]["Percent"] !== undefined) {
                batteryPercent = data["Battery"]["Percent"];
            } else {
                batteryPercent = 0;
            }
            
            // Check if AC adapter is plugged in
            if (data["AC Adapter"] && data["AC Adapter"]["Plugged in"] !== undefined) {
                isPluggedIn = data["AC Adapter"]["Plugged in"];
            } else {
                isPluggedIn = false;
            }
            
            // Check if battery is actually charging (state 1 = charging, 2 = discharging)
            if (data["Battery"] && data["Battery"]["State"] !== undefined) {
                isCharging = (data["Battery"]["State"] === 1);
            } else {
                isCharging = false;
            }
            
            console.log("Battery:", batteryPercent + "%", "Plugged in:", isPluggedIn, "Charging:", isCharging);
        }
        
        Component.onCompleted: {
            console.log("Available sources:", sources);
            dataChanged();
        }
    }

    function getBatteryIcon() {
        // Use absolute path from the widget's installation directory
        var iconBase = plasmoid.file("", "../icons/");
        
        if (isCharging) {
            return "file://" + iconBase + "battery_charging.png";
        } else if (batteryPercent > 80) return "file://" + iconBase + "battery_100.png";
        else if (batteryPercent > 60) return "file://" + iconBase + "battery_80.png";
        else if (batteryPercent > 40) return "file://" + iconBase + "battery_60.png";
        else if (batteryPercent > 20) return "file://" + iconBase + "battery_40.png";
        else return "file://" + iconBase + "battery_20.png";
    }

    toolTipMainText: "Battery"
    toolTipSubText: {
        var status = isCharging ? "Charging" : (isPluggedIn ? "Plugged in (not charging)" : "On battery");
        return batteryPercent + "% - " + status;
    }

    compactRepresentation: MouseArea {
        id: representation
        
        // For panel layout
        implicitWidth: compactRow.implicitWidth
        implicitHeight: compactRow.implicitHeight
        
        // Allow Plasma to determine actual size in panel
        Layout.minimumWidth: Plasmoid.formFactor !== PlasmaCore.Types.Vertical ? implicitHeight : Kirigami.Units.gridUnit
        Layout.minimumHeight: Plasmoid.formFactor === PlasmaCore.Types.Vertical ? implicitWidth : Kirigami.Units.gridUnit
        
        activeFocusOnTab: true
        hoverEnabled: true

        Accessible.name: "Battery: " + batteryPercent + "%"
        Accessible.description: toolTipSubText
        Accessible.role: Accessible.Button

        onClicked: main.expanded = !main.expanded

        Row {
            id: compactRow
            anchors.centerIn: parent
            spacing: 2
            
            Image {
                id: compactIcon
                width: PlasmaCore.Units.iconSizes.small
                height: PlasmaCore.Units.iconSizes.small
                smooth: true
                fillMode: Image.PreserveAspectFit
                source: getBatteryIcon()
                sourceSize.width: width
                sourceSize.height: height
            }

            PlasmaComponents.Label {
                id: compactLabel
                text: batteryPercent + "%"
                font.pixelSize: Math.max(PlasmaCore.Theme.smallestFont.pixelSize, 10)
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    fullRepresentation: Item {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 15
        Layout.minimumHeight: Kirigami.Units.gridUnit * 10

        Row {
            anchors.centerIn: parent
            spacing: Kirigami.Units.gridUnit * 2

            Image {
                width: Kirigami.Units.gridUnit * 8
                height: Kirigami.Units.gridUnit * 8
                smooth: true
                fillMode: Image.PreserveAspectFit
                source: getBatteryIcon()
                sourceSize.width: width
                sourceSize.height: height
            }

            PlasmaComponents.Label {
                text: batteryPercent + " %"
                font.pixelSize: Kirigami.Units.gridUnit * 3
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}