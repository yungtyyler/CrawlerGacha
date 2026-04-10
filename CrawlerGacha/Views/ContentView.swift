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
        ZStack {
            VStack(spacing: 20) {
                // 1. THE ENEMY ROW
                HStack(spacing: 20) {
                    ForEach(Array(enemyParty.enumerated()), id: \.element.characterId) { index, enemy in
                        CharacterSpriteView(character: enemy, isEnemy: true, isTargeted: index == currentTargetIndex)
                            .onTapGesture {
                                if currentPhase != 0 { return }
                                bridge.setTargetIndex(index)
                                withAnimation(.spring(response: 0.3)) {
                                    currentTargetIndex = bridge.getCurrentTargetIndex()
                                }
                            }
                    }
                }
                .padding(.top, 40)
                
                Spacer()
                
                // 2. THE PLAYER ROW
                HStack(spacing: 30) {
                    ForEach(playerParty, id: \.characterId) { player in
                        CharacterSpriteView(character: player, isEnemy: false)
                    }
                }
                
                Spacer()
                
                // 3. ACTION QUEUE (Using our new component)
                ActionQueueView(maxActionPoints: maxActionPoints, actionQueue: actionQueue) {
                    if currentPhase != 0 { return }
                    bridge.skipAction()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                        actionQueue = bridge.getActionQueue()
                        currentActionPoints = bridge.getCurrentActionPoints()
                    }
                    checkTurnCompletion()
                }
                
                // 4. HAND OF CARDS
                HStack(spacing: 5) {
                    ForEach(currentHand, id: \.instanceId) { card in
                        SkillCardView(card: card)
                            .onTapGesture {
                                if currentPhase != 0 { return }
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
                                        if currentPhase != 0 { return }
                                        if draggingCard == nil { draggingCard = card }
                                        dragOffset = value.translation
                                    }
                                    .onEnded { value in
                                        if currentPhase != 0 { return }
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
            }
            
            // --- THE GAME OVER OVERLAYS ---
            GamePhaseOverlay(currentPhase: currentPhase)
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
