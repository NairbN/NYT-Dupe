//
//  SpellingBeeView.swift
//  NYT Dupe
//
//  Created by Brian Nguyen on 3/25/25.
//

import Foundation
import SwiftUI
import CoreData


struct SpellingBeeView: View {
    @ObservedObject var viewModel: SpellingBeeViewModel
    
    struct Hexagon: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            let width = rect.width
            let height = rect.height

            path.move(to: CGPoint(x: width * 0.25, y: 0)) // Top-left
            path.addLine(to: CGPoint(x: width * 0.75, y: 0)) // Top-right
            path.addLine(to: CGPoint(x: width, y: height / 2)) // Right
            path.addLine(to: CGPoint(x: width * 0.75, y: height)) // Bottom-right
            path.addLine(to: CGPoint(x: width * 0.25, y: height)) // Bottom-left
            path.addLine(to: CGPoint(x: 0, y: height / 2)) // Left
            path.closeSubpath()

            return path
        }
    }
    
    private var hexagonView: some View {
        Hexagon()
            .fill(Color.mint)
            .frame(width: viewModel.cellWidth, height: viewModel.cellHeight)
            .overlay(
                Hexagon()
                    .stroke(Color.black, lineWidth: 1)
            )
    }

    struct ProgressBar: View {
        var currentRank: String
        let ranks: [(threshold: Double, rank: String)]
        
        var rankIndex: Int {
            ranks.firstIndex { $0.rank == currentRank } ?? 0
        }
        
        var totalRanks: Int {
            ranks.count
        }
        
        var progress: Double {
            Double(rankIndex) / Double(totalRanks)
        }
        
        var width: CGFloat {
            CGFloat(200)
        }
        
        var body: some View {
            ZStack(alignment: .leading) {
                // Background Line
                Rectangle()
                    .frame(width: width,height: 2)
                    .foregroundColor(Color.gray.opacity(0.3))
                
                // Progress Line (Moves discretely by rank)
                Rectangle()
                    .frame(width: CGFloat(progress) * width, height: 2)
                    .foregroundColor(.yellow)
                    .animation(.easeInOut(duration: 0.5), value: progress)
                
                // Rank Points
                HStack {
                    ForEach(ranks.indices, id: \.self) { index in
                        Circle()
                            .frame(width: 1, height: 1)
                            .foregroundColor(index <= rankIndex ? .yellow : .white)
                            .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                            .offset(x: (CGFloat(index) / CGFloat(totalRanks)) * width)
                    }
                }
            }
        }
    }


    
    var body: some View {
        if viewModel.isGeneratingPuzzle{
            ProgressView("Generating Puzzle...")
                .progressViewStyle(CircularProgressViewStyle())
                .padding()
        } else {
        
            VStack{
                ProgressBar(currentRank: viewModel.rank, ranks: PuzzleSettings.RANKS.reversed())
                    .frame(height: 20)
                    .padding()
                
                VStack{
                    TextField("Type or click", text: $viewModel.currentWord)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding()
                        .disableAutocorrection(true)
                        .autocapitalization(.allCharacters)
                        .multilineTextAlignment(.center)
                        .onSubmit {
                            viewModel.submitWord()
                        }
                    ZStack {
                        ZStack{
                            Hexagon()
                                .foregroundColor(.yellow)
                                .frame(width: viewModel.cellWidth, height: viewModel.cellHeight)
                                .onTapGesture{
                                    viewModel.typeLetter(letter: viewModel.centerLetter.uppercased())
                                }
                            
                            Text(viewModel.centerLetter.uppercased())
                                .foregroundColor(.black)
                                .font(.headline)
                                .bold()
                            
                        }
                        ForEach(0..<6, id: \.self) { i in
                            ZStack{
                                Hexagon()
                                    .foregroundColor(.gray.opacity(0.4))
                                    .frame(width: viewModel.cellWidth, height: viewModel.cellHeight)
                                    .offset(x: viewModel.hexOffset(for: i).x, y: viewModel.hexOffset(for: i).y)
                                    .onTapGesture{
                                        viewModel.typeLetter(letter: viewModel.surroundingLetters[i].uppercased())
                                    }
                                
                                Text(viewModel.surroundingLetters[i].uppercased())
                                    .foregroundColor(.black)
                                    .font(.headline)
                                    .bold()
                                    .offset(x: viewModel.hexOffset(for: i).x, y: viewModel.hexOffset(for: i).y)
                            }
                        }
                    }
                    .padding(80)
                    
                    HStack{
                        Button(action: viewModel.delete){
                            Text("Delete")
                                .padding()
                                .font(.system(size: 14))
                                .cornerRadius(10)
                                .foregroundColor(.black)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 50)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        Button(action: viewModel.shuffleSurrounding){
                            Text("Shuffle")
                                .padding()
                                .font(.system(size: 14))
                                .cornerRadius(10)
                                .foregroundColor(.black)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 50)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        Button(action: viewModel.submitWord){
                            Text("Enter")
                                .padding()
                                .font(.system(size: 14))
                                .cornerRadius(10)
                                .foregroundColor(.black)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 50)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                }

                List(Array(viewModel.wordsFormed), id: \.self) { word in
                    Text(word.uppercased())
                        .font(.headline)
                }
                .frame(height: 200)



            }
        }
    }
 
    
}

struct SpellingBeeView_Previews: PreviewProvider {
    static var previews: some View {
        let previewContext = PersistenceController.preview.container.viewContext
        let previewViewModel = SpellingBeeViewModel(context: previewContext)
        SpellingBeeView(viewModel: previewViewModel)
            .environment(\.managedObjectContext, previewContext)
    }
}
