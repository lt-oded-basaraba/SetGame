//
//  SetGame.swift
//  setGame
//
//  Created by Oded Basaraba on 27/04/2025.
//

import Foundation


struct SetGame{
  private(set) var deck: [Card]

  init() {
    deck = []
    for number in CardNumber.allCases {
      for symbol in CardSymbol.allCases {
        for shading in CardShading.allCases {
          for color in CardColor.allCases {
            let content = CardContent(number: number, symbol: symbol, shading: shading, color: color)
            let card = Card(id: "\(number)\(symbol)\(shading)\(color)", content: content)
            deck.append(card)


          }
        }
      }
    }
  }





  struct Card: Identifiable, Equatable, CustomStringConvertible {
    var id: String
    var content: CardContent
    var isMatched: Bool = false
    var isSelected: Bool = false
    var description: String {
      return "\(content) \(isMatched ? "Matched" : "Not Matched") \(isSelected ? "Selected" : "Not Selected")"
    }
  }
}

