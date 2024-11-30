//
//  ContentView.swift
//  Widget Quotes
//
//  Created by Oren Lindsey on 9/1/24.
//

import SwiftUI
import CoreData
let rainbowColors = ["auto", "red", "orange", "yellow", "green", "mint", "teal", "cyan", "blue", "indigo", "purple", "brown", "gray"]
extension AnyGradient: @retroactive View {
    public var body: some View {
        Rectangle().fill(self)
    }
}
struct ContentView: View {
    @State private var showingPopover = false
    @State var content: String = ""
    @State var citation: String = ""
    @State var bgColor: String = "auto"
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) var context
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Widget.timestamp, ascending: true)], animation: .default) private var widgets: FetchedResults<Widget>
    var body: some View {
        NavigationStack {
            List {
                    ForEach(widgets) { widget in
                            HStack {
                                Spacer()
                                HStack {
                                    Text(widget.content ?? "").font(.callout).foregroundStyle(colorScheme == .dark ? .white : .black).padding()
                                    Spacer()
                                }
                                Spacer()
                            }.background(getColorFromName(name: widget.bgColor ?? "").gradient).cornerRadius(10).padding(.vertical, 1)
                    }.onDelete(perform: deleteItems).listRowSeparator(.hidden)
            }.listStyle(.plain).scrollContentBackground(.hidden).navigationTitle("Widget Quotes").toolbar {
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
        }
    }
    @ViewBuilder var newWidgetMenu: some View {
        Text("New Widget")
            .font(.headline)
            .padding()
        Form {
            Section(header: Text("Content")) {
                TextField("Widget content", text: $content, axis: .vertical)
                TextField("Citation (optional)", text: $citation)
            }
            Section(header: Text("Color")) {
                Picker("Select a background color", selection: $bgColor) {
                    ForEach(rainbowColors, id: \.self) {
                        if $0 != "auto" {
                            Text($0).foregroundStyle(getColorFromName(name: $0))
                        } else {
                            Text("default").foregroundStyle(.black)
                        }
                    }
                }.pickerStyle(.wheel)
            }
            Button("Create Widget") {
                add(content: content, citation: citation, bgColor: bgColor)
                showingPopover = false
                content = ""
                citation = ""
                bgColor = "auto"
            }
        }
    }
    private func add(content: String, citation: String, bgColor: String) {
        withAnimation {
            let newItem = Widget(context: context)
            newItem.timestamp = Date()
            newItem.content = content
            newItem.citation = citation
            newItem.bgColor = bgColor
            newItem.id = UUID()
            do {
                try context.save()
                print("Saved")
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
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
