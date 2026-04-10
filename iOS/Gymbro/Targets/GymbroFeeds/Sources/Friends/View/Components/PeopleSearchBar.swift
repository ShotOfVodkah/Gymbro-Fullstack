import SwiftUI

struct PeopleSearchBar: View {
    
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.white.opacity(0.65))
            
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text("Search people")
                        .foregroundStyle(.white.opacity(0.45))
                }
                
                TextField("", text: $text)
                    .foregroundStyle(.white)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
