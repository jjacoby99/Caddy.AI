import SwiftUI

struct CourseDetailView: View {
    let course: Course
    @ObservedObject var golfCourseService = GolfCourseService()
    @State private var selectedCourse: Course? = nil
    @State private var selectedTeeIndex: Int = 0
    @State private var showTeePicker = false

    func formatNumber(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 15) {
                Image("course_banner") // ✅ Uses your local image
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width, height: 200)
                    .clipped()
                    .ignoresSafeArea(edges: .top)
                
                if let fetchedCourse = selectedCourse {
                        Text(fetchedCourse.course_name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                    
                        Text(fetchedCourse.club_name)
                            .font(.title2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)

                    Divider().padding(.top)

                    // ✅ Tee Selection Section
                    if let tees = fetchedCourse.tees, !tees.isEmpty {
                        VStack(spacing: 15) {
                            // ✅ Tee Selection Button (Opens a Modal)
                            Button(action: {
                                showTeePicker = true
                            }) {
                                HStack {
                                    Text("Tee: \(tees[selectedTeeIndex].tee_name)")
                                        .font(.headline)
                                        .foregroundColor(.black) // ✅ Replaces hyperlink-like blue
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.1))) // ✅ Subtle border
                            }
                            .padding(.horizontal)

                            let selectedTee = tees[selectedTeeIndex]

                            // ✅ Tee Information
                            VStack(spacing: 10) {
                                Text("\(selectedTee.total_yards) yards")
                                    .font(.title)
                                    .fontWeight(.semibold)

                                HStack {
                                    StatRow(icon: "star.fill", title: "Course Rating", value: formatNumber(selectedTee.course_rating))
                                    Divider().frame(height: 20)
                                    StatRow(icon: "chart.bar.fill", title: "Slope Rating", value: "\(selectedTee.slope_rating)")
                                }
                            }
                            .padding(.top)

                            if let selectedTee = fetchedCourse.tees?[selectedTeeIndex] {
                                NavigationLink(destination: HoleView(course: fetchedCourse, selectedTee: selectedTee)) {
                                    Text("Start Round")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(.indigo)
                                        .foregroundColor(.white)
                                        .font(.title2)
                                        .cornerRadius(12)
                                        
                                }
                                .padding(.horizontal)
                            } else {
                                Text("No tee information available.")
                                    .foregroundColor(.red)
                                    .padding()
                            }

                        }
                        .padding(.vertical)
                    } else {
                        Text("No tee information available for this course.")
                            .foregroundColor(.red)
                            .padding()
                    }
                } else {
                    Text("Loading course details...")
                        .foregroundColor(.gray)
                }
            }
            .padding()
        }
        .onAppear {
            golfCourseService.fetchCourseDetails(courseId: course.id)
        }
        .onReceive(golfCourseService.$selectedCourse) { fetchedCourse in
            if let fetchedCourse = fetchedCourse {
                self.selectedCourse = fetchedCourse
                print("🏌️‍♂️ Updated Course: \(fetchedCourse.course_name), Tees: \(fetchedCourse.tees?.count ?? 0)")
            }
        }
        .sheet(isPresented: $showTeePicker) {
            TeeSelectionView(tees: selectedCourse?.tees ?? [], selectedTeeIndex: $selectedTeeIndex)
        }
    }
}

// ✅ Tee Selection Modal
struct TeeSelectionView: View {
    let tees: [Course.TeeBox]
    @Binding var selectedTeeIndex: Int
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List {
                ForEach(tees.indices, id: \.self) { index in
                    Button(action: {
                        selectedTeeIndex = index
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Text(tees[index].tee_name)
                                .font(.headline)
                                .foregroundColor(.black)
                            Spacer()
                            if index == selectedTeeIndex {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
            .navigationTitle("Select a Tee")
            .toolbar {
                Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

// ✅ Reusable Stat Row Component
struct StatRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.indigo) // ✅ Higher contrast black
                .padding(.leading)
                .frame(width: 20)
            Text(title)
                .font(.subheadline)
                .foregroundColor(.black)
                .padding()
            Spacer()
                .foregroundColor(.black)
            Text(value)
                .font(.headline)
                .foregroundColor(.black.opacity(0.7))
                .padding(.trailing)
        }
    }
}
