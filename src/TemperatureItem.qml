import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    property bool cover
    property alias displayTime: timeLabel.visible
    property date timestamp
    property bool highlighted
    property alias temperature: temperatureLabel.text
    width: parent.width
    height: Theme.itemSizeExtraLarge
    Label {
        visible: !cover
        text: Qt.formatDateTime(timestamp, "MMM d")
        color: Theme.secondaryHighlightColor
        anchors {
            baseline: temperatureLabel.baseline
            right: temperatureLabel.left
            rightMargin: Theme.paddingMedium
        }
        Label {
            id: timeLabel
            // TODO: add 12h support
            text: Format.formatDate(timestamp, Format.TimeValueTwentyFourHours)
            color: Theme.secondaryHighlightColor
            anchors {
                right: parent.right
                bottom: parent.top
                bottomMargin: -Theme.paddingSmall
            }
        }
    }
    Label {
        id: temperatureLabel
        anchors.centerIn: parent
        color: highlighted ? Theme.highlightColor : Theme.primaryColor
        font {
            family: Theme.fontFamilyHeading
            pixelSize: 120
        }
    }
    Label {
        // TODO: add support for Fahrenheit
        text: "\u00B0"
        anchors {
            left: temperatureLabel.right
            top: temperatureLabel.top
            leftMargin: Theme.paddingMedium
            topMargin: Theme.paddingMedium
        }
        font.pixelSize: Theme.fontSizeHuge
        color: highlighted ? Theme.highlightColor : Theme.primaryColor
    }
}

