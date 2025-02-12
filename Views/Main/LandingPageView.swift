import SwiftUI

struct LandingPageView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        TabView {
            DataView()
                .tabItem {
                    Label("Data", systemImage: "chart.bar.fill")
                }

            PlayView()
                .tabItem {
                    Label("Play", systemImage: "map.fill")
                }
            
            CourseSearchView()
                .tabItem {
                    Label("Courses", systemImage: "figure.golf")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}
