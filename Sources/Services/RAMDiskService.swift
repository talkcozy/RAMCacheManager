import Foundation

class RAMDiskService {
    static let shared = RAMDiskService()

    private init() {}

    func isRAMDiskMounted(volumeName: String = ConfigManager.shared.loadConfig().volumeName) -> Bool {
        let volumePath = "/Volumes/\(volumeName)"
        var stat = statfs()
        return FMFileExists(at: volumePath)
    }

    func createRAMDisk(name: String, sizeGB: Double) throws {
        guard !isRAMDiskMounted(volumeName: name) else {
            throw RAMDiskError.alreadyMounted
        }

        let sectors = Int(sizeGB * 1024 * 1024 * 1024 / 512)

        // Create RAM disk device
        let deviceResult = runCommand("/usr/bin/hdiutil", arguments: ["attach", "-nomount", "ram://\(sectors)"])
        let device = deviceResult.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !device.isEmpty, !device.hasPrefix("hdiutil") else {
            throw RAMDiskError.creationFailed(deviceResult)
        }

        // Format and mount
        let mountResult = runCommand("/usr/sbin/diskutil", arguments: ["erasevolume", "HFS+", name, device])
        if mountResult.contains("Volume result") {
            throw RAMDiskError.creationFailed(mountResult)
        }
    }

    func deleteRAMDisk(volumeName: String) throws {
        guard isRAMDiskMounted(volumeName: volumeName) else {
            throw RAMDiskError.notMounted
        }

        let volumePath = "/Volumes/\(volumeName)"
        let result = runCommand("/usr/sbin/diskutil", arguments: ["unmountDisk", volumePath])

        if result.contains("Unmount failed") {
            throw RAMDiskError.deletionFailed(result)
        }
    }

    func getStatus(volumeName: String = ConfigManager.shared.loadConfig().volumeName) -> RAMDiskStatus {
        let volumePath = "/Volumes/\(volumeName)"

        guard FileManager.default.fileExists(atPath: volumePath) else {
            return .empty
        }

        do {
            let attributes = try FileManager.default.attributesOfFileSystem(forPath: volumePath)

            let totalSpace = (attributes[.systemSize] as? Int64) ?? 0
            let freeSpace = (attributes[.systemFreeSize] as? Int64) ?? 0
            let usedSpace = totalSpace - freeSpace

            let linkedCount = CacheLinkService.shared.getLinkedCacheCount()

            return RAMDiskStatus(
                isMounted: true,
                totalSpace: totalSpace,
                usedSpace: usedSpace,
                freeSpace: freeSpace,
                linkedCount: linkedCount
            )
        } catch {
            return .empty
        }
    }

    private func runCommand(_ command: String, arguments: [String]) -> String {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: command)
        task.arguments = arguments

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe

        do {
            try task.run()
            task.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            return "Error: \(error.localizedDescription)"
        }
    }

    private func FMFileExists(at path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
}

enum RAMDiskError: LocalizedError {
    case alreadyMounted
    case notMounted
    case creationFailed(String)
    case deletionFailed(String)

    var errorDescription: String? {
        switch self {
        case .alreadyMounted:
            return "RAM disk is already mounted"
        case .notMounted:
            return "RAM disk is not mounted"
        case .creationFailed(let message):
            return "Failed to create RAM disk: \(message)"
        case .deletionFailed(let message):
            return "Failed to delete RAM disk: \(message)"
        }
    }
}
