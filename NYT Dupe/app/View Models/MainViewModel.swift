//
//  MainViewModel.swift
//  NYT Dupe
//
//  Created by Brian Nguyen on 3/25/25.
//

import Foundation
import CoreData

class MainViewModel: ObservableObject{
    private let viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }

    
}
