import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import Sailfish.Weather 1.0

ListModel {
    id: root

    property var weatherConditions
    property var weather
    property var savedWeathers
    property bool active: true

    property int locationId
    property int status: Weather.Loading
    property date lastUpdate: new Date()
    property date lastUpdate: new Date()

    signal loaded
    signal error

    locationId: weather ? weather.locationId : "-1"
    onError: if (status == Weather.Loading) savedWeathersModel.reportError(locationId)
    onLoaded: {
        savedWeathersModel.update(locationId,
                                  {
                                      "temperature": weatherConditions.temperature,
                                      "temperatureFeel": weatherConditions.temperatureFeel,
                                      "weatherType": weatherConditions.weatherType,
                                      "description": weatherConditions.description,
                                      "timestamp": weatherConditions.timestamp
                                  })
    }
    onActiveChanged: {
        if (active) {
            var now = new Date()
            // only update automatically if more than 10 minutes has
            // passed since the last update (10*60*1000)
            if (now - 600000 > lastUpdate) {
                reload()
                lastUpdate = now
            }
        }
    }

    function reload() {
        forecastModel.reload()
        weatherConditionsModel.reload()
    }
    function getWeatherData(weather, forecast) {
        var dateArray
        if (forecast) {
            dateArray = weather.timestamp.split("-")
        } else {
            dateArray = weather.timestamp.split(" ")[0].split("-")
        }
        var timestamp =  new Date(parseInt(dateArray[0]),
                                  parseInt(dateArray[1] - 1),
                                  parseInt(dateArray[2]))

        if (!forecast) {
            var timeArray = weather.timestamp.split(" ")[1].split(":")
            timestamp.setHours(timeArray[0])
            timestamp.setMinutes(timeArray[1])
            timestamp.setSeconds(timeArray[2])
        }

        var precipirationRateCode = weather.code.charAt(2)
        var precipirationRate = ""
        switch (precipirationRateCode) {
        case '0':
            //% "No precipitation"
            precipirationRate = qsTrId("weather-la-no_precipitation")
            break
        case '1':
            //% "Slight precipitation"
            precipirationRate = qsTrId("weather-la-slight_precipitation")
            break
        case '2':
            //% "Showers"
            precipirationRate = qsTrId("weather-la-showers")
            break
        case '3':
            //% "Precipitation"
            precipirationRate = qsTrId("weather-la-precipitation")
            break
        case '4':
            //% "Thunder"
            precipirationRate = qsTrId("weather-la-thunder")
            break
        default:
            console.log("WeatherModel warning: invalid precipiration rate code", precipirationRateCode)
            break
        }

        var precipirationType = ""
        if (precipirationRateCode === '0') { // no rain
            //% "None"
            precipirationType = qsTrId("weather-la-none")
        } else {
            var precipirationTypeCode = weather.code.charAt(3)
            switch (precipirationTypeCode) {
            case '0':
                //% "Rain"
                precipirationType = qsTrId("weather-la-rain")
                break
            case '1':
                //% "Sleet"
                precipirationType = qsTrId("weather-la-sleet")
                break
            case '2':
                //% "Snow"
                precipirationType = qsTrId("weather-la-snow")
                break
            default:
                console.log("WeatherModel warning: invalid precipiration type code", precipirationTypeCode)
                break
            }
        }
        var windDirection = 0
        switch (weather.windDirection) {
        case 'N':
            windDirection = 0
            break
        case 'NW':
            windDirection = 45
            break
        case 'W':
            windDirection = 90
            break
        case 'SW':
            windDirection = 135
            break
        case 'S':
            windDirection = 180
            break
        case 'SE':
            windDirection = 225
            break
        case 'E':
            windDirection = 270
            break
        case 'NE':
            windDirection = 315
            break
        }

        var data = {
            "description": description(weather.code),
            "weatherType": weatherType(weather.code),
            "timestamp": timestamp,
            "cloudiness": (100*parseInt(weather.code.charAt(1))/4) + "%",
            "precipitationRate": precipirationRate,
            "precipitationType": precipirationType,
            "windSpeed": Math.round(weather.windSpeed),
            "windDirection": windDirection
        }

        if (forecast) {
            data.accumulatedPrecipitation = weather.accumulatedPrecipitation
            data.high = weather.high
            data.low = weather.low
        } else {
            data.temperature = weather.temperature
            data.temperatureFeel = weather.temperatureFeel
        }
        return data
    }

    function handleStatusChanged() {
        if (weatherConditionsModel.status == XmlListModel.Ready && forecastModel.status == XmlListModel.Ready) {

            if (weatherConditionsModel.get(0).temperature === "") {
                status = Weather.Error
                error()
                console.log("WeatherModel - could not obtain forecast weather data")
                return
            }
            weatherConditions = getWeatherData(weatherConditionsModel.get(0), false)
            var currentDate = new Date(weatherConditions.timestamp.getTime())
            currentDate.setHours(0)
            currentDate.setMinutes(0)
            var weatherData = []
            for (var i = 0; i < forecastModel.count; i++) {
                var weather = getWeatherData(forecastModel.get(i), true)

                if (weather.timestamp < currentDate) {
                    continue
                }
                weatherData[weatherData.length] = weather
            }
            while (count > weatherData.length) {
                remove(weatherData.length)
            }
            for (var i = 0; i < weatherData.length; i++) {
                if (i < count) {
                    set(i, weatherData[i])
                } else {
                    append(weatherData[i])
                }
            }
            status = Weather.Ready
            if (count > 0) {
                loaded()
            }
        } else {
            var oldStatus = status
            if (weatherConditionsModel.status === XmlListModel.Error || forecastModel.status === XmlListModel.Error) {
                status = Weather.Error
            } else if (weatherConditionsModel.status === XmlListModel.Loading || forecastModel.status === XmlListModel.Loading) {
                status = Weather.Loading
            }
            if (status === Weather.Error && status != oldStatus) {
                error()
                console.log("WeatherModel - could not obtain forecast weather data")
            }
        }
    }
    function weatherType(code) {
        var dayTime = code.charAt(0) === "d" ? "day" : "night"
        var cloudiness = code.charAt(1)
        var precipirationRate = code.charAt(2)
        var precipirationType = code.charAt(3)

        var type
        switch(precipirationRate) {
        case '0':
            switch (cloudiness) {
            case '0':
            case '1':
            case '2':
                type = "cloud-" + dayTime + "-" + cloudiness
                break
            case '3':
                type = "cloud-3"
                break
            case '4':
                type = "cloud-4"
                break
            default:
                console.log("WeatherModel warning: invalid cloudiness code", cloudiness)
                break
            }
            break
        case '1':
        case '2':
        case '3':
        case '4':
            switch (precipirationType) {
            case '0':
                type = "rain-water-" + precipirationRate
                break
            case '1':
                type = "rain-sleet-" + precipirationRate
                break
            case '2':
                type = "rain-snow-" + precipirationRate
                break
            default:
                console.log("WeatherModel warning: invalid precipiration type code", precipirationType)
                break
            }
            break
        default:
            type = "cloud-day-0"
            console.log("WeatherModel warning: invalid precipiration rate code", precipirationRate)
            break
        }
        return type
    }


    function description(code) {
        var localizations = {
            //% "Clear"
            "000": qsTrId("weather-la-clear"),
            //% "Mostly clear"
            "100": qsTrId("weather-la-mostly_clear"),
            //% "Partly cloudy"
            "200": qsTrId("weather-la-Partly cloudy"),
            //% "Cloudy"
            "300": qsTrId("weather-la-cloudy"),
            //% "Overcast"
            "400": qsTrId("weather-la-overcast"),
            //% "Partly cloudy and light rain"
            "210": qsTrId("weather-la-partly_cloudy_and_light_rain"),
            //% "Cloudy and light rain"
            "310": qsTrId("weather-la-cloudy_and_light_rain"),
            //% "Overcast and light rain"
            "410": qsTrId("weather-la-overcast_and_light_rain"),
            //% "Partly cloudy and showers"
            "220": qsTrId("weather-la-partly_cloudy_and_showers"),
            //% "Cloudy and showers"
            "320": qsTrId("weather-la-cloudy_and_showers"),
            //% "Overcast and showers"
            "420": qsTrId("weather-la-overcast_and_showers"),
            //% "Overcast and rain"
            "430": qsTrId("weather-la-overcast_and-rain"),
            //% "Partly cloudy, possible thunderstorms with rain"
            "240": qsTrId("weather-la-partly_cloudy_possible_thunderstorms_with_rain"),
            //% "Cloudy, thunderstorms with rain"
            "340": qsTrId("weather-la-cloudy_thunderstorms_with_rain"),
            //% "Overcast, thunderstorms with rain"
            "440": qsTrId("weather-la-overcast_thunderstorms_with_rain"),
            //% "Partly cloudy and light wet snow"
            "211": qsTrId("weather-la-partly_cloudy_and_light_wet_snow"),
            //% "Cloudy and light wet snow"
            "311": qsTrId("weather-la-cloudy_and_light_wet_snow"),
            //% "Overcast and light wet snow"
            "411": qsTrId("weather-la-overcast_and_light_wet_snow"),
            //% "Partly cloudy and wet snow showers"
            "221": qsTrId("weather-la-partly_cloudy_and_wet_snow_showers"),
            //% "Cloudy and wet snow showers"
            "321": qsTrId("weather-la-cloudy_and_wet_snow_showers"),
            //% "Overcast and wet snow showers"
            "421": qsTrId("weather-la-overcast_and_wet_snow_showers"),
            //% "Overcast and wet snow"
            "431": qsTrId("weather-la-overcast_and_wet_snow"),
            //% "Partly cloudy and light snow"
            "212": qsTrId("weather-la-partly_cloudy_and_light_snow"),
            //% "Cloudy and light snow"
            "312": qsTrId("weather-la-cloudy_and_light_snow"),
            //% "Overcast and light snow"
            "412": qsTrId("weather-la-overcast_and_light_snow"),
            //% "Partly cloudy and snow showers"
            "222": qsTrId("weather-la-partly_cloudy_and_snow_showers"),
            //% "Cloudy and snow showers"
            "322": qsTrId("weather-la-cloudy_and_snow_showers"),
            //% "Overcast and snow showers"
            "422": qsTrId("weather-la-overcast_and_snow_showers"),
            //% "Overcast and snow"
            "432": qsTrId("weather-la-overcast_and_snow")
        }

        return localizations[code.substr(1,3)]
    }
    property var currentDay: XmlListModel {
        id: weatherConditionsModel
        onStatusChanged: root.handleStatusChanged()

        // see http://developer.yahoo.com/weather for more info
        query: "/xml/weather/obs"
        source: root.locationId > 0 ? "http://feed-jll.foreca.com/jolla-jan14fi/data.php?l=" + root.locationId + "&products=cc" : ""

        XmlRole {
            name: "description"
            query: "@sT/string()"
        }
        XmlRole {
            name: "code"
            query: "@s/string()"
        }
        XmlRole {
            name: "timestamp"
            query: "@dt/string()"
        }
        XmlRole {
            name: "temperature"
            query: "@t/string()"
        }
        XmlRole {
            name: "temperatureFeel"
            query: "@t/string()"
        }
        XmlRole {
            name: "windSpeed"
            query: "@ws/number()"
        }
        XmlRole {
            name: "windDirection"
            query: "@wn/string()"
        }
        XmlRole {
            name: "accumulatedPrecipitation"
            query: "@pr/string()"
        }
    }
    property var forecast: XmlListModel {
        id: forecastModel
        onStatusChanged: root.handleStatusChanged()

        // see http://developer.yahoo.com/weather for more info
        query: "/xml/weather/fc"
        source: root.locationId > 0 ? "http://feed-jll.foreca.com/jolla-jan14fi/data.php?l=" + root.locationId + "&products=daily" : ""

        XmlRole {
            name: "description"
            query: "@sT/string()"
        }
        XmlRole {
            name: "code"
            query: "@s/string()"
        }
        XmlRole {
            name: "timestamp"
            query: "@dt/string()"
        }
        XmlRole {
            name: "high"
            query: "@tx/string()"
        }
        XmlRole {
            name: "low"
            query: "@tn/string()"
        }
        XmlRole {
            name: "windSpeed"
            query: "@wsa/number()"
        }
        XmlRole {
            name: "windDirection"
            query: "@wn/string()"
        }
        XmlRole {
            name: "accumulatedPrecipitation"
            query: "@pr/string()"
        }
    }
}
