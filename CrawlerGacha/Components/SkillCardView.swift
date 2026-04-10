//
//  SkillCardView.swift
//  CrawlerGacha
//
//  Created by Tyler Varzeas on 4/9/26.
//

import SwiftUI

struct SkillCardView: View {
    var card: IOSSkillCard
    
    var body: some View {
        VStack {
            Text(card.name)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.4)
                .foregroundColor(.black)
                .padding(.top, 10)
                .padding(.horizontal, 5)
            
            Spacer()
            
            Text("DMG: \(card.baseDamage)")
                .font(.subheadline)
                .bold()
                .foregroundColor(.black)
            
            Text("Tier \(card.tier)")
                .font(.caption)
                .foregroundColor(.black.opacity(0.7))
                .padding(.bottom, 10)
        }
        .frame(maxWidth: .infinity, idealHeight: 160)
        .background(tierColor)
        .cornerRadius(10)
        .shadow(color: tierColor.opacity(0.5), radius: 3, x: 0, y: 3)
        .contentShape(Rectangle())
    }
    
    private var tierColor: Color {
        switch card.tier {
        case 1: return Color.orange.opacity(0.7)
        case 2: return Color(white: 0.8)
        case 3: return Color.yellow
        default: return Color.white
        }
    }
}
