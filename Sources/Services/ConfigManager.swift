import Foundation

class ConfigManager {
    static let shared = ConfigManager()

    private let configPath: URL

    private init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appFolder = appSupport.appendingPathComponent("RAMCacheManager")

        try? FileManager.default.createDirectory(at: appFolder, withIntermediateDirectories: true)

        configPath = appFolder.appendingPathComponent("config.json")
    }

    func loadConfig() -> RAMDiskConfig {
        guard FileManager.default.fileExists(atPath: configPath.path),
              let data = try? Data(contentsOf: configPath),
              let config = try? JSONDecoder().decode(RAMDiskConfig.self, from: data) else {
            return .default
        }
        return config
    }

    func saveConfig(_ config: RAMDiskConfig) {
        guard let data = try? JSONEncoder().encode(config) else { return }
        try? data.write(to: configPath)
    }

    func loadCacheEntries() -> [CacheEntry] {
        let entriesPath = configPath.deletingLastPathComponent().appendingPathComponent("entries.json")

        guard FileManager.default.fileExists(atPath: entriesPath.path),
              let data = try? Data(contentsOf: entriesPath),
              let entries = try? JSONDecoder().decode([CacheEntry].self, from: data) else {
            return CacheEntry.defaultEntries
        }
        return entries
    }

    func saveCacheEntries(_ entries: [CacheEntry]) {
        let entriesPath = configPath.deletingLastPathComponent().appendingPathComponent("entries.json")

        guard let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: entriesPath)
    }
}
