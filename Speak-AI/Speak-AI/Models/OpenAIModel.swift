//
//  OpenAIModel.swift
//  Speak-AI
//
//  Created by QTS Coder on 14/3/25.
//

import Foundation
struct OpenAIResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
}

struct Message: Codable {
    let content: String
}


enum ActionAI: Int{
    case transcription = 0
    case summary
    case quickRecap
    case rephrase
    case transalte
    case bullets
    case addStructre
    case makeLonger
    case MakeShort
    case asEmail
    case note
    case Tweet
    case blogBot
    case professional
    case casual
    case friendly
    case angry
    case none
    var name: String{
        switch self {
        case .quickRecap:
            return "Quick Recap"
        
        case .rephrase:
            return "Rephrase"
        case .transalte:
            return "Translate"
        case .bullets:
            return "Bullets"
        case .addStructre:
            return "Add Structure"
        case .makeLonger:
            return "Make Longer"
        case .MakeShort:
            return "Make Shorter"
        case .asEmail:
            return "As Email"
        case .note:
            return "Note"
        case .Tweet:
            return "Tweet"
        case .blogBot:
            return "Blog Post"
        case .professional:
            return "Professional"
        case .casual:
            return "Casual"
        case .friendly:
            return "Friendly"
        case .angry:
            return "Angry"
        case .transcription:
            return "Transcription"
        case .summary:
            return "Summary"
        case .none:
            return ""
        }
    }
    
    func promptFormat(text: String)-> String{
        switch self {
        case .summary:
            let summaryInstruction = """
            Please summarize the following text in its original language. Automatically detect the language of the input and Write a concise, structured summary that feels original and natural.

            - Interpret the input accurately to maintain context and relevance with concise output.
            - Do not use words like 'transcription' or 'text.'
            - Retain any quotations or proverbs.
            - Start with a brief 1-2 sentence introduction as if it's for an article.
            - Use Markdown for organization and structure:
              **Bold titles with relevant emojis for each section.**
              Mix short paragraphs and bullet points for clarity.
            - Maintain tone and context of the original.
            - Use a professional yet accessible tone.
            - Be concise, focusing on key insights.
            - Avoid unnecessary details or repetition.
            """
            return summaryInstruction + "From the text: " + text
        case .transcription:
            return ""
        case .quickRecap:
            let instruction = """
            Automatically detect the language of the input and Write a brief and clear Quick Recap of the input.
            - Focus only on the most important points or takeaways.
            - Keep it short and straight to the point.
            - Use the same language as the input.
            """
            return instruction + "From the text: " + text
        case .rephrase:
            let instruction = """
            Automatically detect the language of the input and Rephrase and Rewrite the input while keeping the original meaning intact.  
            - Human style, Don't use popular AI words.
            - Maintain the original tone and context.
            - Use the same language as the input.
            - Keep any quotations or proverbs.
            - Make it concise, Include important details without overwhelming the reader.
            - Use paragraphs and bullets to improve readability.
            """
            return instruction + "From the text: " + text
        case .transalte:
            return "Translate \(text) to English"
        case .bullets:
            let instruction = "Automatically detect the language of the input and Convert the text into a clear bullet list. Add a small introduction, Use the same language as the input, Keep it concise and to the point."
            return instruction + "From the text: " + text
        case .addStructre:
            let instruction = "Automatically detect the language of the input and Organize the following text into a well-structured format with headings and subheadings if applicable. Keep the content coherent and maintain the same language and meaning."
            return instruction + "From the text: " + text
        case .makeLonger:
            let instruction = "Automatically detect the language of the input and Expand on the following text by adding relevant details and improving explanations, without altering the original context or meaning. Use the same language as the input."
            return instruction + "From the text: " + text
        case .MakeShort:
            let instruction = "Automatically detect the language of the input and Shorten the following text by removing unnecessary words or repetition while preserving the main ideas, context, and language of the original."
            return instruction + "From the text: " + text
        case .asEmail:
            let instruction = "Automatically detect the language of the input and Rewrite the following text as a professional email. Keep the content and meaning intact, and maintain the same language."
            return instruction + "From the text: " + text
        case .note:
            let instruction = "Automatically detect the language of the input and Rewrite the following text as a brief, straightforward note while keeping the original meaning and language."
            return instruction + "From the text: " + text
        case .Tweet:
            let instruction = "Automatically detect the language of the input and Rewrite the following text as a short, engaging tweet under 280 characters. If the content is too long, break it into a thread with clear headlines. Preserve the key message and maintain the same language as the input."
            return instruction + "From the text: " + text
        case .blogBot:
            let instruction = "Automatically detect the language of the input and Rewrite the following text as a blog post with an appropriate tone and structure. Keep the original context intact. Keep the same language."
            return instruction + "From the text: " + text
        case .professional:
            let instruction = "Automatically detect the language of the input and Adjust the tone of the following text to be more professional and formal while preserving the original message, context. Keep the same language."
            return instruction + "From the text: " + text
        case .casual:
            let instruction = "Automatically detect the language of the input and Make the tone of the following text more casual and relaxed. Keep the meaning and the same language."
            return instruction + "From the text: " + text
        case .friendly:
            let instruction = "Automatically detect the language of the input and Make the following text sound more friendly and approachable while preserving the original meaning and Keep the same language."
            return instruction + "From the text: " + text
        case .angry:
            let instruction = "Automatically detect the language of the input and Adjust the tone of the following text to express frustration or anger clearly, while keeping the original message and same language."
            return instruction + "From the text: " + text
        case .none:
            return ""
        }
        
    }
   
}


class tabDetailOpenAI: NSObject{
    var action: ActionAI = .none
    var desc = ""
    var general = ""
    var id: String = ""
    override init() {
        
    }
}
