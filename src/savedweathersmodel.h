#ifndef SAVEDWEATHERSMODEL_H
#define SAVEDWEATHERSMODEL_H

#include <QAbstractListModel>
#include <QSqlDatabase>

#include "weather.h"

class SavedWeathersModel: public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(int currentLocationId READ currentLocationId WRITE setCurrentLocationId NOTIFY currentLocationIdChanged)
    Q_PROPERTY(Weather *currentWeather READ currentWeather NOTIFY currentWeatherChanged)

public:

    enum Roles {
        LocationId = Qt::UserRole,
        Status,
        City,
        State,
        Country,
        Temperature,
        WeatherType,
        Description,
        Timestamp
    };

    SavedWeathersModel(QObject *parent = 0);
    ~SavedWeathersModel();

    virtual int rowCount(const QModelIndex &parent = QModelIndex()) const;
    virtual QVariant data(const QModelIndex &index, int role) const;

    Q_INVOKABLE void reportError(int locationId);
    Q_INVOKABLE void save(const QVariantMap &locationMap);
    Q_INVOKABLE void update(const QVariantMap &weatherMap);
    Q_INVOKABLE void remove(int locationId);
    Q_INVOKABLE Weather *get(int locationId);

    int count() const;

    Weather *currentWeather() const;
    int currentLocationId() const;
    void setCurrentLocationId(int locationId);

signals:
    void countChanged();
    void currentWeatherChanged();
    void currentLocationIdChanged();
protected:
    QHash<int, QByteArray> roleNames() const;

private:
    void createConnectionToDatabase();
    void saveToSql(Weather *weather, bool newWeather);
    int getWeatherIndex(int locationId);
private:
    int m_currentIndex;
    QList <Weather *> m_savedWeathers;
    QSqlDatabase m_database;
};

QML_DECLARE_TYPE(SavedWeathersModel)

#endif // SAVEDWEATHERSMODEL_H
