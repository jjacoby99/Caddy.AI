//
//  GolfCourseService.swift
//  CaddyAI
//
//  Created by Josh Jacoby on 2025-02-02.
//

//
//  GolfCourseService.swift
//  CaddyAI
//
//  Created by Josh Jacoby on 2025-02-02.
//

import Foundation

class GolfCourseService: ObservableObject {
    @Published var courses: [Course] = [] // Stores search results
    @Published var selectedCourse: Course? // Stores detailed course data

    private let apiKey: String = KeychainHelper.retrieve(key: "GolfAPIKey") ?? ""

    // ✅ Search for courses by name
    func searchCourses(query: String) {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.golfcourseapi.com/v1/search?search_query=\(encodedQuery)") else {
            print("❌ Invalid URL: Query was not properly encoded")
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Key \(apiKey)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("❌ No data received")
                return
            }

            

            do {
                let decodedResponse = try JSONDecoder().decode(CourseSearchResponse.self, from: data)
                DispatchQueue.main.async {
                    self.courses = decodedResponse.courses
                }
                print("✅ Successfully fetched \(decodedResponse.courses.count) courses")
            } catch {
                print("❌ Decoding error: \(error.localizedDescription)")
            }
        }.resume()
    }


    // ✅ Fetch detailed course information including hole data
    func fetchCourseDetails(courseId: Int) {
        guard let url = URL(string: "https://api.golfcourseapi.com/v1/courses/\(courseId)") else {
            print("❌ Invalid URL for course details")
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Key \(apiKey)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("❌ No data received")
                return
            }

            // ✅ Print raw API response for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("🔥 Raw API Response: \(jsonString)")
            }
            
            do {
                // ✅ Decode the API response as a dictionary first
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                guard let courseData = jsonObject?["course"] else {
                    print("❌ Missing 'course' key in API response")
                    return
                }

                // ✅ Convert `courseData` back to JSON and decode as `Course`
                let courseJSON = try JSONSerialization.data(withJSONObject: courseData, options: [])
                let decodedCourse = try JSONDecoder().decode(Course.self, from: courseJSON)

                DispatchQueue.main.async {
                    self.selectedCourse = decodedCourse
                }
            
                print("✅ Successfully fetched course details for \(decodedCourse.course_name)")
            } catch {
                print("❌ Decoding error: \(error.localizedDescription)")
            }
        }.resume()
    }


}

// Helper struct to decode API response for course search
struct CourseSearchResponse: Codable {
    let courses: [Course]
}
