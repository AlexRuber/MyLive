//
//  EventBasicProperties.swift
//  CampusLive
//
//  Created by Maxx on 4/8/17.
//  Copyright © 2017 Mihai Ruber. All rights reserved.
//

import Foundation

class Event {
    var title = ""
    var subtitle = ""
    var startDate = ""
    var endDate = ""
    var imageUrl = ""
    var description = ""
    var coordinates = ""
    
    init(title: String, startDate: String)
    {
        self.title = title
        self.startDate = startDate
    }
}
