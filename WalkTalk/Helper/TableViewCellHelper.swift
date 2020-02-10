//
//  TableViewCellHelper.swift
//  WalkTalk
//
//  Created by Sylvain Chan on 9/2/2020.
//  Copyright © 2020 Sylvain. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Main purpose is to help configuration cell initialization in a faster and centralized way
protocol TableViewCellConfiguration: RawRepresentable where Self.RawValue == String {}

protocol CollectionViewCellConfiguration: TableViewCellConfiguration {}

extension TableViewCellConfiguration {
    var nib: UINib? {
        return UINib(nibName: self.rawValue, bundle: nil)
    }
    
    var reuseId: String {
        return self.rawValue
    }
}
