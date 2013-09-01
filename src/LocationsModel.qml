import QtQuick 2.0

ListModel {
    property string filter
    property var locations: [
        {
            city: "Beijing",
            state: "Beijing",
            country: "China",
            locationId: 2151330
        },
        {
            city: "Brisbane",
            state: "Queensland",
            country: "Australia",
            locationId: 1100661
        },
        {
            city: "Helsinki",
            state: "Uusimaa",
            country: "Finland",
            locationId: 565346
        },
        {
            city: "Hong Kong",
            state: "Hong Kong",
            country: "China",
            locationId: 2165352
        },
        {
            city: "London",
            state: "England",
            country: "United Kingdom",
            locationId: 44418
        },
        {
            city: "New York",
            state: "New York",
            country: "United States",
            locationId: 2459115
        },
        {
            city: "Tampere",
            state: "Pirkanmaa",
            country: "Finland",
            locationId: 573760
        },
        {
            city: "Turku",
            state: "Varsinais-Suomen maakunta",
            country: "Finland",
            locationId: 574224
        }
    ]

    onFilterChanged: update()
    Component.onCompleted: update()

    function update() {
        if (filter.length == 0) {
            clear()
            return
        }

        var formattedList = []
        for (var i = 0; i < locations.length; i++) {
            formattedList[i] = [locations[i].city, locations[i].state, locations[i].country].join(" ")
        }

        var filteredLocations = locations.filter(function (location) {
            return location.city.toLowerCase().indexOf(filter) !== -1
                    || location.state.toLowerCase().indexOf(filter) !== -1
                    || location.country.toLowerCase().indexOf(filter) !== -1
        })
        while (count > filteredLocations.length) {
            remove(filteredLocations.length)
        }
        for (var i = 0; i < filteredLocations.length; i++) {
            if (i < count) {
                set(i, filteredLocations[i])
            } else {
                append(filteredLocations[i])
            }
        }
    }
}
