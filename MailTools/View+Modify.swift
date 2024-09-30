//
//  View+Modify.swift
//  MailTools
//
//  Created by Calvin Buckley on 2024-09-29.
//

import SwiftUI

// https://blog.overdesigned.net/posts/2020-09-23-swiftui-availability/
extension View {
    func modify<T: View>(@ViewBuilder _ modifier: (Self) -> T) -> some View {
        return modifier(self)
    }
}
