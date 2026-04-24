import SwiftUI

struct StatusPanel: View {
    @ObservedObject var ramDiskVM: RAMDiskViewModel

    var body: some View {
        VStack(spacing: 24) {
            // RAM Disk Status Card
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: ramDiskVM.status.isMounted ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(ramDiskVM.status.isMounted ? .green : .red)
                        .font(.title)

                    Text(ramDiskVM.status.isMounted ? "RAM Disk Active" : "RAM Disk Inactive")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Spacer()
                }

                if ramDiskVM.status.isMounted {
                    // Progress Bar
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Storage")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(ramDiskVM.status.formattedUsedSpace) / \(ramDiskVM.status.formattedTotalSpace)")
                                .fontWeight(.medium)
                        }

                        ProgressView(value: Double(ramDiskVM.status.usedSpace), total: Double(ramDiskVM.status.totalSpace))
                            .progressViewStyle(.linear)
                            .tint(ramDiskVM.status.usedPercentage > 80 ? .red : .blue)

                        HStack {
                            Text("\(String(format: "%.1f", ramDiskVM.status.usedPercentage))% used")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(ramDiskVM.status.formattedFreeSpace) free")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    // Stats
                    HStack(spacing: 24) {
                        StatItem(title: "Linked Caches", value: "\(ramDiskVM.status.linkedCount)", icon: "link")
                        StatItem(title: "Volume", value: ramDiskVM.config.volumeName, icon: "externaldrive.fill")
                        StatItem(title: "Size", value: "\(String(format: "%.1f", ramDiskVM.config.sizeGB)) GB", icon: "memorychip")
                    }
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)

            // Action Buttons
            HStack(spacing: 16) {
                Button(action: {
                    if ramDiskVM.status.isMounted {
                        ramDiskVM.deleteRAMDisk()
                    } else {
                        ramDiskVM.createRAMDisk()
                    }
                }) {
                    HStack {
                        if ramDiskVM.isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: ramDiskVM.status.isMounted ? "eject.fill" : "plus.circle.fill")
                        }
                        Text(ramDiskVM.status.isMounted ? "Unmount RAM Disk" : "Create RAM Disk")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(ramDiskVM.isLoading)

                Button(action: {
                    ramDiskVM.refreshStatus()
                    ramDiskVM.isLoading = false
                }) {
                    Image(systemName: "arrow.clockwise")
                        .frame(width: 40)
                }
                .buttonStyle(.bordered)
            }

            if let error = ramDiskVM.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Spacer()

            // Info
            Text("RAM disk contents are stored in memory and will be cleared on restart.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
