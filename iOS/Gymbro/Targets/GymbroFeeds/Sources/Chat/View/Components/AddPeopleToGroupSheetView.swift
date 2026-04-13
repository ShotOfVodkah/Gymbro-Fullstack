import SwiftUI
import GymbroCommonUI
import GymbroTypes

struct AddPeopleToGroupSheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText: String = ""
    @State private var selectedIDs: Set<String> = []
    
    let allPeople: [ChatParticipant]
    let existingParticipantIDs: Set<String>
    let onAdd: ([ChatParticipant]) -> Void
    
    private var filteredPeople: [ChatParticipant] {
        let available = allPeople.filter { !existingParticipantIDs.contains($0.id) }
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return available }
        
        return available.filter {
            $0.name.localizedCaseInsensitiveContains(query)
        }
    }
    
    var body: some View {
        ZStack {
            backgroundView
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Add people")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white)
                
                PeopleSearchBar(text: $searchText)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(filteredPeople) { person in
                            row(person)
                        }
                    }
                }
                
                AppButton("Add selected", size: .l, action: {
                    let selected = filteredPeople.filter { selectedIDs.contains($0.id) } + allPeople.filter { selectedIDs.contains($0.id) && !filteredPeople.contains($0) }
                    onAdd(Array(Set(selected)))
                    dismiss()
                }, wrapContent: false)
                .opacity(selectedIDs.isEmpty ? 0.5 : 1)
                .disabled(selectedIDs.isEmpty)
            }
            .padding(20)
        }
    }
    
    private var backgroundView: some View {
        LinearGradient(
            colors: [
                Color(red: 18.0/255.0, green: 20.0/255.0, blue: 28.0/255.0),
                Color(red: 28.0/255.0, green: 32.0/255.0, blue: 42.0/255.0),
                Color(red: 20.0/255.0, green: 24.0/255.0, blue: 34.0/255.0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    private func row(_ person: ChatParticipant) -> some View {
        let isSelected = selectedIDs.contains(person.id)
        
        return Button {
            if isSelected {
                selectedIDs.remove(person.id)
            } else {
                selectedIDs.insert(person.id)
            }
        } label: {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.appPurple.opacity(0.8))
                    .frame(width: 42, height: 42)
                    .overlay(
                        Image(systemName: person.avatarSystemName)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.white)
                    )
                
                Text(person.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(isSelected ? Color.appPurple : .white.opacity(0.45))
            }
            .padding(14)
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }
}
