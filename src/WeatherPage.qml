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
        contentHeight: column.height
        VerticalScrollDecorator {}
        Column {
            id: column
            width: parent.width
            PageHeader {
                id: pageHeader
                title: weather ? weather.city : ""
                Label {
                    id: secondaryLabel
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.secondaryHighlightColor
                    text: weather ? weather.state + ", " + weather.country : ""
                    horizontalAlignment: Text.AlignRight
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                        bottomMargin: -Theme.paddingSmall
                        rightMargin: Theme.paddingLarge
                    }
                }
                OpacityRampEffect {
                    sourceItem: secondaryLabel
                    direction: OpacityRamp.RightToLeft
                    offset: 0.75
                    slope: 4
                }
            }
            Item {
                width: parent.width
                height: Theme.paddingLarge
            }
            WeatherItem {
                enabled: false
                displayTime: false
                opacity: weatherModel.status == Weather.Ready ? 1.0 : 0.0
                weather: weatherModel.status == Weather.Ready ? weatherModel.get(currentIndex) : null
                Behavior on opacity { FadeAnimation {} }
            }
            Item {
                width: parent.width
                height: 2*Theme.paddingLarge
            }
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

        Image {
            width: parent.width
            source: "image://theme/graphic-gradient-edge"
        }

        width: parent.width
        model: weatherModel
        orientation: ListView.Horizontal
        height: 2*Theme.itemSizeLarge
        anchors.bottom: parent.bottom
        delegate: BackgroundItem {
            width: root.width/5.5
            height: weatherForecastList.height
            highlighted: down || root.currentIndex == model.index
            onClicked: root.currentIndex = model.index
            Column {
                anchors.centerIn: parent
                Label {
                    property bool truncate: implicitWidth > parent.width - Theme.paddingSmall

                    x: truncate ? Theme.paddingSmall : parent.width/2 - width/2
                    width: truncate ? parent.width - Theme.paddingSmall : implicitWidth
                    truncationMode: truncate ? TruncationMode.Fade : TruncationMode.None
                    text: Qt.formatDateTime(model.timestamp, "MMM")
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: highlighted ? Theme.highlightColor : Theme.secondaryColor
                }
                Label {
                    text: Qt.formatDateTime(model.timestamp, "d")
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: highlighted ? Theme.highlightColor : Theme.secondaryColor
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
                    text: model.temperature
                    font.pixelSize: Theme.fontSizeExtraSmall
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: highlighted ? Theme.highlightColor : Theme.secondaryColor

                    Label {
                        // TODO: add support for Fahrenheit
                        text: "\u00B0"
                        anchors.left: parent.right
                        font.pixelSize: Theme.fontSizeSmall
                        color: highlighted ? Theme.highlightColor : Theme.secondaryColor
                    }
                }
            }
        }
    }
}
