//
//  Conversation.swift
//  Adoptr
//
//  Created by Alexandra Negru on 30/05/2022.
//

import Foundation

struct Conversation {
    let id: String
    let otherUserName: String
    let otherUserEmail: String
    var latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}
