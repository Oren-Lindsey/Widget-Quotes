//
//  ContentView.swift
//  Widget Quotes
//
//  Created by Oren Lindsey on 9/1/24.
//

import SwiftUI
import CoreData
let rainbowColors = ["auto", "red", "orange", "yellow", "green", "mint", "teal", "cyan", "blue", "indigo", "purple", "brown", "gray", "white", "black"]
extension AnyGradient: @retroactive View {
    public var body: some View {
        Rectangle().fill(self)
    }
}
func getColorFromName(name: String) -> Color {
        switch name {
        case "auto": return Color.gray
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
        default: return Color.black
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
struct ContentView: View {
    let fontWeights = ["black", "heavy", "bold", "semibold", "medium", "regular", "light", "thin", "ultralight"]
    @State private var showingPopover = false
    @State var content: String = "Your text here"
    @State var citation: String = "Citation"
    @State var bgColor: String = "red"
    @State var fontSize: Double = 17.0
    @State var fontWeight: String = "regular"
    @State var title: String = ""
    @State var previewColor: String = "red"
    @State var previewText: String = "primary"
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) var context
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Widget.timestamp, ascending: true)], animation: .default) private var widgets: FetchedResults<Widget>
    var body: some View {
        NavigationStack {
            List {
                    ForEach(widgets) { widget in
                        NavigationLink() {
                            WidgetDetail(widget: widget)
                        } label: {
                            HStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(getColorFromName(name: widget.bgColor!).gradient)
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Text(widget.content?.first?.uppercased() ?? "").font(.title).foregroundColor(colorScheme == .dark ? .white : .black)
                                    )
                                Spacer()
                                HStack {
                                    VStack {
                                        HStack {
                                            Text((widget.title != "" ? widget.title : widget.content)!).font(.callout).foregroundStyle(.primary)
                                            Spacer()
                                        }
                                        if widget.citation != nil {
                                            HStack {
                                                Text(widget.citation ?? "").font(.caption).foregroundStyle(.secondary)
                                                Spacer()
                                            }
                                        }
                                    }
                                    Spacer()
                                }
                                Spacer()
                            }
                        }
                    }.onDelete(perform: deleteItems)
            }.listStyle(.plain).scrollContentBackground(.hidden).navigationTitle("Your Widgets").toolbar {
                #if os(iOS)
                    ToolbarItem(placement: .primaryAction) {
                        EditButton()
                    }
                #endif
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingPopover = true
                    } label: {
                        Label("New Widget", systemImage: "plus")
                    }.popover(isPresented: $showingPopover) {
                            newWidgetMenu
                    }
                }
            }
        }.onChange(of: bgColor) {
            if colorScheme == .light && bgColor == "auto" {
                previewColor = "white"
            } else if colorScheme == .dark && bgColor == "auto" {
                previewColor = "black"
            } else {
                previewColor = bgColor
            }
        }.onChange(of: colorScheme) {
            // Special case to handle if someone switches their color scheme while in the editor and using the default color
            if previewColor == "white" {
                previewColor = "black"
            } else if previewColor == "black" {
                previewColor = "white"
            } else {
                previewColor = bgColor
            }
        }.onChange(of: previewColor) {
            if previewColor == "black" {
                previewText = "white"
            } else if previewColor == "white" {
                previewText = "black"
            } else {
                previewText = "primary"
            }
        }
    }
    @ViewBuilder var newWidgetMenu: some View {
        HStack {
            Button("Cancel") {
                showingPopover = false
            }.padding([.leading])
            Spacer()
            Text("New Widget")
                .font(.headline)
                .padding()
            Spacer()
            Button("Create", systemImage: "plus") {
                add(content: content, citation: citation, bgColor: bgColor)
                showingPopover = false
                content = "Your text here"
                citation = "Citation"
                bgColor = "red"
                fontSize = 17.0
                fontWeight = "regular"
                title = ""
            }.padding([.trailing]).disabled(content.isEmpty)
        }
            Form {
                VStack {
                    RoundedRectangle(cornerRadius: 10).fill(getColorFromName(name: previewColor).gradient)
                        .frame(width: 300, height: 300)
                        .overlay(
                            VStack {
                                Spacer()
                                Text(content).font(.system(size: fontSize)).fontWeight(getFontWeightFromName(name: fontWeight)).foregroundStyle(getColorFromName(name: previewText))
                                Spacer()
                                if citation.count > 0 {
                                    Text(citation).font(.system(size: fontSize - 1)).fontWeight(getFontWeightFromName(name: fontWeight)).foregroundStyle(getColorFromName(name: previewText))
                                }
                            }.padding()
                        ).padding([.horizontal], 50)
                }.background(Color(UIColor.systemGroupedBackground)).listRowInsets(EdgeInsets())
                Section(header: Text("Title")) {
                    TextField("Title - This helps you find the widget later.", text: $title)
                }
                Section(header: Text("Content")) {
                    TextField("Widget content", text: $content, axis: .vertical)
                    TextField("Citation (optional)", text: $citation)
                }
                Section(header: Text("Text Styling")) {
                    HStack {
                        Text("Font Size:") //\(Int16(fontSize))
                        Slider(
                            value: $fontSize,
                            in: 0...100,
                            step: 1
                        ) {
                            Text("Font Size")
                        } minimumValueLabel: {
                            Text("0")
                        } maximumValueLabel: {
                            Text("100")
                        }
                    }
                    Picker("Font Weight", selection: $fontWeight) {
                        ForEach(fontWeights, id: \.self) {
                            Text($0).fontWeight(getFontWeightFromName(name: $0))
                        }
                    }.pickerStyle(.menu)
                }
                Section(header: Text("Background Styling")) {
                    Picker("Select a background color", selection: $bgColor) {
                        ForEach(rainbowColors, id: \.self) {
                            if $0 != "auto" {
                                Text($0)
                            } else {
                                Text("default")
                            }
                        }
                    }.pickerStyle(.menu)
                }
            }.navigationTitle("New Widget")
    }
    private func add(content: String, citation: String, bgColor: String) {
        withAnimation {
            let newItem = Widget(context: context)
            newItem.timestamp = Date()
            newItem.content = content
            newItem.citation = citation
            newItem.bgColor = bgColor
            newItem.fontSize = fontSize
            newItem.fontWeight = fontWeight
            newItem.id = UUID()
            newItem.title = title
            do {
                try context.save()
            } catch {
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                print("Error \(nsError.userInfo)")
                //fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        //let context = SharedCoreDataManager.shared.viewContext
        withAnimation {
            offsets.map { widgets[$0] }.forEach(context.delete)

            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
#Preview {
    ContentView()
}
