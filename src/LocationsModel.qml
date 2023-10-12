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

import QtQuick 2.0
import Sailfish.Weather 1.0

ListModel {
    id: root

    property string filter
    property alias status: model.status

    onFilterChanged: if (filter.length === 0) clear()

    function reload() {
        model.reload()
    }

    readonly property WeatherRequest model: WeatherRequest {
        id: model

        property string language: {
            var locale = Qt.locale().name
            if (locale === "zh_CN" || locale === "zh_TW") {
                return locale
            } else {
                return locale.split("_")[0]
            }
        }

        source: filter.length > 0 ? "https://pfa.foreca.com/api/v1/location/search/" + filter.toLowerCase() + "&lang=" + language : ""
        onRequestFinished: {
            var locations = result["locations"]
            if (result.length === 0 || locations === undefined) {
                status = Weather.Error
            } else {
                while (root.count > locations.length) {
                    root.remove(locations.length)
                }
                for (var i = 0; i < locations.length; i++) {
                    if (i < root.count) {
                        root.set(i, locations[i])
                    } else {
                        root.append(locations[i])
                    }
                }
            }
        }

        onStatusChanged: {
            if (status === Weather.Error || status === Weather.Unauthorized) {
                root.clear()
                console.log("LocationsModel - location search failed with query string", filter)
            }
        }
    }
}
