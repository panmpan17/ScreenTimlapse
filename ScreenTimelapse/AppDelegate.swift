//
//  AppDelegate.swift
//  TestScreenTimelapse
//
//  Created by Michael Pan on 6/3/20Wednesday.
//  Copyright © 2020 Michael Pan. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var popover: NSPopover!
    var statusBarItem: NSStatusItem!
    
    var prefWindow: NSWindow?
    
    var timer: Timer?
    var screenShotNumber: Int = 0
    var recordingPause: Bool = false


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let contentView = ContentView(appDelegate: self)
        
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 200, height: 200)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
        self.popover = popover
        
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        
        if let button = self.statusBarItem.button {
            button.image = NSImage(named: "Idle")
            button.action = #selector(togglePopover(_:))
        }
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = self.statusBarItem.button {
            if self.popover.isShown {
                self.popover.performClose(sender)
            }
            else {
                self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                self.popover.contentViewController?.view.window?.becomeKey()
            }
        }
    }
    
    
    
    func startRecording() {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyMMdd-HHmmss"

        let date = Date()
        let dateStr = dateFormat.string(from: date)

        let defaults = UserDefaults.standard
        var exportPath = defaults.string(forKey: "ExportPath")!
        exportPath += "/" + dateStr

        let docURL = URL(fileURLWithPath: exportPath)

        if !FileManager.default.fileExists(atPath: docURL.absoluteString) {
            print("\(docURL.absoluteString) not exist")
            do {
                try FileManager.default.createDirectory(at: docURL.absoluteURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(1, error.localizedDescription);
            }
        }
        
        var interval = defaults.float(forKey: "Interval")

        if (interval < 0.1) {
            interval = 0.1
        }
        let resizeImage = defaults.bool(forKey: "ResizeImage")
        let width = defaults.integer(forKey: "ResizeWidth")
        let height = defaults.integer(forKey: "ResizeHeight")

        statusBarItem.button?.image = NSImage(named: "Recording")
        screenShotNumber = 0
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(interval), repeats: true, block: {t in
//            let folder: String = chooseExportFolder()
            if (!self.recordingPause) {
                guard let img: CGImage = CGDisplayCreateImage(CGMainDisplayID()) else { return }
                let url: URL = URL(fileURLWithPath: "\(exportPath)/\(self.screenShotNumber).jpg")

                if (resizeImage) {
                    if (self.writeCGImage(self.resizeImage(img, maxWidth: Float(width), maxHeight: Float(height))!, url, kUTTypeJPEG)) {
                        self.screenShotNumber += 1;
                    }
                }
                else {
                    if (self.writeCGImage(img, url, kUTTypeJPEG)) {
                        self.screenShotNumber += 1;
                    }
                }
            }
        })
    }

    func endRecording() {
        if (timer != nil) {
            statusBarItem.button?.image = NSImage(named: "Idle")
            timer!.invalidate()
            timer = nil
        }
    }
    
    func pauseRecording() {
        recordingPause = true;
        statusBarItem.button?.image = NSImage(named: "Paused")
    }
    func resumeRecording() {
        recordingPause = false;
        statusBarItem.button?.image = NSImage(named: "Recording")
    }
    
    func openPreference() {
        if ((self.prefWindow?.isVisible) != nil) {
            self.prefWindow?.makeKeyAndOrderFront(nil)
            return
        }

        let prefrenceView = Preference(self)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Prefence")
        window.contentView = NSHostingView(rootView: prefrenceView)
        window.makeKeyAndOrderFront(nil)
        window.isReleasedWhenClosed = false
        
        self.prefWindow = window
    }
    
    func closePreference() {
        if ((self.prefWindow?.isVisible) != nil) {
            self.prefWindow?.performClose(nil)
        }
    }
    
    
    // Image Manipulation
    func resizeImage(_ image: CGImage, maxWidth: Float, maxHeight: Float) -> CGImage? {
        var ratio: Float = 0.0
        let imageWidth = Float(image.width)
        let imageHeight = Float(image.height)
        
        // Get ratio (landscape or portrait)
        if (imageWidth > imageHeight) {
            ratio = maxWidth / imageWidth
        } else {
            ratio = maxHeight / imageHeight
        }
        
        // Calculate new size based on the ratio
        if ratio > 1 {
            ratio = 1
        }
        
        let width = imageWidth * ratio
        let height = imageHeight * ratio
        
        guard let colorSpace = image.colorSpace else { return nil }
        guard let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: image.bitsPerComponent, bytesPerRow: image.bytesPerRow, space: colorSpace, bitmapInfo: image.alphaInfo.rawValue) else { return nil }
        
        // draw image to context (resizing it)
        context.interpolationQuality = .high
        context.draw(image, in: CGRect(x: 0, y: 0, width: Int(width), height: Int(height)))
        
        // extract resulting image from context
        return context.makeImage()
    }
    
    @discardableResult func writeCGImage(_ image: CGImage, _ destinationURL: URL, _ type: CFString) -> Bool {
        guard let destination = CGImageDestinationCreateWithURL(destinationURL as CFURL, type, 1, nil) else { print(1); return false }
        CGImageDestinationAddImage(destination, image, nil)
        return CGImageDestinationFinalize(destination)
    }
    
    
    

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "TestScreenTimelapse")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving and Undo support

    @IBAction func saveAction(_ sender: AnyObject?) {
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        let context = persistentContainer.viewContext

        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
        }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Customize this code block to include application-specific recovery steps.
                let nserror = error as NSError
                NSApplication.shared.presentError(nserror)
            }
        }
    }

    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return persistentContainer.viewContext.undoManager
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        let context = persistentContainer.viewContext
        
        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
            return .terminateCancel
        }
        
        if !context.hasChanges {
            return .terminateNow
        }
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError

            // Customize this code block to include application-specific recovery steps.
            let result = sender.presentError(nserror)
            if (result) {
                return .terminateCancel
            }
            
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == .alertSecondButtonReturn {
                return .terminateCancel
            }
        }
        // If we got here, it is time to quit.
        return .terminateNow
    }

}

