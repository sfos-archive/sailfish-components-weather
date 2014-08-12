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
    height: enabled ? Theme.itemSizeMedium : 0
    enabled: weather && weather.status == Weather.Ready
    onClicked: pageStack.push("WeatherPage.qml", { "weather": weather, "weatherModel": weatherModel, "inEventsView": true })

    Label {
        id: temperatureLabel
        text: weather ? TemperatureConverter.format(weather.temperature) + "\u00B0" : ""
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
            leftMargin: Theme.paddingLarge
            right: parent.right
        }
    }

    Item {
        clip: true
        width: parent.width
        height: image.height
        anchors.verticalCenter: parent.verticalCenter
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
    }

    SavedWeathersModel { id: savedWeathersModel }
    WeatherModel {
        id: weatherModel
        active: false
        locationId: savedWeathersModel.currentWeather.locationId
        onError: if (status == Weather.Loading) savedWeathersModel.reportError(locationId)
        onLoaded: {
            savedWeathersModel.update({   "locationId": savedWeathersModel.currentWeather.locationId,
                                          "city": savedWeathersModel.currentWeather.city,
                                          "state": savedWeathersModel.currentWeather.state,
                                          "country": savedWeathersModel.currentWeather.country,
                                          "temperature": currentWeather.temperature,
                                          "weatherType": currentWeather.weatherType,
                                          "description": currentWeather.description,
                                          "timestamp": currentWeather.timestamp
                                      })
        }
    }
}
