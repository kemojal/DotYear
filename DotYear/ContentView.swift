import SwiftUI

struct ContentView: View {
    @State private var selectedView: GridViewType = .year
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
    
    enum GridViewType: String, CaseIterable {
        case year = "Year"
        case month = "Month"
        case week = "Week"
        
        var icon: String {
            switch self {
            case .year: return "calendar"
            case .month: return "calendar.circle"
            case .week: return "calendar.badge.clock"
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Background gradient with a premium feel
            LinearGradient(gradient: Gradient(colors: [Color(.systemBackground), Color(.secondarySystemBackground)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header with current date and view switcher
                VStack(spacing: 16) {
                    Text(getFormattedDate())
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .shadow(color: Color.primary.opacity(0.1), radius: 2, x: 0, y: 2)
                    
                    Text("Track your year, one day at a time.")
                        .font(.system(size: 16, weight: .medium, design: .default))
                        .foregroundColor(.secondary)
                    
                    // Daily Affirmation
                    Text(getDailyAffirmation())
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                                .shadow(color: Color.primary.opacity(0.1), radius: 6, x: 0, y: 3)
                        )
                        .transition(.opacity.combined(with: .scale))
                        .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.8), value: getDailyAffirmation())
                }
                .padding(.top, 40)
                
                // Tab Buttons with Icons (placed right above the grid)
                HStack(spacing: 16) {
                    ForEach(GridViewType.allCases, id: \.self) { view in
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.5)) {
                                selectedView = view
                            }
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: view.icon)
                                    .font(.system(size: 20, weight: .medium, design: .rounded))
                                    .foregroundColor(selectedView == view ? .blue : .secondary)
                                    .padding(10)
                                    .background(
                                        Circle()
                                            .fill(selectedView == view ? Color.blue.opacity(0.1) : Color.clear)
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(selectedView == view ? Color.blue : Color.clear, lineWidth: 1)
                                    )
                                
                                Text(view.rawValue)
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(selectedView == view ? .blue : .secondary)
                            }
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
                .padding(.top, 20)
                
                // Dynamic Grid View
               
                    
                    VStack(spacing: 16) {
                        switch selectedView {
                        case .year:
                            YearGridView(selectedDay: $selectedDay, dailyLogs: $dailyLogs, showingLogEntry: $showingLogEntry, daysPassed: getDaysPassed())
                        case .month:
                            MonthGridView(selectedDay: $selectedDay, dailyLogs: $dailyLogs, showingLogEntry: $showingLogEntry, daysPassed: getDaysPassed())
                        case .week:
                            WeekGridView(selectedDay: $selectedDay, dailyLogs: $dailyLogs, showingLogEntry: $showingLogEntry, daysPassed: getDaysPassed())
                        }
                    }
                
                
                // Footer with Current View and Time Left
                HStack {
                    Text(getCurrentViewText())
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(getTimeLeftText())
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
                .padding(.top, 16)
            }
        }
        .sheet(isPresented: $showingLogEntry) {
            LogEntryView(
                logText: $logText,
                day: selectedDay ?? 0,
                totalDays: selectedView == .year ? 365 : (selectedView == .month ? 31 : 7),
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
    
    // MARK: - Helper Functions
    
    // Helper function to format the current date
    func getFormattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d" // "Tuesday, April 22"
        return formatter.string(from: Date())
    }
    
    // Helper function to get the daily affirmation or tip
    func getDailyAffirmation() -> String {
        let dayOfYear = getDaysPassed()
        return affirmations[dayOfYear % affirmations.count]
    }
    
    // Helper function to calculate days passed in the year
    func getDaysPassed() -> Int {
        let calendar = Calendar.current
        return calendar.ordinality(of: .day, in: .year, for: Date()) ?? 0
    }
    
    // Helper function to calculate days left in the year
    func getDaysLeftInYear() -> Int {
        return 365 - getDaysPassed()
    }
    
    // Helper function to get the current view text (e.g., "2025" or "January")
    func getCurrentViewText() -> String {
        let calendar = Calendar.current
        switch selectedView {
        case .year:
            return getCurrentYear()
        case .month:
            let month = calendar.component(.month, from: Date())
            return calendar.monthSymbols[month - 1]
        case .week:
            let week = calendar.component(.weekOfYear, from: Date())
            return "Week \(week)"
        }
    }
    
    // Helper function to get the current year
    func getCurrentYear() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy" // "2025"
        return formatter.string(from: Date())
    }
    
    // Helper function to get the time left text (e.g., "347 days left" or "11 months left")
    func getTimeLeftText() -> String {
        let calendar = Calendar.current
        switch selectedView {
        case .year:
            return "\(getDaysLeftInYear()) days left"
        case .month:
            let month = calendar.component(.month, from: Date())
            return "\(12 - month) months left"
        case .week:
            let week = calendar.component(.weekOfYear, from: Date())
            return "\(52 - week) weeks left"
        }
    }
}

// MARK: - Grid Views (Year, Month, Week)

struct YearGridView: View {
    @Binding var selectedDay: Int?
    @Binding var dailyLogs: [Int: String]
    @Binding var showingLogEntry: Bool
    let daysPassed: Int
    
    let totalDays = 365
    let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 20)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(0..<totalDays, id: \.self) { day in
                DayDotView(
                    day: day,
                    daysPassed: daysPassed,
                    isSelected: selectedDay == day,
                    hasNote: dailyLogs[day] != nil,
                    isBar: false // Use circles for the Year view
                )
                .onTapGesture {
                    selectedDay = day
                    showingLogEntry = true
                }
            }
        }
        .padding(.horizontal, 40)
        .padding(.top, 16)
    }
}
struct MonthGridView: View {
    @Binding var selectedDay: Int?
    @Binding var dailyLogs: [Int: String]
    @Binding var showingLogEntry: Bool
    let daysPassed: Int
    
    let totalDays = 31
    let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 7)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(0..<totalDays, id: \.self) { day in
                DayDotView(
                    day: day,
                    daysPassed: daysPassed,
                    isSelected: selectedDay == day,
                    hasNote: dailyLogs[day] != nil,
                    dotSize: 20,
                    isBar: true // Use bars for the Month view
                )
                .onTapGesture {
                    selectedDay = day
                    showingLogEntry = true
                }
            }
        }
        .padding(.horizontal, 40)
        .padding(.top, 16)
    }
}
struct WeekGridView: View {
    @Binding var selectedDay: Int?
    @Binding var dailyLogs: [Int: String]
    @Binding var showingLogEntry: Bool
    let daysPassed: Int
    
    let totalDays = 7
    let columns = Array(repeating: GridItem(.flexible(), spacing: 24), count: 7)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 24) {
            ForEach(0..<totalDays, id: \.self) { day in
                DayDotView(
                    day: day,
                    daysPassed: daysPassed,
                    isSelected: selectedDay == day,
                    hasNote: dailyLogs[day] != nil,
                    dotSize: 30,
                    isBar: true // Use bars for the Week view
                )
                .onTapGesture {
                    selectedDay = day
                    showingLogEntry = true
                }
            }
        }
        .padding(.horizontal, 40)
        .padding(.top, 16)
    }
}

// MARK: - Components (DayDotView, ScaleButtonStyle)

struct DayDotView: View {
    let day: Int
    let daysPassed: Int
    let isSelected: Bool
    let hasNote: Bool
    var dotSize: CGFloat = 12
    var isBar: Bool = false // Add this property to toggle between circle and bar

    var body: some View {
        ZStack {
            if isBar {
                // Bar shape for month and week views
                RoundedRectangle(cornerRadius: 4)
                    .fill(getDotColor())
                    .frame(width: isSelected ? dotSize * 1.5 : dotSize, height: dotSize * 2) // Adjust height for bars
                    .shadow(color: getDotColor().opacity(0.2), radius: isSelected ? 8 : 4, x: 0, y: isSelected ? 4 : 2)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.8), value: isSelected)
            } else {
                // Circle shape for year view
                Circle()
                    .fill(getDotColor())
                    .frame(width: isSelected ? dotSize * 1.5 : dotSize, height: isSelected ? dotSize * 1.5 : dotSize)
                    .shadow(color: getDotColor().opacity(0.2), radius: isSelected ? 8 : 4, x: 0, y: isSelected ? 4 : 2)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.8), value: isSelected)
            }

            if isSelected {
                Text("\(day + 1)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .transition(.scale.combined(with: .opacity))
            }

            if hasNote {
                Image(systemName: "pencil.circle.fill")
                    .font(.system(size: 8))
                    .foregroundColor(.white)
                    .offset(x: 6, y: 6)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }

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
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.5), value: configuration.isPressed)
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
