import SwiftUI

struct SettingsView: View {
    @ObservedObject var ramDiskVM: RAMDiskViewModel
    @State private var sizeGB: Double = 4.0
    @State private var volumeName: String = "RAMCache"
    @State private var autoStart: Bool = false

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Volume Name")
                        Spacer()
                        TextField("RAMCache", text: $volumeName)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 150)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Size")
                            Spacer()
                            Text("\(String(format: "%.1f", sizeGB)) GB")
                                .fontWeight(.medium)
                        }

                        Slider(value: $sizeGB, in: 1...16, step: 0.5)
                            .disabled(ramDiskVM.status.isMounted)

                        HStack {
                            Text("1 GB")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("16 GB")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    if ramDiskVM.status.isMounted {
                        Text("Unmount RAM disk to change size")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            } header: {
                Text("RAM Disk Configuration")
            }

            Section {
                Toggle("Launch at Login", isOn: $autoStart)

                Text("When enabled, RAM disk will be automatically created when you log in.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } header: {
                Text("Startup")
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                        Text("About RAM Disk")
                            .fontWeight(.medium)
                    }

                    Text("A RAM disk stores data in your computer's memory (RAM) instead of your hard drive. This makes cache operations extremely fast, but data is lost when you restart your Mac.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .formStyle(.grouped)
        .onAppear {
            sizeGB = ramDiskVM.config.sizeGB
            volumeName = ramDiskVM.config.volumeName
            autoStart = ramDiskVM.config.autoStart
        }
        .onChange(of: sizeGB) { _, newValue in
            ramDiskVM.config.sizeGB = newValue
            ramDiskVM.saveConfig()
        }
        .onChange(of: volumeName) { _, newValue in
            ramDiskVM.config.volumeName = newValue
            ramDiskVM.saveConfig()
        }
        .onChange(of: autoStart) { _, newValue in
            ramDiskVM.toggleAutoStart(newValue)
        }
        .padding()
    }
}
