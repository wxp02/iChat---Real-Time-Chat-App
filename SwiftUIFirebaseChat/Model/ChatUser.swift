//
//  ChatUser.swift
//  SwiftUIFirebaseChat
//
//  Created by Jeremy Poh on 2023-09-10.
//

import Foundation


struct ChatUser {
    let uid, email, profileImageUrl: String
    
    init(data: [String: Any]){
        self.uid = data["uid"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
    }
}
