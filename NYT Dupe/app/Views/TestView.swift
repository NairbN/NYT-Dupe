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
    
    var ranks: [(threshold: Double, rank: String)]{
        [
            (100, "Queen Bee"), (70, "Genius"), (50, "Amazing"),
            (40, "Great"), (25, "Nice"), (15, "Solid"),
            (8, "Good"), (5, "Moving Up"), (2, "Good Start"), (0, "Beginner")
        ].reversed()
    }
    var currentRank: String{
        ranks[3].rank
    }
    
    var rankIndex: Int {
        ranks.firstIndex { $0.rank == currentRank } ?? 0
    }
    
    var totalRanks: Int {
        ranks.count - 1
    }
    
    var progress: Double {
        Double(rankIndex) / Double(totalRanks)
    }
    
    var width: CGFloat {
        CGFloat(300)
    }
    
    var segment_length: CGFloat{
        width / CGFloat(9)
    }
    
    var body: some View {
//        ZStack(alignment: .leading) {
//            // Background Line
//            Rectangle()
//                .frame(width: width,height: 2)
//                .foregroundColor(Color.gray.opacity(0.3))
//
//            // Progress Line (Moves discretely by rank)
//            Rectangle()
//                .frame(width: CGFloat(rankIndex) * segment_length, height: 2)
//                .foregroundColor(.yellow)
//                .animation(.easeInOut(duration: 0.5), value: progress)
//
//            // Rank Points
//            HStack(spacing: segment_length) {
//                ForEach(ranks.indices, id: \.self) { index in
//                    Circle()
//                        .frame(width: 10)
//                        .foregroundColor(index <= rankIndex ? .yellow : .white)
//                        .overlay(Circle().stroke(Color.gray, lineWidth: 0.5))
//                }
//            }
//        }
        ZStack(alignment: .leading){
            Rectangle()
                .frame(width: width, height: 2)
                .foregroundColor(Color.gray.opacity(0.3))
            
            Rectangle()
                .frame(width: CGFloat(rankIndex) * segment_length, height: 2)
                .foregroundColor(.yellow)
                .animation(.easeInOut(duration: 0.5), value: progress)
            
            HStack(spacing: (width - CGFloat(ranks.count) * 10) / CGFloat(ranks.count - 1)) {
                ForEach(ranks.indices, id: \.self) { index in
                    Circle()
                        .frame(width: 10)
                        .foregroundColor(index <= rankIndex ? .yellow : .gray.opacity(0.3))
//                        .overlay(Circle().stroke(Color.gray, lineWidth: 0.5))
                }
            }
            .frame(width: width, alignment: .leading) // Ensures full width usage
        }
        .frame(height: 30)
        .padding()
    }
}


struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        let previewContext = PersistenceController.preview.container.viewContext
        TestView().environment(\.managedObjectContext, previewContext)
    }
}
