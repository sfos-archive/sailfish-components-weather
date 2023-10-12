/****************************************************************************************
** Copyright (c) 2013 - 2023 Jolla Ltd.
**
** All rights reserved.
**
** This file is part of Sailfish Weather components package.
**
** You may use this file under the terms of BSD license as follows:
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are met:
**
** 1. Redistributions of source code must retain the above copyright notice, this
**    list of conditions and the following disclaimer.
**
** 2. Redistributions in binary form must reproduce the above copyright notice,
**    this list of conditions and the following disclaimer in the documentation
**    and/or other materials provided with the distribution.
**
** 3. Neither the name of the copyright holder nor the names of its
**    contributors may be used to endorse or promote products derived from
**    this software without specific prior written permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
** AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
** IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
** DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
** FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
** DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
** SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
** CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
** OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**
****************************************************************************************/

import QtQuick 2.2
import Sailfish.Silica 1.0

Item {
    id: root

    property bool error
    property bool unauthorized
    property bool empty
    property bool enabled
    property Flickable flickable
    property Item _animationHint
    property alias text: mainLabel.text

    signal reload

    function update() {
        if (!_animationHint && enabled && flickable) {
            _animationHint = animationHint.createObject(root)
        }
    }
    Component.onCompleted: update()
    onEnabledChanged: update()
    onFlickableChanged: update()

    width: parent.width
    height: mainLabel.height + Theme.paddingLarge + ((error || unauthorized) ? button.height : busyIndicator.height)
    opacity: enabled ? 1.0 : 0.0
    Behavior on opacity { OpacityAnimator { easing.type: Easing.InOutQuad;  duration: 400 } }
    Label {
        id: mainLabel

        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter

        text: {
            if (error) {
                //% "Loading failed"
                return qsTrId("weather-la-loading_failed")
            } else if (unauthorized) {
                //% "Invalid authentication credentials"
                return qsTrId("weather-la-unauthorized")
            }

            //% "Loading"
            return qsTrId("weather-la-loading")
        }
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
        running: parent.opacity > 0 && !error && !unauthorized && !empty
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
        enabled: error
        Behavior on opacity { FadeAnimation {} }
        anchors {
            top: mainLabel.bottom
            topMargin: Theme.paddingLarge
            horizontalCenter: parent.horizontalCenter
        }
        onClicked: reload()
    }
    Component {
        id: animationHint
        PulleyAnimationHint {
            enabled: !error && !unauthorized
            flickable: root.flickable
            width: parent.width
            height: width
            anchors.centerIn: parent
        }
    }
}
