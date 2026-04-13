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
}
