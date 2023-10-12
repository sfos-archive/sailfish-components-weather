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

.import Sailfish.Weather 1.0 as Weather
.pragma library

var user = ""
var password = ""
var token = ""
var tokenRequest
var pendingTokenRequests = []
var lastUpdate = new Date()

function fetchToken(model) {
    if (model == undefined) {
        console.warn("Token requested for undefined or null model")
        return false
    }

    if (token.length > 0 && !updateAllowed()) {
        model.token = token
        return true
    } else {
        if (!tokenRequest) {

            if (user.length === 0 || password.length === 0) {
                var keyProvider = Qt.createQmlObject(
                            "import com.jolla.settings.accounts 1.0; StoredKeyProvider {}",
                            model, "StoreKeyProvider")

                user = keyProvider.storedKey("foreca", "", "user")
                password = keyProvider.storedKey("foreca", "", "password")
                keyProvider.destroy()

                if (user.length === 0 || password.length === 0) {
                    console.warn("Unable to get Foreca credentials needed to identify with the service")
                    return false
                }
            }

            tokenRequest = new XMLHttpRequest()

            var url = "https://pfa.foreca.com/authorize/token?user=" + user + "&password=" + password

            // Send the proper header information along with the tokenRequest
            tokenRequest.onreadystatechange = function() { // Call a function when the state changes.
                if (tokenRequest.readyState == XMLHttpRequest.DONE) {
                    if (tokenRequest.status == 200) {
                        var json = JSON.parse(tokenRequest.responseText)
                        token = json["access_token"]
                    } else {
                        token = ""
                        console.log("Failed to obtain Foreca token. HTTP error code: " + tokenRequest.status)
                    }

                    for (var i = 0; i < pendingTokenRequests.length; i++) {
                        pendingTokenRequests[i].token = token
                        if (tokenRequest.status !== 200) {
                            pendingTokenRequests[i].status = (tokenRequest.status === 401) ? Weather.Weather.Unauthorized : Weather.Weather.Error
                        }
                    }
                    pendingTokenRequests = []
                    tokenRequest = undefined
                }
            }
            tokenRequest.open("GET", url)
            tokenRequest.send()
        }
        pendingTokenRequests[pendingTokenRequests.length] = model
    }
    return false
}

function updateAllowed(interval) {
    // only update token if older than 45 minutes
    interval = interval === undefined ? 45*60*1000 : interval
    var now = new Date()
    var updateAllowed = now.getDate() != lastUpdate.getDate() || (now - interval > lastUpdate)
    if (updateAllowed) {
        lastUpdate = now
    }
    return updateAllowed
}
