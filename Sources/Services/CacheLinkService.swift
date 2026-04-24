import Foundation

class CacheLinkService {
    static let shared = CacheLinkService()

    private let fileManager = FileManager.default

    private init() {}

    func ensureRAMCacheDirectories() {
        let config = ConfigManager.shared.loadConfig()
        let basePath = "/Volumes/\(config.volumeName)"

        guard fileManager.fileExists(atPath: basePath) else { return }

        for entry in CacheEntry.defaultEntries where entry.isEnabled {
            let targetPath = "\(basePath)/\(entry.targetSubPath)"
            try? fileManager.createDirectory(atPath: targetPath, withIntermediateDirectories: true)
        }
    }

    func isLinkValid(for entry: CacheEntry) -> Bool {
        let sourcePath = entry.sourceFullPath
        let targetPath = entry.targetFullPath

        guard fileManager.fileExists(atPath: targetPath) else { return false }

        do {
            let attributes = try fileManager.attributesOfItem(atPath: sourcePath)
            if let type = attributes[.type] as? FileAttributeType {
                return type == .typeSymbolicLink
            }
        } catch {
            return false
        }

        return false
    }

    func isSourceLinkedToRAMCache(for entry: CacheEntry) -> Bool {
        let sourcePath = entry.sourceFullPath

        do {
            let attributes = try fileManager.attributesOfItem(atPath: sourcePath)
            if let type = attributes[.type] as? FileAttributeType {
                if type == .typeSymbolicLink {
                    let destination = try fileManager.destinationOfSymbolicLink(atPath: sourcePath)
                    return destination == entry.targetFullPath
                }
            }
        } catch {
            return false
        }

        return false
    }

    func linkCache(entry: CacheEntry) throws {
        let sourcePath = entry.sourceFullPath
        let targetPath = entry.targetFullPath

        // Create target directory if needed
        let targetDir = (targetPath as NSString).deletingLastPathComponent
        try fileManager.createDirectory(atPath: targetDir, withIntermediateDirectories: true)

        // Remove existing source if not a symlink
        if fileManager.fileExists(atPath: sourcePath) {
            let isSymlink = try {
                let attrs = try fileManager.attributesOfItem(atPath: sourcePath)
                return (attrs[.type] as? FileAttributeType) == .typeSymbolicLink
            }()

            if !isSymlink {
                // Backup existing directory
                let backupPath = sourcePath + ".backup"
                try? fileManager.moveItem(atPath: sourcePath, toPath: backupPath)
            } else {
                try fileManager.removeItem(atPath: sourcePath)
            }
        }

        // Create symbolic link
        try fileManager.createSymbolicLink(atPath: sourcePath, withDestinationPath: targetPath)

        NotificationCenter.default.post(name: .cacheLinksUpdated, object: entry)
    }

    func unlinkCache(entry: CacheEntry) throws {
        let sourcePath = entry.sourceFullPath

        guard fileManager.fileExists(atPath: sourcePath) else { return }

        let isSymlink = try {
            let attrs = try fileManager.attributesOfItem(atPath: sourcePath)
            return (attrs[.type] as? FileAttributeType) == .typeSymbolicLink
        }()

        if isSymlink {
            try fileManager.removeItem(atPath: sourcePath)
        }

        // Restore from backup if exists
        let backupPath = sourcePath + ".backup"
        if fileManager.fileExists(atPath: backupPath) {
            try fileManager.moveItem(atPath: backupPath, toPath: sourcePath)
        }

        NotificationCenter.default.post(name: .cacheLinksUpdated, object: entry)
    }

    func getLinkedCacheCount() -> Int {
        CacheEntry.defaultEntries.filter { isSourceLinkedToRAMCache(for: $0) }.count
    }

    func syncCacheEntries(entries: [CacheEntry]) {
        for entry in entries {
            if entry.isEnabled && !isSourceLinkedToRAMCache(for: entry) {
                try? linkCache(entry: entry)
            } else if !entry.isEnabled && isSourceLinkedToRAMCache(for: entry) {
                try? unlinkCache(entry: entry)
            }
        }
    }
}
