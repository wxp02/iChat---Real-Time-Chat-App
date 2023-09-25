//
//  MainMessagesView.swift
//  SwiftUIFirebaseChat
//
//  Created by Jeremy Poh on 2023-09-03.
//

import SwiftUI
import SDWebImageSwiftUI


class MainMessagesViewModel : ObservableObject {
    
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    
    init() {
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        fetchCurrentUser()
    }
    
    func fetchCurrentUser() {
        guard let uid =
            FirebaseManager.shared.auth.currentUser?.uid
            else {
            self.errorMessage = "Could not find firebase uid"
            return
        }

        FirebaseManager.shared.firestore.collection("users")
            .document(uid).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "failed to fetch current user: \(error)"
                print("Failed to fetch current user:", error)
                return
            }
                
            guard let data = snapshot?.data() else {
                self.errorMessage = "No data found"
                return
            }
            
            self.chatUser = .init(data: data)
        }
    }
    
    @Published var isUserCurrentlyLoggedOut = false
    
    func handleSignOut() {
        isUserCurrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
    }
}

struct MainMessagesView: View {
    
    @State var shouldShowLogOutOptions = false
    
    @ State var shouldNavigateToChatLogView = false
    
    // Private var cannot be accessed from outside that scope,
    // even within the same module.
    @ObservedObject private var vm = MainMessagesViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                customNavBar
                messagesView
                
                NavigationLink("", isActive: $shouldNavigateToChatLogView) {
                    ChatLogView(chatUser: self.chatUser)
                }
            }
            .overlay(
                newMessageButton, alignment: .bottom)
            .navigationBarHidden(true)
        }
    }
    
    
    private var customNavBar: some View {
        HStack(spacing: 16) {
            // Profile picture
            WebImage(url: URL(string: vm.chatUser?.profileImageUrl ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipped()
                .cornerRadius(50)
                .overlay(RoundedRectangle(cornerRadius: 44).stroke(Color(.label), lineWidth: 1))
                .shadow(radius: 5)
            // Username and online status
            VStack(alignment: .leading, spacing: 4) {
                let email = vm.chatUser?.email.replacingOccurrences(of: "@gmail.com", with: "") ?? ""
                Text("\(email)")
                    .font(.system(size: 24, weight: .bold))
                HStack {
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 14, height: 14)
                    Text("Online")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.lightGray ))
                }
            }
            Spacer()
            // Setting button (logout button)
            Button {
                shouldShowLogOutOptions.toggle()
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.label))
                
            }
        }
        .padding()
        .actionSheet(isPresented: $shouldShowLogOutOptions) {
            .init(title: Text("Settings"), message:
                    Text("What do you want to do"), buttons: [
                        .destructive(Text("Sign Out"), action: {
                            print("Handle signing out")
                            vm.handleSignOut()
                        }),
                            .cancel()
            ])
        }
        // After clicking the logout button, this will take user back to login page
        .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut, onDismiss: nil) {
            LoginView(didCompleteLoginProcess: {
                self.vm.isUserCurrentlyLoggedOut = false
                self.vm.fetchCurrentUser()
            })
        }
    }
    
    
    private var messagesView: some View {
        ScrollView {
            ForEach(0..<10, id: \.self) { num in
                VStack {
                    NavigationLink {
                        Text("Destination")
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 32))
                                .padding(8)
                                .overlay(RoundedRectangle(cornerRadius: 44).stroke(Color(.label), lineWidth: 1)
                            )
                            VStack(alignment: .leading) {
                                Text("Username")
                                    .font(.system(size: 16, weight: .bold))
                                Text("Message sent to user")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(Color(.lightGray))
                            }
                            Spacer()
                            
                            Text("22d")
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }
                    Divider()
                        .padding(.vertical, 8)
                }.padding(.horizontal)
            }.padding(.bottom, 50)
        }
    }
    
    @State var shouldShowNewMessageScreen = false
    
    private var newMessageButton: some View {
        Button {
            shouldShowNewMessageScreen.toggle()
        } label : {
            HStack {
                Spacer()
                Text("+ New Message")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.vertical)
                .background(Color.blue)
                .cornerRadius(32)
                .padding(.horizontal)
                .shadow(radius: 5)
        }
        // When .fullScreenCover is clicked a cover shows up
        .fullScreenCover(isPresented: $shouldShowNewMessageScreen) {
            CreateNewMessageView(didSelectNewUser: { user
                in print(user.email)
                self.shouldNavigateToChatLogView.toggle()
                self.chatUser = user
            })
        }
    }
    
    @State var chatUser: ChatUser?
}

struct ChatLogView: View {
    
    let chatUser: ChatUser?

    var body: some View {
        ScrollView {
            ForEach(0..<10) { num in
                Text("FAKE MESSAGE")
            }
        }.navigationTitle(chatUser?.email ?? "")
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct MainMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        // Dark mode
        MainMessagesView()
            .preferredColorScheme(.dark)
        // Light mode
        MainMessagesView()

    }
}
