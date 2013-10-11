import QtQuick 2.0
import QtQuick.XmlListModel 2.0
import Sailfish.Weather 1.0

ListModel {
    id: root

    property int locationId
    property int status: Weather.Loading
    property bool forecast
    property XmlListModel xmlListModel

    signal loaded
    signal error

    function reload() {
        status =  Weather.Loading
        xmlListModel.reload()
    }

    function handleStatusChanged() {
        if (!xmlListModel)
            return
        var model = xmlListModel
        if (model.status == XmlListModel.Loading) {
        } else if (model.status == XmlListModel.Ready) {
            var weatherData = []
            for (var i = 0; i < model.count; i++) {
                var weather = model.get(i)
                var timestamp = new Date()
                timestamp.setDate(timestamp.getDate() - i);

                if (forecast) {
                    weatherData[i] = {
                        "description": weather.description,
                        "weatherType": weatherType(weather.code),
                        "high": weather.high,
                        "low": weather.low,
                        "timestamp": timestamp
                    }

                } else {
                    weatherData[i] = {
                        "temperature": weather.temperature,
                        "description": weather.description,
                        "weatherType": weatherType(weather.code),
                        "timestamp": timestamp
                    }
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
        var group = "unknown";
        switch(code) {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
        case 37:
        case 38:
        case 45:
        case 47:
            group = "thunder";
            break;
        case 10:
        case 11:
        case 12:
        case 40:
        case 42:
        case 35:
        case 8:
        case 9:
        case 5:
        case 6:
        case 7:
            group = "rain";
            break;
        case 13:
        case 14:
        case 15:
        case 16:
        case 17:
        case 18:
        case 41:
        case 43:
        case 46:
            group = "fog";
            break;
        case 20:
        case 21:
        case 22:
        case 26:
        case 27:
        case 28:
        case 29:
        case 30:
        case 44:
            group = "cloud";
            break;
        case 31:
        case 32:
        case 33:
        case 34:
        case 36:
        case 23:
        case 24:
        case 25:
        case 19:
        default:
            group = "sun";
            break;
        }
        return group;
    }
    Component.onCompleted: {
        if (forecast) {
            xmlListModel = forecastWeatherModel.createObject(this)
        } else {
            xmlListModel = currentWeatherModel.createObject(this)
        }
    }

    property var container: Item {
        Connections {
            target: Qt.application
            onActiveChanged: if (Qt.application.active) root.reload()
        }
        Component {
            id: currentWeatherModel
            XmlListModel {
                onStatusChanged: root.handleStatusChanged()

                // see http://developer.yahoo.com/weather for more info
                query: "/rss/channel/item"
                source: root.locationId > 0 ? "http://weather.yahooapis.com/forecastrss?w=" + root.locationId + "&u=c" : ""
                namespaceDeclarations: "declare namespace yweather=\"http://xml.weather.yahoo.com/ns/rss/1.0\";"
                XmlRole {
                    name: "description"
                    query: "yweather:condition/@text/string()"
                }
                XmlRole {
                    name: "code"
                    query: "yweather:condition/@code/number()"
                }
                XmlRole {
                    name: "temperature"
                    query: "yweather:condition/@temp/number()"
                }
            }
        }
        Component {
            id: forecastWeatherModel
            XmlListModel {
                onStatusChanged: root.handleStatusChanged()

                // see http://developer.yahoo.com/weather for more info
                query: "/rss/channel/item"
                source: root.locationId > 0 ? "http://weather.yahooapis.com/forecastrss?w=" + root.locationId + "&u=c" : ""
                namespaceDeclarations: "declare namespace yweather=\"http://xml.weather.yahoo.com/ns/rss/1.0\";"
                XmlRole {
                    name: "description"
                    query: "yweather:forecast/@text/string()"
                }
                XmlRole {
                    name: "code"
                    query: "yweather:forecast/@code/number()"
                }
                XmlRole {
                    name: "high"
                    query: "yweather:forecast/@high/number()"
                }
                XmlRole {
                    name: "low"
                    query: "yweather:forecast/@low/number()"
                }
            }
        }
    }
}

