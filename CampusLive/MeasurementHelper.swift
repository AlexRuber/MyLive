//
//  Copyright (c) 2015 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Firebase

class MeasurementHelper: NSObject {

    static func sendLoginEvent() {
        FIRAnalytics.logEvent(withName: kFIREventLogin, parameters: nil)
    }
    
    static func sendLogoutEvent() {
        FIRAnalytics.logEvent(withName: "logout", parameters: nil)
    }
    
    static func checkInEvent(){
        FIRAnalytics.logEvent(withName: "event_checkins", parameters: nil)
    }
    
    static func liveAnnotationClickEvent(){
        FIRAnalytics.logEvent(withName: "live_annotation_clicks", parameters: nil)
    }
    
    static func trendingSegmentEvent(){
        FIRAnalytics.logEvent(withName: "trending_segment", parameters: nil)
    }
    
    static func liveSegmentEvent(){
        FIRAnalytics.logEvent(withName: "live_segment", parameters: nil)
    }
    
    static func settingsClickEvent(){
        FIRAnalytics.logEvent(withName: "setting_clicks", parameters: nil)
    }
    
    static func infoEventAnnotationEvent(){
        FIRAnalytics.logEvent(withName: "info_event_annotation_clicks", parameters: nil)
    }
}
