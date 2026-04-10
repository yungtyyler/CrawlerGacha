//
//  GamePhaseOverlay.swift
//  CrawlerGacha
//
//  Created by Tyler Varzeas on 4/9/26.
//

import SwiftUI

struct GamePhaseOverlay: View {
    var currentPhase: Int
    
    var body: some View {
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
        } else if currentPhase == 3 {
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
}
