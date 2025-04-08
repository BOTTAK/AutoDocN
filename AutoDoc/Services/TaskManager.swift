import Foundation

public protocol TaskManagerProtocol {
    func addOrGet(urlString: String, taskProvider: @escaping @Sendable () async throws -> Data) async throws -> Data
    func remove(urlString: String)
    func cancel(urlString: String)
    func getRunningRequests() -> [String: Task<Data, any Error>]
    func cancelAllTasks()
}

public final class TaskManager: TaskManagerProtocol {
    private var runningTasks: [String: Task<Data, any Error>] = [:]
    private let lock = NSLock()

    deinit {
        cancelAllTasks()
    }

    public func addOrGet(urlString: String,
                         taskProvider: @escaping @Sendable () async throws -> Data) async throws -> Data {
        let task: Task<Data, Error> = lock.withLock {
            if let existingTask = runningTasks[urlString] {
                return existingTask
            }

            let newTask = Task {
                try await taskProvider()
            }
            runningTasks[urlString] = newTask
            return newTask
        }

        do {
            let result = try await task.value
            lock.withLock {
                runningTasks[urlString] = nil
            }
            return result
        } catch {
            lock.withLock {
                runningTasks[urlString] = nil
            }
            throw error
        }
    }

    public func remove(urlString: String) {
        lock.withLock {
            runningTasks[urlString] = nil
        }
    }

    public func cancel(urlString: String) {
        lock.withLock {
            runningTasks[urlString]?.cancel()
            runningTasks[urlString] = nil
        }
    }

    public func getRunningRequests() -> [String: Task<Data, any Error>] {
        lock.withLock {
            return runningTasks
        }
    }

    public func cancelAllTasks() {
        lock.withLock {
            runningTasks.forEach { $0.value.cancel() }
            runningTasks.removeAll()
        }
    }
}
