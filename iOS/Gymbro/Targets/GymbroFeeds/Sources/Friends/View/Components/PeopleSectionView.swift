import SwiftUI

struct PeopleSectionView: View {
    
    let title: String
    let people: [PersonItem]
    let onPersonTap: (PersonItem) -> Void
    let onFollowTap: (PersonItem) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
            
            VStack(spacing: 10) {
                ForEach(people) { person in
                    PersonRowView(
                        person: person,
                        onTap: { onPersonTap(person) },
                        onFollowTap: { onFollowTap(person) }
                    )
                }
            }
        }
    }
}
