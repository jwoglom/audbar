//
//  settings.swift
//  
//
//  Created by James Woglom on 5/22/21.
//

import Cocoa
import SwiftUI

class Settings: NSObject, NSApplicationDelegate, NSMenuDelegate {
    
    var settingsMenu: NSMenu!
    var parent: AppDelegate! = nil
    
    enum PreferenceField : String, CaseIterable {
        case showCombinedIcon
        case showOutputIcon
    }
    
    let prefTitles : [PreferenceField:String] = [
        .showCombinedIcon: "Show Combined Icon",
        .showOutputIcon: "Show Output Icon"
    ]
    
    func createMenu() -> NSMenu {
        settingsMenu = NSMenu(title: "Settings")
        addItem(withTitle: prefTitles[.showCombinedIcon]!, action: #selector(settingsShowCombinedIcon))
        addItem(withTitle: prefTitles[.showOutputIcon]!, action: #selector(settingsShowOutputIcon))
        updateCheckboxSettings()
        
        return settingsMenu
    }
    
    func addItem(withTitle: String, action: Selector?) {
        let i = settingsMenu.addItem(withTitle: withTitle, action: action, keyEquivalent: "")
        i.target = self
    }
    
    func updateBar() {
        parent.updateBar()
    }
    
    func getPref(key: PreferenceField) -> String? {
        let defaults = UserDefaults.standard

        return defaults.object(forKey: key.rawValue) as? String
    }
    
    func setPref(key: PreferenceField, val: String) {
        let defaults = UserDefaults.standard
        defaults.set(val, forKey: key.rawValue)
    }
    
    
    @objc func settingsShowCombinedIcon() {
        changeCheckboxSetting(pref: .showCombinedIcon)
    }
    
    @objc func settingsShowOutputIcon() {
        changeCheckboxSetting(pref: .showOutputIcon)
    }
    
    func changeCheckboxSetting(pref: PreferenceField) {
        if getCheckboxSetting(pref: pref) {
            setPref(key: pref, val: "false")
        } else {
            setPref(key: pref, val: "true")
        }
        updateCheckboxSettings()
        updateBar()
    }
    
    func updateCheckboxSettings() {
        for pref in PreferenceField.allCases {
            updateCheckboxSetting(menu: settingsMenu, pref: pref)
        }
    }
    
    func updateCheckboxSetting(menu: NSMenu, pref: PreferenceField) {
        var val = NSControl.StateValue.off
        if getCheckboxSetting(pref: pref) {
            val = NSControl.StateValue.on
        }
        menu.item(withTitle: prefTitles[pref]!)?.state = val
    }
    
    func getCheckboxSetting(pref: PreferenceField) -> Bool {
        return getPref(key: pref) ?? "false" == "true"
    }
}
