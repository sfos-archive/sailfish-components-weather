#ifndef WEATHER_H
#define WEATHER_H

#include <QObject>
#include <QDebug>
#include <QDateTime>
#include <qqml.h>

class Weather : public QObject
{
    Q_OBJECT
    Q_ENUMS(Status)
    Q_PROPERTY(Status status READ status NOTIFY statusChanged)
    Q_PROPERTY(int locationId READ locationId CONSTANT)
    Q_PROPERTY(QString city READ city CONSTANT)
    Q_PROPERTY(QString state READ state CONSTANT)
    Q_PROPERTY(QString country READ country CONSTANT)
    Q_PROPERTY(int temperature READ temperature NOTIFY temperatureChanged)
    Q_PROPERTY(int temperatureFeel READ temperatureFeel NOTIFY temperatureFeelChanged)
    Q_PROPERTY(QString weatherType READ weatherType NOTIFY weatherTypeChanged)
    Q_PROPERTY(QString description READ description NOTIFY descriptionChanged)
    Q_PROPERTY(QDateTime timestamp READ timestamp NOTIFY timestampChanged)

public:
    Weather(QObject *parent, const QVariantMap &locationMap)
        : QObject(parent),
          m_status(Loading),
          m_locationId(locationMap["locationId"].toInt()),
          m_city(locationMap["city"].toString()),
          m_state(locationMap["state"].toString()),
          m_country(locationMap["country"].toString()),
          m_temperature(0),
          m_temperatureFeel(0)
    {
    }

    ~Weather() {}
    enum Status { Null, Ready, Loading, Error };

    int locationId() const { return m_locationId; }
    Status status() const { return m_status; }
    QString city() const { return m_city; }
    QString state() const { return m_state; }
    QString country() const { return m_country; }
    int temperature() const { return m_temperature; }
    int temperatureFeel() const { return m_temperatureFeel; }
    QString weatherType() const { return m_weatherType; }
    QString description() const { return m_description; }
    QDateTime timestamp() const { return m_timestamp; }

    void setStatus(Status status) {
        if (m_status != status) {
            m_status = status;
            emit statusChanged();
        }
    }
    void setTemperature(int temperature) {
        if (m_temperature != temperature) {
            m_temperature = temperature;
            emit temperatureChanged();
        }
    }
    void setTemperatureFeel(int temperatureFeel) {
        if (m_temperatureFeel != temperatureFeel) {
            m_temperatureFeel = temperatureFeel;
            emit temperatureFeelChanged();
        }
    }
    void setWeatherType(QString weatherType) {
        if (m_weatherType != weatherType) {
            m_weatherType = weatherType;
            emit weatherTypeChanged();
        }
    }
    void setDescription(QString description) {
        if (m_description != description) {
            m_description = description;
            emit descriptionChanged();
        }
    }
    void setTimestamp(QDateTime timestamp) {
        if (m_timestamp != timestamp) {
            m_timestamp = timestamp;
            emit timestampChanged();
        }
    }
    Q_INVOKABLE void update(const QVariantMap &weatherMap) {
        setTemperature(weatherMap["temperature"].toInt());
        setTemperatureFeel(weatherMap["temperatureFeel"].toInt());
        setWeatherType(weatherMap["weatherType"].toString());
        setDescription(weatherMap["description"].toString());
        setTimestamp(weatherMap["timestamp"].toDateTime());
    }

signals:
    void statusChanged();
    void temperatureChanged();
    void temperatureFeelChanged();
    void weatherTypeChanged();
    void descriptionChanged();
    void timestampChanged();

private:
    Status m_status;
    int m_locationId;
    QString m_city;
    QString m_state;
    QString m_country;
    int m_temperature;
    int m_temperatureFeel;
    QString m_weatherType;
    QString m_description;
    QDateTime m_timestamp;
};

QML_DECLARE_TYPE(Weather)

#endif // WEATHER_H
