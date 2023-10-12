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

import QtQuick 2.2
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0

Page {
    id: root

    property var weather
    property var weatherModel
    property int currentIndex
    property bool current

    SilicaFlickable {
        anchors {
            top: parent.top
            bottom: weatherForecastList.top
        }
        clip: true
        width: parent.width
        contentHeight: weatherHeader.height
        VerticalScrollDecorator {}

        PullDownMenu {
            visible: forecastModel.count > 0
            busy: forecastModel.status === Weather.Loading

            MenuItem {
                //% "More information"
                text: qsTrId("weather-me-more_information")
                onClicked: Qt.openUrlExternally("http://foreca.mobi/spot.php?l=" + root.weather.locationId)
            }
            MenuItem {
                //% "Update"
                text: qsTrId("weather-me-update")
                onClicked: forecastModel.reload(true)
            }
        }
        WeatherDetailsHeader {
            id: weatherHeader

            current: root.current
            today: root.currentIndex === 0
            opacity: forecastModel.count > 0 ? 1.0 : 0.0
            weather: root.weather
            status: forecastModel.status
            model: forecastModel.count > 0 ? forecastModel.get(currentIndex) : null
            Behavior on opacity { OpacityAnimator { easing.type: Easing.InOutQuad;  duration: 400 } }
        }
        PlaceholderItem {
            y: Theme.itemSizeSmall + Theme.itemSizeLarge*2
            error: forecastModel.status === Weather.Error
            unauthorized: forecastModel.status === Weather.Unauthorized
            enabled: forecastModel.count === 0
            onReload: forecastModel.reload(true)
        }
    }

    PanelBackground {
        width: parent.width
        height: weatherForecastList.height
        anchors.bottom: parent.bottom
        opacity: forecastModel.count > 0 ? 1.0 : 0.0
        Behavior on opacity { OpacityAnimator { easing.type: Easing.InOutQuad;  duration: 400 } }
    }
    SilicaListView {
        id: weatherForecastList

        readonly property int availableWidth: Screen.sizeCategory >= Screen.Large ? Screen.width : root.width
        readonly property int itemWidth: availableWidth/forecastModel.visibleCount

        width: forecastModel.visibleCount * itemWidth
        opacity: forecastModel.count > 0 ? 1.0 : 0.0
        Behavior on opacity { OpacityAnimator { easing.type: Easing.InOutQuad;  duration: 400 } }

        model: WeatherForecastModel {
            id: forecastModel
            weather: root.weather
            timestamp: weatherModel.timestamp
            active: root.status === PageStatus.Active && Qt.application.active
        }

        clip: true
        orientation: ListView.Horizontal
        height: 2*(Screen.sizeCategory >= Screen.Large ? Theme.itemSizeExtraLarge : Theme.itemSizeLarge)
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        delegate: MouseArea {
            readonly property bool down: pressed && containsMouse

            onClicked: root.currentIndex = model.index

            width: weatherForecastList.itemWidth
            height: weatherForecastList.height

            Rectangle {
                visible: down || root.currentIndex == model.index
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: "transparent"
                    }
                    GradientStop {
                        position: 1.0
                        color: Theme.rgba(Theme.highlightBackgroundColor,
                                          Theme.colorScheme === Theme.LightOnDark ? 0.3 : 0.5)
                    }
                }
            }

            DailyForecastItem {
                highlighted: down
            }
        }
    }
}
