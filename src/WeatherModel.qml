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
import "WeatherModel.js" as WeatherModel

WeatherRequest {
    property var weather
    property var savedWeathers
    property date timestamp: new Date()
    readonly property int locationId: !!weather ? weather.locationId : -1

    readonly property WeatherRequest latestObservation: WeatherRequest {
        property var weatherJson
        // Store our own copy of locationId, since parent.locationId may change mid-fetch
        property int requestedLocationId: -1

        active: false
        source: requestedLocationId > 0
                ? "https://pfa.foreca.com/api/v1/observation/latest/" + requestedLocationId
                : ""
        onRequestFinished: {
            if (!weatherJson) return

            active = false;
            var observations = result["observations"]
            if (observations.length > 0) {
                weatherJson["station"] = observations[0].station
            }
            savedWeathersModel.update(requestedLocationId, weatherJson)
        }

        onStatusChanged: {
            if (status === Weather.Error || status == Weather.Unauthorized) {
                if (savedWeathers) {
                    savedWeathers.setErrorStatus(requestedLocationId, status)
                }

                console.log("WeatherModel - could not obtain weather station data", weather ? weather.city : "", weather ? weather.locationId : "")
            }
        }
    }

    source: locationId > 0 ? "https://pfa.foreca.com/api/v1/current/" + locationId : ""

    function updateAllowed() {
        return status === Weather.Null || status === Weather.Error || WeatherModel.updateAllowed()
    }

    onRequestFinished: {
        var current = result["current"]
        if (result.length === 0 || current.temperature === "") {
            status = Weather.Error
        } else {
            var weather = WeatherModel.getWeatherData(current)
            weather.timestamp =  new Date(current.time)
            this.timestamp = weather.timestamp

            weather.temperature = current.temperature
            weather.feelsLikeTemperature = current.feelsLikeTemp
            var json = {
                "temperature": weather.temperature,
                "feelsLikeTemperature": weather.feelsLikeTemperature,
                "weatherType": weather.weatherType,
                "description": weather.description,
                "timestamp": weather.timestamp
            }
            latestObservation.weatherJson = json
            latestObservation.requestedLocationId = locationId
            latestObservation.active = true
        }
    }

    onStatusChanged: {
        if (status === Weather.Error || status == Weather.Unauthorized) {
            if (savedWeathers) {
                savedWeathers.setErrorStatus(locationId, status)
            }

            console.log("WeatherModel - could not obtain weather data", weather ? weather.city : "", weather ? weather.locationId : "")
        }
    }
}
