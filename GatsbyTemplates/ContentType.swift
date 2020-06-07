//
//  ContentType.swift
//  gblog
//
//  Created by Ivan Sapozhnik on 07.06.20.
//  Copyright © 2020 heavylightapps. All rights reserved.
//

import Foundation
import ArgumentParser

enum ContentType: String, ExpressibleByArgument, CaseIterable {
    case article
    case page

    init(with choice: String) {
        if let contentType = ContentType(rawValue: choice) {
            self = contentType
        } else {
            self = .article
        }
    }
}

extension ContentType {
    var directoryPath: String {
        switch self {
        case .article:
            return "articles"
        case .page:
            return "pages"
        }
    }
}
