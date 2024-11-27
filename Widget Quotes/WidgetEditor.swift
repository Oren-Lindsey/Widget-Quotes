//
//  WidgetEditor.swift
//  Widget Quotes
//
//  Created by Oren Lindsey on 11/26/24.
//
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
struct WidgetEditor: View {
    var defaults = UserDefaults(suiteName: "group.studio.lindsey.Widget-Quotes.Quotes")
    @State var widgetText: String = ""
    @State var citation: String = ""
    @State var bgColor = "red"
    let rainbowColors = ["red", "orange", "yellow", "green", "mint", "teal", "cyan", "blue", "indigo", "purple", "brown", "gray", "auto"]
    var body: some View {
        VStack {
            Text("Enter Content for Widget:")
                .font(.headline)
            
            TextField("Type something...", text: $widgetText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Text("Enter Citation:")
            TextField("Citation...", text: $citation)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Text("Background Color:")
            Picker("Select a background color", selection: $bgColor) {
                ForEach(rainbowColors, id: \.self) {
                    Text($0).foregroundStyle(getColorFromName(name: $0))
                }
            }.pickerStyle(.wheel).onAppear {
                widgetText = defaults?.string(forKey: "widgetText") ?? ""
                citation = defaults?.string(forKey: "citation") ?? ""
                bgColor = defaults?.string(forKey: "bgColor") ?? "red"
            }
        }
        .padding()
    }
}
#Preview {
    WidgetEditor()
}
