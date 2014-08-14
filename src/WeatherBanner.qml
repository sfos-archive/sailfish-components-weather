import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0

BackgroundItem {
    property alias weather: savedWeathersModel.currentWeather
    property alias autoRefresh: savedWeathersModel.autoRefresh

    function update() {
        weatherModel.active = true
        weatherModel.reload()
    }
    function save() {
        savedWeathersModel.save()
    }

    visible: enabled
    height: enabled ? temperatureLabel.height + 2*Theme.paddingLarge : 0
    enabled: weather && weather.status == Weather.Ready
    onClicked: pageStack.push("WeatherPage.qml", { "weather": weather, "weatherModel": weatherModel, "inEventsView": true })

    Label {
        id: temperatureLabel
        text: weather ? TemperatureConverter.format(weather.temperature) + "\u00B0" : ""
        color: highlighted ? Theme.highlightColor : Theme.primaryColor
        font {
            pixelSize: Theme.fontSizeHuge
            family: Theme.fontFamilyHeading
        }
        y: Theme.paddingLarge
        anchors {
            left: parent.left
            leftMargin: Theme.paddingLarge
        }
    }
    Label {
        text: weather ? weather.city : ""
        color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
        font {
            pixelSize: Theme.fontSizeHuge
            family: Theme.fontFamilyHeading
        }
        truncationMode: TruncationMode.Fade
        anchors {
            left: temperatureLabel.right
            leftMargin: Theme.paddingLarge
            verticalCenter: temperatureLabel.verticalCenter
            right: parent.right
        }
    }

    Item {
        clip: true
        width: parent.width
        height: image.height
        anchors.verticalCenter: temperatureLabel.verticalCenter
        Image {
            id: image
            opacity: 0.3
            anchors {
                right: parent.right
                rightMargin: -width/3
            }
            source: weather && weather.weatherType.length > 0 ? "image://theme/graphic-weather-" + weather.weatherType
                                                                + "?" + (highlighted ? Theme.highlightColor : Theme.primaryColor)
                                                              : ""
        }
    }

    SavedWeathersModel { id: savedWeathersModel }
    WeatherModel {
        id: weatherModel
        weather: savedWeathersModel.currentWeather
        savedWeathers: savedWeathersModel
        active: false
    }
}
