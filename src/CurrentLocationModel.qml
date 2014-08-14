import QtQuick 2.0
import QtPositioning 5.2
import QtQuick.XmlListModel 2.0

XmlListModel {
    id: model

    property bool ready
    property alias active: positionSource.active
    property string locationId
    property string city
    property var coordinate: positionSource.position.coordinate
    property QtObject positionSource: PositionSource { id: positionSource }

    query: "/searchdata/location"
    source: positionSource.active && positionSource.valid ? "http://fnw2.foreca.com/findloc.php?lon="
                                                            + coordinate.longitude +"&lat=" + coordinate.latitude + "&format=xml/jolla-sep13fi&radius=5"
                                                          :  ""
    onStatusChanged: {
        if (XmlListModel.Ready && count > 0) {
            var location = get(0)
            locationId = location.locationId
            city = location.city
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
}
