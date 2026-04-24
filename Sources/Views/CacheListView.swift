import SwiftUI

struct CacheListView: View {
    @ObservedObject var cacheLinkVM: CacheLinkViewModel
    @ObservedObject var ramDiskVM: RAMDiskViewModel

    var body: some View {
        VStack(spacing: 16) {
            if !ramDiskVM.status.isMounted {
                // Warning Banner
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("RAM disk is not mounted. Mount it first to link caches.")
                        .font(.subheadline)
                    Spacer()
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }

            List {
                ForEach(cacheLinkVM.entries) { entry in
                    CacheEntryRow(
                        entry: entry,
                        isRAMDiskMounted: ramDiskVM.status.isMounted
                    ) { updatedEntry in
                        cacheLinkVM.toggleEntry(updatedEntry)
                    }
                }
            }
            .listStyle(.inset(alternatesRowBackgrounds: true))

            HStack {
                Text("\(cacheLinkVM.linkedCount) of \(cacheLinkVM.entries.count) caches enabled")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Button("Refresh") {
                    cacheLinkVM.loadEntries()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
}

struct CacheEntryRow: View {
    let entry: CacheEntry
    let isRAMDiskMounted: Bool
    let onToggle: (CacheEntry) -> Void

    @State private var isActuallyLinked: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: entry.icon)
                .foregroundColor(.secondary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.displayName)
                    .fontWeight(.medium)

                Text(entry.sourcePath)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            if isActuallyLinked {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Linked")
                        .font(.caption)
                        .foregroundColor(.green)
                    Text(entry.targetSubPath)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else if entry.isEnabled {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Pending")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Text("RAM disk offline")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Toggle("", isOn: Binding(
                get: { entry.isEnabled },
                set: { _ in onToggle(entry) }
            ))
            .toggleStyle(.switch)
            .disabled(!isRAMDiskMounted)
        }
        .padding(.vertical, 4)
        .onAppear {
            checkLinkStatus()
        }
    }

    private func checkLinkStatus() {
        isActuallyLinked = CacheLinkService.shared.isSourceLinkedToRAMCache(for: entry)
    }
}
