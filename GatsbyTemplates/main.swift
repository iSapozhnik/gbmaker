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
    static let configuration = CommandConfiguration(abstract: "Gatsby blog template maker", subcommands: [Make.self])
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

Gbmaker.main()

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
