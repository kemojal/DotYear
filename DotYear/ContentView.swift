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
                .transition(.opacity.combined(with: .scale))
                .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.8), value: selectedView)
                
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


//day dot view
struct DayDotView: View {
    let day: Int
    let daysPassed: Int
    let isSelected: Bool
    let hasNote: Bool
    var dotSize: CGFloat = 12

    var body: some View {
        ZStack {
            Circle()
                .fill(getDotColor())
                .frame(width: isSelected ? dotSize * 1.5 : dotSize, height: isSelected ? dotSize * 1.5 : dotSize)
                .shadow(color: getDotColor().opacity(0.2), radius: isSelected ? 8 : 4, x: 0, y: isSelected ? 4 : 2)
                .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.8), value: isSelected)

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
// MARK: - Grid Views (Year, Month, Week)

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
                    hasNote: dailyLogs[day] != nil
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
    
    let totalMonths = 12
    let columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 4) // Adjusted spacing
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) { // Increased spacing
            ForEach(0..<totalMonths, id: \.self) { month in
                MonthBarView(
                    month: month,
                    currentMonth: getCurrentMonth(),
                    isSelected: selectedDay == month,
                    hasNote: dailyLogs[month] != nil
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.5)) {
                        selectedDay = month
                        showingLogEntry = true
                    }
                }
            }
        }
        .padding(.horizontal, 32) // Increased padding for better alignment
        .padding(.top, 24)
    }
    
    // Helper function to get the current month of the year
    func getCurrentMonth() -> Int {
        let calendar = Calendar.current
        return calendar.component(.month, from: Date()) - 1 // Adjust for zero-based index
    }
}

struct MonthBarView: View {
    let month: Int
    let currentMonth: Int
    let isSelected: Bool
    let hasNote: Bool
    var barWidth: CGFloat = 80 // Increased width
    var barHeight: CGFloat = 120 // Increased height

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12) // Increased corner radius
                .fill(getBarColor())
                .frame(width: isSelected ? barWidth * 1.1 : barWidth, height: isSelected ? barHeight * 1.1 : barHeight)
                .shadow(color: getBarColor().opacity(0.3), radius: isSelected ? 12 : 6, x: 0, y: isSelected ? 6 : 3)
                .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.8), value: isSelected)

            VStack(spacing: 8) {
                Text("\(month + 1)") // Display month number
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .transition(.scale.combined(with: .opacity))

                if hasNote {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
    }

    private func getBarColor() -> Color {
        if month < currentMonth {
            return Color(red: 0.86, green: 0.08, blue: 0.24) // Crimson for past months
        } else if month == currentMonth {
            return Color.green // Current month
        } else {
            return Color.gray.opacity(0.3) // Future months
        }
    }
}

//struct MonthBarView: View {
//    let month: Int
//    let currentMonth: Int
//    let isSelected: Bool
//    let hasNote: Bool
//    var barWidth: CGFloat = 40
//    var barHeight: CGFloat = 60
//
//    var body: some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 8)
//                .fill(getBarColor())
//                .frame(width: isSelected ? barWidth * 1.2 : barWidth, height: isSelected ? barHeight * 1.2 : barHeight)
//                .shadow(color: getBarColor().opacity(0.2), radius: isSelected ? 8 : 4, x: 0, y: isSelected ? 4 : 2)
//                .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.8), value: isSelected)
//
//            if isSelected {
//                Text("\(month + 1)")
//                    .font(.system(size: 12, weight: .bold, design: .rounded))
//                    .foregroundColor(.white)
//                    .transition(.scale.combined(with: .opacity))
//            }
//
//            if hasNote {
//                Image(systemName: "pencil.circle.fill")
//                    .font(.system(size: 8))
//                    .foregroundColor(.white)
//                    .offset(x: 16, y: 24)
//                    .transition(.scale.combined(with: .opacity))
//            }
//        }
//    }
//
//    private func getBarColor() -> Color {
//        if month < currentMonth {
//            return Color(red: 0.86, green: 0.08, blue: 0.24) // Crimson for past months
//        } else if month == currentMonth {
//            return Color.green // Current month
//        } else {
//            return Color.gray.opacity(0.3) // Future months
//        }
//    }
//}

struct WeekGridView: View {
    @Binding var selectedDay: Int?
    @Binding var dailyLogs: [Int: String]
    @Binding var showingLogEntry: Bool
    let daysPassed: Int
    
    let totalWeeks = 52
    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 7) // Adjusted spacing
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) { // Increased spacing
            ForEach(0..<totalWeeks, id: \.self) { week in
                WeekBarView(
                    week: week,
                    currentWeek: getCurrentWeek(),
                    isSelected: selectedDay == week,
                    hasNote: dailyLogs[week] != nil
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.5)) {
                        selectedDay = week
                        showingLogEntry = true
                    }
                }
            }
        }
        .padding(.horizontal, 32) // Increased padding for better alignment
        .padding(.top, 16) // Reduced top padding to make space for footer
    }
    
    // Helper function to get the current week of the year
    func getCurrentWeek() -> Int {
        let calendar = Calendar.current
        return calendar.component(.weekOfYear, from: Date())
    }
}

struct WeekBarView: View {
    let week: Int
    let currentWeek: Int
    let isSelected: Bool
    let hasNote: Bool
    var barWidth: CGFloat = 40 // Increased width
    var barHeight: CGFloat = 50 // Reduced height to ensure footer visibility

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8) // Increased corner radius
                .fill(getBarColor())
                .frame(width: isSelected ? barWidth * 1.1 : barWidth, height: isSelected ? barHeight * 1.1 : barHeight)
                .shadow(color: getBarColor().opacity(0.3), radius: isSelected ? 12 : 6, x: 0, y: isSelected ? 6 : 3)
                .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.8), value: isSelected)

            VStack(spacing: 4) {
                Text("\(week + 1)") // Display week number
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .transition(.scale.combined(with: .opacity))

                if hasNote {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
    }

    private func getBarColor() -> Color {
        if week < currentWeek {
            return Color(red: 0.86, green: 0.08, blue: 0.24) // Crimson for past weeks
        } else if week == currentWeek {
            return Color.green // Current week
        } else {
            return Color.gray.opacity(0.3) // Future weeks
        }
    }
}
struct DayBarView: View {
    let day: Int
    let daysPassed: Int
    let isSelected: Bool
    let hasNote: Bool
    var barWidth: CGFloat = 20
    var barHeight: CGFloat = 40

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(getDotColor())
                .frame(width: isSelected ? barWidth * 1.2 : barWidth, height: isSelected ? barHeight * 1.2 : barHeight)
                .shadow(color: getDotColor().opacity(0.2), radius: isSelected ? 8 : 4, x: 0, y: isSelected ? 4 : 2)
                .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.8), value: isSelected)

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
                    .offset(x: 10, y: 16)
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
