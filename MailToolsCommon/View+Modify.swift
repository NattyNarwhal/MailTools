//
//  View+Modify.swift
//  MailTools
//
//  Created by Calvin Buckley on 2024-09-29.
//

// Note that this is *not* part of the MailToolsCommon target,
// because evil SwiftUI linker errors afoot.
// It's used in both app and appex though
import SwiftUI

// https://blog.overdesigned.net/posts/2020-09-23-swiftui-availability/
extension View {
    func modify<T: View>(@ViewBuilder _ modifier: (Self) -> T) -> some View {
        return modifier(self)
    }
}
