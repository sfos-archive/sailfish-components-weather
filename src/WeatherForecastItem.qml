import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0

Column {
    width: parent.width
    anchors.centerIn: parent
    Label {
        property bool truncate: implicitWidth > parent.width - Theme.paddingSmall

        x: truncate ? Theme.paddingSmall : parent.width/2 - width/2
        width: truncate ? parent.width - Theme.paddingSmall : implicitWidth
        truncationMode: truncate ? TruncationMode.Fade : TruncationMode.None
        text: model.index === 0 ?
                  //% "Today"
                  qsTrId("weather-la-today")
                :
                  //% "ddd"
                  Qt.formatDateTime(timestamp, qsTrId("weather-la-date_pattern_shortweekdays"))
        color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
        font.pixelSize: Theme.fontSizeSmall
    }
    Label {
        text: TemperatureConverter.format(model.high)
        anchors.horizontalCenter: parent.horizontalCenter
        color: highlighted ? Theme.highlightColor : Theme.primaryColor
    }
    Image {
        sourceSize.width: width
        sourceSize.height: height
        width: Screen.sizeCategory >= Screen.Large ? Theme.iconSizeLarge : Theme.iconSizeMedium
        height: Screen.sizeCategory >= Screen.Large ? Theme.iconSizeLarge : Theme.iconSizeMedium
        anchors.horizontalCenter: parent.horizontalCenter
        source: model.weatherType.length > 0 ? "image://theme/graphic-weather-" + model.weatherType
                                               + (highlighted ? "?" + Theme.highlightColor : "")
                                             : ""
    }
    Label {
        text: TemperatureConverter.format(model.low)
        anchors.horizontalCenter: parent.horizontalCenter
        color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
    }
}
