import Foundation
import Combine

@MainActor
class RAMDiskViewModel: ObservableObject {
    @Published var status: RAMDiskStatus = .empty
    @Published var config: RAMDiskConfig
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let ramDiskService = RAMDiskService.shared
    private let launchAgentService = LaunchAgentService.shared

    init() {
        self.config = ConfigManager.shared.loadConfig()
        refreshStatus()

        NotificationCenter.default.addObserver(
            forName: .ramDiskStatusChanged,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.refreshStatus()
            }
        }
    }

    func refreshStatus() {
        status = ramDiskService.getStatus(volumeName: config.volumeName)
    }

    func createRAMDisk() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                try ramDiskService.createRAMDisk(name: config.volumeName, sizeGB: config.sizeGB)
                CacheLinkService.shared.ensureRAMCacheDirectories()
                refreshStatus()
                if config.autoStart {
                    try? launchAgentService.install(config: config)
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    func deleteRAMDisk() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                try ramDiskService.deleteRAMDisk(volumeName: config.volumeName)
                refreshStatus()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    func saveConfig() {
        ConfigManager.shared.saveConfig(config)
    }

    func toggleAutoStart(_ enabled: Bool) {
        config.autoStart = enabled
        saveConfig()

        if enabled {
            try? launchAgentService.install(config: config)
        } else {
            try? launchAgentService.uninstall()
        }
    }

    var formattedTotalSpace: String {
        ByteCountFormatter.string(fromByteCount: status.totalSpace, countStyle: .file)
    }

    var formattedUsedSpace: String {
        ByteCountFormatter.string(fromByteCount: status.usedSpace, countStyle: .file)
    }

    var formattedFreeSpace: String {
        ByteCountFormatter.string(fromByteCount: status.freeSpace, countStyle: .file)
    }
}

@MainActor
class CacheLinkViewModel: ObservableObject {
    @Published var entries: [CacheEntry] = []
    @Published var isLoading: Bool = false

    private let cacheLinkService = CacheLinkService.shared

    init() {
        loadEntries()

        NotificationCenter.default.addObserver(
            forName: .cacheLinksUpdated,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.loadEntries()
            }
        }
    }

    func loadEntries() {
        // 从配置加载用户设置的 enabled 状态
        let savedEntries = ConfigManager.shared.loadCacheEntries()

        entries = savedEntries
    }

    func toggleEntry(_ entry: CacheEntry) {
        isLoading = true

        Task {
            // 找到对应的 entry 并更新状态
            if let index = entries.firstIndex(where: { $0.id == entry.id }) {
                entries[index].isEnabled.toggle()
                saveEntries()

                // 根据新的 enabled 状态链接或取消链接
                if entries[index].isEnabled {
                    try? cacheLinkService.linkCache(entry: entries[index])
                } else {
                    try? cacheLinkService.unlinkCache(entry: entries[index])
                }
            }
            isLoading = false
        }
    }

    func saveEntries() {
        ConfigManager.shared.saveCacheEntries(entries)
    }

    var linkedCount: Int {
        entries.filter { $0.isEnabled }.count
    }
}
