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

  func choose(_ card: SetGame.Card) {
    model.choose(card)
  }
    // Add game logic functions here that modify model and publish changes.
}
