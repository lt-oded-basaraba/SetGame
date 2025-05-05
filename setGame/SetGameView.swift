//
//  ContentView.swift
//  setGame
//
//  Created by Oded Basaraba on 27/04/2025.
//


import SwiftUI

struct SetGameView: View {
  @Namespace private var dealingNamespace
  @ObservedObject var viewModel: SetGameViewModel
  @State private var dealing = Set<SetGame.Card.ID>()
  @State private var discarding = Set<SetGame.Card.ID>()
  @State private var matchAnimationIds = Set<SetGame.Card.ID>()
  @State private var mismatchAnimationIds = Set<SetGame.Card.ID>()

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
        HStack {
            Button("New Game") {
                viewModel.newGame()
                dealing.removeAll()
                discarding.removeAll()
            }
            .buttonStyle(.borderedProminent)
            .padding()

            Button("Shuffle") {
                viewModel.shuffle()
            }
            .buttonStyle(.bordered)
            .padding()
        }
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
                    if !dealing.contains(card.id) && !discarding.contains(card.id) {
                        CardView(card: card, isMatch: matchAnimationIds.contains(card.id), isMismatch: mismatchAnimationIds.contains(card.id))
                            .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                            .padding(4)
                            .onTapGesture { choose(card) }
                            .transition(.asymmetric(insertion: .identity, removal: .identity))
                    } else if discarding.contains(card.id) {
                        CardView(card: card)
                            .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                            .padding(4)
                            .transition(.asymmetric(insertion: .identity, removal: .identity))
                    }
                }
            }
            .padding(.horizontal)
        }
    } else {
        AspectVGrid(cards, aspectRatio: 2/3) { card in
            if !dealing.contains(card.id) && !discarding.contains(card.id) {
                CardView(card: card, isMatch: matchAnimationIds.contains(card.id), isMismatch: mismatchAnimationIds.contains(card.id))
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .padding(4)
                    .onTapGesture { choose(card) }
                    .transition(.asymmetric(insertion: .identity, removal: .identity))
            } else if discarding.contains(card.id) {
                CardView(card: card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .padding(4)
                    .transition(.asymmetric(insertion: .identity, removal: .identity))
            }
        }
    }
  }

  func choose(_ card: SetGame.Card) {
    let selected = viewModel.displayCards.indices.filter { viewModel.displayCards[$0].isSelected }
    if selected.count == 2, let idx = viewModel.displayCards.firstIndex(where: { $0.id == card.id }) {
        let newSelected = selected + [idx]
        let isMatch = viewModel.isSetForSelectedIndices(newSelected)
        if isMatch {
            let ids = newSelected.map { viewModel.displayCards[$0].id }
            matchAnimationIds.formUnion(ids)
            withAnimation(.easeInOut(duration: 0.3)) {}
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                matchAnimationIds.subtract(ids)
                viewModel.choose(card)
            }
            return
        } else {
            let ids = newSelected.map { viewModel.displayCards[$0].id }
            mismatchAnimationIds.formUnion(ids)
            withAnimation(.default) {}
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                mismatchAnimationIds.subtract(ids)
                viewModel.choose(card)
            }
            return
        }
    }
    withAnimation { viewModel.choose(card) }
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
        ForEach(viewModel.deck, id: \.id) { card in
          FaceDownCardView()
            .frame(width: 50, height: 75)
            .matchedGeometryEffect(id: card.id, in: dealingNamespace)
            .transition(.asymmetric(insertion: .identity, removal: .identity))
        }
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
        handleDeckTap()
      }
    }
  }

  private func handleDeckTap() {
    let selected = viewModel.displayCards.indices.filter { viewModel.displayCards[$0].isSelected }
    if selected.count == 3 && viewModel.displayCards.count > selected.max()! {
      let isSet = viewModel.isSetForSelectedIndices(selected)
      if isSet {
        let discardingIds = selected.map { viewModel.displayCards[$0].id }
        discarding.formUnion(discardingIds)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
          withAnimation(.easeInOut(duration: 0.6)) {
            discarding.subtract(discardingIds)
            viewModel.dealThreeMoreCards()
          }
        }
        return
      }
    }
    dealCards()
  }

  private func dealCards(_ count: Int = 3) {
    let newCards = viewModel.deck.prefix(count)
    let newIds = newCards.map { $0.id }
    dealing.formUnion(newIds)
    viewModel.addThreeCards()
    for (i, id) in newIds.enumerated() {
      DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
        withAnimation(.easeInOut(duration: 0.6)) {
          _ = dealing.remove(id)
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
        ForEach(viewModel.DiscardPile.suffix(3), id: \.id) { card in
          if discarding.contains(card.id) {
            CardView(card: card)
              .frame(width: 50, height: 75)
              .matchedGeometryEffect(id: card.id, in: dealingNamespace)
              .transition(.asymmetric(insertion: .identity, removal: .identity))
          } else {
            CardView(card: card)
              .frame(width: 50, height: 75)
              .matchedGeometryEffect(id: card.id, in: dealingNamespace)
              .transition(.asymmetric(insertion: .identity, removal: .identity))
          }
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
    var isMatch: Bool = false
    var isMismatch: Bool = false

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
            if card.isSelected {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.green, lineWidth: 4)
            }
            if card.isMatched {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.red, lineWidth: 4)
            }
        }
        .aspectRatio(2/3, contentMode: .fit)
        .scaleEffect(isMatch ? 1.15 : 1)
        .background(isMatch ? Color.green.opacity(0.3) : (isMismatch ? Color.red.opacity(0.3) : Color.clear))
        .modifier(ShakeEffect(shakes: isMismatch ? 2 : 0))
        .animation(.easeInOut(duration: 0.3), value: isMatch)
        .animation(.default, value: isMismatch)
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

struct FaceDownCardView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.blue)
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white, lineWidth: 2)
        }
        .aspectRatio(2/3, contentMode: .fit)
    }
}

struct ShakeEffect: GeometryEffect {
    var shakes: CGFloat = 0
    var animatableData: CGFloat {
        get { shakes }
        set { shakes = newValue }
    }
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: 10 * sin(shakes * .pi * 2), y: 0))
    }
}

struct SetGameView_Previews: PreviewProvider {
    static var previews: some View {
        SetGameView(viewModel: SetGameViewModel())
            .previewDevice("iPhone 16 Pro")
    }
}
