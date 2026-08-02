import SwiftUI

struct WeatherCard: View {
    let weather: WeatherData
    let forecastDays: [ForecastDay]
    @State private var isExpanded = false

    var body: some View {
        CardView {
            Button {
                withAnimation(.snappy) { isExpanded.toggle() }
            } label: {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Weather at the Field")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("\(Int(weather.temperature.rounded()))°")
                            .font(.system(size: 40, weight: .bold))
                        Text(weather.conditions)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 8) {
                        FlyDayIndicator(rating: FlyDayRating(weather.flyDayRating))
                        VStack(alignment: .trailing, spacing: 2) {
                            Label("\(Int(weather.windSpeed.rounded())) mph \(weather.windDirection)", systemImage: "wind")
                            Label("\(Int(weather.humidity.rounded()))%", systemImage: "humidity")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }
            }
            .buttonStyle(.plain)

            if isExpanded && !forecastDays.isEmpty {
                Divider()
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(forecastDays) { day in
                            VStack(spacing: 6) {
                                Text(day.date.asDate?.formatted(.dateTime.weekday(.abbreviated)) ?? day.date)
                                    .font(.caption.weight(.medium))
                                FlyDayIndicator(rating: FlyDayRating(day.flyDayRating), compact: true)
                                Text("\(Int(day.high.rounded()))° / \(Int(day.low.rounded()))°")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
    }
}
