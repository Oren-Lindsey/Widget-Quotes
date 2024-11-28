//
//  Quotes.swift
//  Quotes
//
//  Created by Oren Lindsey on 9/1/24.
//

import WidgetKit
import SwiftUI
import CoreData
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

struct QuotesEntry: TimelineEntry {
    var date: Date
    var timestamp: Date
    let content: String
    let citation: String
    let bgColor: Color
    let id: UUID
}
struct Provider: TimelineProvider {
        let context = SharedCoreDataManager.shared.viewContext
        //@FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Widget.timestamp, ascending: true)], animation: .default) private var widgets: FetchedResults<Widget>
        /*private func fetchLatestEntry() -> QuotesEntry? {
            let fetchRequest: NSFetchRequest<Widget> = Widget.fetchRequest()
            fetchRequest.fetchLimit = 1
            do {
                let latest = try context.fetch(fetchRequest).first
                if latest == nil { return nil }
                return QuotesEntry(date: Date(), timestamp: latest!.timestamp ?? Date(), content: latest!.content ?? "", citation: latest!.citation ?? "", bgColor: getColorFromName(name: latest!.bgColor!), id: UUID())
            } catch {
                print("Error fetching data: \(error)")
            }
            return nil
        }*/
    private func fetchLatestEntry() -> QuotesEntry? {
        let fetchRequest: NSFetchRequest<Widget> = Widget.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        fetchRequest.fetchLimit = 1

        do {
            let results = try context.fetch(fetchRequest)
            if let latest = results.first {
                return QuotesEntry(date: Date(), timestamp: latest.timestamp ?? Date(), content: latest.content ?? "", citation: latest.citation ?? "", bgColor: getColorFromName(name: latest.bgColor!), id: UUID())
            }
        } catch {
            print("Error fetching data: \(error)")
        }
        return QuotesEntry(date: Date(), timestamp: Date(), content: "No Data", citation: "", bgColor: .clear, id: UUID())
    }

        func placeholder(in context: Context) -> QuotesEntry {
            return QuotesEntry(date: Date(), timestamp: Date(), content: "Loading...", citation: "", bgColor: .red, id: UUID())
        }

        func getSnapshot(in context: Context, completion: @escaping (QuotesEntry) -> ()) {
            let entry = fetchLatestEntry() ?? QuotesEntry(date: Date(), timestamp: Date(), content: "No Data", citation: "", bgColor: .clear, id: UUID())
            return completion(entry)
        }

        func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
            var entries: [QuotesEntry] = []
            let entry = fetchLatestEntry() ?? QuotesEntry(date: Date(), timestamp: Date(), content: "No Data", citation: "", bgColor: .clear, id: UUID())
            entries.append(entry)

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
                QuotesEntryView(entry: entry).containerBackground(entry.bgColor.gradient, for: .widget).padding()
            } else {
                QuotesEntryView(entry: entry)
                    .padding()
            }
        }
        .configurationDisplayName("Quote")
        .description("Displays customizable text.")
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
