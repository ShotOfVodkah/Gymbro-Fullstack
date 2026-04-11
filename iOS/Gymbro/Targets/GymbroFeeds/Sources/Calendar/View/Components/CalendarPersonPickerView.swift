import SwiftUI
import GymbroTypes

struct CalendarPersonPickerView: View {
    
    let people: [CalendarPerson]
    let selectedPerson: CalendarPerson?
    let onSelect: (CalendarPerson) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(people) { person in
                    Button {
                        onSelect(person)
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: person.avatarSystemName)
                                .font(.system(size: 14, weight: .semibold))
                            
                            Text(person.name)
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(
                                    selectedPerson?.id == person.id
                                    ? Color.purple.opacity(0.45)
                                    : Color.white.opacity(0.07)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
