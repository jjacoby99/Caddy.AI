import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var userName: String = "Loading..."
    @State private var location: String = ""
    @State private var activity: [String] = [] // Placeholder for rounds played
    @State private var isEditing: Bool = false
    
    var body: some View {
        ScrollView {
            VStack {
                // User Info
                if isEditing {
                    TextField("Name", text: $userName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    TextField("Location", text: $location)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                } else {
                    Text(userName)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if !location.isEmpty {
                        Text(location)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                Button(action: {
                    if isEditing {
                        saveUserProfile()
                    }
                    isEditing.toggle()
                }) {
                    Text(isEditing ? "Save" : "Edit Profile")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isEditing ? Color.green : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                }
                
                Divider()
                    .padding()
                
                // Activity Section
                Text("Recent Rounds")
                    .font(.headline)
                    .padding(.bottom, 5)
                
                ForEach(activity, id: \ .self) { round in
                    Text(round)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                Button(action: {
                    authViewModel.signOut()
                }) {
                    Text("Sign Out")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                }
            }
            .padding()
        }
        .onAppear {
            fetchUserProfile()
        }
    }
    
    func fetchUserProfile() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        
        db.collection("users").document(user.uid).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                self.userName = data?["name"] as? String ?? "No Name"
                self.location = data?["location"] as? String ?? ""
                self.activity = data?["activity"] as? [String] ?? []
            }
        }
    }
    
    func saveUserProfile() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        
        let userData: [String: Any] = [
            "name": userName,
            "location": location
        ]
        
        db.collection("users").document(user.uid).setData(userData, merge: true) { error in
            if let error = error {
                print("❌ Error updating profile: \(error.localizedDescription)")
            } else {
                print("✅ Profile updated successfully")
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthViewModel())
    }
}
