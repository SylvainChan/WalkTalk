//
//  UIColorExtension.swift
//  WalkTalk
//
//  Created by Sylvain Chan on 10/2/2020.
//  Copyright © 2020 Sylvain. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    // generate random color
    static var random: UIColor {
         let red:CGFloat = CGFloat(drand48())
         let green:CGFloat = CGFloat(drand48())
         let blue:CGFloat = CGFloat(drand48())
         return UIColor(red:red, green: green, blue: blue, alpha: 1.0)
    }
}
