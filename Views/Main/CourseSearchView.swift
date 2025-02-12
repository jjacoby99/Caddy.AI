//
//  CourseSearchView.swift
//  CaddyAI
//
//  Created by Josh Jacoby on 2025-02-03.
//

import SwiftUI
import FirebaseFirestore

struct CourseSearchView: View {
    @State private var searchQuery = ""
    @State private var showDropdown = false  // ✅ Controls dropdown visibility
    @ObservedObject var golfCourseService = GolfCourseService()
    @ObservedObject var userCourseManager = UserCourseManager() // ✅ Fetch played courses

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    // ✅ Search Bar & Magnifying Glass Button
                    HStack {
                        TextField("Search for a golf course", text: $searchQuery, onEditingChanged: { isEditing in
                            showDropdown = !searchQuery.isEmpty // ✅ Show dropdown only if input exists
                        })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading)

                        Button(action: {
                            golfCourseService.searchCourses(query: searchQuery)
                            showDropdown = true  // ✅ Show dropdown when searching
                        }) {
                            Image(systemName: "magnifyingglass")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .padding()
                        }
                    }
                    .padding()

                    // ✅ Drop-down for Search Results
                    if showDropdown && !golfCourseService.courses.isEmpty {
                        List(golfCourseService.courses, id: \.id) { course in
                            NavigationLink(destination: CourseDetailView(course: course)) {
                                VStack(alignment: .leading) {
                                    Text(course.course_name)
                                        .font(.headline)
                                    Text(course.club_name)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .frame(maxHeight: 250) // ✅ Limit dropdown height
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }

                    // ✅ Scrollable Previously Played Courses
                    ScrollView {
                        VStack(alignment: .leading) {
                            if !userCourseManager.playedCourses.isEmpty {
                                Text("Previously Played Courses")
                                    .font(.headline)
                                    .padding(.leading)

                                LazyVStack(spacing: 10) {
                                    ForEach(userCourseManager.playedCourses) { course in
                                        NavigationLink(destination: CourseDetailView(course: course)) {
                                            VStack(alignment: .leading) {
                                                Text(course.course_name)
                                                    .font(.headline)
                                                Text("\(course.location.city), \(course.location.state)")
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                            }
                                            .padding()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color(.systemGray6))
                                            .cornerRadius(10)
                                            .padding(.horizontal)
                                        }
                                    }
                                }
                                .padding(.bottom, 20) // ✅ Ensures scrolling works properly
                            }
                        }
                    }
                    .frame(maxHeight: .infinity) // ✅ Allows scrolling when many courses exist
                }
                .navigationTitle("Courses")

                // ✅ Tap Gesture to Hide Dropdown
                .background(
                    Color.clear.contentShape(Rectangle())
                        .onTapGesture {
                            showDropdown = false
                        }
                )
            }
        }
        .onAppear {
            userCourseManager.fetchPlayedCourses() // ✅ Ensure played courses are loaded
        }
    }
}
