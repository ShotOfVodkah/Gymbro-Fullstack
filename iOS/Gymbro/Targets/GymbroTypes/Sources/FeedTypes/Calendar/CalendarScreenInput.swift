import Foundation
import GymbroNavigation

public struct CalendarScreenInput: Hashable {
    public let context: CalendarContext
    
    public init(context: CalendarContext) {
        self.context = context
    }
}
