//
//  WeatherWidget.swift
//  Life OS
//
//  Created by Assistant on 22/7/25.
//

import SwiftUI
import CoreLocation

struct WeatherData {
    let temperature: Int
    let condition: String
    let icon: String
    let humidity: Int
    let windSpeed: Double
    let location: String
}

struct WeatherWidget: View {
    @State private var weather: WeatherData?
    @State private var isLoading = true
    @State private var locationManager = CLLocationManager()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if isLoading {
                // Loading state
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Loading weather...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else if let weather = weather {
                // Weather display
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(weather.location)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: getWeatherIcon(weather.icon))
                                .font(.title)
                                .foregroundColor(getWeatherIconColor(weather.icon))
                            
                            Text("\(weather.temperature)°")
                                .font(.largeTitle)
                                .fontWeight(.semibold)
                        }
                        
                        Text(weather.condition)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: "humidity")
                                .font(.caption2)
                            Text("\(weather.humidity)%")
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "wind")
                                .font(.caption2)
                            Text("\(Int(weather.windSpeed)) m/s")
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                }
                .padding()
            } else {
                // Error state
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.icloud")
                        .font(.title2)
                        .foregroundColor(.gray)
                    Text("Weather unavailable")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
        }
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.1),
                    Color.blue.opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .onAppear {
            loadWeather()
        }
    }
    
    private func getWeatherIcon(_ condition: String) -> String {
        switch condition.lowercased() {
        case let x where x.contains("clear"):
            return "sun.max"
        case let x where x.contains("cloud"):
            return "cloud"
        case let x where x.contains("rain"):
            return "cloud.rain"
        case let x where x.contains("drizzle"):
            return "cloud.drizzle"
        case let x where x.contains("snow"):
            return "cloud.snow"
        case let x where x.contains("thunder"):
            return "cloud.bolt"
        case let x where x.contains("fog"), let x where x.contains("mist"):
            return "cloud.fog"
        default:
            return "cloud"
        }
    }
    
    private func getWeatherIconColor(_ condition: String) -> Color {
        switch condition.lowercased() {
        case let x where x.contains("clear"):
            return .yellow
        case let x where x.contains("rain"), let x where x.contains("drizzle"):
            return .blue
        case let x where x.contains("snow"):
            return .cyan
        case let x where x.contains("thunder"):
            return .purple
        default:
            return .gray
        }
    }
    
    private func loadWeather() {
        // Mock weather data for now
        // In a real app, you'd fetch from a weather API
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            weather = WeatherData(
                temperature: 22,
                condition: "Partly cloudy",
                icon: "cloud",
                humidity: 65,
                windSpeed: 12,
                location: "San Francisco"
            )
            isLoading = false
        }
    }
}