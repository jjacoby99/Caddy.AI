//
//  UserCourseManager.swift
//  CaddyAI
//
//  Created by Josh Jacoby on 2025-02-03.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class UserCourseManager: ObservableObject {
    @Published var playedCourses: [Course] = []

    private let db = Firestore.firestore()
    private var userId: String? {
        Auth.auth().currentUser?.uid
    }

    init() {
        fetchPlayedCourses()
    }

    func fetchPlayedCourses() {
        guard let userId = userId else { return }
        
        db.collection("users").document(userId).collection("played_courses").getDocuments { snapshot, error in
            if let error = error {
                print("❌ Error fetching played courses: \(error.localizedDescription)")
                return
            }
            
            if let snapshot = snapshot {
                self.playedCourses = snapshot.documents.compactMap { document -> Course? in
                    do {
                        let data = document.data()
                        let id = data["id"] as? Int ?? 0
                        let clubName = data["club_name"] as? String ?? "Unknown Club"
                        let courseName = data["course_name"] as? String ?? "Unknown Course"
                        
                        let locationData = data["location"] as? [String: Any] ?? [:]
                        let location = Course.Location(
                            address: locationData["address"] as? String ?? "",
                            city: locationData["city"] as? String ?? "",
                            state: locationData["state"] as? String ?? "",
                            country: locationData["country"] as? String ?? "",
                            latitude: locationData["latitude"] as? Double ?? 0.0,
                            longitude: locationData["longitude"] as? Double ?? 0.0
                        )

                        // ✅ Handle tees safely by decoding both "male" and "female" tees
                        let teeData = data["tees"] as? [String: [[String: Any]]] ?? [:]
                        let maleTees = teeData["male"] ?? []
                        let femaleTees = teeData["female"] ?? []
                        
                        let tees: [Course.TeeBox] = (maleTees + femaleTees).map { teeDict in
                            let teeName = teeDict["tee_name"] as? String ?? "Unknown Tee"
                            let parTotal = teeDict["par_total"] as? Int ?? 72
                            let totalYards = teeDict["total_yards"] as? Int ?? 0
                            let slopeData = teeDict["slope_rating"] as? Double ?? 0.0
                            let ratingData = teeDict["course_rating"] as? Double ?? 0.0
                            let bogeyData = teeDict["bogey_rating"] as? Double ?? 0.0
                            let holesData = teeDict["holes"] as? [[String: Any]] ?? []

                            let holes: [Course.Hole] = holesData.compactMap { holeDict in
                                guard let par = holeDict["par"] as? Int,
                                      let yardage = holeDict["yardage"] as? Int,
                                      let handicap = holeDict["handicap"] as? Int else {
                                    print("⚠️ Skipping invalid hole data: \(holeDict)")
                                    return nil
                                }
                                return Course.Hole(par: par, yardage: yardage, handicap: handicap)
                            }

                            return Course.TeeBox(
                                tee_name: teeName,
                                par_total: parTotal,
                                total_yards: totalYards,
                                slope_rating: Int(slopeData),
                                course_rating: ratingData,
                                bogey_rating: bogeyData,
                                holes: holes
                            )
                        }


                        return Course(
                            id: id,
                            club_name: clubName,
                            course_name: courseName,
                            location: location,
                            tees: tees.isEmpty ? nil : tees // ✅ Pass nil if no tees exist
                        )
                    } catch {
                        print("❌ Error decoding course: \(error.localizedDescription)")
                        return nil
                    }
                }
                print("✅ Successfully loaded \(self.playedCourses.count) played courses")
            }
        }
    }




    func addPlayedCourse(_ course: Course) {
        guard let userId = userId else { return }

        let courseRef = db.collection("users").document(userId).collection("played_courses").document("\(course.id)")

        let courseData: [String: Any] = [
            "id": course.id,
            "club_name": course.club_name,
            "course_name": course.course_name,
            "location": [
                "address": course.location.address,
                "city": course.location.city,
                "state": course.location.state,
                "country": course.location.country,
                "latitude": course.location.latitude,
                "longitude": course.location.longitude
            ]
        ]

        courseRef.setData(courseData) { error in
            if let error = error {
                print("❌ Error saving course: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self.playedCourses.append(course)
                }
                print("✅ Course saved successfully!")
            }
        }
    }
}

