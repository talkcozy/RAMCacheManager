import Foundation

class LaunchAgentService {
    static let shared = LaunchAgentService()

    private let launchAgentsPath = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Library/LaunchAgents")

    private let agentLabel = "com.ramcachemanager"

    private var agentPlistPath: URL {
        launchAgentsPath.appendingPathComponent("\(agentLabel).plist")
    }

    private init() {}

    var isInstalled: Bool {
        FileManager.default.fileExists(atPath: agentPlistPath.path)
    }

    func install(config: RAMDiskConfig) throws {
        let executablePath = Bundle.main.executablePath ?? "/usr/local/bin/RAMCacheManager"

        let plist: [String: Any] = [
            "Label": agentLabel,
            "ProgramArguments": [executablePath, "autostart"],
            "RunAtLoad": true,
            "KeepAlive": false,
            "StandardOutPath": "/tmp/\(agentLabel).log",
            "StandardErrorPath": "/tmp/\(agentLabel).error.log"
        ]

        // Create LaunchAgents directory if needed
        try FileManager.default.createDirectory(
            at: launchAgentsPath,
            withIntermediateDirectories: true
        )

        // Write plist
        let data = try PropertyListSerialization.data(
            fromPropertyList: plist,
            format: .xml,
            options: 0
        )
        try data.write(to: agentPlistPath)

        // Load the agent
        runCommand("/bin/launchctl", arguments: ["load", agentPlistPath.path])
    }

    func uninstall() throws {
        if isInstalled {
            runCommand("/bin/launchctl", arguments: ["unload", agentPlistPath.path])
            try FileManager.default.removeItem(at: agentPlistPath)
        }
    }

    func load() {
        guard isInstalled else { return }
        runCommand("/bin/launchctl", arguments: ["load", agentPlistPath.path])
    }

    func unload() {
        guard isInstalled else { return }
        runCommand("/bin/launchctl", arguments: ["unload", agentPlistPath.path])
    }

    private func runCommand(_ command: String, arguments: [String]) {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: command)
        task.arguments = arguments

        do {
            try task.run()
            task.waitUntilExit()
        } catch {
            print("LaunchAgent command failed: \(error)")
        }
    }
}

extension Bundle {
    var executablePath: String? {
        return executableURL?.path
    }
}
