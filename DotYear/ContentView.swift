//
//  ContentView.swift
//  DotYear
//
//  Created by Kemo Jallow on 2025/1/18.
//

import SwiftUI

struct ContentView: View {
    let totalDays = 365
    let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 20) // 20 columns with spacing
    
    @State private var selectedDay: Int? = nil
    
    var body: some View {
        ZStack {
            // Background gradient for a premium feel
            LinearGradient(gradient: Gradient(colors: [Color(.systemBackground), Color(.secondarySystemBackground)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 24) {
                // Header with current date
                VStack(alignment: .leading, spacing: 8) {
                    Text(getFormattedDate())
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Track your year, one day at a time.")
                        .font(.system(size: 16, weight: .medium, design: .default))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // Dots grid for the year
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(0..<totalDays, id: \.self) { day in
                        DayDotView(day: day, daysPassed: getDaysPassed(), isSelected: selectedDay == day)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.8)) {
                                    selectedDay = day
                                }
                            }
                    }
                }
                .padding(.horizontal)
                
                // Year and days left at the bottom
                HStack {
                    Text(getCurrentYear()) // Year on the left
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Spacer() // Push the days left to the right
                    
                    Text("\(getDaysLeftInYear()) days left") // Days left on the right
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
    }
    
    // Helper function to format the current date
    func getFormattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd.MM" // "Tuesday, 22.04"
        return formatter.string(from: Date())
    }
    
    // Helper function to get the current year
    func getCurrentYear() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy" // "2025"
        return formatter.string(from: Date())
    }
    
    // Helper function to calculate days passed in the year
    func getDaysPassed() -> Int {
        let calendar = Calendar.current
        return calendar.ordinality(of: .day, in: .year, for: Date()) ?? 0
    }
    
    // Helper function to calculate days left in the year
    func getDaysLeftInYear() -> Int {
        return totalDays - getDaysPassed()
    }
}

// View for a single day dot
struct DayDotView: View {
    let day: Int
    let daysPassed: Int
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(getDotColor())
                .frame(width: isSelected ? 16 : 12, height: isSelected ? 16 : 12)
                .shadow(color: getDotColor().opacity(0.2), radius: isSelected ? 8 : 4, x: 0, y: isSelected ? 4 : 2)
                .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.8), value: isSelected)
            
            if isSelected {
                Text("\(day + 1)")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
    }
    
    // Determine the color of the dot based on the day
    private func getDotColor() -> Color {
        if day < daysPassed {
            return Color(red: 0.86, green: 0.08, blue: 0.24) // Crimson for past days
        } else if day == daysPassed {
            return Color.green // Current day
        } else {
            return Color.gray.opacity(0.3) // Future days
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark) // Test in dark mode
    }
}
