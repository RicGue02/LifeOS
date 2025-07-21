//
//  HexagonView.swift
//  Life OS
//
//  Created by Ricardo Guerrero Godínez on 21/7/25.
//

import SwiftUI

struct HexagonShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let radius = min(rect.width, rect.height) / 2
            let corners = 6
            
            for i in 0..<corners {
                let angle = (Double(i) * 2 * Double.pi / Double(corners)) - Double.pi / 2
                let x = center.x + CGFloat(cos(angle)) * radius
                let y = center.y + CGFloat(sin(angle)) * radius
                
                if i == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            path.closeSubpath()
        }
    }
}

struct HexagonProgressView: View {
    let dimensions: LifeDimensions
    @State private var animateProgress = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background hexagon
                HexagonShape()
                    .stroke(Color(.systemGray5), lineWidth: 2)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                
                // Grid lines
                ForEach(0..<6) { i in
                    Path { path in
                        let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        let angle = (Double(i) * 2 * Double.pi / 6) - Double.pi / 2
                        let endX = center.x + CGFloat(cos(angle)) * (geometry.size.width / 2)
                        let endY = center.y + CGFloat(sin(angle)) * (geometry.size.height / 2)
                        
                        path.move(to: center)
                        path.addLine(to: CGPoint(x: endX, y: endY))
                    }
                    .stroke(Color(.systemGray6), lineWidth: 1)
                }
                
                // Progress shape
                Path { path in
                    let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    let allDimensions = dimensions.allDimensions
                    
                    for (index, dimension) in allDimensions.enumerated() {
                        let angle = (Double(index) * 2 * Double.pi / 6) - Double.pi / 2
                        let progress = animateProgress ? dimension.score / 100.0 : 0
                        let radius = (geometry.size.width / 2) * progress
                        
                        let x = center.x + CGFloat(cos(angle)) * radius
                        let y = center.y + CGFloat(sin(angle)) * radius
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                    path.closeSubpath()
                }
                .fill(Color.accentColor.opacity(0.3))
                .overlay(
                    Path { path in
                        let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        let allDimensions = dimensions.allDimensions
                        
                        for (index, dimension) in allDimensions.enumerated() {
                            let angle = (Double(index) * 2 * Double.pi / 6) - Double.pi / 2
                            let progress = animateProgress ? dimension.score / 100.0 : 0
                            let radius = (geometry.size.width / 2) * progress
                            
                            let x = center.x + CGFloat(cos(angle)) * radius
                            let y = center.y + CGFloat(sin(angle)) * radius
                            
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                        path.closeSubpath()
                    }
                    .stroke(Color.accentColor, lineWidth: 2)
                )
                
                // Dimension labels and icons
                ForEach(Array(dimensions.allDimensions.enumerated()), id: \.1.id) { index, dimension in
                    let angle = (Double(index) * 2 * Double.pi / 6) - Double.pi / 2
                    let labelRadius = (geometry.size.width / 2) + 30
                    let x = geometry.size.width / 2 + CGFloat(cos(angle)) * labelRadius
                    let y = geometry.size.height / 2 + CGFloat(sin(angle)) * labelRadius
                    
                    VStack(spacing: 4) {
                        Image(systemName: dimension.icon)
                            .font(.title2)
                            .foregroundColor(dimension.color)
                        
                        Text(dimension.name)
                            .font(.caption2)
                            .fontWeight(.medium)
                        
                        Text("\(Int(dimension.score))%")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .position(x: x, y: y)
                }
                
                // Center level display
                VStack(spacing: 4) {
                    Text("Level")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(dimensions.allDimensions.first?.score ?? 0)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("\(Int(dimensions.averageScore))% Overall")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animateProgress = true
            }
        }
    }
}

// Mini version for dashboard
struct MiniHexagonView: View {
    let dimensions: LifeDimensions
    let size: CGFloat
    
    var body: some View {
        ZStack {
            HexagonShape()
                .stroke(Color(.systemGray5), lineWidth: 1)
                .frame(width: size, height: size)
            
            Path { path in
                let center = CGPoint(x: size / 2, y: size / 2)
                let allDimensions = dimensions.allDimensions
                
                for (index, dimension) in allDimensions.enumerated() {
                    let angle = (Double(index) * 2 * Double.pi / 6) - Double.pi / 2
                    let progress = dimension.score / 100.0
                    let radius = (size / 2) * progress
                    
                    let x = center.x + CGFloat(cos(angle)) * radius
                    let y = center.y + CGFloat(sin(angle)) * radius
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                path.closeSubpath()
            }
            .fill(Color.accentColor.opacity(0.3))
            .overlay(
                Path { path in
                    let center = CGPoint(x: size / 2, y: size / 2)
                    let allDimensions = dimensions.allDimensions
                    
                    for (index, dimension) in allDimensions.enumerated() {
                        let angle = (Double(index) * 2 * Double.pi / 6) - Double.pi / 2
                        let progress = dimension.score / 100.0
                        let radius = (size / 2) * progress
                        
                        let x = center.x + CGFloat(cos(angle)) * radius
                        let y = center.y + CGFloat(sin(angle)) * radius
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                    path.closeSubpath()
                }
                .stroke(Color.accentColor, lineWidth: 1)
            )
        }
    }
}