//
//  Optional+FlatMap.swift
//  Gallery
//
//  Created by Andrew Vyazovoy on 30.11.14.
//  Copyright (c) 2014 My Corp. All rights reserved.
//

import Foundation

extension Optional {
    func flatMap<U>(f: T -> U?) -> U? {
        switch self {
        case .Some(let value):
            return f(value)
            
        case .None:
            return .None
        }
    }
}
