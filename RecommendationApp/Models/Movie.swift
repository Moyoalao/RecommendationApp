import Foundation

struct myMovie: Codable, Hashable, Identifiable {
    //The id of the movie
    var id: Int
    //The title of the movie
    var title: String
    //The desctiption of the of the movie
    var overview: String
    //The original release date of the movie
    var releaseDate: String
    //The path to the poster held in optional string
    var posterPath: String?
    //The array of genre ids
    var genreIds: [Int]
    //The  optional array of genre names
    var genreNames: [String]?
    //The avrage rating of the movie gotten from the TMDB
    var ratings: Double
    //The unique id
    let uuid: UUID = UUID()
    //The users own  rating
    var userRating: Double?
    
    // computes the full URL of the poster of the movie using posterpath
    var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }
    
    //How properties map to JSON keys
    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case releaseDate = "release_date"
        case posterPath = "poster_path"
        case genreIds = "genre_ids"
        case ratings = "vote_average"
        case userRating
    }
}

//converts myMovie to a dictionary for interacting with apis that need it in that format
extension myMovie {
    var dictionary: [String: Any] {
        var dict = [String: Any]()
        dict["id"] = id
        dict["title"] = title
        dict["overview"] = overview
        dict["release_date"] = releaseDate
        dict["poster_path"] = posterPath
        dict["genre_ids"] = genreIds
        dict["vote_average"] = ratings
        dict["userRating"] = userRating
        if let genreNames = genreNames {
            dict["genreNames"] = genreNames
        }
        return dict
    }
}
