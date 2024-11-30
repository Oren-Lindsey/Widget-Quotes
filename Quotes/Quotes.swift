//
//  Quotes.swift
//  Quotes
//
//  Created by Oren Lindsey on 9/1/24.
//

import WidgetKit
import SwiftUI
import CoreData
import AppIntents
struct Quote: AppEntity {
    let date: Date
    let timestamp: Date
    let citation: String
    let bgColor: Color
    let id: UUID
    let content: String
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Quote"
    static var defaultQuery = QuotesQuery()
    var displayRepresentation: DisplayRepresentation {
        if citation.count > 0 {
            DisplayRepresentation(title: "\(citation)")
        } else {
            DisplayRepresentation(title: "\(content)")
        }
    }
}
struct QuotesQuery: EntityQuery {
    func entities(for identifiers: [Quote.ID]) async throws -> [Quote] {
        let entries = fetchAllEntries()
        let quotes = entries.map {
            Quote(date: $0.date, timestamp: $0.timestamp, citation: $0.citation, bgColor: $0.bgColor, id: $0.id, content: $0.content)
        }
        return quotes
    }
    func suggestedEntities() async throws -> [Quote] {
        let entries = fetchLatestEntries()
        let quotes = entries.map {
            Quote(date: $0.date, timestamp: $0.timestamp, citation: $0.citation, bgColor: $0.bgColor, id: $0.id, content: $0.content)
        }
        return quotes
    }
    func defaultResult() async throws -> Quote? {
        return try? await suggestedEntities().first
    }
}
struct SelectWidgetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Quote"
    static var description = IntentDescription("Selects the quote to display.")


    @Parameter(title: "Quote", description: "The quote to display.") var quote: Quote
        init(quote: Quote) {
            self.quote = quote
        }


        init() {
        }
}
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
func fetchLatestEntry() -> QuotesEntry? {
    let context = SharedCoreDataManager.shared.viewContext
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
func fetchLatestEntries() -> [QuotesEntry] {
    let context = SharedCoreDataManager.shared.viewContext
    let fetchRequest: NSFetchRequest<Widget> = Widget.fetchRequest()
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]

    do {
        let results = try context.fetch(fetchRequest)
        if !results.isEmpty {
            return results.map {
                QuotesEntry(date: Date(), timestamp: $0.timestamp ?? Date(), content: $0.content ?? "", citation: $0.citation ?? "", bgColor: getColorFromName(name: $0.bgColor!), id: $0.id!)
            }
        }
    } catch {
        print("Error fetching data: \(error)")
    }
    return []
}
func fetchAllEntries() -> [QuotesEntry] {
    let context = SharedCoreDataManager.shared.viewContext
    let fetchRequest: NSFetchRequest<Widget> = Widget.fetchRequest()

    do {
        let results = try context.fetch(fetchRequest)
        if !results.isEmpty {
            return results.map {
                QuotesEntry(date: Date(), timestamp: $0.timestamp ?? Date(), content: $0.content ?? "", citation: $0.citation ?? "", bgColor: getColorFromName(name: $0.bgColor!), id: $0.id!)
            }
        }
    } catch {
        print("Error fetching data: \(error)")
    }
    return []
}
struct Provider: AppIntentTimelineProvider {
    
        let context = SharedCoreDataManager.shared.viewContext

        func placeholder(in context: Context) -> QuotesEntry {
            return QuotesEntry(date: Date(), timestamp: Date(), content: "Loading...", citation: "", bgColor: .red, id: UUID())
        }

        func snapshot(for configuration: SelectWidgetIntent, in context: Context) async -> QuotesEntry {
            let entry = fetchLatestEntry() ?? QuotesEntry(date: Date(), timestamp: Date(), content: "No Data", citation: "", bgColor: .clear, id: UUID())
            return entry
        }

        /*func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
            var entries: [QuotesEntry] = []
            let entry = fetchLatestEntry() ?? QuotesEntry(date: Date(), timestamp: Date(), content: "No Data", citation: "", bgColor: .clear, id: UUID())
            entries.append(entry)

            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }*/
    func timeline(for configuration: SelectWidgetIntent, in context: Context) async -> Timeline<QuotesEntry> {
        let q = configuration.quote
        let entry = QuotesEntry(date: Date(), timestamp: q.timestamp, content: q.content, citation: q.citation, bgColor: q.bgColor, id: q.id)
        let timeline = Timeline(entries: [entry], policy: .never)
        return timeline
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
        AppIntentConfiguration(
                    kind: kind,
                    intent: SelectWidgetIntent.self,
                    provider: Provider()) { entry in
                        QuotesEntryView(entry: entry).containerBackground(entry.bgColor.gradient, for: .widget).padding()
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
