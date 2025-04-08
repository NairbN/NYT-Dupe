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
    var hints: [Int] = [0,0,4,0,6,0]
    @State private var offsetX: CGFloat = 0
    var displayString: String {
        hints.enumerated()
            .compactMap { index, count in
                count > 0 ? "\(index)-Letter Words Left: \(count)" : nil
            }
            .joined(separator: "\n")
    }
    
    var body: some View {
        Text(displayString)
            .font(.system(size: 12))
            .foregroundColor(.black)
            .padding(6)
            .background(Color.yellow)
            .offset(x: offsetX)
            .onAppear {
                
            }
        
    }
        
    
}


struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        let previewContext = PersistenceController.preview.container.viewContext
        TestView().environment(\.managedObjectContext, previewContext)
    }
}
