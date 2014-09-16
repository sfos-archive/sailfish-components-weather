import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import Sailfish.Weather 1.0
import "WeatherModel.js" as WeatherModel

XmlListModel {
    id: root

    property var weather
    property var savedWeathers
    property bool active: true
    property int locationId: weather ? weather.locationId : -1
    property date lastUpdate: new Date()
    property date timestamp: new Date()

    signal error

    onError: {
        if (savedWeathersModel && weather) {
            savedWeathersModel.reportError(locationId)
        }
        console.log("WeatherModel - could not obtain weather data")
    }

    query: "/xml/weather/obs"
    source: locationId > 0 ? "http://feed-jll.foreca.com/jolla-jan14fi/data.php?l=" + root.locationId + "&products=cc" : ""

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

    onStatusChanged: {
        if (status == XmlListModel.Ready) {
            var modelItem = get(0)
            if (modelItem.temperature === "") {
                error()
            }
            if (count > 0) {
                var data = WeatherModel.getWeatherData(modelItem, false)
                var json = {
                    "temperature": data.temperature,
                    "temperatureFeel": data.temperatureFeel,
                    "weatherType": data.weatherType,
                    "description": data.description,
                    "timestamp": data.timestamp
                }
                root.timestamp = data.timestamp
                savedWeathersModel.update(locationId, json)
            }
        } else if (status == XmlListModel.Error){
            error()
        } else if (status == XmlListModel.Loading) {
            console.log("WeatherModel reload")
        }
    }

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
