import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0

Page {
    id: root

    property var weather
    property var weatherModel
    property int currentIndex
    property bool inEventsView
    property bool current

    SilicaFlickable {
        anchors {
            top: parent.top
            bottom: weatherForecastList.top
        }
        clip: true
        width: parent.width
        contentHeight: weatherItem.height
        VerticalScrollDecorator {}

        PullDownMenu {
            visible: weatherModel.count > 0
            busy: weatherModel.status === Weather.Loading

            MenuItem {
                visible: inEventsView
                //% "Open app"
                text: qsTrId("weather-me-open_app")
                onClicked: launcher.launch()
                WeatherLauncher { id: launcher }
            }
            MenuItem {
                //% "More information"
                text: qsTrId("weather-me-more_information")
                onClicked: Qt.openUrlExternally("http://foreca.mobi/spot.php?l=" + root.weather.locationId)
            }
            MenuItem {
                //% "Update"
                text: qsTrId("weather-me-update")
                onClicked: weatherModel.reload()
            }
        }
        WeatherDetailsItem {
            id: weatherItem

            current: root.current
            today: root.currentIndex === 0
            opacity: weatherModel.count > 0 ? 1.0 : 0.0
            weather: root.weather
            status: weatherModel.status
            model: weatherModel.count > 0 ? weatherModel.get(currentIndex) : null
            Behavior on opacity { FadeAnimation {} }
        }
        PlaceholderItem {
            y: Theme.itemSizeSmall + Theme.itemSizeLarge*2
            status: weatherModel.status
            enabled: weatherModel.count === 0
            onReload: weatherModel.reload()
        }
    }
    SilicaListView {
        id: weatherForecastList

        opacity: weatherModel.count > 0 ? 1.0 : 0.0
        Behavior on opacity { FadeAnimation {} }

        interactive: false
        width: parent.width
        model: weatherModel
        orientation: ListView.Horizontal
        height: 2*Theme.itemSizeLarge
        anchors.bottom: parent.bottom
        delegate: MouseArea {
            property bool highlighted: (pressed && containsMouse) || root.currentIndex == model.index

            width: root.width/5
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
                    text: TemperatureConverter.format(model.high) + "\u00B0"
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
                    text: TemperatureConverter.format(model.low) + "\u00B0"
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
