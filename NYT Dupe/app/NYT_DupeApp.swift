//
//  NYT_DupeApp.swift
//  NYT Dupe
//
//  Created by Brian Nguyen on 3/24/25.
//

import SwiftUI

@main
struct NYT_DupeApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainView(context: persistenceController.container.viewContext)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
