//
//  SetGame.swift
//  setGame
//
//  Created by Oded Basaraba on 27/04/2025.
//

import Foundation


struct SetGame{
  private(set) var deck: [Card]
   var NumberOfCardsInPlay: Int = 12

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
    NumberOfCardsInPlay = 12
    deck.shuffle()
    for index in 0..<NumberOfCardsInPlay {
      deck[index].isOnTable = true
    }
  }

  /// Indices of currently selected cards
  var indexOfSelectedCards: [Int] {
    deck.indices.filter { deck[$0].isSelected }
  }

  mutating func checkIfSet(selectedCards: [Int], card: Int) {
    let allCards = (selectedCards).map { deck[$0].content }

    if isSet(allCards) {
      removeCards(at: selectedCards, card)
    } else {
      deselectCards(at: selectedCards)
      deck[card].isSelected.toggle()
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
  private mutating func removeCards(at indices: [Int], _ card: Int) {
    let sortedIndices = indices.sorted(by: >)
    for idx in 0..<3 {
      if let index = deck.firstIndex(where : {$0.isOnTable == false})
      {
          deck[index].isOnTable = true
          deck[sortedIndices[idx]] = deck[index]
      }
      else {
        deck.remove(at: sortedIndices[idx])
      }
    }
    if !indices.contains(card) {
      deck[card].isSelected.toggle()
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
      
      // Toggle the card's selection if we have less than 3 cards selected
      // or if this card wasn't previously selected
      if previouslySelected.count < 3 || previouslySelected.contains(index) {
          deck[index].isSelected.toggle()
      }
      
      // Check for set if we now have 3 selected cards
      if previouslySelected.count == 3 {
          checkIfSet(selectedCards: previouslySelected, card: index)
      }
    }
  }

  mutating func addThreeCards() {
    for _ in 0..<3 {
      if let index = deck.firstIndex(where : {$0.isOnTable == false})
      {
        deck[index].isOnTable = true
        NumberOfCardsInPlay += 1
      }
    }
  }





  struct Card: Identifiable, Equatable, CustomStringConvertible {
    var id: String
    var content: CardContent
    var isMatched: Bool = false
    var isSelected: Bool = false
    var isOnTable: Bool = false
    var description: String {
      return "\(content) \(isMatched ? "Matched" : "Not Matched") \(isSelected ? "Selected" : "Not Selected")"
    }
  }
}

