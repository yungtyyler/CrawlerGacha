//
//  ContentView.swift
//  CrawlerGacha
//
//  Created by Tyler Varzeas on 4/6/26.
//
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    let bridge = GameBridge()
    @State private var currentHand: [IOSSkillCard] = []
    
    @State private var playerParty: [IOSCharacter] = []
    @State private var enemyParty: [IOSCharacter] = []
    
    @State private var draggingCard: IOSSkillCard? = nil
    @State private var dragOffset: CGSize = .zero
    
    @State private var currentActionPoints: Int = 3
    @State private var maxActionPoints: Int = 3
    @State private var actionQueue: [IOSSkillCard] = []
    @State private var currentTargetIndex: Int = 0
    
    @State private var currentPhase: Int = 0
    
    private var screenWidth: CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return windowScene.screen.bounds.width
        }
        return 400
    }
    
    private func checkTurnCompletion() {
        if currentActionPoints == 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                bridge.endTurn()
                
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    enemyParty = bridge.getEnemyParty()
                    actionQueue = bridge.getActionQueue()
                    currentPhase = bridge.getCurrentPhase()
                }
                
                if bridge.getCurrentPhase() == 2 { return }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    bridge.executeEnemyTurn()
                    
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        playerParty = bridge.getPlayerParty()
                        currentHand = bridge.getCurrentHand()
                        currentActionPoints = bridge.getCurrentActionPoints()
                        currentPhase = bridge.getCurrentPhase()
                    }
                }
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // 1. THE ENEMY ROW (Top of screen)
            HStack(spacing: 20) {
                ForEach(Array(enemyParty.enumerated()), id: \.element.characterId) { index, enemy in
                    CharacterSpriteView(character: enemy, isEnemy: true, isTargeted: index == currentTargetIndex)
                        .onTapGesture {
                            bridge.setTargetIndex(index)
                            withAnimation(.spring(response: 0.3)) {
                                currentTargetIndex = bridge.getCurrentTargetIndex()
                            }
                        }
                }
            }
            .padding(.top, 40)
            
            Spacer()
            
            // 2. THE PLAYER ROW (Middle of screen)
            HStack(spacing: 30) {
                ForEach(playerParty, id: \.characterId) { player in
                    CharacterSpriteView(character: player, isEnemy: false)
                }
            }
            
            Spacer()
            
            // 2. ACTION QUEUE
            HStack(spacing: 15) {
                ForEach(0..<maxActionPoints, id: \.self) { index in
                    ZStack {
                        // The Empty Slot Background
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [5]))
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.1)))
                            .frame(width: 55, height: 75)
                        
                        if index < actionQueue.count {
                            let queuedCard = actionQueue[index]
                            
                            if queuedCard.cardId == -1 {
                                // THE MOVE RECEIPT
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.blue.opacity(0.6))
                                    .frame(width: 55, height: 75)
                                    .shadow(radius: 2)
                                
                                VStack(spacing: 5) {
                                    Image(systemName: "arrow.left.and.right")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("MOVE")
                                        .font(.system(size: 10, weight: .heavy))
                                        .foregroundColor(.white)
                                }
                                
                            } else if queuedCard.cardId == -2 {
                                // THE SKIP RECEIPT
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.6))
                                    .frame(width: 55, height: 75)
                                    .shadow(radius: 2)
                                
                                VStack(spacing: 5) {
                                    Image(systemName: "forward.end.fill")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("SKIP")
                                        .font(.system(size: 10, weight: .heavy))
                                        .foregroundColor(.white)
                                }
                                
                            } else {
                                // THE NORMAL ATTACK CARD
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(queuedCard.tier == 3 ? Color.yellow : (queuedCard.tier == 2 ? Color(white: 0.8) : Color.orange.opacity(0.7)))
                                    .frame(width: 55, height: 75)
                                    .shadow(radius: 2)
                                
                                Text(queuedCard.name)
                                    .font(.caption2)
                                    .bold()
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.5)
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)
                                    .padding(2)
                            }
                            
                        } else {
                            // THE EMPTY STATE
                            VStack(spacing: 4) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.gray.opacity(0.4))
                                
                                Text("SLOT \(index + 1)")
                                    .font(.system(size: 9, weight: .heavy))
                                    .foregroundColor(.gray.opacity(0.4))
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                bridge.skipAction()
                                
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                                    actionQueue = bridge.getActionQueue()
                                    currentActionPoints = bridge.getCurrentActionPoints()
                                }
                                
                                checkTurnCompletion()
                            }
                        }
                    }
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: actionQueue)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
            
            // 3. HAND OF CARDS
            HStack(spacing: 5) {
                ForEach(currentHand, id: \.instanceId) { card in
                    SkillCardView(card: card)
                        .onTapGesture {
                            guard let index = currentHand.firstIndex(of: card) else { return }
                            bridge.queueCard(at: index)
                            
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                                currentHand = bridge.getCurrentHand()
                                actionQueue = bridge.getActionQueue()
                                currentActionPoints = bridge.getCurrentActionPoints()
                            }
                            
                            checkTurnCompletion()
                        }
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.1).combined(with: .opacity),
                            removal: .scale(scale: 0.1).combined(with: .opacity)
                        ))
                        
                        .offset(x: draggingCard == card ? dragOffset.width : 0,
                                y: draggingCard == card ? dragOffset.height : 0)
                        .zIndex(draggingCard == card ? 100 : 0)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    if draggingCard == nil { draggingCard = card }
                                    dragOffset = value.translation
                                }
                                .onEnded { value in
                                    guard let currentIndex = currentHand.firstIndex(of: card) else { return }
                                    
                                    let approximateCardWidth = screenWidth / CGFloat(currentHand.count)
                                    let slotsMoved = Int(round(value.translation.width / approximateCardWidth))
                                    
                                    var targetIndex = currentIndex + slotsMoved
                                    targetIndex = max(0, min(currentHand.count - 1, targetIndex))
                                    
                                    if currentIndex != targetIndex {
                                        bridge.moveCard(from: currentIndex, to: targetIndex)
                                    }
                                    
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.6, blendDuration: 0)) {
                                        draggingCard = nil
                                        dragOffset = .zero
                                        currentHand = bridge.getCurrentHand()
                                        currentActionPoints = bridge.getCurrentActionPoints()
                                        actionQueue = bridge.getActionQueue()
                                    }
                                    
                                    checkTurnCompletion()
                                }
                        )
                }
            }
            .padding(.horizontal, 10)
            .frame(height: 180)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentHand)
            
            if currentPhase == 2 {
                // VICTORY SCREEN
                ZStack {
                    Color.black.opacity(0.8).edgesIgnoringSafeArea(.all)
                    VStack(spacing: 20) {
                        Text("VICTORY!")
                            .font(.system(size: 60, weight: .heavy, design: .rounded))
                            .foregroundColor(.yellow)
                            .shadow(color: .orange, radius: 10)
                        
                        Text("The Syndicate has been wiped out.")
                            .foregroundColor(.white)
                            .font(.title3)
                    }
                }
                .transition(.opacity)
            }
            
            if currentPhase == 3 {
                // DEFEAT SCREEN
                ZStack {
                    Color.black.opacity(0.8).edgesIgnoringSafeArea(.all)
                    VStack(spacing: 20) {
                        Text("DEFEAT")
                            .font(.system(size: 60, weight: .heavy, design: .rounded))
                            .foregroundColor(.red)
                            .shadow(color: .black, radius: 10)
                        
                        Text("Carl and Donut were annihilated.")
                            .foregroundColor(.white)
                            .font(.title3)
                    }
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            currentPhase = bridge.getCurrentPhase()
            bridge.startBattle()
            bridge.drawCards(7)
            currentHand = bridge.getCurrentHand()
            playerParty = bridge.getPlayerParty()
            enemyParty = bridge.getEnemyParty()
            currentActionPoints = bridge.getCurrentActionPoints()
            maxActionPoints = bridge.getMaxActionPoints()
            currentTargetIndex = bridge.getCurrentTargetIndex()
        }
    }
}

//#Preview {
//    ContentView()
//}
