/****************************************************************************************
** Copyright (c) 2018 - 2023 Jolla Ltd.
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

Row {
    id: root

    property alias weather: savedWeathersModel.currentWeather
    property alias autoRefresh: savedWeathersModel.autoRefresh
    property alias active: weatherModel.active
    property alias temperatureFont: temperatureLabel.font

    anchors.horizontalCenter: parent.horizontalCenter
    height: image.height
    spacing: Theme.paddingMedium
    visible: !!weather

    Image {
        id: image
        anchors.verticalCenter: parent.verticalCenter
        source: weather && weather.weatherType.length > 0
                ? "image://theme/icon-m-weather-" + weather.weatherType
                : ""
        // JB#43864 don't yet have weather graphics in small-plus size, so set size manually
        sourceSize.width: Theme.iconSizeSmallPlus
        sourceSize.height: Theme.iconSizeSmallPlus
    }

    Label {
        id: temperatureLabel
        anchors.verticalCenter: image.verticalCenter
        text: weather ? TemperatureConverter.format(weather.temperature) : ""
        color: Theme.primaryColor
        font {
            pixelSize: Theme.fontSizeExtraLarge
            family: Theme.fontFamilyHeading
        }
    }

    SavedWeathersModel {
        id: savedWeathersModel
        autoRefresh: true
    }

    WeatherModel {
        id: weatherModel
        weather: savedWeathersModel.currentWeather
        savedWeathers: savedWeathersModel
    }
}
