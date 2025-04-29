//
//  SetGameViewModel.swift
//  setGame
//
//  Created by Oded Basaraba on 27/04/2025.
//

import SwiftUI

class SetGameViewModel: ObservableObject {
    @Published private var model = SetGame()
    // Number of cards to display in the view
    @Published var cardsToShow: Int = 12

    var deck: [SetGame.Card] {
        model.deck
    }

  var NumberOfCardsInPlay: Int {
    model.NumberOfCardsInPlay
  }

    func choose(_ card: SetGame.Card) {
        model.choose(card)
    }

    func newGame() {
        model = SetGame()
        cardsToShow = 12
    }

    func addThreeCards() {
      model.addThreeCards()

  }
    // Add game logic functions here that modify model and publish changes.
}
