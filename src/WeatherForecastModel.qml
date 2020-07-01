import QtQuick 2.0
import Sailfish.Weather 1.0
import "WeatherModel.js" as WeatherModel

ListModel {
    id: root

    property var weather
    property alias active: model.active
    property date timestamp
    property alias status: model.status
    readonly property int locationId: weather ? weather.locationId : -1

    readonly property WeatherRequest model: WeatherRequest {
        id: model
        source: root.locationId > 0 ? "https://pfa.foreca.com/api/v1/forecast/daily/" + root.locationId : ""

        function updateAllowed() {
            // update allowed every 3 hours
            return status === Weather.Error || status === Weather.Null || WeatherModel.updateAllowed(180*60*1000)
        }

        onRequestFinished: {
            var forecast = result["forecast"]
            if (result.length === 0 || forecast.length === "") {
                error = true
            } else {
                var weatherData = []
                for (var i = 0; i < forecast.length; i++) {
                    var data = forecast[i]
                    var weather = WeatherModel.getWeatherData(data)
                    var dateArray = data.date.split("-")
                    weather.timestamp = new Date(parseInt(dateArray[0]),
                                                 parseInt(dateArray[1] - 1),
                                                 parseInt(dateArray[2]))
                    weather.accumulatedPrecipitation = data.precipAccum
                    weather.maximumWindSpeed = data.maxWindSpeed
                    weather.windDirection = data.windDir
                    weather.high = data.maxTemp
                    weather.low = data.minTemp
                    weatherData[weatherData.length] = weather
                }

                while (root.count > weatherData.length) {
                    root.remove(weatherData.length)
                }

                for (i = 0; i < weatherData.length; i++) {
                    if (i < root.count) {
                        root.set(i, weatherData[i])
                    } else {
                        root.append(weatherData[i])
                    }
                }
            }
        }

        onStatusChanged: {
            if (status === Weather.Error) {
                console.log("WeatherForecastModel - could not obtain forecast weather data", weather ? weather.city : "", weather ? weather.locationId : "")
            }
        }
    }
}
