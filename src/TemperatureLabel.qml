/****************************************************************************************
** Copyright (c) 2014 - 2023 Jolla Ltd.
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

Item {
    property alias temperature: temperatureLabel.text
    property alias feelsLikeTemperature: feelsLikeTemperatureLabel.text
    property alias color: temperatureLabel.color

    height: temperatureLabel.height
    width: temperatureLabel.width + degreeSymbol.width + Theme.paddingMedium
    Label {
        id: temperatureLabel
        color: Theme.primaryColor

        // Glyphs larger than 100 or so look poorly in the default rendering mode
        renderType: font.pixelSize > 100 ? Text.NativeRendering : Text.QtRendering
        font {
            pixelSize: 120*Screen.width/540
            family: Theme.fontFamilyHeading
        }
    }
    Label {
        id: degreeSymbol
        text: "\u00B0"
        color: parent.color
        anchors {
            left: temperatureLabel.right
            leftMargin: Theme.paddingMedium
        }
        font {
            pixelSize: 3*Theme.fontSizeLarge
            family: Theme.fontFamilyHeading
        }
    }
    Label {
        id: feelsLikeTemperatureLabel
        opacity: 0.6
        color: parent.color
        font.pixelSize: Theme.fontSizeLarge
        anchors {
            baseline: temperatureLabel.baseline
            right: degreeSymbol.right
        }
    }
}
