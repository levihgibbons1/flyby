import Foundation

/// Sample photos for the mock journal. Captions match the fictional trip notes.
enum MockPhotos {
    static let kpaoKmry: [FlightPhoto] = [
        photo("kpao-kmry-coast", "Coastal haze over Santa Cruz", "water.waves", .coast),
        photo("kpao-kmry-field", "Final into Monterey", "airplane.arrival", .field),
        photo("kpao-kmry-cabin", "Smooth air the whole way", "sun.max", .cabin),
    ]

    static let ksqlKtvl: [FlightPhoto] = [
        photo("ksql-ktvl-sierra", "Over the Sierra", "mountain.2", .sierra),
        photo("ksql-ktvl-lake", "Glassy water at Tahoe", "water.waves", .lake),
        photo("ksql-ktvl-cabin", "Light chop past Placerville", "cloud.sun", .cabin),
    ]

    static let khafKsql: [FlightPhoto] = [
        photo("khaf-ksql-sunset", "Sunset over Crystal Springs", "sun.horizon", .sunset),
        photo("khaf-ksql-hills", "Hop home over the hills", "mountain.2", .sierra),
    ]

    static let ksqlKsba: [FlightPhoto] = [
        photo("ksql-ksba-coast", "Down the coast past Big Sur", "water.waves", .coast),
        photo("ksql-ksba-field", "Santa Barbara in the distance", "airplane.arrival", .field),
        photo("ksql-ksba-cabin", "Coastal cruise", "sun.max", .sunset),
    ]

    private static func photo(_ id: String, _ caption: String, _ symbol: String, _ style: FlightPhoto.Style) -> FlightPhoto {
        FlightPhoto(id: id, caption: caption, symbolName: symbol, style: style)
    }
}
