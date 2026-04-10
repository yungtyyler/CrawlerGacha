//
//  CharacterSpriteView.swift
//  CrawlerGacha
//
//  Created by Tyler Varzeas on 4/9/26.
//

import SwiftUI

struct CharacterSpriteView: View {
    var character: IOSCharacter
    var isEnemy: Bool = false
    var isTargeted: Bool = false
    
    var body: some View {
        VStack(spacing: 8) {
            HealthBarView(health: Int(character.health), maxHealth: Int(character.maxHealth))
            
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(isEnemy ? Color.red.opacity(0.8) : Color.blue.opacity(0.8))
                    .frame(width: 80, height: 80)
                    .shadow(radius: 3)
                    .opacity(character.health > 0 ? 1.0 : 0.3)
                    .grayscale(character.health > 0 ? 0.0 : 1.0)
                
                Text(character.name)
                    .font(.caption)
                    .bold()
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(4)
                
                if isEnemy && isTargeted && character.health > 0 {
                    Image(systemName: "scope")
                        .font(.system(size: 40, weight: .thin))
                        .foregroundColor(.yellow)
                        .shadow(color: .black, radius: 2)
                }
            }
        }
    }
}
