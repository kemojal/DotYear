import SwiftUI

struct ContentView: View {
    let totalDays = 365
    let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 20) // Reduced grid spacing
    
    @State private var selectedDay: Int? = nil
    @State private var dailyLogs: [Int: String] = [:]
    @State private var showingLogEntry = false
    @State private var logText = ""
    
    // Array of daily affirmations or tips
    let affirmations = [
        "You got this!",
        "One day at a time.",
        "Stay positive!",
        "Believe in yourself.",
        "Every day is a new opportunity.",
        "You are capable of amazing things.",
        "Keep going, you're doing great!",
        "Small steps lead to big changes.",
        "You are stronger than you think.",
        "Today is a gift, make the most of it."
    ]
    
    var body: some View {
        ZStack {
            // Background gradient with a premium feel
            LinearGradient(gradient: Gradient(colors: [Color(.systemBackground), Color(.secondarySystemBackground)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) { // Reduced spacing
                    // Header with current date
                    VStack(alignment: .leading, spacing: 8) { // Reduced spacing
                        Text(getFormattedDate())
                            .font(.system(size: 24, weight: .bold, design: .rounded)) // Reduced font size
                            .foregroundColor(.primary)
                            .shadow(color: Color.primary.opacity(0.1), radius: 2, x: 0, y: 2)
                        
                        Text("Track your year, one day at a time.")
                            .font(.system(size: 16, weight: .medium, design: .default)) // Reduced font size
                            .foregroundColor(.secondary)
                        
                        // Daily Affirmation with Animation
                        Text(getDailyAffirmation())
                            .font(.system(size: 18, weight: .semibold, design: .rounded)) // Reduced font size
                            .foregroundColor(.primary)
                            .padding(.vertical, 8) // Reduced padding
                            .padding(.horizontal, 12) // Reduced padding
                            .background(
                                RoundedRectangle(cornerRadius: 12) // Reduced corner radius
                                    .fill(Color(.systemGray6))
                                    .shadow(color: Color.primary.opacity(0.1), radius: 6, x: 0, y: 3) // Reduced shadow
                            )
                            .transition(.opacity.combined(with: .scale))
                            .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.8), value: getDailyAffirmation())
                    }
                    .padding(.horizontal, 40) // Reduced left/right padding
                    .padding(.top, 40) // Reduced top padding
                    
                    // Dots grid for the year
                    LazyVGrid(columns: columns, spacing: 8) { // Reduced grid spacing
                        ForEach(0..<totalDays, id: \.self) { day in
                            DayDotView(day: day, daysPassed: getDaysPassed(), isSelected: selectedDay == day, hasNote: dailyLogs[day] != nil)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.8)) {
                                        selectedDay = day
                                        logText = dailyLogs[day] ?? ""
                                        showingLogEntry = true
                                    }
                                    // Haptic feedback
                                    let generator = UIImpactFeedbackGenerator(style: .soft)
                                    generator.impactOccurred()
                                }
                        }
                    }
                    .padding(.horizontal, 40) // Reduced left/right padding
                    .padding(.top, 32)
                    
                    // Year and days left at the bottom
                    HStack {
                        Text(getCurrentYear())
                            .font(.system(size: 18, weight: .bold, design: .rounded)) // Reduced font size
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(getDaysLeftInYear()) days left")
                            .font(.system(size: 18, weight: .bold, design: .rounded)) // Reduced font size
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 40) // Reduced left/right padding
                    .padding(.bottom, 40) // Reduced bottom padding
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure content fills the screen
            }
        }
        .sheet(isPresented: $showingLogEntry) {
            LogEntryView(
                logText: $logText,
                day: selectedDay ?? 0,
                totalDays: totalDays,
                onSave: {
                    if let day = selectedDay {
                        dailyLogs[day] = logText
                    }
                    showingLogEntry = false
                }
            )
            .transition(.move(edge: .bottom))
            .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.8), value: showingLogEntry)
        }
    }
    
    // Helper function to format the current date
    func getFormattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d" // "Tuesday, April 22"
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
    
    // Helper function to get the daily affirmation or tip
    func getDailyAffirmation() -> String {
        let dayOfYear = getDaysPassed()
        return affirmations[dayOfYear % affirmations.count]
    }
}

// View for a single day dot
struct DayDotView: View {
    let day: Int
    let daysPassed: Int
    let isSelected: Bool
    let hasNote: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(getDotColor())
                .frame(width: isSelected ? 16 : 12, height: isSelected ? 16 : 12) // Reduced circle size
                .shadow(color: getDotColor().opacity(0.2), radius: isSelected ? 8 : 4, x: 0, y: isSelected ? 4 : 2) // Reduced shadow
                .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.8), value: isSelected)
            
            if isSelected {
                Text("\(day + 1)")
                    .font(.system(size: 10, weight: .bold, design: .rounded)) // Reduced font size
                    .foregroundColor(.white)
                    .transition(.scale.combined(with: .opacity))
            }
            
            if hasNote {
                Image(systemName: "pencil.circle.fill")
                    .font(.system(size: 8)) // Reduced icon size
                    .foregroundColor(.white)
                    .offset(x: 6, y: 6) // Adjusted offset
                    .transition(.scale.combined(with: .opacity))
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
