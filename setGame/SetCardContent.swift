//
//  SetCaedContent.swift
//  setGame
//
//  Created by Oded Basaraba on 27/04/2025.
//

import Foundation

// MARK: - Card Content
enum CardNumber: Int, CaseIterable, CustomStringConvertible {
    case one, two, three

    var description: String {
        switch self {
        case .one: return "1"
        case .two: return "2"
        case .three: return "3"
        }
    }
}

enum CardSymbol: Int, CaseIterable, CustomStringConvertible {
    case diamond, squiggle, oval

    var description: String {
        switch self {
        case .diamond: return "Diamond"
        case .squiggle: return "Squiggle"
        case .oval: return "Oval"
        }
    }
}

enum CardShading: Int, CaseIterable, CustomStringConvertible {
    case solid, striped, open

    var description: String {
        switch self {
        case .solid: return "Solid"
        case .striped: return "Striped"
        case .open: return "Open"
        }
    }
}

enum CardColor: Int, CaseIterable, CustomStringConvertible {
    case red, green, purple

    var description: String {
        switch self {
        case .red: return "Red"
        case .green: return "Green"
        case .purple: return "Purple"
        }
    }
}

struct CardContent: Equatable, CustomStringConvertible, Hashable {
    var number: CardNumber
    var symbol: CardSymbol
    var shading: CardShading
    var color: CardColor


    var description: String {
        return "\(number), \(symbol), \(shading), \(color)"
    }
}

extension CardContent {
    var symbolString: String {
        switch symbol {
        case .diamond: return "◆"
        case .squiggle: return "≈"
        case .oval: return "●"
        }
    }

    var repeatedSymbols: String {
        let count = number.rawValue + 1 // .one -> 1, .two -> 2, .three -> 3
        return String(repeating: symbolString, count: count)
    }
}
