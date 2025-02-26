//
//  WidgetDetail.swift
//  Widget Quotes
//
//  Created by Oren Lindsey on 2/24/25.
//

import SwiftUI
import CoreData

struct WidgetDetail: View {
    var widget: Widget
    @State var editorMode = false
    var body: some View {
        NavigationStack {
            Form {
                Text(widget.content ?? "")
            }.navigationTitle("Widget")
        }
    }
}
