//
//  main.swift
//  GatsbyTemplates
//
//  Created by Ivan Sapozhnik on 07.06.20.
//  Copyright © 2020 heavylightapps. All rights reserved.
//

import Foundation
import Files
import ArgumentParser
import ColorizeSwift
import Cocoa

struct Gbmaker: ParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Gatsby blog template maker", subcommands: [Make.self, Preview.self])
}

extension Gbmaker {
    struct Make: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Make command")

        private static var values: String {
            ContentType.allCases
                .map { "\"\($0.rawValue)\"" }
                .joined(separator: ", ")
        }

        @Option(name: .shortAndLong, help: "The title of the article.")
        var title: String

        @Argument(help: "Content type. Possible values: \(values)")
        var contentType: ContentType

        @Option(name: .shortAndLong, help: "Website path.")
        var path: String

        func validate() throws {
            guard !title.isEmpty else { throw ValidationError("Title should not be an empty string") }
            guard !path.isEmpty else { throw ValidationError("Web site path should not be an empty string") }

        }

        mutating func run() throws {
            let formattedFolderName = title.replacingOccurrences(of: " ", with: "-")
            let formattedDate = DateUtility.makeDateString()
            let folderName = contentType == .article ? formattedFolderName : formattedFolderName.lowercased()

            let blogFolder = try Folder(path: path)
            let pagesFolder = try blogFolder.createSubfolderIfNeeded(at: "/src/pages")
            let contentFolder = try pagesFolder.createSubfolderIfNeeded(at: contentType.directoryPath)
            let name = formattedDate.date + "---" + folderName
            let articleFolder = try contentFolder.createSubfolderIfNeeded(withName: name)

            let fileContent = FolderUtility.makeFolder(for: title, contentType: contentType, formattedDate: formattedDate, postPath: formattedFolderName)

            let image = NSImage.init(color: .red, size: NSSize(width: 256, height: 256))
            let thumbFile = try articleFolder.createFile(named: "thumb.png")
            try thumbFile.write(image.png!)

            let file = try articleFolder.createFile(named: "index.md")
            try file.write(fileContent, encoding: .utf8)

            let output = """

           _                     _
          | |                   | |
      __ _| |__  _ __ ___   __ _| | _____ _ __
     / _` | '_ \\| '_ ` _ \\ / _` | |/ / _ \\ '__|
    | (_| | |_) | | | | | | (_| |   <  __/ |
     \\__, |_.__/|_| |_| |_|\\__,_|_|\\_\\___|_|
      __/ |
     |___/

    """
            print(output.foregroundColor(.orange1))
            print("✅ The new \(contentType.rawValue) has been created at:\n".foregroundColor(.orange1))
            print("\(file.path)\n\n".foregroundColor(.white))

        }
    }
}

extension Gbmaker {
    struct Preview: ParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Preview command")

        @Option(name: .shortAndLong, help: "The title of the article.")
        var title: String

        mutating func run() throws {
            let view = TwitterView(title: title)

            let documentsFolder = Folder.documents
            let preview = try documentsFolder?.createFile(named: "preview.png")
            try preview?.write(view.data())

            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.writeObjects([view.image()])
        }
    }
}

Gbmaker.main()

class TwitterView: View {
    private let title: String

    init(title: String) {
        self.title = title
        super.init(frame: .twitterRect)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        wantsLayer = true
        backgroundColor = NSColor(calibratedRed: 0.949, green: 0.427, blue: 0.314, alpha: 1.0)

        let previewCaption = NSTextField(labelWithString: "Xcode Tips&Tricks")
        previewCaption.font = NSFont.monospacedSystemFont(ofSize: 68, weight: .light)
        previewCaption.translatesAutoresizingMaskIntoConstraints = false
        addSubview(previewCaption)

        let titleCaption = NSTextField(labelWithString: title)
        titleCaption.maximumNumberOfLines = 0
        titleCaption.lineBreakMode = .byWordWrapping
        titleCaption.font = NSFont.systemFont(ofSize: 138, weight: .bold)
        titleCaption.translatesAutoresizingMaskIntoConstraints = false
//        titleCaption.textColor = NSColor(calibratedRed: 0.949, green: 0.427, blue: 0.314, alpha: 1.0)
        addSubview(titleCaption)

        NSLayoutConstraint.activate([
            previewCaption.topAnchor.constraint(equalTo: topAnchor, constant: 32),
            previewCaption.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            titleCaption.topAnchor.constraint(equalTo: previewCaption.bottomAnchor, constant: 32),
            titleCaption.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            titleCaption.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)

        ])
    }
}

class View: NSView {
    override var isFlipped: Bool { true }
    var backgroundColor: NSColor {
        didSet {
            layer?.backgroundColor = backgroundColor.cgColor
        }
    }

    override init(frame frameRect: NSRect) {
        backgroundColor = .red
        super.init(frame: frameRect)
        layer?.backgroundColor = backgroundColor.cgColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NSRect {
    static var twitterRect: NSRect {
        return NSRect(x: 0, y: 0, width: 1280, height: 672)
    }
}

extension NSBitmapImageRep {
    var png: Data? { representation(using: .png, properties: [:]) }
}
extension Data {
    var bitmap: NSBitmapImageRep? { NSBitmapImageRep(data: self) }
}

extension NSImage {
    convenience init(color: NSColor, size: NSSize) {
        self.init(size: size)
        lockFocus()
        color.drawSwatch(in: NSRect(origin: .zero, size: size))
        unlockFocus()
    }

    var png: Data? {
        return tiffRepresentation?.bitmap?.png
    }
}

extension NSView {

    /// Get `NSImage` representation of the view.
    ///
    /// - Returns: `NSImage` of view

    func image() -> NSImage {
        let imageRepresentation = bitmapImageRepForCachingDisplay(in: bounds)!
        cacheDisplay(in: bounds, to: imageRepresentation)
        return NSImage(cgImage: imageRepresentation.cgImage!, size: bounds.size)
    }

    /// Get `Data` representation of the view.
    ///
    /// - Parameters:
    ///   - fileType: The format of file. Defaults to PNG.
    ///   - properties: A dictionary that contains key-value pairs specifying image properties.
    /// - Returns: `Data` for image.

    func data(using fileType: NSBitmapImageRep.FileType = .png, properties: [NSBitmapImageRep.PropertyKey : Any] = [:]) -> Data {
        let imageRepresentation = bitmapImageRepForCachingDisplay(in: bounds)!
        cacheDisplay(in: bounds, to: imageRepresentation)
        return imageRepresentation.representation(using: fileType, properties: properties)!
    }

}
