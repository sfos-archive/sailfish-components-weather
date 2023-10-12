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
import Sailfish.Weather 1.0

MouseArea {
    id: root

    property var weather
    property bool highlighted: pressed && containsMouse
    property date timestamp: weather ? weather.timestamp : new Date()

    enabled: weather && weather.populated
    width: parent.width
    height: childrenRect.height

    Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
    WeatherImage {
        id: weatherImage
        x: Theme.horizontalPageMargin
        y: 2*Theme.horizontalPageMargin
        highlighted: root.highlighted
        height: sourceSize.height > 0 ? sourceSize.height : 256*Theme.pixelRatio
        weatherType: weather && weather.weatherType.length > 0 ? weather.weatherType : ""
    }
    PageHeader {
        id: pageHeader
        property int offset: _titleItem.y + _titleItem.height
        anchors {
            left: weatherImage.right
            // weather graphics have some inline padding and rounded edges to give space for header
            leftMargin: -Theme.itemSizeMedium
            right: parent.right
        }
        title: weather ? (weather.city + ", " + weather.country
                          + (weather.adminArea ? (", " + weather.adminArea) : "")) : ""
    }
    Column {
        id: column
        anchors {
            top: pageHeader.top
            topMargin: pageHeader.offset
            left: weatherImage.right
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
        }

        spacing: -Theme.paddingMedium
        Item {
            width: parent.width
            height: secondaryLabel.height + timestampLabel.height
            Label {
                id: secondaryLabel
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryHighlightColor
                //% "Current location"
                text: qsTrId("weather-la-current_location")
                horizontalAlignment: Text.AlignRight
                wrapMode: Text.Wrap
                width: parent.width
            }
            Label {
                id: timestampLabel
                width: parent.width
                wrapMode: Text.Wrap
                anchors.top: secondaryLabel.bottom
                font.pixelSize: Theme.fontSizeSmall
                horizontalAlignment: Text.AlignRight
                color: Theme.secondaryHighlightColor
                text: Format.formatDate(timestamp, Format.TimeValue)
            }
        }
        TemperatureLabel {
            anchors.right: parent.right
            temperature: weather ? TemperatureConverter.formatWithoutUnit(weather.temperature) : ""
            feelsLikeTemperature: weather ? TemperatureConverter.formatWithoutUnit(weather.feelsLikeTemperature) : ""
            color: highlighted ? Theme.highlightColor : Theme.primaryColor
        }
    }
    Label {
        anchors {
            top: column.bottom
            topMargin: -Theme.paddingMedium
            left: parent.left
            right: parent.right
            leftMargin: Theme.horizontalPageMargin
            rightMargin: Theme.horizontalPageMargin
        }
        color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
        font {
            pixelSize: Theme.fontSizeExtraLarge
            family: Theme.fontFamilyHeading
        }
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignRight
        text: weather ? weather.description : ""
    }
}
