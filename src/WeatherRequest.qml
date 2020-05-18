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

    function updateAllowed() {
        return true
    }

    function attemptReload() {
        if (updateAllowed()) {
            reload()
        }
    }

    function reload() {
        if (online && source.length > 0) {
            status = Weather.Loading
            if (Token.fetchToken(root)) {
                sendRequest()
            }
        } else {
            status = Weather.Null
            WeatherConnectionHelper.requestNetwork()
        }
    }

    function sendRequest() {
        if (source.length > 0 && token.length > 0 && !request) {
            status = Weather.Loading
            request = new XMLHttpRequest()

            // Send the proper header information along with the request
            request.onreadystatechange = function() { // Call a function when the state changes.
                if (request.readyState == XMLHttpRequest.DONE) {
                    if (request.status === 200) {
                        var data = JSON.parse(request.responseText)
                        requestFinished(data)
                        request = undefined
                        status = Weather.Ready
                    } else {
                        console.warn("Failed to optain weather data. HTTP error code:" + request.status)
                        status = Weather.Error
                    }
                }
            }
            request.open("GET", source + "&token=" + token)
            request.send()
        }
    }
}
