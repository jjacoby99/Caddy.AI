import Foundation

struct Course: Identifiable, Codable {
    let id: Int
    let club_name: String
    let course_name: String
    let location: Location
    let tees: [TeeBox]?

    struct Location: Codable {
        let address: String
        let city: String
        let state: String
        let country: String
        let latitude: Double
        let longitude: Double
    }

    struct TeeBox: Codable {
            let tee_name: String
            let par_total: Int
            let total_yards: Int
            let slope_rating: Int
            let course_rating: Double
            let bogey_rating: Double
            let holes: [Hole]?
        }

    struct Hole: Codable {
        let par: Int
        let yardage: Int
        let handicap: Int
    }

    init(id: Int, club_name: String, course_name: String, location: Location, tees: [TeeBox]?) {
        self.id = id
        self.club_name = club_name
        self.course_name = course_name
        self.location = location
        self.tees = tees
    }

    // ✅ Custom decoding to merge "male" and "female" tees into a single array
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        club_name = try container.decode(String.self, forKey: .club_name)
        course_name = try container.decode(String.self, forKey: .course_name)
        location = try container.decode(Location.self, forKey: .location)

        // ✅ Decode `tees` dictionary and extract "male" and "female" keys
        if let teeData = try? container.decode([String: [TeeBox]].self, forKey: .tees) {
            let maleTees = teeData["male"] ?? []
            let femaleTees = teeData["female"] ?? []
            let allTees = maleTees + femaleTees

            // ✅ Fix: Ensure tees aren't mistakenly discarded
            tees = allTees.isEmpty ? nil : allTees
            print("✅ Parsed \(allTees.count) tees for \(course_name)")
        } else {
            print("⚠️ No tee data found for \(course_name)")
            tees = nil
        }
    }


    // ✅ Explicit coding keys to ensure correct mapping
    private enum CodingKeys: String, CodingKey {
        case id, club_name, course_name, location, tees
    }
}
