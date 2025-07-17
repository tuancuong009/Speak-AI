//
//  ToolModel.swift
//  Einstein AI
//
//  Created by QTS Coder on 3/2/25.
//

import UIKit
enum enumTool: Int{
    case ask
    case summrize
    case draft
    case improve
    case changeTool
    case paraphrase
    case translate
    case fixGrammar
    case chatAI
    var name: String{
        switch self {
        case .ask:
            return "Ask Anything"
            
        case .summrize:
            return "Summarize"
        case .draft:
            return "Draft an Essay"
        case .improve:
            return "Improve"
        case .changeTool:
            return "Change Tone"
        case .paraphrase:
            return "Paraphrase"
        case .translate:
            return "Translate"
        case .fixGrammar:
            return "Fix Grammar"
        case .chatAI:
            return "Chat AI"
        }
    }
    
    var image: String{
        switch self {
        case .ask:
            return "tool_ask"
        case .summrize:
            return "tool_summrize"
        case .draft:
            return "tool_drap"
        case .improve:
            return "tool_imprive"
        case .changeTool:
            return "tool_change"
        case .paraphrase:
            return "tool_para"
        case .translate:
            return "tool_translate"
        case .fixGrammar:
            return "tool_fix"
        case .chatAI:
            return ""
        }
    }
}
class ToolModel: NSObject {
    var title = ""
    var desc = ""
    var tools = [enumTool]()
    init(title: String = "", desc: String = "", tools: [enumTool] = []) {
        self.title = title
        self.desc = desc
        self.tools = tools
    }
}





enum ActionMore: Int{
    case moveFolder = 0
    case exportAudio
    case exportPDF
    case shareSummary
    case shareTransacription
    case deleteNote
}
