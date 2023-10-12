/****************************************************************************************
** Copyright (c) 2020 - 2023 Jolla Ltd.
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

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0

Column {
    width: parent.width
    anchors.centerIn: parent
    property bool highlighted
    Label {
        property bool truncate: implicitWidth > parent.width - Theme.paddingSmall

        x: truncate ? Theme.paddingSmall : parent.width/2 - width/2
        // Difficult layout due to limited horizontal space
        // Fade truncation overflows slightly to the adjacent delegate,
        // but should be ok since there is horizontal padding
        width: truncate ? parent.width : implicitWidth
        truncationMode: truncate ? TruncationMode.Fade : TruncationMode.None
        text: model.index === 0
              ? //% "Today"
                qsTrId("weather-la-today")
              : //% "ddd"
                Qt.formatDateTime(timestamp, qsTrId("weather-la-date_pattern_shortweekdays"))
        color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
        font.pixelSize: Theme.fontSizeSmall
    }
    Label {
        text: TemperatureConverter.format(model.high)
        anchors.horizontalCenter: parent.horizontalCenter
    }
    Image {
        property string prefix: "image://theme/icon-" + (Screen.sizeCategory >= Screen.Large ? "l" : "m")
        anchors.horizontalCenter: parent.horizontalCenter
        source: model.weatherType.length > 0 ? prefix + "-weather-" + model.weatherType
                                               + (highlighted ? "?" + Theme.highlightColor : "")
                                             : ""
    }
    Label {
        text: TemperatureConverter.format(model.low)
        anchors.horizontalCenter: parent.horizontalCenter
        color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
    }
}
