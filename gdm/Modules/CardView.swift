//
//  CardView.swift
//  gdm
//
//  Created by Anatoliy Podkladov on 01.06.2025.
//

import SwiftUI

/// Современная карточка для группировки связанного контента
struct CardView<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Card Header
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.accentColor)
                    .frame(width: 20, height: 20)
                
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            // Card Content
            content
        }
        .padding(.all, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator).opacity(0.2), lineWidth: 0.5)
        )
    }
}

#Preview("CardView") {
    VStack(spacing: 16) {
        CardView(title: "Основные данные", icon: "calendar.badge.clock") {
            VStack(spacing: 12) {
                Text("Содержимое карточки")
                    .foregroundColor(.secondary)
                
                Button("Кнопка") {
                    // Action
                }
                .buttonStyle(.borderedProminent)
            }
        }
        
        CardView(title: "Инсулин", icon: "syringe.fill") {
            Text("Другое содержимое")
                .foregroundColor(.secondary)
        }
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
