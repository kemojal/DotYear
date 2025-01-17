import SwiftUI

// MARK: - Title Section Component
struct TitleSectionView: View {
    @Binding var title: String
    let day: Int
    let totalDays: Int
   
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Day \(day + 1) / \(totalDays) Journal")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            TextField("Title", text: $title)
                .font(.system(size: 18, weight: .medium, design: .default))
                .padding()
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .padding(.horizontal)
    }
}

// MARK: - List Item Component
struct ListItemView: View {
    @Binding var item: String
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            TextField("Item", text: $item)
                .font(.system(size: 16, weight: .regular, design: .default))
                .padding()
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .padding(8)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
        }
    }
}

// MARK: - Notes Section Component
struct NotesSectionView: View {
    @Binding var logText: String
    @Binding var isEditing: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            TextEditor(text: $logText)
                .frame(height: 150)
                .padding()
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isEditing ? Color.blue : Color(.systemGray4), lineWidth: 1)
                )
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isEditing = true
                    }
                }
        }
        .padding(.horizontal)
    }
}

// MARK: - Main View
struct LogEntryView: View {
    @Binding var logText: String
    var day: Int
    var totalDays: Int
    var onSave: () -> Void
    
    @State private var isEditing: Bool = false
    @State private var title: String = ""
    @State private var listItems: [String] = []
    @State private var newListItem: String = ""
    
    var mainContent: some View {
    VStack(spacing: 16) {
        // Title Section
        TitleSectionView(title: $title, day: day, totalDays: totalDays)
        
     // List Items
// ForEach(listItems.indices, id: \.self) { index in
//     ListItemView(
//         item: Binding<String>(
//             get: { self.listItems[index] },
//             set: { self.listItems[index] = $0 }
//         ),
//         onDelete: {
//             withAnimation(.easeInOut(duration: 0.2)) {
//                 self.listItems.remove(at: index)
//             }
//         }
//     )
// }
// .padding(.horizontal)

        
        // Add New List Item
        HStack {
            TextField("Add a new item", text: $newListItem)
                .font(.system(size: 16, weight: .regular, design: .default))
                .padding()
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if !newListItem.isEmpty {
                        listItems.append(newListItem)
                        newListItem = ""
                    }
                }
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
                    .padding(8)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
        }
        
        // Notes Section
        NotesSectionView(logText: $logText, isEditing: $isEditing)
    }
    .padding(.horizontal)
}

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            mainContent
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(.systemBackground), Color(.secondarySystemBackground)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationTitle("Journal Entry")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.8)) {
                        onSave()
                    }
                }) {
                    Text("Save")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.blue)
                }
            }
        }
    }
}
