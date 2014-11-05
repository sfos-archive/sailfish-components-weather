pragma Singleton
import QtQuick 2.2
import org.nemomobile.configuration 1.0

ConfigurationValue {
    // TODO: if no position fall back to Qt.locale().measurementSystem === Locale.MetricSystem
    property bool metric: true
    property bool celsius: {
        switch (value) {
        case "Celsius":
            return true
        case "Fahrenheit":
            return false
        default:
            console.log("TemperatureConverter: Invalid temperature unit value", value)
            return true
        }
    }
    function format(temperature) {
        return celsius ? temperature : Math.round(9/5*parseInt(temperature)+32).toString()
    }
    key: "/sailfish/weather/temperature_unit"
    defaultValue: "Celsius"
}
