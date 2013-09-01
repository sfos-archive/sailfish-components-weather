import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0

MouseArea {
    id: root

    property bool cover
    property var weather
    property bool displayTime: true
    property bool highlighted: pressed && containsMouse

    enabled: weather && weather.status == Weather.Ready
    width: parent.width
    height: column.height
    Column {
        id: column
        width: parent.width
        Image {
            id: image
            width: 256
            height: 256
            anchors.horizontalCenter: parent.horizontalCenter
            source: weather && weather.weatherType.length > 0 ? "image://theme/graphic-weather-" + weather.weatherType
                                                                + (highlighted ? "?" + Theme.highlightColor : "")
                                                              : ""
            states: State {
                when: cover
                PropertyChanges {
                    target: image
                    smooth: true
                    sourceSize.width: 180
                    sourceSize.height: 180
                    width: 180
                    height: 180
                }
            }
        }
        Label {
            visible: !cover
            color: Theme.secondaryHighlightColor
            font {
                pixelSize: Theme.fontSizeHuge
                family: Theme.fontFamilyHeading
            }
            anchors {
                left: parent.left
                right: parent.right
                margins: Theme.paddingLarge
            }
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            text: weather ? weather.description : ""
        }
        TemperatureItem {
            cover: root.cover
            displayTime: root.displayTime
            highlighted: root.highlighted
            timestamp: weather ? weather.timestamp : new Date()
            temperature: weather ? weather.temperature : ""
            height: Theme.itemSizeLarge
        }
    }
}
