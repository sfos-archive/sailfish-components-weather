import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0

BackgroundItem {
    property var weather: savedWeathersModel.currentWeather
    property alias autoRefresh: savedWeathersModel.autoRefresh

    function update() {
        savedWeathersModel.loadWeather()
        weatherModel.active = true
        weatherModel.reload()
    }

    visible: enabled
    height: enabled ? Theme.itemSizeMedium : 0
    enabled: weather && weather.status == Weather.Ready
    onClicked: pageStack.push("WeatherPage.qml", { "weather": weather, "weatherModel": weatherModel })

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
        // TODO: instead pass only one location object
        locationId: savedWeathersModel.currentWeather.locationId
        onError: if (status == Weather.Loading) savedWeathersModel.reportError(locationId)
        onLoaded: {
            if (count > 0) {                
                var weather = get(0)
                savedWeathersModel.update({   "locationId": model.locationId,
                                              "city": model.city,
                                              "state": model.state,
                                              "country": model.country,
                                              "temperature": weather.temperature,
                                              "weatherType": weather.weatherType,
                                              "description": weather.description,
                                              "timestamp": weather.timestamp
                                          })
            }
        }
    }
}
