//
//  UIStoryboardExtension.swift
//  HSBC_CMB
//
//  Created by Sylvain on 21/3/2018.
//  Copyright © 2018 Green Tomato. All rights reserved.
//

import UIKit

extension UIStoryboard {
    
    func instantiateViewController<T: UIViewController>(ofType _: T.Type, withIdentifier identifier: String? = nil) -> T {
        let identifier = identifier ?? String(describing: T.self)
        return instantiateViewController(withIdentifier: identifier) as! T
    }

}
