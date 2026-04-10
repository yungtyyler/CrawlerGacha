//
//  ActionQueueView.swift
//  CrawlerGacha
//
//  Created by Tyler Varzeas on 4/9/26.
//

import SwiftUI

struct ActionQueueView: View {
    var maxActionPoints: Int
    var actionQueue: [IOSSkillCard]
    var onSkipTapped: () -> Void
    
    var body: some View {
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
                            RoundedRectangle(cornerRadius: 8).fill(Color.blue.opacity(0.6)).frame(width: 55, height: 75).shadow(radius: 2)
                            VStack(spacing: 5) {
                                Image(systemName: "arrow.left.and.right").font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                                Text("MOVE").font(.system(size: 10, weight: .heavy)).foregroundColor(.white)
                            }
                        } else if queuedCard.cardId == -2 {
                            // THE SKIP RECEIPT
                            RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.6)).frame(width: 55, height: 75).shadow(radius: 2)
                            VStack(spacing: 5) {
                                Image(systemName: "forward.end.fill").font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                                Text("SKIP").font(.system(size: 10, weight: .heavy)).foregroundColor(.white)
                            }
                        } else {
                            // THE NORMAL ATTACK CARD
                            RoundedRectangle(cornerRadius: 8)
                                .fill(queuedCard.tier == 3 ? Color.yellow : (queuedCard.tier == 2 ? Color(white: 0.8) : Color.orange.opacity(0.7)))
                                .frame(width: 55, height: 75).shadow(radius: 2)
                            Text(queuedCard.name).font(.caption2).bold().lineLimit(2).minimumScaleFactor(0.5).foregroundColor(.black).multilineTextAlignment(.center).padding(2)
                        }
                    } else {
                        // THE EMPTY STATE
                        VStack(spacing: 4) {
                            Image(systemName: "xmark").font(.system(size: 16, weight: .bold)).foregroundColor(.gray.opacity(0.4))
                            Text("SLOT \(index + 1)").font(.system(size: 9, weight: .heavy)).foregroundColor(.gray.opacity(0.4))
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onSkipTapped()
                        }
                    }
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: actionQueue)
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
}
