import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0

MouseArea {
    id: root

    property var weather
    property bool highlighted: pressed && containsMouse
    property date timestamp: weather ? weather.timestamp : new Date()

    enabled: weather && weather.status == Weather.Ready
    width: parent.width
    height: childrenRect.height

    Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
    WeatherImage {
        id: weatherImage
        x: Theme.paddingLarge
        y: 2*Theme.paddingLarge
        highlighted: root.highlighted
        weatherType: weather && weather.weatherType.length > 0 ? weather.weatherType : ""
    }
    PageHeader {
        id: pageHeader
        property int offset: _titleItem.y + _titleItem.height
        anchors {
            left: weatherImage.right
            // weather graphics have some inline padding and rounded edges to give space for header
            leftMargin: -Theme.itemSizeMedium
            right: parent.right
        }
        title: weather ? weather.city : ""
    }
    Column {
        id: column
        anchors {
            top: pageHeader.top
            topMargin: pageHeader.offset
            left: weatherImage.right
            right: parent.right
            rightMargin: Theme.paddingLarge
        }
        Label {
            id: secondaryLabel
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.secondaryHighlightColor
            //% "Current location"
            text: qsTrId("weather-la-current_location")
            horizontalAlignment: Text.AlignRight
            wrapMode: Text.Wrap
            width: parent.width
        }
        Label {
            id: timestampLabel
            width: parent.width
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignRight
            color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
            text: Format.formatDate(timestamp, Format.TimeValue) + " " + Qt.formatDateTime(timestamp, "MMM d")
        }
    }
    TemperatureLabel {
        anchors {
            right: parent.right
            rightMargin: Theme.paddingLarge
            bottom: weatherImage.bottom
        }
        temperature: weather ? weather.temperature : ""
        temperatureFeel: weather ? weather.temperatureFeel : ""
        color: highlighted ? Theme.highlightColor : Theme.primaryColor
    }
    Label {
        color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
        anchors.top: weatherImage.bottom
        font {
            pixelSize: Theme.fontSizeExtraLarge
            family: Theme.fontFamilyHeading
        }
        anchors {
            left: parent.left
            right: parent.right
            leftMargin: Theme.paddingLarge
            rightMargin: Theme.paddingLarge
        }
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignRight
        text: weather ? weather.description : ""
    }
}
