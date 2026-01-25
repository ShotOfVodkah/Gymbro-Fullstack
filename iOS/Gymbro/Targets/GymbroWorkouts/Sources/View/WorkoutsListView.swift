import SwiftUI

import GymbroNetwork
import DivKit

struct WorkoutsListView: View {

    init(viewModel: WorkoutsListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Group {
            if let source = viewModel.source {
                DivHostingView(divkitComponents: divkitComponents, source: source)
            } else {
                ProgressView("Loading")
            }
        }
        .onAppear { viewModel.onAppear() }
        .sheet(item: $sheetItem) { item in
            WorkoutDetailsSheet(workoutName: item.name)
        }
    }

    // MARK: - Sheet state

    private struct SheetItem: Identifiable {
        let id = UUID()
        let name: String
    }

    @State private var sheetItem: SheetItem? = nil

    // MARK: - DivKit

    private var divkitComponents: DivKitComponents {
        let handler = WorkoutsDivUrlHandler { name in
            sheetItem = SheetItem(name: name)
        }
        return DivKitComponents(urlHandler: handler)
    }

    @ObservedObject private var viewModel: WorkoutsListViewModel
}

struct WorkoutDetailsSheet: View {
    let workoutName: String

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                Text(workoutName)
                    .font(.title2)
                Text("Details / actions here…")
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding()
            .navigationTitle("Workout")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutsListView(
            viewModel: WorkoutsListViewModel(
                networkClient: WorkoutsNetworkClientImpl()
            )
        )
    }
}

