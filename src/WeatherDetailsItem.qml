import QtQuick 2.2
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0

Item {
    id: root

    property var model
    property var weather
    property bool today
    property int status

    width: parent.width
    height: childrenRect.height

    Column {
        width: parent.width
        PageHeader {
            id: pageHeader
            title: weather ? weather.city : ""
            description: {
                if (status === Weather.Error) {
                    //% "Loading failed"
                    return qsTrId("weather-la-weather_loading_failed")
                } else if (status === Weather.Loading) {
                    //% "Loading"
                    return qsTrId("weather-la-weather_loading")
                } else if (today) {
                    //% "Weather today"
                    return qsTrId("weather-la-weather_today")
                } else {
                    //% "Weather forecast"
                    return qsTrId("weather-la-weather_forecast")
                }
            }
        }


        Item {
            width: parent.width
            height: windDirectionIcon.height

            Label {
                id: temperatureHighLabel
                x: Theme.paddingLarge
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeHuge
                text: model ? converter.format(model.high) + "\u00B0" : ""
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
                text: model ? qsTrId("weather-la-low").arg(converter.format(model.low) + "\u00B0") : ""
            }
            Image {
                id: windDirectionIcon
                source: "image://theme/graphic-weather-wind-direction?" + Theme.highlightColor
                anchors.centerIn: parent
                rotation: model ? model.windDirection : 0
                Behavior on rotation {
                    RotationAnimator {
                        duration: 200
                        easing.type: Easing.InOutQuad
                        direction: RotationAnimator.Shortest
                    }
                }
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
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeHuge
                text: model ? model.accumulatedPrecipitation : ""
                anchors {
                    right: precipitationMetricLabel.left
                    verticalCenter: windDirectionIcon.verticalCenter
                }
            }
            Label {
                id: precipitationMetricLabel
                anchors {
                    baseline: accumulatedPrecipitationLabel.baseline
                    right: parent.right
                    rightMargin: Theme.paddingLarge
                }
                color: Theme.highlightColor
                //: Millimeters, short form
                //% "mm"
                text: qsTrId("weather-la-mm")
                font.pixelSize: Theme.fontSizeExtraSmall
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
                //% "Precipitation"
                text: qsTrId("weather-la-precipitation")
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
            height: lineCount === 1 ? 2*implicitHeight : implicitHeight
        }
        Item { width: 1; height: Theme.paddingMedium }
        Column {
            width: parent.width
            DetailItem {
                //% "Weather station"
                label: qsTrId("weather-la-weather_station")
                value: weather ? (weather.state.length > 0 ? weather.state + ", " : "") + weather.country : ""
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
