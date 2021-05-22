import Cocoa
import SwiftUI
import CoreAudio
import soundadditions

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    
    var statusBarItem: NSStatusItem!
    var statusBarMenu: NSMenu!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))

        self.statusBarMenu = NSMenu(title: "AudioBar")
        if let menu = self.statusBarMenu {
            menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
            
            menu.delegate = self
        }

        if let button = self.statusBarItem.button {
             //button.image = NSImage(named: "Icon")
            button.action = #selector(onClick)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.updateBar()
        }

    }
    
    @objc func onClick(sender: NSStatusItem) {
        let event = NSApp.currentEvent!
        
        if event.type == NSEvent.EventType.rightMouseUp {
            statusBarItem.menu = statusBarMenu
            statusBarMenu.popUp(positioning: nil,
                                at: NSPoint(x: 0, y: statusBarItem.statusBar!.thickness),
                                in: statusBarItem.button)
            
        } else {
            updateBar()
        }
    }
    
    @objc func menuDidClose(_ menu: NSMenu) {
        statusBarItem.menu = nil
    }
    
    func s(_ s: String) -> NSAttributedString {
        return NSAttributedString(string: s)
    }
    
    func clr(s: String, c: NSColor) -> NSAttributedString {
        return NSAttributedString(string: s, attributes: [
            NSAttributedString.Key.foregroundColor: c
        ])
    }

    func append(_ strs: NSAttributedString...) -> NSMutableAttributedString {
        let fmt = NSMutableAttributedString()

        for s in strs {
            fmt.append(s)
        }

        return fmt
    }
    
    func clean(_ name: String) -> String {
        if name.hasPrefix("Built-in") {
            return "Built-in"
        }
        if name.hasSuffix("AirPods") {
            return "AirPods"
        }
        return name
    }
    
    func isHeadphone(_ name: String) -> Bool {
        let n = name.lowercased()
        return n.contains("airpods") || n.contains("mdr-") || n.contains("headphone")
    }
    
    
    let speakerIcon = "🔊";
    let mutedIcon = "🔇";
    let headphoneIcon = "🎧";
    let micIcon = "🎙️";
    
    func icon(_ dev: AudioDevice) -> String {
        if dev.isInput && !dev.isOutput {
            return micIcon
        }
        if NSSound.systemVolume() == 0 || NSSound.isMuted() {
            return mutedIcon
        }
        if isHeadphone(dev.name) {
            return headphoneIcon
        }
        return speakerIcon
    }

    func buildString() -> NSAttributedString {
        
        var defInput:AudioDevice
        var defOutput:AudioDevice
        do {
            defInput = try AudioDevice.getDefaultDevice(for: .input)
            defOutput = try AudioDevice.getDefaultDevice(for: .output)
        } catch {
            return s("error")
        }
        
        let inpName = clean(defInput.name)
        let outName = clean(defOutput.name)
        
        if inpName == outName {
            return s(icon(defOutput)+outName)
        }
        
        return append(
            s(icon(defOutput)+outName),
            s(" "),
            s(icon(defInput)+inpName)
        )
    }
    
    // Updates the status bar
    @objc func updateBar() {
        let s = self.buildString()
        print(s)
        if let button = self.statusBarItem.button {
            DispatchQueue.main.async {
                button.attributedTitle = s
            }
        }
    }
}


let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
