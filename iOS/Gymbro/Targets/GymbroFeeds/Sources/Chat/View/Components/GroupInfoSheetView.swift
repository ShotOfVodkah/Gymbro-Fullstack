import SwiftUI
import GymbroCommonUI
import GymbroTypes

struct GroupInfoSheetView: View {
    
    @State private var title: String
    @State private var description: String
    @State private var isShowingAddPeopleSheet = false
    
    let info: ChatGroupInfo
    let onUpdate: (String, String) -> Void
    let onDelete: () -> Void
    let onRemovePerson: (String) -> Void
    let onAddPeople: ([ChatParticipant]) -> Void
    
    init(
        info: ChatGroupInfo,
        onUpdate: @escaping (String, String) -> Void,
        onDelete: @escaping () -> Void,
        onRemovePerson: @escaping (String) -> Void,
        onAddPeople: @escaping ([ChatParticipant]) -> Void
    ) {
        self.info = info
        self.onUpdate = onUpdate
        self.onDelete = onDelete
        self.onRemovePerson = onRemovePerson
        self.onAddPeople = onAddPeople
        
        _title = State(initialValue: info.title)
        _description = State(initialValue: info.description)
    }
    
    var body: some View {
        ZStack {
            backgroundView
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Group info")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                    
                    inputField(title: "Group name", text: $title)
                    inputField(title: "Description", text: $description)
                    
                    Text("Participants")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                    
                    VStack(spacing: 10) {
                        ForEach(info.participants) { participant in
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(Color.appPurple.opacity(0.8))
                                    .frame(width: 42, height: 42)
                                    .overlay(
                                        Image(systemName: participant.avatarSystemName)
                                            .font(.system(size: 17, weight: .bold))
                                            .foregroundStyle(.white)
                                    )
                                
                                Text(participant.name)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.white)
                                
                                Spacer()
                                
                                Button("Remove") {
                                    onRemovePerson(participant.id)
                                }
                                .foregroundStyle(.red.opacity(0.85))
                            }
                            .padding(14)
                            .background(Color.white.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                    }
                    
                    AppButton("Add people", size: .l, action: {
                        isShowingAddPeopleSheet = true
                    }, wrapContent: false)
                    
                    AppButton("Save changes", size: .l, action: {
                        onUpdate(title, description)
                    }, wrapContent: false)
                    
                    AppButton("Delete group", size: .l, action: onDelete, wrapContent: false)
                }
                .padding(20)
            }
        }
        .sheet(isPresented: $isShowingAddPeopleSheet) {
            AddPeopleToGroupSheetView(
                existingParticipantIDs: Set(info.participants.map(\.id)),
                onAdd: { people in
                    onAddPeople(people)
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.clear)
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
    
    private func inputField(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white.opacity(0.7))
            
            TextField(title, text: text, axis: .vertical)
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }
}
