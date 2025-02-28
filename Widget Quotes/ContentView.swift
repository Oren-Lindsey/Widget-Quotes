//
//  ContentView.swift
//  Widget Quotes
//
//  Created by Oren Lindsey on 9/1/24.
//

import SwiftUI
import CoreData
import Foundation
import CoreMotion
extension AnyGradient: @retroactive View {
    public var body: some View {
        Rectangle().fill(self)
    }
}
func StringFromUIColor(color: UIColor) -> String {
    let components = color.cgColor.components
    return "[\(components![0]), \(components![1]), \(components![2]), \(components![3])]"
    }
    
func UIColorFromString(string: String) -> UIColor {
        let componentsString = string.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
        let components = componentsString.split(separator: ", ")
        if components.count > 0 {
            return UIColor(red: CGFloat((components[0] as NSString).floatValue),
                           green: CGFloat((components[1] as NSString).floatValue),
                           blue: CGFloat((components[2] as NSString).floatValue),
                           alpha: CGFloat((components[3] as NSString).floatValue))
        } else {
            return UIColor(Color.primary)
        }
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
func fontFromName(name: String) -> Font.Design {
    switch name {
    case "default": return Font.Design.default
    case "monospaced": return Font.Design.monospaced
    case "rounded": return Font.Design.rounded
    case "serif": return Font.Design.serif
    default: return Font.Design.default
    }
}
extension View {
    func `if`<Content: View>(_ conditional: Bool, content: (Self) -> Content) -> some View {
        if conditional {
            return AnyView(content(self))
        } else {
            return AnyView(self)
        }
    }
}
struct ContentView: View {
    let fontWeights = ["black", "heavy", "bold", "semibold", "medium", "regular", "light", "thin", "ultralight"]
    let gradientLocations = ["bottom left", "bottom right", "bottom center", "left", "right", "top left", "top right", "top center"]
    //let fontModifiers = ["regular", "bold", "italic", "monospaced", "monospaced digit", "small caps", "lowercase small caps", "uppercase small caps"]
    let fonts = ["default", "monospaced", "rounded", "serif"]
    let motionManager = CMMotionManager()
    @State private var showingPopover = false
    @State var content: String = "Your text here"
    @State var citation: String = "Citation"
    @State var fontSize: Double = 17.0
    @State var fontWeight: String = "regular"
    @State var title: String = ""
    //@State var previewText: String = "primary"
    @State var customColorCode: Color = Color.red
    @State var tintable: Bool = true
    @State var gradientColorCode: Color = Color.blue
    @State var gradientMode: Bool = false
    @State var firstColorPos: String = "top center"
    @State var secondColorPos: String = "bottom center"
    @State var roll: Double = 0
    @State var pitch: Double = 0
    @State var font: String = "default"
    @State var fontColor: Color = Color.primary
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) var context
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Widget.timestamp, ascending: true)], animation: .default) private var widgets: FetchedResults<Widget>
    func fetchMotionData() {
        if motionManager.isDeviceMotionAvailable {
           motionManager.deviceMotionUpdateInterval = 0.01
           motionManager.startDeviceMotionUpdates(to: .main) { motion, _ in
               if let motion {
                   roll = motion.attitude.roll
                   pitch = motion.attitude.pitch
               }
           }
        }
    }
    var body: some View {
        NavigationStack {
            List {
                    ForEach(widgets) { widget in
                        NavigationLink() {
                            WidgetDetail(widget: widget)
                        } label: {
                            HStack {
                                let startPoint = getGradientLocationFromName(name: widget.firstColorPos ?? "top center")
                                let endPoint = getGradientLocationFromName(name: widget.secondColorPos ?? "bottom center")
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(widget.gradient ? AnyShapeStyle(LinearGradient(colors: [Color(UIColorFromString(string: widget.bgColor!)), Color(UIColorFromString(string: widget.bgColor2!))], startPoint: startPoint, endPoint: endPoint)) : AnyShapeStyle(getColorFromName(name: widget.bgColor!).gradient))
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Text(widget.content?.first?.uppercased() ?? "").font(.system(.title, design: fontFromName(name: widget.font ?? "default"))).foregroundColor(Color(UIColorFromString(string: widget.textColor ?? "")))
                                    )
                                Spacer()
                                HStack {
                                    VStack {
                                        HStack {
                                            Text((widget.title != "" ? widget.title : widget.content) ?? "No title").font(.callout).foregroundStyle(.primary)
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
                    }.onDelete(perform: deleteItems).onAppear() {
                        fetchMotionData()
                    }
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
        }
    }
    @ViewBuilder var newWidgetMenu: some View {
        let gradient = RadialGradient(gradient: Gradient(colors: [.white.opacity(0.15), .white.opacity(0.1), .white.opacity(0.05), .clear]), center: .center, startRadius: 0, endRadius: 200)
        HStack {
            Button("Cancel") {
                showingPopover = false
                content = "Your text here"
                citation = "Citation"
                customColorCode = Color.red
                fontSize = 17.0
                fontWeight = "regular"
                title = ""
            }.padding([.leading]).tint(customColorCode)
            Spacer()
            Text("New Widget")
                .font(.headline)
                .padding()
            Spacer()
            Button("Create", systemImage: "plus") {
                add(content: content, citation: citation)
                showingPopover = false
                content = "Your text here"
                citation = "Citation"
                customColorCode = Color.red
                fontSize = 17.0
                fontWeight = "regular"
                title = ""
                font = "default"
                fontColor = Color.primary
            }.padding([.trailing]).disabled(content.isEmpty).tint(customColorCode)
        }
            Form {
                VStack {
                    let startPoint = getGradientLocationFromName(name: firstColorPos)
                    let endPoint = getGradientLocationFromName(name: secondColorPos)
                    let pitchDegrees = -pitch * 180 / .pi
                    let rollDegrees = -roll * 180 / .pi
                    ZStack {
                        RoundedRectangle(cornerRadius: 10).fill(colorScheme == .dark ? Color.black : Color.white)
                            .frame(width: 300, height: 300).rotation3DEffect(
                                .degrees(rollDegrees / 7), axis: (x: 0.0, y: 1.0, z: 0.0), anchor: .center, anchorZ: 0.0, perspective: 1.0
                            ).rotation3DEffect(
                                .degrees(pitchDegrees / 7), axis: (x: -1, y: 0.0, z: 0.0), anchor: .center, anchorZ: 0.0, perspective: 1.0
                            )
                        RoundedRectangle(cornerRadius: 10).fill(gradientMode ? AnyShapeStyle(LinearGradient(colors: [customColorCode, gradientColorCode], startPoint: startPoint, endPoint: endPoint)) : AnyShapeStyle(customColorCode.gradient))
                            .frame(width: 300, height: 300)
                            .overlay(
                                VStack {
                                    Spacer()
                                    Text(content).font(.system(size: fontSize, design: fontFromName(name: font))).fontWeight(getFontWeightFromName(name: fontWeight)).foregroundColor(fontColor)
                                    Spacer()
                                    if citation.count > 0 {
                                        Text(citation).font(.system(size: fontSize - 1, design: fontFromName(name: font))).fontWeight(getFontWeightFromName(name: fontWeight)).foregroundColor(fontColor)
                                    }
                                }.padding()
                            ).rotation3DEffect(
                                .degrees(rollDegrees / 7), axis: (x: 0.0, y: 1.0, z: 0.0), anchor: .center, anchorZ: 0.0, perspective: 1.0
                            ).rotation3DEffect(
                                .degrees(pitchDegrees / 7), axis: (x: -1, y: 0.0, z: 0.0), anchor: .center, anchorZ: 0.0, perspective: 1.0
                            ).padding([.horizontal], 50).shadow(radius: 7, x: 5, y: 10)
                        gradient.frame(width: 400, height: 350).rotationEffect(.degrees(20)).offset(x: -rollDegrees * 9, y: -pitchDegrees * 9).mask {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 300, height: 300)
                                .rotation3DEffect(
                                    .degrees(rollDegrees / 7), axis: (x: 0.0, y: 1.0, z: 0.0), anchor: .center, anchorZ: 0.0, perspective: 1.0
                                ).rotation3DEffect(
                                    .degrees(pitchDegrees / 7), axis: (x: -1, y: 0.0, z: 0.0), anchor: .center, anchorZ: 0.0, perspective: 1.0
                                ).padding([.horizontal], 50).padding([.vertical], 20).shadow(radius: 7, x: 5, y: 10)
                        }.rotation3DEffect(
                            .degrees(rollDegrees / 7), axis: (x: 0.0, y: 1.0, z: 0.0), anchor: .center, anchorZ: 0.0, perspective: 1.0
                        ).rotation3DEffect(
                            .degrees(pitchDegrees / 7), axis: (x: -1, y: 0.0, z: 0.0), anchor: .center, anchorZ: 0.0, perspective: 1.0
                        )
                    }
                    Text("Preview").foregroundStyle(Color.gray)
                }.background(Color(UIColor.systemGroupedBackground)).listRowInsets(EdgeInsets()).zIndex(0)
                Section(header: Text("Title")) {
                    TextField("Title - This helps you find the widget later.", text: $title)
                }
                Section(header: Text("Content")) {
                    TextField("Widget content", text: $content, axis: .vertical)
                    TextField("Citation (optional)", text: $citation)
                }
                Section(header: Text("Text Styling")) {
                    ColorPicker("Text Color", selection: $fontColor, supportsOpacity: true)
                    Picker("Font", selection: $font) {
                        ForEach(fonts, id: \.self) {
                            Text($0).font(.system(.body, design: fontFromName(name: $0)))
                        }
                    }.pickerStyle(.menu)
                    HStack {
                        Text("Font Size:")
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
                    ColorPicker("Select a color", selection: $customColorCode, supportsOpacity: true)
                    if gradientMode {
                        ColorPicker("Select a second color", selection: $gradientColorCode, supportsOpacity: true)
                        Picker("First Color Position", selection: $firstColorPos) {
                            ForEach(gradientLocations, id: \.self) {
                                Text($0)
                            }
                        }.pickerStyle(.menu)
                        Picker("Second Color Position", selection: $secondColorPos) {
                            ForEach(gradientLocations, id: \.self) {
                                Text($0)
                            }
                        }.pickerStyle(.menu)
                    }
                    Toggle("Gradient Background", isOn: $gradientMode)
                }
                Section(header: Text("System Features")) {
                    Toggle("Tintable", isOn: $tintable)
                }
            }.navigationTitle("New Widget")
    }
    private func add(content: String, citation: String) {
        withAnimation {
            let newItem = Widget(context: context)
            newItem.timestamp = Date()
            newItem.content = content
            newItem.citation = citation
            newItem.bgColor = StringFromUIColor(color: UIColor(customColorCode))
            newItem.bgColor2 = StringFromUIColor(color: UIColor(gradientColorCode))
            newItem.gradient = gradientMode
            newItem.fontSize = fontSize
            newItem.fontWeight = fontWeight
            newItem.id = UUID()
            newItem.title = title
            newItem.tintable = tintable
            newItem.firstColorPos = firstColorPos
            newItem.secondColorPos = secondColorPos
            newItem.font = font
            newItem.textColor = StringFromUIColor(color: UIColor(fontColor))
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
