import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0

Item {
    id: root

    property var model
    property var weather
    property bool today

    width: parent.width
    height: childrenRect.height

    Column {
        width: parent.width
        PageHeader {
            id: pageHeader
            title: weather ? weather.city : ""
            //% "Weather today"
            description: today ? qsTrId("weather-la-weather_today")
                                 //% "Weather forecast"
                               : qsTrId("weather-la-weather_forecast")
        }
        Item {
            width: parent.width
            height: windDirectionIcon.height

            Label {
                id: temperatureHighLabel
                x: Theme.paddingLarge
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeHuge
                text: model ? model.high + "\u00B0" : ""
                anchors.verticalCenter: windDirectionIcon.verticalCenter
            }
            Label {
                x: Theme.paddingLarge
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeExtraSmall
                anchors {
                    top: temperatureHighLabel.baseline
                    topMargin: Theme.paddingSmall
                }
                //% "Low %1"
                text: model ? qsTrId("weather-la-low").arg(model.low + "\u00B0") : ""
            }
            Image {
                id: windDirectionIcon
                source: "image://theme/graphic-weather-wind-direction?" + Theme.highlightColor
                anchors.centerIn: parent
                rotation: model ? model.windDirection : 0
                Behavior on rotation { SmoothedAnimation { velocity: 600*Theme.pixelRatio } }
            }
            Label {
                id: windSpeedLabel
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeHuge
                anchors.centerIn: windDirectionIcon
                text: model ? model.windSpeed : ""
            }
            Label {
                anchors {
                    horizontalCenter: windSpeedLabel.horizontalCenter
                    top: windSpeedLabel.baseline
                    topMargin: Theme.paddingSmall
                }

                // TODO: localize
                //: Meters per second, short form
                //% "m/s"
                text: qsTrId("weather-la-m_per_s")
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeExtraSmall
            }
            Label {
                id: accumulatedPrecipitationLabel
                anchors {
                    right: parent.right
                    rightMargin: Theme.paddingLarge
                }
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeHuge
                text: model ? model.accumulatedPrecipitation : ""
                anchors.verticalCenter: windDirectionIcon.verticalCenter
            }
            Label {
                anchors {
                    right: parent.right
                    rightMargin: Theme.paddingLarge
                    top: accumulatedPrecipitationLabel.baseline
                    topMargin: Theme.paddingSmall
                }
                horizontalAlignment: Text.AlignRight
                width: parent.width/3 - Theme.paddingLarge
                wrapMode: Text.WordWrap
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeExtraSmall
                //: Accumulated precipitation in millimeters
                //% "Accumulated precipitation (mm)"
                text: qsTrId("weather-la-accumulated_precipitation_mm")
            }
        }
        Item { width: 1; height: Theme.paddingLarge }
        Label {
            color: Theme.highlightColor
            anchors {
                left: parent.left
                right: parent.right
                leftMargin: Theme.paddingLarge
                rightMargin: Theme.paddingLarge
            }
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeLarge
            horizontalAlignment: Text.AlignHCenter
            text: model ? model.description : ""
        }
        Item { width: 1; height: Theme.paddingLarge }
        Column {
            width: parent.width
            DetailItem {
                //% "Weather station"
                label: qsTrId("weather-la-weather_station")
                value: weather ? weather.state + ", " + weather.country : ""
            }
            DetailItem {
                //% "Date"
                label: qsTrId("weather-la-weather_date")
                value: {
                    var dateString = Format.formatDate(model.timestamp, Format.DateLong)
                    return dateString.charAt(0).toUpperCase() + dateString.substr(1)
                }
            }
            DetailItem {
                //% "Cloudiness"
                label: qsTrId("weather-la-cloudiness")
                value: model ? model.cloudiness : ""
            }
            DetailItem {
                //% "Precipitation rate"
                label: qsTrId("weather-la-precipitationRate")
                value: model ? model.precipitationRate : ""
            }
            DetailItem {
                //% "Precipitation type"
                label: qsTrId("weather-la-precipitationType")
                value: model ? model.precipitationType : ""
            }
        }
    }
}
