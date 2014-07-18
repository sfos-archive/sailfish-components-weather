import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import Sailfish.Weather 1.0

ListModel {
    id: root

    property int locationId
    property int status: Weather.Loading

    signal loaded
    signal error

    function reload() {
        status =  Weather.Loading
        xmlListModel.reload()
    }

    function handleStatusChanged() {
        var model = xmlListModel
        if (model.status == XmlListModel.Loading) {
        } else if (model.status == XmlListModel.Ready) {
            var weatherData = []
            for (var i = 0; i < model.count; i++) {
                var weather = model.get(i)
                var timestamp = new Date()
                timestamp.setDate(timestamp.getDate() - i);

                weatherData[i] = {
                    "description": description(weather.code),
                    "weatherType": weatherType(weather.code),
                    "temperature": weather.high,
                    "timestamp": timestamp
                }
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
            if (model.status == XmlListModel.Error) {
                status = Weather.Error
                error()
                console.log("WeatherModel - error obtaining weather data", model.errorString())
            }
        }
    }
    function weatherType(code) {
        var cloudiness = parseInt(code.charAt(1))
        var precipirationRate = parseInt(code.charAt(2))
        var precipirationType = parseInt(code.charAt(3))

        var group
        switch(precipirationRate) {
        case 0:
            switch (cloudiness) {
            case 0:
            case 1:
                group = "sun"
                break
            case 2:
            case 3:
            case 4:
                group = "cloud"
                break
            default:
                break
            }
            break
        case 1:
            group = "fog";
            break;
        case 2:
        case 3:
            group = "rain";
            break;
        case 4:
            group = "thunder";
            break;
        default:
            group = "sun"
            break
        }
        return group
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
            //% "Partly cloudy, possible thuderstorms with rain"
            "240": qsTrId("weather-la-partly_cloudy_possible_thuderstorms_with_rain"),
            //% "Cloudy, thuderstorms with rain"
            "340": qsTrId("weather-la-cloudy_thuderstorms_with_rain"),
            //% "Overcast, thuderstorms with rain"
            "440": qsTrId("weather-la-overcast_thuderstorms_with_rain"),
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
    property var container: Item {
        Connections {
            target: Qt.application
            onActiveChanged: if (Qt.application.active) root.reload()
        }
        XmlListModel {
            id: xmlListModel
            onStatusChanged: root.handleStatusChanged()

            // see http://developer.yahoo.com/weather for more info
            query: "/xml/weather/fc"
            source: root.locationId > 0 ? "http://feed.foreca.com/jolla-jan14fi/data.php?l=" + root.locationId + "&products=cc,daily" : ""

            XmlRole {
                name: "description"
                query: "@sT/string()"
            }
            XmlRole {
                name: "code"
                query: "@s/string()"
            }
            XmlRole {
                name: "high"
                query: "@tx/number()"
            }
            XmlRole {
                name: "low"
                query: "@tn/number()"
            }
        }
    }
}
