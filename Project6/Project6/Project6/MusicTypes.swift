struct MusicResult: Codable {
    var results: ResultList
}

struct ResultList: Codable {
    var songs: [Result]
}

struct Result: Codable {
    var name: String
    var chart: String
    var data: [Song]
}

struct Song: Codable, Comparable {
    var id: String
    var href: String
    var attributes: SongAttributes
    
    static func <(lhs: Song, rhs: Song) -> Bool {
         lhs.attributes.name < rhs.attributes.name
    }
    
    static func ==(lhs: Song, rhs: Song) -> Bool {
        lhs.attributes.name == rhs.attributes.name
    }
}

struct SongAttributes: Codable {
    var name: String
    var artistName: String
}

