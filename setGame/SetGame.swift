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

  /// Indices of currently selected cards
  var indexOfSelectedCards: [Int] {
    deck.indices.filter { deck[$0].isSelected }
  }

  mutating func checkIfSet(selectedCards: [Int], card: Int) {
      let allCards = (selectedCards + [card]).map { deck[$0].content }

      if isSet(allCards) {
          removeCards(at: selectedCards + [card])
      } else {
          deselectCards(at: selectedCards + [card])
      }
  }

  // Helper to check if 3 cards form a SET
  private func isSet(_ cards: [CardContent]) -> Bool {
      guard cards.count == 3 else { return false }

      let numbers = Set(cards.map { $0.number })
      let symbols = Set(cards.map { $0.symbol })
      let shadings = Set(cards.map { $0.shading })
      let colors = Set(cards.map { $0.color })

      return (numbers.count == 1 || numbers.count == 3) &&
             (symbols.count == 1 || symbols.count == 3) &&
             (shadings.count == 1 || shadings.count == 3) &&
             (colors.count == 1 || colors.count == 3)
  }

  // Helper to remove cards after a successful match
  private mutating func removeCards(at indices: [Int]) {
      let sortedIndices = indices.sorted(by: >)
      for idx in sortedIndices {
          deck[idx].isSelected = false
      }
      for idx in sortedIndices {
          deck.remove(at: idx)
      }
  }

  // Helper to deselect cards after mismatch
  private mutating func deselectCards(at indices: [Int]) {
      for idx in indices {
          deck[idx].isSelected = false
      }
  }

  /// Choose a card: toggles selection and checks for a set when two were selected before
  mutating func choose(_ card: Card) {
    if let index = deck.firstIndex(where: { $0.id == card.id }), !deck[index].isMatched {
      let previouslySelected = indexOfSelectedCards
      // Toggle selection
      deck[index].isSelected.toggle()
      // Only proceed to check if this card is now selected and two were selected before
      if deck[index].isSelected && previouslySelected.count == 2 {
        checkIfSet(selectedCards: previouslySelected, card: index)
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

