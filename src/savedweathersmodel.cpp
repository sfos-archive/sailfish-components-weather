#include "savedweathersmodel.h"
#include <QDir>
#include <qqmlinfo.h>
#include <QStandardPaths>
#include <QFileSystemWatcher>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

static QString weatherStoragePath()
{
    return QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)
           + QStringLiteral("/sailfish-weather/");
}

SavedWeathersModel::SavedWeathersModel(QObject *parent)
    : QAbstractListModel(parent), m_currentIndex(-1), m_autoRefresh(false),
      m_fileWatcher(0)
{
    loadWeather();
}

SavedWeathersModel::~SavedWeathersModel()
{
}

void SavedWeathersModel::loadWeather()
{
    QFile file(weatherStoragePath() + QStringLiteral("/weather.json"));
    if (!file.exists())
        return;

    if (!file.open(QIODevice::ReadOnly)) {
        qmlInfo(this) << "Could not open weather data file!";
        return;
    }

    beginResetModel();
    qDeleteAll(m_savedWeathers);
    m_savedWeathers.clear();

    QByteArray data = file.readAll();
    QJsonDocument json = QJsonDocument::fromJson(data);

    QJsonObject root = json.object();

    QJsonObject locations = root.value("locations").toObject();
    foreach (const QJsonValue &value, locations) {
        QJsonObject location = value.toObject();

        QJsonArray forecasts = location.value("forecasts").toArray();
        foreach (const QJsonValue &forecastValue, forecasts) {
            QJsonObject forecast = forecastValue.toObject();

            Weather *weather = new Weather(this, location["id"].toInt(),
                                           location["city"].toString(),
                                           location["state"].toString(),
                                           location["country"].toString());

            weather->setStatus(Weather::Status(forecast["status"].toInt()));
            if (weather->status() == Weather::Ready) {
                weather->setTemperature(forecast["temperature"].toInt());
                weather->setTemperatureFeel(forecast["temperatureFeel"].toInt());
                weather->setWeatherType(forecast["weatherType"].toString());
                weather->setDescription(forecast["description"].toString());
                weather->setTimestamp(QDateTime::fromString(forecast["timestamp"].toString()));
            }

            m_savedWeathers.append(weather);
        }
    }

    endResetModel();

    int currentLocation = root.value("currentLocation").toInt();
    if (currentLocation) {
        m_currentIndex = getWeatherIndex(currentLocation);
        emit currentLocationIdChanged();
        emit currentWeatherChanged();
    }

    if (m_savedWeathers.count() > 0) {
        emit countChanged();
    }
}

void SavedWeathersModel::saveWeather()
{
    QDir dir(weatherStoragePath());
    if (!dir.mkpath(QStringLiteral("."))) {
        qmlInfo(this) << "Could not create data directory!";
        return;
    }

    QFile file(dir.filePath(QStringLiteral("weather.json")));
    if (!file.open(QIODevice::ReadWrite | QIODevice::Truncate)) {
        qmlInfo(this) << "Could not open weather data file!";
        return;
    }

    QJsonObject locations;
    foreach (Weather *weather, m_savedWeathers) {
        QJsonObject location = locations.value(QString::number(weather->locationId())).toObject();
        if (location.isEmpty()) {
            location["id"] = weather->locationId();
            location["city"] = weather->city();
            location["state"] = weather->state();
            location["country"] = weather->country();
        }

        QJsonObject forecast;
        forecast["status"] = weather->status();
        forecast["temperature"] = weather->temperature();
        forecast["temperatureFeel"] = weather->temperatureFeel();
        forecast["weatherType"] = weather->weatherType();
        forecast["description"] = weather->description();
        forecast["timestamp"] = weather->timestamp().toUTC().toString(Qt::ISODate);

        QJsonArray forecasts = location["forecasts"].toArray();
        forecasts.append(forecast);
        location["forecasts"] = forecasts;

        locations.insert(QString::number(weather->locationId()), location);
    }

    QJsonObject root;
    root.insert("locations", locations);
    if (currentWeather())
        root.insert("currentLocation", currentWeather()->locationId());

    QJsonDocument json(root);
    if (!file.write(json.toJson()) < 0) {
        qmlInfo(this) << "Could not write weather data:" << file.errorString();
        return;
    }
}

void SavedWeathersModel::addLocation(const QVariantMap &locationMap)
{
    int locationId = locationMap["locationId"].toInt();
    int i = getWeatherIndex(locationId);
    if (i >= 0) {
        qmlInfo(this) << "Location already exists " << locationId;
        return;
    }

    beginInsertRows(QModelIndex(), m_savedWeathers.count(), m_savedWeathers.count());

    Weather *weather = new Weather(this,
            locationId,
            locationMap["city"].toString(),
            locationMap["state"].toString(),
            locationMap["country"].toString());
    m_savedWeathers.append(weather);
    saveWeather();

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
    weather->setTemperatureFeel(weatherMap["temperatureFeel"].toInt());
    weather->setWeatherType(weatherMap["weatherType"].toString());
    weather->setDescription(weatherMap["description"].toString());
    weather->setTimestamp(weatherMap["timestamp"].toDateTime());
    weather->setStatus(Weather::Ready);
    saveWeather();
    dataChanged(index(i), index(i));
}

void SavedWeathersModel::remove(int locationId)
{
    bool currentRemoved = false;
    int i = getWeatherIndex(locationId);
    if (i >= 0) {
        Weather *weather = m_savedWeathers[i];
        currentRemoved = (weather == currentWeather());

        beginRemoveRows(QModelIndex(), i, i);
        m_savedWeathers.removeAt(i);
        saveWeather();
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
    if (m_currentIndex >= 0 && m_currentIndex < m_savedWeathers.size()) {
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

int SavedWeathersModel::currentLocationId() const
{
    if (currentWeather())
        return currentWeather()->locationId();
    return -1;
}

void SavedWeathersModel::setCurrentLocationId(int locationId)
{
    int index = getWeatherIndex(locationId);
    if (index >= 0 && index != m_currentIndex) {
        m_currentIndex = index;
        saveWeather();
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
    case TemperatureFeel:
        return weather->temperatureFeel();
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
    roles.insert(TemperatureFeel, "temperatureFeel");
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

bool SavedWeathersModel::autoRefresh() const
{
    return m_autoRefresh;
}

void SavedWeathersModel::setAutoRefresh(bool enabled)
{
    if (m_autoRefresh == enabled)
        return;

    m_autoRefresh = enabled;

    if (m_autoRefresh) {
        QString filePath = weatherStoragePath() + QStringLiteral("weather.json");
        if (!QFile::exists(filePath)) {
            // QFileSystemWatcher needs the file to exist, so write out an
            // empty file
            saveWeather();
        }

        m_fileWatcher = new QFileSystemWatcher(this);
        connect(m_fileWatcher, &QFileSystemWatcher::fileChanged,
                this, &SavedWeathersModel::loadWeather);
        m_fileWatcher->addPath(filePath);
    } else {
        delete m_fileWatcher;
        m_fileWatcher = 0;
    }
}

