#include "savedweathersmodel.h"
#include <QSqlQuery>
#include <QSqlRecord>
#include <QDir>
#include <qqmlinfo.h>
#include <QSqlError>

SavedWeathersModel::SavedWeathersModel(QObject *parent)
    : QAbstractListModel(parent), m_currentIndex(-1)
{
    createConnectionToDatabase();
    QSqlQuery query("select * from locations", m_database);

    int locationIdIndex = query.record().indexOf("locationId");
    int statusIndex = query.record().indexOf("status");
    int isCurrentIndex = query.record().indexOf("isCurrent");
    int cityIndex = query.record().indexOf("city");
    int stateIndex = query.record().indexOf("state");
    int countryIndex = query.record().indexOf("country");
    int temperatureIndex = query.record().indexOf("temperature");
    int weatherTypeIndex = query.record().indexOf("weatherType");
    int descriptionIndex = query.record().indexOf("description");
    int timestampIndex = query.record().indexOf("timestamp");

    while (query.next()) {
        Weather *weather = new Weather(this, query.value(locationIdIndex).toInt(),
                                       query.value(cityIndex).toString(),
                                       query.value(stateIndex).toString(),
                                       query.value(countryIndex).toString());

        weather->setStatus(Weather::Status(query.value(statusIndex).toInt()));
        if (weather->status() == Weather::Ready) {
            weather->setTemperature(query.value(temperatureIndex).toInt());
            weather->setWeatherType(query.value(weatherTypeIndex).toString());
            weather->setDescription(query.value(descriptionIndex).toString());
            weather->setTimestamp(query.value(timestampIndex).toDateTime());
        }

        if (query.value(isCurrentIndex).toBool()) {
            m_currentIndex = m_savedWeathers.count();
        }
        m_savedWeathers.append(weather);
    }
    if (m_savedWeathers.count() > 0) {
        emit countChanged();
    }
}

SavedWeathersModel::~SavedWeathersModel()
{
}

void SavedWeathersModel::save(const QVariantMap &locationMap)
{
    int locationId = locationMap["locationId"].toInt();
    int i = getWeatherIndex(locationId);
    if (i >= 0) {
        qmlInfo(this) << "Location already exists " << locationId;
        return;
    }
    Weather *weather = new Weather(this,
            locationId,
            locationMap["city"].toString(),
            locationMap["state"].toString(),
            locationMap["country"].toString());
    saveToSql(weather, true);
    beginInsertRows(QModelIndex(), m_savedWeathers.count(), m_savedWeathers.count());
    m_savedWeathers.append(weather);
    endInsertRows();
    emit countChanged();
}

void SavedWeathersModel::reportError(int locationId)
{
    int i = getWeatherIndex(locationId);
    if (i < 0) {
        qmlInfo(this) << "No location with id " << locationId << " exists";
        return;
    }
    Weather *weather = m_savedWeathers[i];
    weather->setStatus(Weather::Error);
    dataChanged(index(i), index(i));
}

void SavedWeathersModel::update(const QVariantMap &weatherMap)
{
    int locationId = weatherMap["locationId"].toInt();
    int i = getWeatherIndex(locationId);
    if (i < 0) {
        qmlInfo(this) << "Location hasn't been saved " << locationId;
        return;
    }
    Weather *weather = m_savedWeathers[i];
    weather->setTemperature(weatherMap["temperature"].toInt());
    weather->setWeatherType(weatherMap["weatherType"].toString());
    weather->setDescription(weatherMap["description"].toString());
    weather->setTimestamp(weatherMap["timestamp"].toDateTime());
    weather->setStatus(Weather::Ready);
    saveToSql(weather, false);
    dataChanged(index(i), index(i));
}

void SavedWeathersModel::saveToSql(Weather *weather, bool newWeather)
{
    int locationId = weather->locationId();
    if (!newWeather) {
        QSqlQuery query(m_database);
        query.prepare("delete from locations where locationId = ?");
        query.addBindValue(locationId);
        if (!query.exec()) {
             qmlInfo(this) << "Error removing location " << locationId << query.lastError();
        }
    }
    QSqlQuery query(m_database);
    query.prepare(QLatin1String(
                      "insert into locations (locationId, status, isCurrent, city, state, country, temperature, weatherType, description, timestamp) "
                      "values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"));

    query.addBindValue(weather->locationId());
    query.addBindValue(weather->status());
    query.addBindValue(locationId == currentLocationId()); // isCurrent
    query.addBindValue(weather->city());
    query.addBindValue(weather->state());
    query.addBindValue(weather->country());
    query.addBindValue(weather->temperature());
    query.addBindValue(weather->weatherType());
    query.addBindValue(weather->description());
    query.addBindValue(weather->timestamp());
    if (!query.exec()) {
        qmlInfo(this) << "Error adding location " << locationId << " " << query.lastError();
    }
}

void SavedWeathersModel::remove(int locationId)
{
    bool currentRemoved = false;
    int i = getWeatherIndex(locationId);
    if (i >= 0) {
        Weather *weather = m_savedWeathers[i];
        currentRemoved = (weather == currentWeather());
        QSqlQuery query(m_database);
        query.prepare("delete from locations where locationId = ?");
        query.addBindValue(locationId);
        if (!query.exec()) {
            qmlInfo(this) << "Error removing location " << locationId << query.lastError();
        }

        beginRemoveRows(QModelIndex(), i, i);
        m_savedWeathers.removeAt(i);
        endRemoveRows();
        emit countChanged();
    }

    if (currentRemoved && m_savedWeathers.count() > 0) {
        m_currentIndex = 0;
        emit currentLocationIdChanged();
        emit currentWeatherChanged();
    }
}

int SavedWeathersModel::count() const
{
    return rowCount();
}

Weather *SavedWeathersModel::currentWeather() const
{
    if (m_currentIndex >= 0) {
        return m_savedWeathers.at(m_currentIndex);
    } else {
        return 0;
    }
}

Weather *SavedWeathersModel::get(int locationId)
{
    int index = getWeatherIndex(locationId);
    if (index >= 0) {
        return m_savedWeathers.at(index);
    } else {
        qmlInfo(this) << "SavedWeathersModel::get(locationId) - no location with id " << locationId << " stored";
        return 0;
    }
}

Q_INVOKABLE void SavedWeathersModel::updateCurrent()
{
    QSqlQuery query("select * from locations", m_database);
    int isCurrentIndex = query.record().indexOf("isCurrent");
    int index = 0;
    while (query.next()) {
        if (query.value(isCurrentIndex).toBool()) {
            if (m_currentIndex != index) {
                m_currentIndex = index;
                emit currentLocationIdChanged();
                emit currentWeatherChanged();
            }
            break;
        }
        index++;
    }
}

int SavedWeathersModel::currentLocationId() const
{
    if (m_currentIndex >= 0) {
        return m_savedWeathers.at(m_currentIndex)->locationId();
    } else {
        return -1;
    }
}

void SavedWeathersModel::setCurrentLocationId(int locationId)
{
    int index = getWeatherIndex(locationId);
    if (index >= 0 && index != m_currentIndex) {
        Weather *current = currentWeather();
        if (current) {
            QSqlQuery query(m_database);
            query.prepare(QLatin1String("update locations SET isCurrent = ? WHERE locationId = ?"));
            query.addBindValue(false);
            query.addBindValue(current->locationId());
            if (!query.exec()) {
                qmlInfo(this) << "Error removing location " << locationId << " as the current location " << query.lastError();
            }
        }
        QSqlQuery query(m_database);
        query.prepare(QLatin1String("update locations SET isCurrent = ? WHERE locationId = ?"));
        query.addBindValue(true);
        query.addBindValue(locationId);
        if (!query.exec()) {
            qmlInfo(this) << "Error adding location " << locationId << " as the current location " << query.lastError();
        }
        m_currentIndex = index;
        emit currentLocationIdChanged();
        emit currentWeatherChanged();
    }
}

int SavedWeathersModel::rowCount(const QModelIndex &) const
{
    return m_savedWeathers.count();
}

QVariant SavedWeathersModel::data(const QModelIndex &index, int role) const
{
    const Weather *weather = m_savedWeathers.at(index.row());
    switch (role) {
    case LocationId:
        return weather->locationId();
    case Status:
        return weather->status();
    case City:
        return weather->city();
    case State:
        return weather->state();
    case Country:
        return weather->country();
    case Temperature:
        return weather->temperature();
    case WeatherType:
        return weather->weatherType();
    case Description:
        return weather->description();
    case Timestamp:
        return weather->timestamp();
    }

    return QVariant();
}

QHash<int, QByteArray> SavedWeathersModel::roleNames() const
{
    QHash<int,QByteArray> roles;
    roles.insert(LocationId, "locationId");
    roles.insert(Status, "status");
    roles.insert(City, "city");
    roles.insert(State, "state");
    roles.insert(Country, "country");
    roles.insert(Temperature, "temperature");
    roles.insert(WeatherType, "weatherType");
    roles.insert(Description, "description");
    roles.insert(Timestamp, "timestamp");

    return roles;
}

int SavedWeathersModel::getWeatherIndex(int locationId)
{
    for (int i = 0; i < m_savedWeathers.count(); i++) {
        if (m_savedWeathers[i]->locationId() == locationId) {
            return i;
        }
    }
    return -1;
}

void SavedWeathersModel::createConnectionToDatabase()
{
    m_database = QSqlDatabase::addDatabase("QSQLITE");

    m_database.setDatabaseName(QDir::home().filePath("sailfish-weather.db.sqlite"));
    // TODO switch to this when it works
    //    QString path = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)
    //        + QStringLiteral("/system/privileged/location/sailfish-weather.db.sqlite");
    //    db.setDatabaseName(path);

    if (!m_database.open()) {
        qmlInfo(this) << "Failed to open database!";
        return;
    }

    QSqlQuery query(m_database);

    if (!query.exec("create table if not exists "
                    "locations (locationId integer, status integer, isCurrent integer, city text, state text, "
                    "country text, temperature integer, weatherType text, description text, timestamp date)")) {
        qmlInfo(this) << "Error setting up database!" << query.lastError();
    }
}
