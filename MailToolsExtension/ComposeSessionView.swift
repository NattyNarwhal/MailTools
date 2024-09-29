//
//  ComposeSessionView.swift
//  MailToolsExtension
//
//  Created by Calvin Buckley on 2024-09-27.
//

import SwiftUI
import MimeParser
import MailKit

#if DEBUG
// BEGIN EVIL-DIVISION.
private struct IdentifiableWrapper<T>: Identifiable {
    let id = UUID()
    let wrapped: T
}

private extension Collection {
    func makeIdentifiable() -> [IdentifiableWrapper<Element>] {
        self.map { IdentifiableWrapper(wrapped: $0) }
    }
}
// END.

struct DebugMimeHeaderView: View {
    let mimeHeader: MimeHeader
    
    var body: some View {
        Text("Content-Type: \(mimeHeader.contentType?.raw ?? "<none>")")
        ForEach(mimeHeader.other.makeIdentifiable()) {
            Text("\($0.wrapped.name): \($0.wrapped.body)")
        }
    }
}

struct DebugMimeBodyView: View {
    let mimeContent: MimeContent
    
    var body: some View {
        switch (mimeContent) {
        case .body(let mimeBody):
            Text(mimeBody.raw)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        case .mixed(let mimes):
            GroupBox(label: Label("Mixed", systemImage: "building.columns")) {
                ForEach(mimes.makeIdentifiable()) {
                    DebugMimeHeaderView(mimeHeader: $0.wrapped.header)
                    DebugMimeBodyView(mimeContent: $0.wrapped.content)
                }
            }
        case .alternative(let mimes):
            GroupBox(label: Label("Alternative", systemImage: "building.columns")) {
                ForEach(mimes.makeIdentifiable()) {
                    DebugMimeHeaderView(mimeHeader: $0.wrapped.header)
                    DebugMimeBodyView(mimeContent: $0.wrapped.content)
                }
            }
        }
    }
}
#endif

struct ComposeSessionView: View {
    var sessionHandler: ComposeSessionHandler!
    
    var body: some View {
        VStack(alignment: .leading) {
#if DEBUG
            if let message = sessionHandler.parser?.mimeMessage {
                DebugMimeHeaderView(mimeHeader: message.header)
                DebugMimeBodyView(mimeContent: message.content)
            } else {
                Text("The mail message couldn't be parsed.")
            }
#endif
        }
        .frame(maxWidth: 1000)
    }
}
