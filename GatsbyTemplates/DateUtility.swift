//
//  DateUtility.swift
//  gblog
//
//  Created by Ivan Sapozhnik on 07.06.20.
//  Copyright © 2020 heavylightapps. All rights reserved.
//

import Foundation

struct FormattedDate {
    let date: String
    let dateAndTime: String
}

struct DateUtility {
    static func makeDateString() -> FormattedDate {
        let currentDate = Date()

        let format = DateFormatter()

        format.dateFormat = "yyyy-MM-dd"
        let formattedDate = format.string(from: currentDate)

        format.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let formattedDateAndTime = format.string(from: currentDate)

        return FormattedDate(date: formattedDate, dateAndTime: formattedDateAndTime)
    }
}
