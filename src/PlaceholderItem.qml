import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0

Item {
    property int status
    property bool enabled: status != Weather.Ready
    property alias text: mainLabel.text

    signal reload

    width: parent.width
    height: mainLabel.height + Theme.paddingLarge
            + (status == Weather.Error ? button.height : busyIndicator.height)
    opacity: enabled ? 1.0 : 0.0
    Behavior on opacity { FadeAnimation {} }
    Label {
        id: mainLabel

        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        text: status == Weather.Error ?
                  //% "Loading failed"
                  qsTrId("weather-la-loading_failed")
                :
                  //% "Loading"
                  qsTrId("weather-la-loading")
        font {
            pixelSize: Theme.fontSizeExtraLarge
            family: Theme.fontFamilyHeading
        }
        anchors {
            left: parent.left
            right: parent.right
            margins: Theme.paddingLarge
        }
        color: Theme.highlightColor
        opacity: 0.6
    }
    BusyIndicator {
        id: busyIndicator
        running: parent.status == Weather.Loading
        size: BusyIndicatorSize.Large
        anchors {
            top: mainLabel.bottom
            topMargin: Theme.paddingLarge
            horizontalCenter: parent.horizontalCenter
        }
    }
    Button {
        id: button
        //% "Try again"
        text: qsTrId("weather-la-try_again")
        opacity: enabled ? 1.0 : 0.0
        enabled: status == Weather.Error
        Behavior on opacity { FadeAnimation {} }
        anchors {
            top: mainLabel.bottom
            topMargin: Theme.paddingLarge
            horizontalCenter: parent.horizontalCenter
        }
        onClicked: reload()
    }
}
