import Foundation

struct WeatherData: Codable, Sendable {
    let temperature: Double
    let windSpeed: Double
    let windDirection: String
    let humidity: Double
    let conditions: String
    let flyDayRating: String // "good", "marginal", "poor"

    struct Forecast: Codable, Sendable {
        let current: WeatherData
        let days: [ForecastDay]
    }
}

struct ForecastDay: Codable, Identifiable, Sendable {
    let id: String // date
    let date: String
    let high: Double
    let low: Double
    let windSpeed: Double
    let conditions: String
    let flyDayRating: String
}

enum FlyDayRating: String {
    case good, marginal, poor

    init(_ raw: String) {
        self = FlyDayRating(rawValue: raw.lowercased()) ?? .marginal
    }
}
