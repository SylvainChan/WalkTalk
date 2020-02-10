//
//  Notification.swift
//  WalkTalk
//
//  Created by Sylvain Chan on 10/2/2020.
//  Copyright © 2020 Sylvain. All rights reserved.
//

import Foundation

// Define the notification we will send in the app
enum WTNotification: String {
    case pushTokenUpdated = "pushTokenUpdated"
    case appWillTerminate = "appWillTerminate"
}
