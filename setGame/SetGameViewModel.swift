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

    func dealThreeMoreCards() {
        let selected = model.indexOfSelectedCards
        if selected.count == 3 && model.isSet(selected.map { model.deck[$0].content }) {
            model.checkIfSet(selectedCards: selected, card: selected[0])
        } else {
            model.addThreeCards()
        }
    }

    var canDealMoreCards: Bool {
        model.deck.filter { !$0.isOnTable }.count >= 3
    }

    // Add game logic functions here that modify model and publish changes.
}
