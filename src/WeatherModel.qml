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
                    "description": weather.description,
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
