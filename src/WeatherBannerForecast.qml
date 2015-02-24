import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0

Column {
    property bool loading: forecastModel.status == Weather.Loading && forecastModel.count === 0

    height: parent.height
    opacity: forecastModel.count > 0 ? 1.0 : 0.0
    Behavior on opacity { FadeAnimation {} }
    SilicaListView {
        id: weatherForecastList

        clip: true // limit to five day forecast
        currentIndex: -1
        x: Theme.horizontalPageMargin-Theme.paddingLarge
        width: parent.width - 2*x
        height: parent.height - providerDisclaimer.height
        interactive: false
        orientation: ListView.Horizontal
        model: WeatherForecastModel {
            id: forecastModel
            active: weatherBanner.expanded
            weather: weatherBanner.weather
            timestamp: weatherModel.timestamp
        }
        delegate: Item {
            width: weatherForecastList.width/5
            height: weatherForecastList.height
            WeatherForecastItem { id: forecastItem }
        }
    }
    MouseArea {
        id: providerDisclaimer

        property bool down: pressed && containsMouse

        onClicked: Qt.openUrlExternally("http://foreca.mobi/spot.php?l=" + savedWeathersModel.currentWeather.locationId)

        width: row.width
        height: row.height + Theme.paddingSmall
        anchors { right: parent.right; rightMargin: Theme.horizontalPageMargin }
        enabled: weatherBanner.expanded && savedWeathersModel.currentWeather && savedWeathersModel.currentWeather.populated
        Row {
            id: row

            spacing: Theme.paddingMedium
            Label {
                //% "Powered by"
                text: qsTrId("weather-la-powered_by")
                font.pixelSize: Theme.fontSizeTiny
                anchors.verticalCenter: parent.verticalCenter
                color: highlighted || providerDisclaimer.down ? Theme.secondaryHighlightColor : Theme.secondaryColor
            }
            Image {
                // TODO: replace with properly-sized icon from design
                anchors.verticalCenter: parent.verticalCenter
                source: "image://theme/graphic-foreca-small?" + (highlighted || providerDisclaimer.down ? Theme.highlightColor : Theme.primaryColor)
            }
        }
    }
}

