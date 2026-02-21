import SwiftUI
import DivKit

struct PremadeWorkoutSheet: View {
    
    struct Model: Identifiable {
        let id: Int = 1
        let components: DivKitComponents
        let source: DivViewSource
    }
    
    init(model: Model) {
        self.model = model
    }
    
    var body: some View {
        DivHostingView(divkitComponents: model.components, source: model.source)
            .ignoresSafeArea(.container, edges: .bottom)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.appDarkGray.ignoresSafeArea(.all))
        
    }
    
    private let model: Model
}
