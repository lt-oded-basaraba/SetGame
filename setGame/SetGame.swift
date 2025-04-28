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
    deck.shuffle()
  }

  var indexOfSelectedCards: [Int]? {
    var selectedIndexes: [Int]? = nil
    for index in deck.indices {
      if deck[index].isSelected {
        selectedIndexes.append(index)
      }
    }
    return selectedIndexes
  }

  mutating func checkIfSet(selectedCards: [Int], card: Int) {
    let selectedCardContents = selectedCards.map { deck[$0].content }
    let currentCardContent = deck[card].content
    let allCards = selectedCardContents + [currentCardContent]
    let allNumbers = Set(allCards.map { $0.number })
    let allSymbols = Set(allCards.map { $0.symbol })
    let allShadings = Set(allCards.map { $0.shading })
    let allColors = Set(allCards.map { $0.color })
    if ((allNumbers.count == 1 || allSymbols.count == 1 || allShadings.count == 1 || allColors.count == 1) ||
        (allNumbers.count == 3 && allSymbols.count == 3 && allShadings.count == 3 && allColors.count == 3)) {
      for index in selectedCards {
        deck[index].isMatched = true
      }
      deck[card].isMatched = true
      deck[card].isSelected = false
      for index in selectedCards {
        deck[index].isSelected = false
      }
    } else {
      for index in selectedCards {
        deck[index].isSelected = false
      }
      deck[card].isSelected = true
    }
  }


  mutating func choose(_ card: Card) {
    if let index = deck.firstIndex(where: { $0.id == card.id }) {
      if !deck[index].isMatched && !deck[index].isSelected {
        deck[index].isSelected = true
        if let selectedIndexes = indexOfSelectedCards {
          if selectedIndexes.count == 2 {
            checkIfSet(selectedCards: selectedIndexes, card: index)



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

