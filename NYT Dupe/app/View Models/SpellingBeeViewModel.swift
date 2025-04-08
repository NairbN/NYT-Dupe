//
//  SpellingBeeViewModel.swift
//  NYT Dupe
//
//  Created by Brian Nguyen on 3/25/25.
//

/*
 Ranks and Percentages:
 Beginner: 0%
 Good Start: 2%
 Moving Up: 5%
 Good: 8%
 Solid: 15%
 Nice: 25%
 Great: 40%
 Amazing: 50%
 Genius: 70%
 Queen Bee: 100%
 */
import Foundation
import CoreData
import SwiftUI

struct PuzzleSettings {
    //UI Variables
    static let CELL_SIDE_LENGTH: CGFloat = 35
    
    // Puzzle Generation Settings
    static let NUM_LETTERS = 7
    static let MIN_WORD_LENGTH = 4
    static let MAX_WORD_LENGTH = 20
    static let MIN_NUM_SOLUTIONS = 20
    static let MAX_NUM_SOLUTIONS = 70
    
    // Dictionary File (Must be csv)
    static let FILE_NAME = "filtered_dictionary"
    
    // Rank
    static let RANKS: [(threshold: Double, rank: String)] = [
        (100, "Queen Bee"), (70, "Genius"), (50, "Amazing"),
        (40, "Great"), (25, "Nice"), (15, "Solid"),
        (8, "Good"), (5, "Moving Up"), (2, "Good Start"), (0, "Beginner")
    ]
    
    // Alphabet for selecting surrounding letters
    static let ALPHABET = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]

    // Letters considered common and frequently used for center and surrounding letters
    static let MOST_FREQUENT_LETTERS = ["e", "a", "r", "o", "t", "n", "s"]
}

class SpellingBeeViewModel: ObservableObject{
    private let viewContext: NSManagedObjectContext
    
    private var wordList = Set<String>()
    
    @Published var isGeneratingPuzzle: Bool = false
    
    private var validWords = [String]()
    private var validPangrams = [String]()
    private var maxScore: Int = 0
//    private var numLetterValid = [Int]()

    @Published var centerLetter: String = ""
    @Published var surroundingLetters: [String] = []
    @Published var currentWord: String = ""
    @Published var score: Int = 0
    @Published var wordsFormed: Set<String> = []
    @Published var isPangram: Bool = false
    @Published var percent: Double = 0
    @Published var rank: String = ""
    @Published var notification: String = ""
    @Published var letterValid: [Int] = []
    
    //UI Variables
    @Published var cellSideLength: CGFloat = 0
    @Published var cellHeight: CGFloat = 0
    @Published var cellWidth: CGFloat = 0
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        
        self.cellSideLength = PuzzleSettings.CELL_SIDE_LENGTH
        self.cellHeight = cellSideLength * sqrt(3)
        self.cellWidth = cellSideLength * 2
        
        loadDictionary()
        createPuzzle()
    }
    
    func hexOffset(for index: Int) -> CGPoint {
        let angle = CGFloat(index) * 60.0 - 90.0 // Start at 12 o’clock (-90°)
        let angleInRadians = angle * .pi / 180 // Convert degrees to radians
        
        let dx = cellSideLength * cos(angleInRadians) * 2 // Adjusted X spacing
        let dy = cellSideLength * sin(angleInRadians) * 2 // Adjusted Y spacing
        
        return CGPoint(x: dx, y: dy)
    }
    
    func loadDictionary() {
        guard let fileURL = Bundle.main.url(forResource: PuzzleSettings.FILE_NAME, withExtension: "csv") else {
            print("CSV file not found.")
            return
        }
        do {
            let fileContent = try String(contentsOf: fileURL)
            let lines = fileContent.split(whereSeparator: \.isNewline)
            wordList = Set(lines.map { $0.lowercased() })
        } catch {
            print("Failed to read CSV file: \(error.localizedDescription)")
        }
    }
    
    func createPuzzle(){
        if(!isGeneratingPuzzle){
            isGeneratingPuzzle = true
            print("Generating Puzzle...")
            generatePuzzle()
        } else{
            print("puzzle is already generating...")
        }
    }
    
    private func generatePuzzle() {
        DispatchQueue.global(qos: .background).async{
            let center = PuzzleSettings.MOST_FREQUENT_LETTERS.randomElement() ?? "e"
            let surrounding = self.chooseSurroundingLetters(center: center)
            let valid = self.generateValidWords(center: center, surrounding: surrounding)

            if valid.isGood {
                DispatchQueue.main.async{
                    self.centerLetter = center
                    self.surroundingLetters = surrounding
                    self.validWords = valid.valid
                    self.validPangrams = valid.pangrams
                    self.letterValid = valid.numLetter
                    for word in valid.valid{
                        self.maxScore += word.count - 3
                        if(valid.pangrams.contains(word)){
                            self.maxScore += 7
                        }
                    }
                    self.isGeneratingPuzzle = false
                    print("Center Letter: " + self.centerLetter)
                    print("Surrounding Letters: ")
                    dump(self.surroundingLetters)
                    print("Valid Words: ")
                    dump(self.validWords)
                    print("Valid Pangrams: ")
                    dump(valid.pangrams)
                    print("Max Score: \(self.maxScore)")
                }
            } else {
                DispatchQueue.main.async{
                    print("Center Letter: " + center)
                    print("Surrounding Letters: ")
                    dump(surrounding)
                    print("Valid Words: ")
                    dump(valid.valid)
                    print("Valid Pangrams: ")
                    dump(valid.pangrams)
                    print("Max Score: \(self.maxScore)")
                    self.generatePuzzle()
                    
                }
            }
        }
    }

    private func chooseSurroundingLetters(center: String) -> [String] {
        let remainingLetters = PuzzleSettings.ALPHABET.filter { $0 != center }
        let prioritizedLetters = remainingLetters.filter { PuzzleSettings.MOST_FREQUENT_LETTERS.contains($0) }
        let otherLetters = remainingLetters.filter { !PuzzleSettings.MOST_FREQUENT_LETTERS.contains($0) }
        let shuffled = (prioritizedLetters + otherLetters).shuffled().prefix(PuzzleSettings.NUM_LETTERS - 1)
        return Array(shuffled)
    }

    private func generateValidWords(center: String, surrounding: [String]) -> (isGood: Bool, valid: [String], pangrams: [String], numLetter: [Int]) {
        let validLetters = Set(surrounding + [center])
        
        
        let filteredWords = wordList.filter { word in
            word.contains(center) &&
            word.allSatisfy { validLetters.contains(String($0)) }
        }
        
        let validWordsSet = Set(filteredWords.filter { $0.count >= PuzzleSettings.MIN_WORD_LENGTH })
        
        let numLetter = getNumLetter(from: validWordsSet)
        
        let pangramSet = validWordsSet.filter { word in
            surrounding.allSatisfy{word.contains($0)} &&
            word.contains(center)
        }
        
        let pangramArray = Array(pangramSet)
        let validWordsArray = Array(validWordsSet)
        
        return (validWordsSet.count >= PuzzleSettings.MIN_NUM_SOLUTIONS && validWordsSet.count <= PuzzleSettings.MAX_NUM_SOLUTIONS && !pangramSet.isEmpty , validWordsArray, pangramArray, numLetter)
    }
    
    private func getNumLetter(from set: Set<String>) -> ([Int]){
        var result = Array(repeating: 0, count: PuzzleSettings.MAX_WORD_LENGTH + 1)

        for word in set {
            let length = word.count
            if length <= PuzzleSettings.MAX_WORD_LENGTH {
                result[length] += 1
            }
        }

        return result
    }
    
    func submitWord(){
        let word = currentWord.lowercased()
        if(word.count < 4 || word.isEmpty){
            notification = "Too Short"
            print("Word must be >= 4 letters")
            currentWord = ""
        } else if(!word.contains(centerLetter)){
            notification = "Missing center letter"
            print("Word must contain center letter")
            currentWord = ""
        }else if (!validWords.contains(word)){
            notification = "Not in word list"
            print("Not a valid word")
            currentWord = ""
        } else if(wordsFormed.contains(word)){
            notification = "Already Found"
            print("Word already found")
            currentWord = ""
        }else{
            print("Found word!")
            let letterCount = word.count
            var scoreAdd = 0
            scoreAdd += letterCount - 3
            if(validPangrams.contains(word)){
                scoreAdd += 7
            }
            score += scoreAdd
            wordsFormed.insert(word)
            currentWord = ""
            letterValid = getNumLetter(from: Set(validWords).subtracting(wordsFormed))
            
            percent = Double(score) / Double(maxScore) * 100
            rank = PuzzleSettings.RANKS.first(where: { percent >= $0.threshold })?.rank ?? "Beginner"
            print(rank)
            
            dump(wordsFormed)
            print("Score: \(score)")
            notification = rank + "! +" + String(scoreAdd)
        }
    }
    
    func shuffleSurrounding(){
        surroundingLetters.shuffle()
    }
    
    func delete(){
        if(currentWord.count > 0){
            currentWord.removeLast()
        }
    }
    
    func typeLetter(letter: String){
        currentWord.append(letter)
    }

    func saveGameResult(){
        
    }
    
}

