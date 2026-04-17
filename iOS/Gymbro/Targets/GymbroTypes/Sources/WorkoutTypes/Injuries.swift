import Foundation

public enum Injury: CaseIterable {
    case knee
    case shoulder
    case lowerBack
    case wrist
    case neck
    case ankle
    case bloodPressure
    case elbow
    case pregnancy
    
    public var codingValue: String {
        switch self {
        case .knee: "knee_injury"
        case .shoulder: "shoulder_injury"
        case .lowerBack: "lower_back_pain"
        case .wrist: "wrist_injury"
        case .neck: "neck_injury"
        case .ankle: "ankle_injury"
        case .bloodPressure: "high_blood_pressure"
        case .elbow: "elbow_injury"
        case .pregnancy: "pregnancy"
        }
    }
    
    public var stringValue: String {
        switch self {
        case .knee: "Knee injury"
        case .shoulder: "Shoulder injury"
        case .lowerBack: "Lower back pain"
        case .wrist: "Wrist injury"
        case .neck: "Neck injury"
        case .ankle: "Ankle injury"
        case .bloodPressure: "High blood pressure"
        case .elbow: "Elbow injury"
        case .pregnancy: "Pregnancy"
        }
    }

    public var localizedTitle: String {
        switch self {
        case .knee:
            return String(localized: "injury.knee", bundle: .module)
        case .shoulder:
            return String(localized: "injury.shoulder", bundle: .module)
        case .lowerBack:
            return String(localized: "injury.lower_back", bundle: .module)
        case .wrist:
            return String(localized: "injury.wrist", bundle: .module)
        case .neck:
            return String(localized: "injury.neck", bundle: .module)
        case .ankle:
            return String(localized: "injury.ankle", bundle: .module)
        case .bloodPressure:
            return String(localized: "injury.blood_pressure", bundle: .module)
        case .elbow:
            return String(localized: "injury.elbow", bundle: .module)
        case .pregnancy:
            return String(localized: "injury.pregnancy", bundle: .module)
        }
    }
}
