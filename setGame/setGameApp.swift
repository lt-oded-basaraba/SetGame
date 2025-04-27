//
//  setGameApp.swift
//  setGame
//
//  Created by Oded Basaraba on 27/04/2025.
//

import SwiftUI

@main
struct setGameApp: App {
    @StateObject private var viewModel = SetGameViewModel()
    var body: some Scene {
        WindowGroup {
          SetGameView(viewModel: viewModel)
        }
    }
}
