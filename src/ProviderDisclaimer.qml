import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {
    height: column.height + 3*Theme.paddingLarge
    onClicked: Qt.openUrlExternally("http://foreca.mobi")
    Column {
        id: column
        width: parent.width
        spacing: Theme.paddingSmall
        Label {
            //% "Powered by"
            text: qsTrId("weather-la-powered_by")
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: Theme.fontSizeTiny
            color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
        }
        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            source: "image://theme/graphic-foreca?" + (highlighted ? Theme.highlightColor : Theme.primaryColor)
        }
        anchors {
            bottom: parent.bottom
            bottomMargin: 2*Theme.paddingLarge
        }
    }
}
