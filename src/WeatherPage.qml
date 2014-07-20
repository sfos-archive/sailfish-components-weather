import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0

Page {
    id: root

    property var weather
    property var weatherModel
    property int currentIndex

    SilicaFlickable {
        anchors {
            top: parent.top
            bottom: weatherForecastList.top
        }
        clip: true
        width: parent.width
        contentHeight: weatherItem.height
        VerticalScrollDecorator {}

        WeatherDetailsItem {
            id: weatherItem

            today: root.currentIndex === 0
            opacity: weatherModel.status == Weather.Ready ? 1.0 : 0.0
            weather: root.weather
            model: weatherModel.status == Weather.Ready ? weatherModel.get(currentIndex) : null
            Behavior on opacity { FadeAnimation {} }
        }
        PlaceholderItem {
            y: Theme.itemSizeSmall + Theme.itemSizeLarge*2
            status: weatherModel.status
            onReload: weatherModel.reload()
        }
    }
    SilicaListView {
        id: weatherForecastList

        opacity: weatherModel.status == Weather.Ready ? 1.0 : 0.0
        Behavior on opacity { FadeAnimation {} }

        width: parent.width
        model: weatherModel
        orientation: ListView.Horizontal
        height: 2*Theme.itemSizeLarge
        anchors.bottom: parent.bottom
        delegate: MouseArea {
            property bool highlighted: (pressed && containsMouse) || root.currentIndex == model.index

            width: root.width/5.5
            height: weatherForecastList.height

            Rectangle {
                visible: highlighted
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: "transparent"
                    }
                    GradientStop {
                        position: 1.0
                        color: Theme.rgba(Theme.highlightBackgroundColor, 0.3)
                    }
                }
            }
            onClicked: root.currentIndex = model.index
            Column {
                anchors.centerIn: parent
                Label {
                    property bool truncate: implicitWidth > parent.width - Theme.paddingSmall

                    x: truncate ? Theme.paddingSmall : parent.width/2 - width/2
                    width: truncate ? parent.width - Theme.paddingSmall : implicitWidth
                    truncationMode: truncate ? TruncationMode.Fade : TruncationMode.None
                    text: model.index === 0 ?
                              //% "Today"
                              qsTrId("weather-la-today")
                            :
                              Qt.formatDateTime(model.timestamp, "ddd")
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall
                }
                Label {
                    text: model.high + "\u00B0"
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: highlighted ? Theme.highlightColor : Theme.primaryColor
                }
                Image {
                    sourceSize.width: width
                    sourceSize.height: height
                    width: Theme.iconSizeMedium
                    height: Theme.iconSizeMedium
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: model.weatherType.length > 0 ? "image://theme/graphic-weather-" + model.weatherType
                                                            + (highlighted ? "?" + Theme.highlightColor : "")
                                                          : ""
                }
                Label {
                    text: model.low + "\u00B0"
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                }
            }
        }
        PanelBackground {
            z: -1
            anchors.fill: parent
        }
    }
}
