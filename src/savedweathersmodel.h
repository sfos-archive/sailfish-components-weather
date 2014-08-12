#ifndef SAVEDWEATHERSMODEL_H
#define SAVEDWEATHERSMODEL_H

#include <QAbstractListModel>
#include <QSqlDatabase>

#include "weather.h"

class QFileSystemWatcher;

class SavedWeathersModel: public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(int currentLocationId READ currentLocationId WRITE setCurrentLocationId NOTIFY currentLocationIdChanged)
    Q_PROPERTY(Weather *currentWeather READ currentWeather NOTIFY currentWeatherChanged)
    Q_PROPERTY(bool autoRefresh READ autoRefresh WRITE setAutoRefresh NOTIFY autoRefreshChanged)

public:
    enum Roles {
        LocationId = Qt::UserRole,
        Status,
        City,
        State,
        Country,
        Temperature,
        TemperatureFeel,
        WeatherType,
        Description,
        Timestamp
    };

    SavedWeathersModel(QObject *parent = 0);
    ~SavedWeathersModel();

    virtual int rowCount(const QModelIndex &parent = QModelIndex()) const;
    virtual QVariant data(const QModelIndex &index, int role) const;

    Q_INVOKABLE void reportError(int locationId);
    Q_INVOKABLE void addLocation(const QVariantMap &locationMap, bool saveImmediatelly = true);
    Q_INVOKABLE void update(const QVariantMap &weatherMap, Weather::Status status = Weather::Ready);
    Q_INVOKABLE void remove(int locationId);
    Q_INVOKABLE Weather *get(int locationId);
    Q_INVOKABLE void save();

    int count() const;

    Weather *currentWeather() const;
    int currentLocationId() const;
    void setCurrentLocationId(int locationId, bool internal = false);

    // Automatically reload cached data when it is changed by another model
    // Default false
    bool autoRefresh() const;
    void setAutoRefresh(bool enabled);

public slots:
    void loadWeather();

signals:
    void countChanged();
    void currentWeatherChanged();
    void currentLocationIdChanged();
    void autoRefreshChanged();

protected:
    QHash<int, QByteArray> roleNames() const;

private:
    int m_currentIndex;
    QList <Weather *> m_savedWeathers;
    bool m_autoRefresh;
    QFileSystemWatcher *m_fileWatcher;

    int getWeatherIndex(int locationId);
};

QML_DECLARE_TYPE(SavedWeathersModel)

#endif // SAVEDWEATHERSMODEL_H
