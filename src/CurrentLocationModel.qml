import QtQuick 2.0
import QtPositioning 5.2
import QtQuick.XmlListModel 2.0

XmlListModel {
    id: model

    property bool ready
    property string city
    property string locationId
    property bool metric: true
    property alias active: positionSource.active
    property real searchRadius: 10 // find biggest city in specified kilometers
    property var coordinate: positionSource.position.coordinate

    property string longitude: format(coordinate.longitude)
    property string latitude: format(coordinate.latitude)
    property QtObject positionSource: PositionSource { id: positionSource }

    function format(value) {
        // optimize Foreca backend caching by
        // rounding to closest even decimal
        // (0.02 degree accuracy) e.g. 0.99 -> 1.00, 175.5637 -> 175.56
        if (value) {
            var longitude = value
            var integer = Math.floor(value)
            var decimal = 2*Math.round(50*(longitude - integer))
            if (decimal == 100) {
                integer = Math.floor(value+1)
                decimal = 0
            }
            return integer.toString() + "." + (decimal < 10 ? "0" : "") + decimal.toString()
        } else {
            return "0.0"
        }
    }

    query: "/searchdata/location"
    source: positionSource.active && positionSource.valid ? "http://fnw-jll.foreca.com/findloc.php?lon="
                                                            + longitude +"&lat=" + latitude + "&format=xml/jolla-sep13fi&radius=" + searchRadius
                                                          :  ""
    onStatusChanged: {
        if (XmlListModel.Ready && count > 0) {
            var location = get(0)
            locationId = location.locationId
            city = location.city
            metric = (location.locale !== "gb" && location.locale !== "us")
            ready = true
        }
    }

    XmlRole {
        name: "locationId"
        query: "id/string()"
    }
    XmlRole {
        name: "city"
        query: "name/string()"
    }
    XmlRole {
        name: "locale"
        query: "land/string()"
    }
}
