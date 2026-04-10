//
//  HealthBarView.swift
//  CrawlerGacha
//
//  Created by Tyler Varzeas on 4/9/26.
//

import SwiftUI

struct HealthBarView: View {
    var health: Int
    var maxHealth: Int
    
    var percent: Double {
        return maxHealth > 0 ? Double(health) / Double(maxHealth) : 0
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .frame(width: 80, height: 10)
                .foregroundColor(.black.opacity(0.3))
            
            Capsule()
                .frame(width: 80 * CGFloat(max(0, percent)), height: 10)
                .foregroundColor(percent > 0.3 ? .green : .red)
                .animation(.spring(), value: percent)
        }
    }
}
