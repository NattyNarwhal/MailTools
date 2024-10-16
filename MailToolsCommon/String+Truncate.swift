//
//  String+Truncate.swift
//  MailTools
//
//  Created by Calvin Buckley on 2024-10-02.
//
//  Copyright (c) 2024 Calvin Buckley
//  SPDX-License-Identifier: MPL-2.0
//

import Foundation

extension String {
    public func truncate(to newLength: Int, ellipsis: String = "...") -> String {
        if self.count <= newLength {
            return self
        }
        return "\(self.prefix(newLength))\(ellipsis)"
    }
}
