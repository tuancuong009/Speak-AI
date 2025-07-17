//
//  SpeakWidget.swift
//  SpeakWidget
//
//  Created by QTS Coder on 28/3/25.
//


import WidgetKit
import SwiftUI

struct SimpleEntry: TimelineEntry {
    let date: Date
    let imageName: String
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), imageName: "bgWidget")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        completion(SimpleEntry(date: Date(), imageName: "bgWidget"))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let entry = SimpleEntry(date: Date(), imageName: "bgWidget")
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct SpeakWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.widgetFamily) var family
    var body: some View {
        Link(destination: URL(string: "myappscheme://openapp")!) {
            
            Image(family == .systemSmall ? "bgWidget" : "medium")
                .containerBackground(for: .widget) {
                    backgroundView
                }
        }
    }
    
    var backgroundView: some View {
            LinearGradient(
                gradient: Gradient(colors: backgroundColors),
                startPoint: .top,
                endPoint: .bottom
            )
        }

        // MARK: - Dynamic Colors
        var backgroundColors: [Color] {
            if colorScheme == .dark {
                return [
                    Color(red: 245/255, green: 206/255, blue: 255/255).opacity(1),
                    Color.white
                ]
            } else {
                return [
                    Color(red: 204/255, green: 0, blue: 255/255).opacity(0.2),
                    Color.white
                ]
            }
        }
}

struct SpeakWidget: Widget {
    let kind: String = "SpeakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SpeakWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Speak-AI Widget")
        .description("A widget opens the app when tapped.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
