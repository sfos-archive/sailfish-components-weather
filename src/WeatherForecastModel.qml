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
import Sailfish.Weather 1.0
import "WeatherModel.js" as WeatherModel

ListModel {
    id: root

    property bool hourly
    property var weather
    property alias active: model.active
    property date timestamp
    property alias status: model.status
    property int visibleCount: 6
    property int minimumHourlyRange: 4
    readonly property bool loading: forecastModel.status == Weather.Loading
    readonly property int locationId: weather ? weather.locationId : -1

    onLocationIdChanged: {
        model.status = Weather.Null
        clear()
    }

    function attemptReload(userRequested) {
        model.attemptReload(userRequested)
    }

    function reload(userRequested) {
        model.reload(userRequested)
    }

    readonly property WeatherRequest model: WeatherRequest {
        id: model

        source: root.locationId > 0 ?
                    "https://pfa.foreca.com/api/v1/forecast/"
                    + (hourly ? "hourly/" : "daily/") + root.locationId : ""

        // update allowed every half hour for hourly weather, every 3 hours for daily weather
        property int maxUpdateInterval: hourly ? 30*60*1000 : 180*60*1000
        function updateAllowed() {
            return status !== Weather.Unauthorized && (status === Weather.Error || status === Weather.Null || WeatherModel.updateAllowed(maxUpdateInterval))
        }

        onRequestFinished: {
            var forecast = result["forecast"]
            if (result.length === 0 || forecast.length === "") {
                error = true
            } else {
                var weatherData = []
                for (var i = 0; i < forecast.length; i++) {
                    var data = forecast[i]
                    var weather = WeatherModel.getWeatherData(data)
                    if (hourly) {
                        if (i % 3 !== 0) continue
                        weather.timestamp =  new Date(data.time)
                        weather.temperature = data.temperature
                    } else {
                        var dateArray = data.date.split("-")
                        weather.timestamp = new Date(parseInt(dateArray[0]),
                                                     parseInt(dateArray[1] - 1),
                                                     parseInt(dateArray[2]))
                        weather.accumulatedPrecipitation = data.precipAccum
                        weather.maximumWindSpeed = data.maxWindSpeed
                        weather.windDirection = data.windDir
                        weather.high = data.maxTemp
                        weather.low = data.minTemp
                    }
                    weatherData[weatherData.length] = weather
                }

                if (hourly) {
                    var minimumTemperature = weatherData[0].temperature
                    var maximumTemperature = weatherData[0].temperature
                    for (i = 1; i < visibleCount + 1; i++) {
                        var temperature = weatherData[i].temperature
                        minimumTemperature = Math.min(minimumTemperature, temperature)
                        maximumTemperature = Math.max(maximumTemperature, temperature)
                    }
                    var range = maximumTemperature - minimumTemperature
                    if (range < minimumHourlyRange) {
                        minimumTemperature -= Math.floor((minimumHourlyRange - range ) / 2)
                        range = minimumHourlyRange
                    }

                    var array = []
                    for (i = 0; i < visibleCount + 1; i++) {
                        weatherData[i].relativeTemperature = (weatherData[i].temperature - minimumTemperature) / range
                    }
                }

                while (root.count > weatherData.length) {
                    root.remove(weatherData.length)
                }

                for (i = 0; i < weatherData.length; i++) {
                    if (i < root.count) {
                        root.set(i, weatherData[i])
                    } else {
                        root.append(weatherData[i])
                    }
                }
            }
        }

        onStatusChanged: {
            if (status === Weather.Error) {
                console.log("WeatherForecastModel - could not obtain forecast weather data", weather ? weather.city : "", weather ? weather.locationId : "")
            }
        }
    }
}
