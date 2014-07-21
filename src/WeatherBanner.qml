import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0

BackgroundItem {
    property var weather: savedWeathersModel.currentWeather
    property alias autoRefresh: savedWeathersModel.autoRefresh

    function update() {
        savedWeathersModel.loadWeather()
    }

    visible: enabled
    height: enabled ? Theme.itemSizeMedium : 0
    enabled: weather && weather.status == Weather.Ready
    onClicked: pageStack.push("WeatherPage.qml", { "weather": weather })

    Label {
        id: temperatureLabel
        // TODO: support Fahrenheit
        text: weather ? weather.temperature + "\u00B0" : ""
        color: Theme.highlightColor
        font {
            pixelSize: Theme.fontSizeHuge
            family: Theme.fontFamilyHeading
        }
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: Theme.paddingLarge
        }
    }
    Label {
        text: weather ? weather.city : ""
        color: Theme.secondaryHighlightColor
        font {
            pixelSize: Theme.fontSizeHuge
            family: Theme.fontFamilyHeading
        }
        truncationMode: TruncationMode.Fade
        anchors {
            verticalCenter: parent.verticalCenter
            left: temperatureLabel.right
            leftMargin: Theme.paddingSmall
            right: parent.right
        }
    }

    Image {
        id: image
        opacity: 0.3
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: -width/3
        }
        source: weather && weather.weatherType.length > 0 ? "image://theme/graphic-weather-" + weather.weatherType
                                                            + (highlighted ? "?" + Theme.highlightColor : "")
                                                          : ""
    }
    SavedWeathersModel { id: savedWeathersModel }
}
