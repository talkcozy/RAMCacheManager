import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow?
    var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        setupWindow()

        // Check if RAM disk exists on launch
        let ramDiskService = RAMDiskService.shared
        if ramDiskService.isRAMDiskMounted() {
            NotificationCenter.default.post(name: .ramDiskStatusChanged, object: true)
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    private func setupWindow() {
        let contentView = ContentView()

        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 400),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )

        window?.center()
        window?.setFrameAutosaveName("RAMCacheManagerMainWindow")
        window?.title = "RAMCacheManager"
        window?.contentView = NSHostingView(rootView: contentView)
        window?.makeKeyAndOrderFront(nil)
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "externaldrive.fill.badge.plus", accessibilityDescription: "RAM Cache")
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Show Window", action: #selector(showWindow), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())

        let toggleItem = NSMenuItem(title: "Toggle RAM Disk", action: #selector(toggleRAMDisk), keyEquivalent: "r")
        menu.addItem(toggleItem)

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))

        statusItem?.menu = menu
    }

    @objc func showWindow() {
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func toggleRAMDisk() {
        let service = RAMDiskService.shared
        let config = ConfigManager.shared.loadConfig()

        if service.isRAMDiskMounted() {
            do {
                try service.deleteRAMDisk(volumeName: config.volumeName)
                NotificationCenter.default.post(name: .ramDiskStatusChanged, object: false)
            } catch {
                showAlert(message: "Failed to delete RAM disk: \(error.localizedDescription)")
            }
        } else {
            do {
                try service.createRAMDisk(name: config.volumeName, sizeGB: config.sizeGB)
                CacheLinkService.shared.ensureRAMCacheDirectories()
                NotificationCenter.default.post(name: .ramDiskStatusChanged, object: true)
            } catch {
                showAlert(message: "Failed to create RAM disk: \(error.localizedDescription)")
            }
        }
    }

    @objc func quitApp() {
        NSApp.terminate(nil)
    }

    private func showAlert(message: String) {
        let alert = NSAlert()
        alert.messageText = "RAMCacheManager"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

extension Notification.Name {
    static let ramDiskStatusChanged = Notification.Name("ramDiskStatusChanged")
    static let cacheLinksUpdated = Notification.Name("cacheLinksUpdated")
}
