//
//  HoleView.swift
//  CaddyAI
//
//  Created by Josh Jacoby on 2025-02-11.
//

import SwiftUI

struct HoleView: View {
    let course: Course
    let selectedTee: Course.TeeBox
    @State private var currentHoleIndex: Int = 0

    var body: some View {
        VStack(spacing: 20) {

            HStack(spacing: 20) {
                Text("Hole \(currentHoleIndex + 1)")
                    .font(.title)
                    .padding(.trailing)
                    .foregroundColor(.indigo)
                    .cornerRadius(10)
                    .border(Color.gray, width: 3)
                
                
                
                if let hole = selectedTee.holes?[currentHoleIndex] {
                    VStack(spacing: 20){
                        Text("Par \(hole.par)")
                            .font(.title)
                            .foregroundColor(.black)
                        
                        
                        
                        Text("\(hole.yardage) yards")
                            .font(.title2)
                            .fontWeight(.medium)
                    }
                    
                } else {
                    Text("Hole data unavailable")
                        .foregroundColor(.red)
                }
            }
            Divider()
            Spacer()

            // ✅ Next Hole Button
            Button(action: {
                if currentHoleIndex < (selectedTee.holes?.count ?? 1) - 1 {
                    currentHoleIndex += 1  // ✅ Move to next hole
                } else {
                    print("⛳ Round complete!") // ✅ Later: Navigate to summary screen
                }
            }) {
                Text(currentHoleIndex < (selectedTee.holes?.count ?? 1) - 1 ? "Next Hole" : "Finish Round")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.indigo) // ✅ Uses custom accent color
                    .foregroundColor(.white)
                    .font(.title2)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
        .navigationTitle(course.club_name)
    }
}
