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
import QtPositioning 5.2
import QtQuick.XmlListModel 2.0
import Nemo.KeepAlive 1.2

Item {
    id: model

    property bool ready
    property bool error
    property string city
    property string locationId
    property bool metric: true
    property bool positioningAllowed
    property bool locationObtained
    property bool active: true
    property real searchRadius: 10 // find biggest city in specified kilometers
    property var coordinate: positionSource.position.coordinate

    property string longitude: format(coordinate.longitude)
    property string latitude: format(coordinate.latitude)
    property bool waitForSecondUpdate

    function format(value) {
        // optimize Foreca backend caching by
        // rounding to closest even decimal
        // (0.02 degree accuracy) e.g. 0.99 -> 1.00, 175.5637 -> 175.56
        if (value) {
            var angle = value
            var integer = Math.floor(value)
            var decimal = 2*Math.round(50*(angle - integer))
            if (decimal == 100) {
                integer = Math.floor(value+1)
                decimal = 0
            }
            return integer.toString() + "." + (decimal < 10 ? "0" : "") + decimal.toString()
        } else {
            return "0.0"
        }
    }
    function updateLocation() {
        active = true
        // first update returns cached location, wait for real position fix
        waitForSecondUpdate = true
    }
    function reloadModel() {
        locationModel.reload()
    }

    XmlListModel {
        id: locationModel

        query: "/searchdata/location"
        source: locationObtained ? "http://fnw-jll.foreca.com/findloc.php"
                                   + "?lon=" + longitude
                                   + "&lat=" + latitude
                                   + "&format=xml/jolla-sep13fi"
                                   + "&radius=" + searchRadius
                                 :  ""
        onStatusChanged: {
            if (status === XmlListModel.Ready && count > 0) {
                var location = get(0)
                locationId = location.locationId
                city = location.city
                metric = (location.locale !== "gb" && location.locale !== "us")
                ready = true
            }
            if (status !== XmlListModel.Loading) {
                if (backgroundJob.running) {
                    backgroundJob.finished()
                }
            }
            error = (status === XmlListModel.Error)
        }

        XmlRole {
            name: "locationId"
            query: "id/string()"
        }
        XmlRole {
            name: "city"
            query: "name/string()"
        }
        XmlRole {
            name: "locale"
            query: "land/string()"
        }
    }
    PositionSource {
        id: positionSource
        active: model.positioningAllowed && model.active
        onPositionChanged: {
            locationObtained = true
            if (!waitForSecondUpdate) {
                model.active = false
            }
            waitForSecondUpdate = false
        }
    }
    BackgroundJob {
        id: backgroundJob

        triggeredOnEnable: true
        enabled: true
        frequency: BackgroundJob.ThirtyMinutes
        onTriggered: model.updateLocation()
    }
}
