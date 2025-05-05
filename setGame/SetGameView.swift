//
//  ContentView.swift
//  setGame
//
//  Created by Oded Basaraba on 27/04/2025.
//


import SwiftUI

struct SetGameView: View {
  @ObservedObject var viewModel: SetGameViewModel

  var body: some View {
    ZStack {
      Color(.systemBackground) // visible background
      VStack {
        // Debug check: confirm that deck has cards
        if viewModel.deck.isEmpty {
          Text("Deck is empty")
            .foregroundColor(.red)
        }

        // Display all cards in play (displayCards), excluding matched cards
        cardGrid
        Spacer()
        pilesView
        Button("New Game") {
          viewModel.newGame()
        }
        .buttonStyle(.borderedProminent)
        .padding()
      }
      .padding()
    }
  }

  @ViewBuilder
  private var cardGrid: some View {
    let cards = viewModel.displayCards.filter { !$0.isMatched }
    if cards.count > 45 {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 5), spacing: 4) {
                ForEach(cards, id: \.id) { card in
                    CardView(card: card)
                        .padding(4)
                        .onTapGesture { viewModel.choose(card) }
                }
            }
            .padding(.horizontal)
        }
    } else {
        AspectVGrid(cards, aspectRatio: 2/3) { card in
            CardView(card: card)
                .padding(4)
                .onTapGesture { viewModel.choose(card) }
        }
    }
  }

  private var pilesView : some View {
    HStack(alignment: .top) {
      deck
      Spacer()
      discardPile
    }
  }

  private var deck: some View {
    VStack(spacing: 4) {
      ZStack {
        RoundedRectangle(cornerRadius: 10)
          .fill(Color.gray)
          .aspectRatio(2/3, contentMode: .fit)
          .frame(width: 50, height: 75)
        Text("\(viewModel.deck.count)")
          .foregroundColor(.white)
          .bold()
      }
      .overlay(
        Text("Deck")
          .font(.caption)
          .foregroundColor(.gray)
          .offset(y: 45)
      )
      .onTapGesture {
        if viewModel.canDealMoreCards {
          viewModel.dealThreeMoreCards()
        }
      }
    }
  }
  

  private var discardPile: some View {
    VStack(spacing: 2) {
      ZStack {
        RoundedRectangle(cornerRadius: 10)
          .fill(Color.clear)
          .aspectRatio(2/3, contentMode: .fit)
          .frame(width: 50, height: 75)
        if let topCard = viewModel.DiscardPile.last {
          CardView(card: topCard)
            .frame(width: 50, height: 75)
        }
      }
      // Count below the pile
      if viewModel.DiscardPile.count > 0 {
        Text("\(viewModel.DiscardPile.count)")
          .foregroundColor(.red)
          .bold()
      }
      // Label below the pile
      Text("Discard Pile")
        .font(.caption)
        .foregroundColor(.gray)
    }
  }
}
struct CardView: View {
    var card: SetGame.Card

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
            RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 2)
            VStack(spacing: 10) {
                ForEach(0..<(card.content.number.rawValue + 1), id: \.self) { _ in
                    symbolView
                        .aspectRatio(2/1, contentMode: .fit)
                }
            }
            .padding(4)
            // Highlight selected card with a green border
            if card.isSelected {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.green, lineWidth: 4)
            }
            // Show a red border for matched cards
            if card.isMatched {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.red, lineWidth: 4)
            }
        }
        .aspectRatio(2/3, contentMode: .fit)
    }

    @ViewBuilder
    private var symbolView: some View {
        let color = color(for: card.content.color)
        switch card.content.symbol {
        case .diamond:
            if card.content.shading == .open {
                Diamond().stroke(color, lineWidth: 2)
            } else if card.content.shading == .solid {
                Diamond().fill(color)
            } else {
                Diamond().fill(color).opacity(0.3)
            }
        case .squiggle:
            if card.content.shading == .open {
                Squiggle().stroke(color, lineWidth: 2)
            } else if card.content.shading == .solid {
                Squiggle().fill(color)
            } else {
                Squiggle().fill(color).opacity(0.3)
            }
        case .oval:
            if card.content.shading == .open {
                Circle().stroke(color, lineWidth: 2)
            } else if card.content.shading == .solid {
                Circle().fill(color)
            } else {
                Circle().fill(color).opacity(0.3)
            }
        }
    }

    private func color(for cardColor: CardColor) -> Color {
        switch cardColor {
        case .red: return .red
        case .green: return .green
        case .purple: return .purple
        }
    }
}

// MARK: - Custom Shape Definitions
struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        path.move(to: CGPoint(x: width/2, y: 0))
        path.addLine(to: CGPoint(x: width, y: height/2))
        path.addLine(to: CGPoint(x: width/2, y: height))
        path.addLine(to: CGPoint(x: 0, y: height/2))
        path.closeSubpath()
        return path
    }
}

struct Squiggle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.move(to: CGPoint(x: 0.1*w, y: 0.5*h))
        path.addCurve(
            to: CGPoint(x: 0.5*w, y: 0.1*h),
            control1: CGPoint(x: 0.2*w, y: 0.0*h),
            control2: CGPoint(x: 0.3*w, y: 0.3*h)
        )
        path.addCurve(
            to: CGPoint(x: 0.9*w, y: 0.5*h),
            control1: CGPoint(x: 0.7*w, y: 0.3*h),
            control2: CGPoint(x: 0.8*w, y: 0.0*h)
        )
        path.addCurve(
            to: CGPoint(x: 0.5*w, y: 0.9*h),
            control1: CGPoint(x: 1.0*w, y: 0.6*h),
            control2: CGPoint(x: 0.6*w, y: 0.8*h)
        )
        path.addCurve(
            to: CGPoint(x: 0.1*w, y: 0.5*h),
            control1: CGPoint(x: 0.4*w, y: 0.7*h),
            control2: CGPoint(x: 0.0*w, y: 0.6*h)
        )
        path.closeSubpath()
        return path
    }
}

struct SetGameView_Previews: PreviewProvider {
    static var previews: some View {
        SetGameView(viewModel: SetGameViewModel())
            .previewDevice("iPhone 16 Pro")
    }
}
