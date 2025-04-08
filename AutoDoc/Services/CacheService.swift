import Foundation

public protocol CacheServiceProtocol {
    func save(key: String, value: Data)
    func load(key: String) -> Data?
    func delete(key: String)
}

public final class CacheService: CacheServiceProtocol {
    private let cache = NSCache<NSString, NSData>()

    init() {
        cache.countLimit = 500
    }

    public func save(key: String, value: Data) {
        cache.setObject(value as NSData, forKey: key as NSString)
    }

    public func load(key: String) -> Data? {
        cache.object(forKey: key as NSString) as Data?
    }

    public func delete(key: String) {
        cache.removeObject(forKey: key as NSString)
    }
}
