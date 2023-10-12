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

#ifndef SAVEDWEATHERSMODEL_H
#define SAVEDWEATHERSMODEL_H

#include <QAbstractListModel>

#include "weather.h"

class QFileSystemWatcher;

class SavedWeathersModel: public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(Weather *currentWeather READ currentWeather NOTIFY currentWeatherChanged)
    Q_PROPERTY(bool autoRefresh READ autoRefresh WRITE setAutoRefresh NOTIFY autoRefreshChanged)

public:
    enum Roles {
        LocationId = Qt::UserRole,
        Status,
        Station,
        City,
        AdminArea,
        AdminArea2,
        State,
        Country,
        Temperature,
        FeelsLikeTemperature,
        WeatherType,
        Description,
        Timestamp,
        Populated
    };

    SavedWeathersModel(QObject *parent = 0);
    ~SavedWeathersModel();

    virtual int rowCount(const QModelIndex &parent = QModelIndex()) const;
    virtual QVariant data(const QModelIndex &index, int role) const;

    Q_INVOKABLE void setErrorStatus(int locationId, int status);
    Q_INVOKABLE void addLocation(const QVariantMap &locationMap);
    Q_INVOKABLE void update(int locationId, const QVariantMap &weatherMap, Weather::Status status = Weather::Ready, bool internal = false);
    Q_INVOKABLE void remove(int locationId);
    Q_INVOKABLE Weather *get(int locationId);
    Q_INVOKABLE void moveToTop(int index);
    Q_INVOKABLE void save();

    int count() const;

    Weather *currentWeather() const;
    Q_INVOKABLE void setCurrentWeather(const QVariantMap &locationMap, bool internal = false);

    // Automatically reload cached data when it is changed by another model
    // Default false
    bool autoRefresh() const;
    void setAutoRefresh(bool enabled);

    void addLocation(Weather * weather);
    void load();

signals:
    void countChanged();
    void currentWeatherChanged();
    void autoRefreshChanged();

protected:
    QHash<int, QByteArray> roleNames() const;
    QJsonObject convertToJson(const Weather *weather);
private:
    Weather *m_currentWeather;
    QList <Weather *> m_savedWeathers;
    bool m_autoRefresh;
    QFileSystemWatcher *m_fileWatcher;

    int getWeatherIndex(int locationId);
};

QML_DECLARE_TYPE(SavedWeathersModel)

#endif // SAVEDWEATHERSMODEL_H
