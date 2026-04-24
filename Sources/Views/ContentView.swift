import SwiftUI

struct ContentView: View {
    @StateObject private var ramDiskVM = RAMDiskViewModel()
    @StateObject private var cacheLinkVM = CacheLinkViewModel()

    var body: some View {
        TabView {
            StatusPanel(ramDiskVM: ramDiskVM)
                .tabItem {
                    Label("Status", systemImage: "gauge.with.dots.needle.bottom.50percent")
                }

            SettingsView(ramDiskVM: ramDiskVM)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }

            CacheListView(cacheLinkVM: cacheLinkVM, ramDiskVM: ramDiskVM)
                .tabItem {
                    Label("Caches", systemImage: "folder.fill.badge.gearshape")
                }
        }
        .frame(minWidth: 500, minHeight: 400)
        .onAppear {
            ramDiskVM.refreshStatus()
            cacheLinkVM.loadEntries()
        }
    }
}

extension RAMDiskStatus {
    var formattedTotalSpace: String {
        ByteCountFormatter.string(fromByteCount: totalSpace, countStyle: .file)
    }

    var formattedUsedSpace: String {
        ByteCountFormatter.string(fromByteCount: usedSpace, countStyle: .file)
    }

    var formattedFreeSpace: String {
        ByteCountFormatter.string(fromByteCount: freeSpace, countStyle: .file)
    }
}
