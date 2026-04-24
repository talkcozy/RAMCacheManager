import Foundation

struct RAMDiskConfig: Codable {
    var sizeGB: Double
    var volumeName: String
    var autoStart: Bool

    static let `default` = RAMDiskConfig(
        sizeGB: 4.0,
        volumeName: "RAMCache",
        autoStart: false
    )
}

struct CacheEntry: Identifiable, Codable, Hashable {
    let id: UUID
    var sourcePath: String
    var targetSubPath: String
    var icon: String
    var displayName: String
    var isEnabled: Bool

    var sourceFullPath: String {
        (sourcePath as NSString).expandingTildeInPath
    }

    var targetFullPath: String {
        "/Volumes/\(ConfigManager.shared.loadConfig().volumeName)/\(targetSubPath)"
    }

    init(id: UUID = UUID(), sourcePath: String, targetSubPath: String, icon: String, displayName: String, isEnabled: Bool = false) {
        self.id = id
        self.sourcePath = sourcePath
        self.targetSubPath = targetSubPath
        self.icon = icon
        self.displayName = displayName
        self.isEnabled = isEnabled
    }

    static let defaultEntries: [CacheEntry] = [
        CacheEntry(sourcePath: "~/.npm", targetSubPath: "npm", icon: "shippingbox.fill", displayName: "npm Cache"),
        CacheEntry(sourcePath: "~/.cache", targetSubPath: "cache", icon: "folder.fill", displayName: "General Cache"),
        CacheEntry(sourcePath: "~/.cache/uv", targetSubPath: "cache/uv", icon: "arrow.triangle.2.circlepath", displayName: "uv Cache"),
        CacheEntry(sourcePath: "~/.cache/puppeteer", targetSubPath: "cache/puppeteer", icon: "globe", displayName: "Puppeteer Cache"),
        CacheEntry(sourcePath: "~/.cargo/registry", targetSubPath: "cargo-registry", icon: "shippingbox", displayName: "Cargo Registry"),
        CacheEntry(sourcePath: "~/.cocoapods/repos", targetSubPath: "cocoapods", icon: "cube.box.fill", displayName: "CocoaPods"),
        CacheEntry(sourcePath: "~/Library/Caches/go-build", targetSubPath: "go-build", icon: "chevron.left.forwardslash.chevron.right", displayName: "Go Build Cache"),
        CacheEntry(sourcePath: "~/.pnpm-store", targetSubPath: "pnpm-store", icon: "archivebox.fill", displayName: "pnpm Store"),
        CacheEntry(sourcePath: "~/.pub-cache", targetSubPath: "pub-cache", icon: "dartlang", displayName: "Dart Pub Cache")
    ]
}

struct RAMDiskStatus {
    var isMounted: Bool
    var totalSpace: Int64
    var usedSpace: Int64
    var freeSpace: Int64
    var linkedCount: Int

    var usedPercentage: Double {
        guard totalSpace > 0 else { return 0 }
        return Double(usedSpace) / Double(totalSpace) * 100
    }

    static let empty = RAMDiskStatus(
        isMounted: false,
        totalSpace: 0,
        usedSpace: 0,
        freeSpace: 0,
        linkedCount: 0
    )
}
