import Foundation
import SwiftUI

import GymbroNetwork
import GymbroNavigation

public final class WorkoutBuilderFactoryImpl {

    public init() {}

    @MainActor
    public func makeView(
    ) -> some View  {
        return WorkoutBuilderView()
    }
    
    private var viewModelCache: WorkoutsListViewModel?
}
