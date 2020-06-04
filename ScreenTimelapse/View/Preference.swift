//
//  Preference.swift
//  TestScreenTimelapse
//
//  Created by Michael Pan on 6/4/20Thursday.
//  Copyright © 2020 Michael Pan. All rights reserved.
//

import SwiftUI

struct Preference: View {
    var appDelegate: AppDelegate?

    @State private var exportPath: String
//    @State private var interval: String
    @State private var intervalI: Float


    @State private var resizeImg: Bool
    @State private var resizeWidth: String
    @State private var resizeHeight: String
    
    init(_ _appDelegate: AppDelegate) {
        self.appDelegate = _appDelegate
        
        let defaults = UserDefaults.standard
        _exportPath = State(initialValue: defaults.string(forKey: "ExportPath") ?? "")
        
        let interval = defaults.float(forKey: "Interval")
//        _interval = State(initialValue: String(interval))
        
        _intervalI = State(initialValue: interval)

        _resizeImg = State(initialValue: defaults.bool(forKey: "ResizeImage") )

        let width = defaults.integer(forKey: "ResizeWidth")
        _resizeWidth = State(initialValue: String(width))
        
        let height = defaults.integer(forKey: "ResizeHeight")
        _resizeHeight = State(initialValue: String(height))
    }
    
    init (_ nonValue: Bool) {
        self.appDelegate = nil

        _exportPath = State(initialValue: "/Users/michael/Movies/Timelapse")
//        _interval = State(initialValue: "5")
        _intervalI = State(initialValue: 5.0)
        _resizeImg = State(initialValue: true)
        _resizeWidth = State(initialValue: "1024")
        _resizeHeight = State(initialValue: "728")
    }
    
    var intervalInt: Binding<String> {
        Binding<String>(
            get: {
                String(self.intervalI)
            },
            set: {
//                var value: String = $0 as String
                self.intervalI = ($0 as NSString).floatValue
            }
        )
    }

    var body: some View {
        VStack (spacing: 10) {
            VStack (spacing: 0) {
                Text("Export Path")
                HStack () {
                    TextField("", text: $exportPath).disabled(true)
                    Button (action: self.chooseExportFolder) {
                        Text("Choose")
                    }
                }
            }
            
            VStack (spacing: 0) {
                Text("Screenshot Interval")
                HStack () {
                    TextField("Enter Interval", text: intervalInt).multilineTextAlignment(.trailing).frame(idealWidth: 100, maxWidth: 100)
                    Text("seconds")
                }
            }
            
            VStack (spacing: 0) {
                Toggle(isOn: $resizeImg) {
                    Text("Resize image")
                }
                
                HStack () {
                    Text("Max Width")
                    TextField("Pixel", text: $resizeWidth).multilineTextAlignment(.trailing).frame(idealWidth: 100, maxWidth: 100)

                    Text("Max Width")
                    TextField("Pixel", text: $resizeHeight).multilineTextAlignment(.trailing).frame(idealWidth: 100, maxWidth: 100)
                }.disabled(!resizeImg)
            }
            Spacer()
                HStack () {
                    Button (action: self.closeWindow) {
                        Text("Cancel")
                    }
                    Button (action: self.saveChanges) {
                        Text("Save").frame(idealWidth: 120, maxWidth: 120)
                    }
                }.frame(idealWidth: 300, maxWidth: 300)
        }.padding(10).frame(idealWidth: 400, maxWidth: 400, idealHeight: 200, maxHeight: 200)
    }
    
    func chooseExportFolder() {
        let openPanel = NSOpenPanel();
        openPanel.title = "Select Export Folder"
        openPanel.message = ""
        openPanel.showsResizeIndicator = true
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.allowsMultipleSelection = false
        openPanel.canCreateDirectories = true
//        openPanel.delegate = self;
        
        if (openPanel.runModal() == NSApplication.ModalResponse.OK) {
            let result = openPanel.url

            if (result != nil) {
                self.exportPath = result!.path
            }
        }
    }
    
    func closeWindow() {
        appDelegate?.closePreference();
    }
    
    func saveChanges() {
        let defaults = UserDefaults.standard
        let interval: Float = intervalI

        guard let width: Int = (resizeWidth as NSString).integerValue else {
            return
        }
        guard let height: Int = (resizeHeight as NSString).integerValue else {
            return
        }

        defaults.set(exportPath, forKey: "ExportPath")
        defaults.set(resizeImg, forKey: "ResizeImage")
        
        defaults.set(interval, forKey: "Interval")
        defaults.set(width, forKey: "ResizeWidth")
        defaults.set(height, forKey: "ResizeHeight")

        closeWindow()
    }
}

struct Preference_Previews: PreviewProvider {
    static var previews: some View {
        Preference(true)
    }
}
