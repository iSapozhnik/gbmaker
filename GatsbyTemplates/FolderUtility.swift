//
//  FolderUtility.swift
//  gblog
//
//  Created by Ivan Sapozhnik on 07.06.20.
//  Copyright © 2020 heavylightapps. All rights reserved.
//

import Foundation

struct FolderUtility {
    static func makeFolder(for folderName: String, contentType: ContentType, formattedDate: FormattedDate, postPath: String) -> String {
        switch contentType {
        case .article:
            return articleContent(for: folderName, contentType: contentType, formattedDate: formattedDate, postPath: postPath)
        case .page:
            return pageContent(for: folderName, formattedDate: formattedDate, postPath: postPath)
        }
    }

    private static func articleContent(for folderName: String, contentType: ContentType, formattedDate: FormattedDate, postPath: String) -> String {
        return """
---
title: \(folderName)
date: \"\(formattedDate.dateAndTime)\"
layout: post
thumb: "./thumb.png"
draft: false
path: \"/\(contentType.directoryPath)/\(postPath.lowercased())/\"
category: \"Blog\"
tags:
  - \"<your tag>\"
description: \"your description\"
---
"""
    }

    private static func pageContent(for folderName: String, formattedDate: FormattedDate, postPath: String) -> String {
        return """
---
title: \(folderName)
layout: page
path: \"/\(postPath.lowercased())\"
---

# This is your new page
"""
    }
}
