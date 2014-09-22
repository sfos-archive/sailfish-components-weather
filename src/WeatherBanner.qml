import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0

BackgroundItem {
    property alias weather: savedWeathersModel.currentWeather
    property alias autoRefresh: savedWeathersModel.autoRefresh
    property alias active: weatherModel.active

    onActiveChanged: if (!active) save()

    function reload() {
        weatherModel.reload()
    }
    function save() {
        savedWeathersModel.save()
    }

    visible: enabled
    height: enabled ? temperatureLabel.height + 2*(isPortrait ? Theme.paddingLarge : Theme.paddingMedium) : 0
    enabled: weather && weather.status == Weather.Ready
    onClicked: pageStack.push("WeatherPage.qml", { "weather": weather, "weatherModel": weatherModel, "inEventsView": true, "current": true })

    Label {
        id: temperatureLabel
        text: weather ? TemperatureConverter.format(weather.temperature) + "\u00B0" : ""
        color: highlighted ? Theme.highlightColor : Theme.primaryColor
        font {
            pixelSize: isPortrait ? Theme.fontSizeHuge : Theme.fontSizeExtraLarge
            family: Theme.fontFamilyHeading
        }
        y: isPortrait ? Theme.paddingLarge : Theme.paddingMedium
        anchors {
            left: parent.left
            leftMargin: Theme.paddingLarge
        }
    }
    Label {
        text: weather ? weather.city : ""
        color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
        font {
            pixelSize: isPortrait ? Theme.fontSizeHuge : Theme.fontSizeExtraLarge
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
    Connections {
        target: LocationDetection
        onReadyChanged: updateLocation()
        onLocationIdChanged: updateLocation()
        function updateLocation() {
            if (LocationDetection.ready && LocationDetection.locationId.length > 0) {
                var weather = {
                    "locationId": LocationDetection.locationId,
                    "city": LocationDetection.city,
                    "state": "",
                    "country": ""
                }
                savedWeathersModel.setCurrentWeather(weather)
                savedWeathersModel.metric = LocationDetection.metric
            }
        }
    }
    SavedWeathersModel {
        id: savedWeathersModel
    }
    Binding {
        target:	TemperatureConverter
        property: "metric"
        value: savedWeathersModel.metric
    }
    WeatherModel {
        id: weatherModel
        weather: savedWeathersModel.currentWeather
        savedWeathers: savedWeathersModel
    }
}
