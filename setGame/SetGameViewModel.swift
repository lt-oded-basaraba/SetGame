//
//  SetGameViewModel.swift
//  setGame
//
//  Created by Oded Basaraba on 27/04/2025.
//

import SwiftUI

class SetGameViewModel: ObservableObject {
    @Published private var model = SetGame()

    var deck: [SetGame.Card] {
        model.deck
    }

    var DiscardPile: [SetGame.Card] {
      model.discardedCards
    }

    var displayCards: [SetGame.Card] {
        model.displayCards
    }

    var NumberOfCardsInPlay: Int {
        model.NumberOfCardsInPlay
    }

  func choose(_ card: SetGame.Card) {
      let selected = model.indexOfSelectedCards
      if selected.count == 3 && model.isSet(selected.map { model.displayCards[$0].content }) {
          withAnimation(.easeInOut(duration: 0.6)) {
              model.checkIfSet(selectedCards: selected, card: selected[0])
          }
      } else {
          model.choose(card)
      }
  }

    func newGame() {
        model = SetGame()
    }

    func addThreeCards() {
        model.addThreeCards()
    }

  func dealThreeMoreCards() {
    withAnimation(.easeInOut(duration: 0.6)) {
      let selected = model.indexOfSelectedCards
      if selected.count == 3 && model.isSet(selected.map { model.displayCards[$0].content }) {
        model.checkIfSet(selectedCards: selected, card: selected[0])
      } else {
        model.addThreeCards()
      }
    }
  }

    var canDealMoreCards: Bool {
      !model.deck.isEmpty
    }

    // Add game logic functions here that modify model and publish changes.

    func isSetForSelectedIndices(_ indices: [Int]) -> Bool {
        model.isSet(indices.map { model.displayCards[$0].content })
    }

    func shuffle() {
        withAnimation(.easeInOut) {
            model.shuffleDisplayCards()
        }
    }
}
