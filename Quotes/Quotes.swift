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
    let fontSize: Double
    let fontWeight: String
    let title: String
    let tintable: Bool
    let gradient: Bool
    let bgColor2: Color
    let firstColorPos: UnitPoint
    let secondColorPos: UnitPoint
    let font: Font.Design
    let textColor: Color
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Quote"
    static var defaultQuery = QuotesQuery()
    var displayRepresentation: DisplayRepresentation {
        if title.count > 0 {
            DisplayRepresentation(title: "\(title)")
        } else if citation.count > 0 {
            DisplayRepresentation(title: "\(citation)")
        } else {
            DisplayRepresentation(title: "\(content)")
        }
    }
}
func getGradientLocationFromName(name: String) -> UnitPoint {
    switch name {
    case "bottom left": return .bottomLeading
    case "bottom right": return .bottomTrailing
    case "bottom center": return .bottom
    case "left": return .leading
    case "right": return .trailing
    case "top left": return .topLeading
    case "top right": return .topTrailing
    case "top center": return .top
    default: return .bottom
    }
}
func StringFromUIColor(color: UIColor) -> String {
    let components = color.cgColor.components
    return "[\(components![0]), \(components![1]), \(components![2]), \(components![3])]"
    }
struct QuotesQuery: EntityQuery {
    func entities(for identifiers: [Quote.ID]) async throws -> [Quote] {
        let entries = fetchAllEntries()
        let quotes = entries.map {
            Quote(date: $0.date, timestamp: $0.timestamp, citation: $0.citation, bgColor: $0.bgColor, id: $0.id, content: $0.content, fontSize: $0.fontSize, fontWeight: $0.fontWeight, title: $0.title, tintable: $0.tintable, gradient: $0.gradient, bgColor2: getColorFromName(name: $0.bgColor2), firstColorPos: $0.firstColorPos, secondColorPos:$0.secondColorPos, font: $0.font, textColor: $0.textColor)
        }
        return quotes
    }
    func suggestedEntities() async throws -> [Quote] {
        let entries = fetchLatestEntries()
        let quotes = entries.map {
            Quote(date: $0.date, timestamp: $0.timestamp, citation: $0.citation, bgColor: $0.bgColor, id: $0.id, content: $0.content, fontSize: $0.fontSize, fontWeight: $0.fontWeight, title: $0.title, tintable: $0.tintable, gradient: $0.gradient, bgColor2: getColorFromName(name: $0.bgColor2), firstColorPos: $0.firstColorPos, secondColorPos:$0.secondColorPos, font: $0.font, textColor: $0.textColor)
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
func UIColorFromString(string: String) -> UIColor {
        let componentsString = string.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
        let components = componentsString.split(separator: ", ")
        return UIColor(red: CGFloat((components[0] as NSString).floatValue),
                     green: CGFloat((components[1] as NSString).floatValue),
                      blue: CGFloat((components[2] as NSString).floatValue),
                     alpha: CGFloat((components[3] as NSString).floatValue))
    }
func getColorFromName(name: String) -> Color {
        switch name {
        case "dynamic": return Color.gray
        case "gray": return Color.gray
        case "white": return Color.white
        case "black": return Color.black
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
        case "primary": return Color.primary
        default: return Color(UIColorFromString(string: name))
        }
}
func getFontWeightFromName(name: String) -> Font.Weight {
    switch name {
        case "black": return .black
        case "heavy": return .heavy
        case "bold": return .bold
        case "semibold": return .semibold
        case "medium": return .medium
        case "regular": return .regular
        case "light": return .light
        case "thin": return .thin
        case "ultralight": return .ultraLight
        default: return .regular
    }
}
func fontFromName(name: String) -> Font.Design {
    switch name {
    case "default": return Font.Design.default
    case "monospaced": return Font.Design.monospaced
    case "rounded": return Font.Design.rounded
    case "serif": return Font.Design.serif
    default: return Font.Design.default
    }
}
struct QuotesEntry: TimelineEntry {
    var date: Date
    var timestamp: Date
    let content: String
    let citation: String
    let bgColor: Color
    let id: UUID
    let fontSize: Double
    let fontWeight: String
    let title: String
    let tintable: Bool
    let gradient: Bool
    let bgColor2: String
    let firstColorPos: UnitPoint
    let secondColorPos: UnitPoint
    let font: Font.Design
    let textColor: Color
}
func fetchLatestEntry() -> QuotesEntry? {
    let context = SharedCoreDataManager.shared.viewContext
    let fetchRequest: NSFetchRequest<Widget> = Widget.fetchRequest()
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
    fetchRequest.fetchLimit = 1

    do {
        let results = try context.fetch(fetchRequest)
        if let latest = results.first {
            return QuotesEntry(date: Date(), timestamp: latest.timestamp ?? Date(), content: latest.content ?? "", citation: latest.citation ?? "", bgColor: getColorFromName(name: latest.bgColor!), id: UUID(), fontSize: latest.fontSize, fontWeight: latest.fontWeight ?? "regular", title: "", tintable: true, gradient: latest.gradient, bgColor2: latest.bgColor2 ?? "red", firstColorPos: getGradientLocationFromName(name: latest.firstColorPos ?? "top center"), secondColorPos: getGradientLocationFromName(name: latest.secondColorPos ?? "bottom center"), font: fontFromName(name: latest.font ?? "default"), textColor: getColorFromName(name: latest.textColor ?? "black"))
        }
    } catch {
        print("Error fetching data: \(error)")
    }
    return QuotesEntry(date: Date(), timestamp: Date(), content: "No Data", citation: "", bgColor: .clear, id: UUID(), fontSize: 12.0, fontWeight: "regular", title: "", tintable: true, gradient: false, bgColor2: "red", firstColorPos: .top, secondColorPos: .bottom, font: Font.Design.default, textColor: Color.primary)
}
func fetchLatestEntries() -> [QuotesEntry] {
    let context = SharedCoreDataManager.shared.viewContext
    let fetchRequest: NSFetchRequest<Widget> = Widget.fetchRequest()
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]

    do {
        let results = try context.fetch(fetchRequest)
        if !results.isEmpty {
            return results.map {
                QuotesEntry(date: Date(), timestamp: $0.timestamp ?? Date(), content: $0.content ?? "", citation: $0.citation ?? "", bgColor: getColorFromName(name: $0.bgColor!), id: $0.id!, fontSize: $0.fontSize, fontWeight: $0.fontWeight ?? "regular", title: $0.title ?? "", tintable: $0.tintable, gradient: $0.gradient, bgColor2: $0.bgColor2 ?? "red", firstColorPos: getGradientLocationFromName(name: $0.firstColorPos ?? "top center"), secondColorPos: getGradientLocationFromName(name: $0.secondColorPos ?? "bottom center"), font: fontFromName(name: $0.font ?? "default"), textColor: getColorFromName(name: $0.textColor ?? "black"))
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
                //QuotesEntry(date: Date(), timestamp: $0.timestamp ?? Date(), content: $0.content ?? "", citation: $0.citation ?? "", bgColor: getColorFromName(name: $0.bgColor!), id: $0.id!, fontSize: $0.fontSize, fontWeight: $0.fontWeight ?? "regular", title: $0.title ?? "", tintable: $0.tintable)
                QuotesEntry(date: Date(), timestamp: $0.timestamp ?? Date(), content: $0.content ?? "", citation: $0.citation ?? "", bgColor: getColorFromName(name: $0.bgColor!), id: $0.id!, fontSize: $0.fontSize, fontWeight: $0.fontWeight ?? "regular", title: $0.title ?? "", tintable: $0.tintable, gradient: $0.gradient, bgColor2: $0.bgColor2 ?? "red", firstColorPos: getGradientLocationFromName(name: $0.firstColorPos ?? "top center"), secondColorPos: getGradientLocationFromName(name: $0.secondColorPos ?? "bottom center"), font: fontFromName(name: $0.font ?? "default"), textColor: getColorFromName(name: $0.textColor ?? "black"))
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
            return QuotesEntry(date: Date(), timestamp: Date(), content: "No Data", citation: "", bgColor: .clear, id: UUID(), fontSize: 12.0, fontWeight: "regular", title: "", tintable: true, gradient: false, bgColor2: "red", firstColorPos: .top, secondColorPos: .bottom, font: Font.Design.default, textColor: Color.primary)
        }

        func snapshot(for configuration: SelectWidgetIntent, in context: Context) async -> QuotesEntry {
            let entry = fetchLatestEntry() ?? QuotesEntry(date: Date(), timestamp: Date(), content: "No Data", citation: "", bgColor: .clear, id: UUID(), fontSize: 12.0, fontWeight: "regular", title: "", tintable: true, gradient: false, bgColor2: "red", firstColorPos: .top, secondColorPos: .bottom, font: Font.Design.default, textColor: Color.primary)
            return entry
        }
    func timeline(for configuration: SelectWidgetIntent, in context: Context) async -> Timeline<QuotesEntry> {
        let q = configuration.quote
        let entry = QuotesEntry(date: Date(), timestamp: q.timestamp, content: q.content, citation: q.citation, bgColor: q.bgColor, id: q.id, fontSize: q.fontSize, fontWeight: q.fontWeight, title: q.title, tintable: q.tintable, gradient: q.gradient, bgColor2: StringFromUIColor(color: UIColor(q.bgColor2)), firstColorPos: q.firstColorPos, secondColorPos: q.secondColorPos, font: q.font, textColor: q.textColor)
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
            Text(entry.content).font(.system(size: entry.fontSize, design: entry.font)).fontWeight(getFontWeightFromName(name: entry.fontWeight)).widgetAccentable(entry.tintable).foregroundStyle(entry.textColor)
        case .accessoryRectangular:
            VStack {
                Text(entry.content).font(.system(size: entry.fontSize, design: entry.font)).fontWeight(getFontWeightFromName(name: entry.fontWeight)).foregroundStyle(entry.textColor)
                if entry.citation != "" {
                    Text(entry.citation).font(.system(size: entry.fontSize - 1, design: entry.font)).fontWeight(getFontWeightFromName(name: entry.fontWeight)).foregroundStyle(entry.textColor)
                }
            }.widgetAccentable(entry.tintable)
        case .accessoryInline:
            Text(entry.content).font(.system(size: entry.fontSize, design: entry.font)).fontWeight(getFontWeightFromName(name: entry.fontWeight)).widgetAccentable(entry.tintable).foregroundStyle(entry.textColor)
        case .systemSmall:
            VStack {
                Spacer()
                Text(entry.content).font(.system(size: entry.fontSize, design: entry.font)).fontWeight(getFontWeightFromName(name: entry.fontWeight)).widgetAccentable(entry.tintable).foregroundStyle(entry.textColor)
                Spacer()
                if entry.citation != "" {
                    Text(entry.citation).font(.system(size: entry.fontSize - 1, design: entry.font)).fontWeight(getFontWeightFromName(name: entry.fontWeight)).foregroundStyle(entry.textColor)
                }
            }
        case .systemLarge:
            VStack {
                Spacer()
                Text(entry.content).font(.system(size: entry.fontSize, design: entry.font)).fontWeight(getFontWeightFromName(name: entry.fontWeight)).widgetAccentable(entry.tintable).foregroundStyle(entry.textColor)
                Spacer()
                if entry.citation != "" {
                    Text(entry.citation).font(.system(size: entry.fontSize - 1, design: entry.font)).fontWeight(getFontWeightFromName(name: entry.fontWeight)).foregroundStyle(entry.textColor)
                }
            }
        case .systemMedium:
            VStack {
                Spacer()
                Text(entry.content).font(.system(size: entry.fontSize, design: entry.font)).fontWeight(getFontWeightFromName(name: entry.fontWeight)).widgetAccentable(entry.tintable).foregroundStyle(entry.textColor)
                Spacer()
                if entry.citation != "" {
                    Text(entry.citation).font(.system(size: entry.fontSize - 1, design: entry.font)).fontWeight(getFontWeightFromName(name: entry.fontWeight)).foregroundStyle(entry.textColor)
                }
            }
        case .systemExtraLarge:
            VStack {
                Spacer()
                Text(entry.content).font(.system(size: entry.fontSize, design: entry.font)).fontWeight(getFontWeightFromName(name: entry.fontWeight)).widgetAccentable(entry.tintable).foregroundStyle(entry.textColor)
                Spacer()
                if entry.citation != "" {
                    Text(entry.citation).font(.system(size: entry.fontSize - 1, design: entry.font)).fontWeight(getFontWeightFromName(name: entry.fontWeight)).foregroundStyle(entry.textColor)
                }
            }
        default:
            VStack {
                Spacer()
                Text(entry.content).font(.system(size: entry.fontSize, design: entry.font)).fontWeight(getFontWeightFromName(name: entry.fontWeight)).widgetAccentable(entry.tintable).foregroundStyle(entry.textColor)
                Spacer()
                if entry.citation != "" {
                    Text(entry.citation).font(.system(size: entry.fontSize - 1, design: entry.font)).fontWeight(getFontWeightFromName(name: entry.fontWeight)).foregroundStyle(entry.textColor)
                }
            }
        }
    }
}
@main
struct Quotes: SwiftUI.Widget {
    let kind: String = "Quotes"
    @Environment(\.colorScheme) var colorScheme
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
                    kind: kind,
                    intent: SelectWidgetIntent.self,
                    provider: Provider()) { entry in
                        QuotesEntryView(entry: entry).containerBackground(entry.gradient ? AnyShapeStyle(LinearGradient(colors: [entry.bgColor, Color(UIColorFromString(string: entry.bgColor2))], startPoint: entry.firstColorPos, endPoint: entry.secondColorPos)) : AnyShapeStyle(entry.bgColor.gradient), for: .widget).padding()
                }
        .configurationDisplayName("Quote")
        .description("Displays customizable text.")
        #if os(watchOS)
        .supportedFamilies([.accessoryCircular,
                            .accessoryRectangular, .accessoryInline])
        #else
        .supportedFamilies([.accessoryCircular,
                            .accessoryRectangular, .accessoryInline,
                            .systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
        #endif
    }
}
