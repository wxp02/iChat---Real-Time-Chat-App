//
//  RecentMessage.swift
//  SwiftUIFirebaseChat
//
//  Created by Jeremy Poh on 2023-10-06.
//

import Foundation
import FirebaseFirestoreSwift


struct RecentMessage: Codable, Identifiable {
    
    @DocumentID var id: String?
    
    let text, email: String
    let fromId, toId: String
    let profileImageUrl: String
    let timestamp: Date
    
    var username: String {
        email.components(separatedBy: "@").first ?? email
    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}
