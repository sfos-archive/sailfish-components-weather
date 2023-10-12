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

var lastUpdate = new Date()

function updateAllowed(interval) {
    // only update automatically if more than <interval> minutes has
    // passed since the last update (default 30mins: 30*60*1000)
    // or the date has changed
    interval = interval === undefined ? 30*60*1000 : interval
    var now = new Date()
    var updateAllowed = now.getDate() != lastUpdate.getDate() || (now - interval > lastUpdate)
    if (updateAllowed) {
        lastUpdate = now
    }
    return updateAllowed
}

function getWeatherData(weather) {
    var precipitationRateCode = weather.symbol.charAt(2)
    var precipitationRate = ""
    switch (precipitationRateCode) {
    case '0':
        //% "No precipitation"
        precipitationRate = qsTrId("weather-la-precipitation_none")
        break
    case '1':
        //% "Slight precipitation"
        precipitationRate = qsTrId("weather-la-precipitation_slight")
        break
    case '2':
        //% "Showers"
        precipitationRate = qsTrId("weather-la-precipitation_showers")
        break
    case '3':
        //% "Precipitation"
        precipitationRate = qsTrId("weather-la-precipitation_normal")
        break
    case '4':
        //% "Thunder"
        precipitationRate = qsTrId("weather-la-precipitation_thunder")
        break
    default:
        console.log("WeatherModel warning: invalid precipitation rate code", precipitationRateCode)
        break
    }

    var precipitationType = ""
    if (precipitationRateCode === '0') { // no rain
        //% "None"
        precipitationType = qsTrId("weather-la-precipitationtype_none")
    } else {
        var precipitationTypeCode = weather.symbol.charAt(3)
        switch (precipitationTypeCode) {
        case '0':
            //% "Rain"
            precipitationType = qsTrId("weather-la-precipitationtype_rain")
            break
        case '1':
            //% "Sleet"
            precipitationType = qsTrId("weather-la-precipitationtype_sleet")
            break
        case '2':
            //% "Snow"
            precipitationType = qsTrId("weather-la-precipitationtype_snow")
            break
        default:
            console.log("WeatherModel warning: invalid precipitation type code", precipitationTypeCode)
            break
        }
    }

    var data = {
        "description": description(weather.symbol),
        "weatherType": weatherType(weather.symbol),
        "cloudiness": (100*parseInt(weather.symbol.charAt(1))/4),
        "precipitationRate": precipitationRate,
        "precipitationType": precipitationType
    }
    return data
}

function weatherType(code) {
    // just direct mapping, but ensure we receive valid data
    if (code.length === 4) {
        return code
    } else {
        console.warn("Invalid weather code")
        return ""
    }
}

function description(code) {
    var localizations = {
        //% "Clear"
        "000": qsTrId("weather-la-description_clear"),
        //% "Mostly clear"
        "100": qsTrId("weather-la-description_mostly_clear"),
        //% "Partly cloudy"
        "200": qsTrId("weather-la-description_partly_cloudy"),
        //% "Cloudy"
        "300": qsTrId("weather-la-description_cloudy"),
        //% "Overcast"
        "400": qsTrId("weather-la-description_overcast"),
        //% "Thin high clouds"
        "500": qsTrId("weather-la-description-thin_high_clouds"),
        //% "Fog"
        "600": qsTrId("weather-la-description-fog"),
        //% "Partly cloudy and light rain"
        "210": qsTrId("weather-la-description_partly_cloudy_and_light_rain"),
        //% "Cloudy and light rain"
        "310": qsTrId("weather-la-description_cloudy_and_light_rain"),
        //% "Overcast and light rain"
        "410": qsTrId("weather-la-description_overcast_and_light_rain"),
        //% "Partly cloudy and showers"
        "220": qsTrId("weather-la-description_partly_cloudy_and_showers"),
        //% "Cloudy and showers"
        "320": qsTrId("weather-la-description_cloudy_and_showers"),
        //% "Overcast and showers"
        "420": qsTrId("weather-la-description_overcast_and_showers"),
        //% "Overcast and rain"
        "430": qsTrId("weather-la-description_overcast_and_rain"),
        //% "Partly cloudy, possible thunderstorms with rain"
        "240": qsTrId("weather-la-description_partly_cloudy_possible_thunderstorms_with_rain"),
        //% "Cloudy, thunderstorms with rain"
        "340": qsTrId("weather-la-description_cloudy_thunderstorms_with_rain"),
        //% "Overcast, thunderstorms with rain"
        "440": qsTrId("weather-la-description_overcast_thunderstorms_with_rain"),
        //% "Partly cloudy and light wet snow"
        "211": qsTrId("weather-la-description_partly_cloudy_and_light_wet_snow"),
        //% "Cloudy and light wet snow"
        "311": qsTrId("weather-la-description_cloudy_and_light_wet_snow"),
        //% "Overcast and light wet snow"
        "411": qsTrId("weather-la-description_overcast_and_light_wet_snow"),
        //% "Partly cloudy and wet snow showers"
        "221": qsTrId("weather-la-description_partly_cloudy_and_wet_snow_showers"),
        //% "Cloudy and wet snow showers"
        "321": qsTrId("weather-la-description_cloudy_and_wet_snow_showers"),
        //% "Overcast and wet snow showers"
        "421": qsTrId("weather-la-description_overcast_and_wet_snow_showers"),
        //% "Overcast and wet snow"
        "431": qsTrId("weather-la-description_overcast_and_wet_snow"),
        //% "Partly cloudy and light snow"
        "212": qsTrId("weather-la-description_partly_cloudy_and_light_snow"),
        //% "Cloudy and light snow"
        "312": qsTrId("weather-la-description_cloudy_and_light_snow"),
        //% "Overcast and light snow"
        "412": qsTrId("weather-la-description_overcast_and_light_snow"),
        //% "Partly cloudy and snow showers"
        "222": qsTrId("weather-la-description_partly_cloudy_and_snow_showers"),
        //% "Cloudy and snow showers"
        "322": qsTrId("weather-la-description_cloudy_and_snow_showers"),
        //% "Overcast and snow showers"
        "422": qsTrId("weather-la-description_overcast_and_snow_showers"),
        //% "Overcast and snow"
        "432": qsTrId("weather-la-description_overcast_and_snow")
    }

    return localizations[code.substr(1,3)]
}
