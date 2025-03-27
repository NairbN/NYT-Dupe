//
//  MainView.swift
//  NYT Dupe
//
//  Created by Brian Nguyen on 3/25/25.
//

import Foundation
import SwiftUI
import CoreData

struct MainView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: MainViewModel

    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: MainViewModel(context: context))
    }

    var body: some View {
        SpellingBeeView(viewModel: SpellingBeeViewModel(context: viewContext))
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        let previewContext = PersistenceController.preview.container.viewContext
        MainView(context: previewContext).environment(\.managedObjectContext, previewContext)
    }
}
