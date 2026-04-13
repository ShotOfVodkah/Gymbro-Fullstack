import Foundation
import GymbroTypes

public final class ExercisesRepository {
    private let dataSource: ExercisesCacheDataSource
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(dataSource: ExercisesCacheDataSource) {
        self.dataSource = dataSource
    }

    public func load(type: AvailableExercisesKey) -> [ExerciseItemDTO] {
        guard
            let data = try? dataSource.load(key: type.rawKey),
            let items = try? decoder.decode([ExerciseItemDTO].self, from: data)
        else { return [] }

        return items
    }

    public func load(type: AvailableExercisesKey, id: String) -> ExerciseItemDTO? {
        load(type: type).first { $0.asExercise.id == id }
    }

    public func save(type: AvailableExercisesKey, items: [ExerciseItemDTO]) {
        guard let data = try? encoder.encode(items) else { return }
        try? dataSource.save(key: type.rawKey, data: data)
    }

    public func upsert(type: AvailableExercisesKey, item: ExerciseItemDTO) {
        var current = load(type: type)

        let itemId = item.asExercise.id
        if let idx = current.firstIndex(where: { $0.asExercise.id == itemId }) {
            current[idx] = item
        } else {
            current.append(item)
        }

        save(type: type, items: current)
    }

    public func clearAll() {
        try? dataSource.deleteAll()
    }
}
