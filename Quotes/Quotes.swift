//
//  Quotes.swift
//  Quotes
//
//  Created by Oren Lindsey on 9/1/24.
//

import WidgetKit
import SwiftUI
func getColorFromName(name: String) -> Color {
        switch name {
        case "auto": return Color.white
        case "gray": return Color.gray
        case "white": return Color.white
        case "red": return Color.red
        case "green": return Color.green
        case "mint": return Color.mint
        case "teal": return Color.teal
        case "blue": return Color.blue
        case "cyan": return Color.cyan
        case "yellow": return Color.yellow
        case "pink": return Color.pink
        case "orange": return Color.orange
        case "purple": return Color.purple
        case "indigo": return Color.indigo
        case "brown": return Color.brown
        default: return Color.black
        }
}
extension UserDefaults {

    func color(forKey key: String) -> Color? {
        var color: Color?
        if let colorData = data(forKey: key) {
            color = NSKeyedUnarchiver.unarchiveObject(with: colorData) as? Color
        }
        return color
    }

    func set(_ value: Color?, forKey key: String) {
        var colorData: Data?
        if let color = value {
            colorData = NSKeyedArchiver.archivedData(withRootObject: color)
        }
        set(colorData, forKey: key)
    }

}
struct QuotesEntry: TimelineEntry {
    var date: Date
    var timestamp: Date
    let content: String
    let citation: String
    let bgColor: Color
    let id: UUID
}
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> QuotesEntry {
        QuotesEntry(date: Date(), timestamp: Date(), content: "Quote Here", citation: "", bgColor: Color(UIColor.tertiarySystemFill), id: UUID())
    }

    func getSnapshot(in context: Context, completion: @escaping (QuotesEntry) -> ()) {
        let entry = QuotesEntry(date: Date(), timestamp: Date(), content: "Quote Here", citation: "", bgColor: Color(UIColor.tertiarySystemFill), id: UUID())
        completion(entry)
    }
    func getQuote() -> String {
        return "e"
    }
    func getCitation() -> String {
        // make sure you use your app group identifier as the suitname
        return ""
    }
    func getColor() -> Color {
        return(Color(UIColor.tertiarySystemFill))
    }
    func getID() -> UUID {
        return UUID()
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [QuotesEntry] = []
        for _ in 0 ..< 5 {
            let currentDate = Date()
            let widgetMessage: String = getQuote()
            let citation: String = getCitation()
            let color: Color = getColor()
            let id: UUID = getID()
            let entry = QuotesEntry(date: currentDate, timestamp: currentDate, content: widgetMessage, citation: citation, bgColor: color, id: id)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct QuotesEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family


        @ViewBuilder
    var body: some View {
        switch family {
        case .accessoryCircular:
            Text(entry.content).font(.system(size: 10))
        case .accessoryRectangular:
            VStack {
                if entry.content.count > 25 {
                    Text(entry.content).font(.system(size: 10))
                } else {
                    Text(entry.content)
                }
                if entry.citation != "" {
                    Text(entry.citation).font(.system(size: 10))
                }
            }
        case .accessoryInline:
            Text(entry.content)
        case .systemSmall:
            VStack {
                Spacer()
                Text(entry.content).font(.callout)
                Spacer()
                if entry.citation != "" {
                    Text(entry.citation).font(.caption)
                }
            }
        case .systemLarge:
            VStack {
                Spacer()
                Text(entry.content).font(.callout)
                Spacer()
                if entry.citation != "" {
                    Text(entry.citation).font(.caption)
                }
            }
        case .systemMedium:
            VStack {
                Spacer()
                Text(entry.content).font(.callout)
                Spacer()
                if entry.citation != "" {
                    Text(entry.citation).font(.caption)
                }
            }
        default:
            VStack {
                Spacer()
                Text(entry.content).font(.callout)
                Spacer()
                if entry.citation != "" {
                    Text(entry.citation).font(.caption)
                }
            }
        }
    }
}
@main
struct Quotes: SwiftUI.Widget {
    let kind: String = "Quotes"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                QuotesEntryView(entry: entry).containerBackground(entry.bgColor.gradient, for: .widget)
            } else {
                QuotesEntryView(entry: entry)
                    .padding()
            }
        }
        .configurationDisplayName("Quote")
        .description("Displays a customizable quote.")
        #if os(watchOS)
        .supportedFamilies([.accessoryCircular,
                            .accessoryRectangular, .accessoryInline])
        #else
        .supportedFamilies([.accessoryCircular,
                            .accessoryRectangular, .accessoryInline,
                            .systemSmall, .systemMedium, .systemLarge])
        #endif
    }
}
