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
    @State private var showNotification = false
    
    @State private var isLandscape = false

    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            
            VStack {
                
                if viewModel.isGeneratingPuzzle {
                    VStack {
                        Spacer()
                        ProgressView("Generating Puzzle...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    if isLandscape {
                        LandscapeLayout
                    } else {
                        PortraitLayout
                    }
                }
            }
        }
        .preferredColorScheme(.light)
    }
    
    private var LandscapeLayout: some View {
        HStack {
            VStack {
                Spacer()
                MainContentView
                Spacer()
            }
            .frame(maxWidth: .infinity)

            VStack {
                ProgressBar(currentRank: viewModel.rank, ranks: PuzzleSettings.RANKS.reversed(), score: viewModel.score)
                    .frame(height: 20)
                    .padding()
                WordListView
            }
            .padding()
        }
    }

    private var PortraitLayout: some View {
        VStack {
            Spacer()
            ProgressBar(currentRank: viewModel.rank, ranks: PuzzleSettings.RANKS.reversed(), score: viewModel.score)
                .frame(height: 20)
                .padding()

            MainContentView
            Spacer()
            WordListView
        }
    }

    private var MainContentView: some View {
        VStack {
            ZStack{
                TextField("Type or click", text: $viewModel.currentWord)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding()
                    .disableAutocorrection(true)
                    .autocapitalization(.allCharacters)
                    .multilineTextAlignment(.center)
                    .onSubmit {
                        viewModel.submitWord()
                        showNotification = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            showNotification = false
                        }
                    }

                if showNotification {
                    NotificationView(notification: viewModel.notification)
                }
            }
            
            HexagonGridView
            ActionButtons
        }
    }
    
    private var WordListView: some View {
        GeometryReader { geometry in
            let columns = [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ]
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(Array(viewModel.wordsFormed), id: \.self) { word in
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
    
    private var HexagonGridView: some View {
        ZStack {
            HexagonView(color: .yellow, width: viewModel.cellWidth, height: viewModel.cellHeight)
                .onTapGesture {
                    viewModel.typeLetter(letter: viewModel.centerLetter.uppercased())
                }

            Text(viewModel.centerLetter.uppercased())
                .foregroundColor(.black)
                .font(.headline)
                .bold()

            ForEach(0..<6, id: \.self) { i in
                ZStack {
                    HexagonView(color: .gray.opacity(0.4), width: viewModel.cellWidth, height: viewModel.cellHeight)
                        .offset(x: viewModel.hexOffset(for: i).x, y: viewModel.hexOffset(for: i).y)
                        .onTapGesture {
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
    }

    private var ActionButtons: some View {
        HStack {
            Button(action: viewModel.delete) {
                Text("Delete")
            }
            .buttonStyle(text: "Delete", action: viewModel.delete)

            Button(action: viewModel.shuffleSurrounding) {
                Text("Shuffle")
            }
            .buttonStyle(text: "Shuffle", action: viewModel.shuffleSurrounding)

            Button(action: {
                viewModel.submitWord()
                showNotification = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    showNotification = false
                }
            }) {
                Text("Enter")
            }
            .buttonStyle(text: "Enter", action: {
                viewModel.submitWord()
                showNotification = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    showNotification = false
                }
            })
        }
    }
}

extension View {
    func buttonStyle(text: String, action: @escaping () -> Void) -> some View {
        self.modifier(ButtonStyleModifier(text: text, action: action))
    }
}

struct ButtonStyleModifier: ViewModifier {
    var text: String
    var action: () -> Void

    func body(content: Content) -> some View {
        Button(action: action) {
            Text(text)
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

struct HexagonView: View {
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
    var color: Color = .mint
    var width: CGFloat
    var height: CGFloat
    
    var body: some View {
        Hexagon()
            .fill(color)
            .frame(width: width, height: height) 
    }
}

struct ProgressBar: View {
    var currentRank: String
    
    var ranks: [(threshold: Double, rank: String)]

    var score: Int
    
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
        ZStack(alignment: .leading){
            Rectangle()
                .frame(width: width, height: 1)
                .foregroundColor(Color.gray.opacity(0.3))
            Rectangle()
                .frame(width: CGFloat(rankIndex) * segment_length, height: 1)
                .foregroundColor(.yellow)
                .animation(.easeInOut(duration: 0.5), value: progress)
            HStack(spacing: (width - CGFloat(ranks.count) * 7) / CGFloat(ranks.count - 1)) {
                ForEach(ranks.indices, id: \.self) { index in
                    ZStack{
                        Circle()
                            .frame(width: 6)
                            .background(Color.white)
                            .foregroundColor(index <= rankIndex ? .yellow : .gray.opacity(0.3))
                            .overlay(Circle().stroke(Color.white, lineWidth: 0.5))
                        if index == rankIndex {
                            Circle()
                                .frame(width: 20)
                                .foregroundColor(.yellow)
                                .overlay(Circle().stroke(Color.white, lineWidth: 0.5))
                            Text(String(score))
                                .font(.system(size: 8))
                                .foregroundColor(.black)
                                .frame(width: 18, height: 18)
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                                .scaledToFit()
                        }
                    }
                }
                
            }
            .frame(width: width, alignment: .leading) // Ensures full width usage
        }
        .frame(height: 30)
        .padding()
    }
}

struct NotificationView: View{
    var notification:String
    @State private var offsetX: CGFloat = 0
    
    var body: some View {
        Text(notification)
            .font(.system(size: 12)) // Small readable font
            .foregroundColor(.white) // White text for contrast
            .padding(6) // Adds padding for spacing inside the rectangle
            .background(Color.black) // Black rectangle
            .offset(x: offsetX)
            .onAppear {
                startShaking()
            }

    }
    
    private func startShaking() {
        withAnimation(
            Animation.easeInOut(duration: 0.1)
                .repeatCount(6, autoreverses: true)
        ) {
            offsetX = 5
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            offsetX = 0
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
