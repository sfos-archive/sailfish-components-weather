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
import Sailfish.Weather 1.0
import "ForecaToken.js" as Token

QtObject {
    id: root
    property bool active: true
    property string source
    readonly property bool online: WeatherConnectionHelper.online
    property int status: Weather.Null
    property string token
    property var request

    signal requestFinished(var result)

    onTokenChanged: sendRequest()
    onActiveChanged: if (active) attemptReload()
    onOnlineChanged: if (online) attemptReload()
    onSourceChanged: if (source.length > 0) attemptReload()
    Component.onCompleted: Token.fetchToken(this)

    // Note: this is overridden in WeatherModel and WeatherForecastModel
    function updateAllowed() {
        return active
    }

    function attemptReload(userRequested) {
        if (updateAllowed()) {
            reload(userRequested)
        } else if (userRequested) {
            console.log("Weather update not allowed (not active)")
        }
    }

    // userRequested: true to open a connection dialog in case
    //                there's no currently available connection;
    //                false for the request to fail silently
    function reload(userRequested) {
        if (online && source.length > 0) {
            status = Weather.Loading
            if (Token.fetchToken(root)) {
                sendRequest()
            }
        } else if (source.length === 0) {
            status = Weather.Null
        } else {
            status = Weather.Error
            if (userRequested) {
                WeatherConnectionHelper.attemptToConnectNetwork()
            } else {
                WeatherConnectionHelper.requestNetwork()
            }
        }
    }

    function sendRequest() {
        if (source.length > 0 && token.length > 0 && !request) {
            status = Weather.Loading
            request = new XMLHttpRequest()
            timeout.restart()

            // Send the proper header information along with the request
            request.onreadystatechange = function() { // Call a function when the state changes.
                if (request.readyState == XMLHttpRequest.DONE) {
                    timeout.stop()
                    if (request.status === 200) {
                        var data = JSON.parse(request.responseText)
                        requestFinished(data)
                        status = Weather.Ready
                    } else {
                        console.warn("Failed to obtain weather data. HTTP error code: " + request.status)
                        status = Weather.Error
                    }
                    request = undefined
                }
            }
            request.open("GET", source + "&token=" + token)
            request.send()
        }
    }
    property Timer timeout: Timer {
        id: timeout
        interval: 8000
        onTriggered: {
            if (request) {
                request.abort()
                request = undefined
                console.warn("Failed to obtain weather data. The request timed out after 8 seconds")
                status = Weather.Error
            }
        }
    }
}
