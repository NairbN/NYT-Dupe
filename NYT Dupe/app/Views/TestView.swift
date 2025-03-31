//
//  TestView.swift
//  NYT Dupe
//
//  Created by Brian Nguyen on 3/25/25.
//

import Foundation
import SwiftUI
import CoreData

struct TestView: View {

    @Environment(\.managedObjectContext) private var viewContext
    let wordsFormed: Set<String> = [
        "rugby",
        "burry",
        "rubbly",
        "burl",
        "grum",
        "grumbly",
        "rumbly",
        "bulgur",
        "grub",
        "murr",
        "burr",
        "brrr"
    ]
    
    private var WordListView: some View {
        GeometryReader { geometry in
            let columns = [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ]
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(Array(wordsFormed), id: \.self) { word in
                        Text(word.uppercased())
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding()
                .frame(width: geometry.size.width, alignment: .center)
            }
        }
    }

    var body: some View {
         WordListView
    }
}


struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        let previewContext = PersistenceController.preview.container.viewContext
        TestView().environment(\.managedObjectContext, previewContext)
    }
}
