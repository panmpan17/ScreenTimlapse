//
//  ContentView.swift
//  TestScreenTimelapse
//
//  Created by Michael Pan on 6/3/20Wednesday.
//  Copyright © 2020 Michael Pan. All rights reserved.
//

import SwiftUI
//import AppKit

struct ContentView: View {
    var appDelegate: AppDelegate;
    @State private var isRecording = false
    @State private var isPausing = false
    
    var body: some View {
        VStack (spacing: 5) {
            VStack (spacing: 5) {
                Button (action: {
                    self.isRecording = true
                    self.appDelegate.startRecording()
                }) {
                    Text("Start Recording")
                }.disabled(isRecording)
                
                if (!isPausing) {
                    Button (action: {
                        self.isPausing = true
                        self.appDelegate.pauseRecording()
                    }) {
                        Text("Pause Recording").disabled(!isRecording)
                    }
                }
                else {
                    Button (action: {
                        self.isPausing = false
                        self.appDelegate.resumeRecording()
                    }) {
                        Text("Resume Recording").disabled(!isRecording)
                    }
                }
                
                Button (action: {
                    self.isRecording = false;
                    self.appDelegate.endRecording()
                }) {
                    Text("End Recording")
                }.disabled(!isRecording)
                Button (action: self.appDelegate.openPreference) {
                    Text("Preference")
                }
                
                Button (action: {
                    NSApplication.shared.terminate(self)
                }) {
                    Text("Quit")
                }
            }.padding().frame(idealWidth: 150, maxWidth: 150, idealHeight: 170, maxHeight: 170)
        }
    }
}
