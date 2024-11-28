//
//  Widget_QuotesApp.swift
//  Widget Quotes
//
//  Created by Oren Lindsey on 9/1/24.
//

import SwiftUI

@main
struct Widget_QuotesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environment(\.managedObjectContext, SharedCoreDataManager.shared.viewContext)
        }
    }
}
