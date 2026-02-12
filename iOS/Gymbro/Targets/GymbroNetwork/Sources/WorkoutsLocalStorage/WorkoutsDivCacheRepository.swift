import Foundation

public final class DivCacheRepository {
    private let dataSource: DivCacheDataSource


   public init(dataSource: DivCacheDataSource) {
        self.dataSource = dataSource
    }


    public func load(key: String) -> Data? {
        (try? dataSource.load(key: key))
    }


    public func save(key: String, data: Data) {
        try? dataSource.save(key: key, data: data)
    }
}


