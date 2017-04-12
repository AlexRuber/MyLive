//
//  EventBasicProperties.swift
//  CampusLive
//
//  Created by Maxx on 4/8/17.
//  Copyright © 2017 Mihai Ruber. All rights reserved.
//

import Foundation
import CoreLocation

class Event {
    var title: String?
    var subtitle: String?
    var startDate: String?
    var endDate: String?
    var imageUrl: String?
    var eventId: String?
    var unformattedStartDate: String?
    var unformattedEndDate: String?

    var coordinate: CLLocationCoordinate2D
    
    init(lat: CLLocationDegrees, long: CLLocationDegrees, title: String? = nil, subtitle: String? = nil, imageUrl: String!, eventId: String!, endDate: String? = nil, startDate: String? = nil, unformattedStartDate: String? = nil, unformattedEndDate: String? = nil)
    {
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        self.title = title
        self.subtitle = subtitle
        self.imageUrl = imageUrl
        self.eventId = eventId
        self.endDate = endDate
        self.startDate = startDate
        self.unformattedEndDate = unformattedEndDate
        self.unformattedStartDate = unformattedStartDate
    }
}
