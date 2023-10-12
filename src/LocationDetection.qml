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

pragma Singleton
import QtQuick 2.2
import Sailfish.Weather 1.0
import org.nemomobile.systemsettings 1.0

Item {
    id: root

    property bool ready: model && model.ready
    property bool error: model && model.error
    property string city: ready ? model.city : true
    property string locationId: ready ? model.locationId : ""
    property bool positioningAllowed: locationSettings.locationEnabled
    property bool metric: ready ? model.metric : true
    property QtObject model

    onPositioningAllowedChanged: handleLocationSetting()
    Component.onCompleted: handleLocationSetting()

    function updateLocation() {
        if (positioningAllowed && model) {
            model.updateLocation()
        }
    }
    function reloadModel() {
        if (positioningAllowed && model) {
            model.reloadModel()
        }
    }

    function handleLocationSetting() {
        if (positioningAllowed) {
            if (!model) {
                var modelComponent = Qt.createComponent("CurrentLocationModel.qml")
                if (modelComponent.status === Component.Ready) {
                    model = modelComponent.createObject(root)
                    model.positioningAllowed = Qt.binding(function() {
                        return positioningAllowed
                    })
                } else {
                    console.log(modelComponent.errorString())
                }
            }
        }
    }
    LocationSettings { id: locationSettings }
}
