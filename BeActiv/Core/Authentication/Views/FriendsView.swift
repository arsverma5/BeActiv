import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct FriendsView: View {
    @StateObject private var viewModel = FriendsViewModel()
    @State private var searchQuery: String = ""
    @State private var searchResults: [User] = []
    @State private var isSearching: Bool = false
    @State private var noResultsFound: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("Friends")) {
                        ForEach(viewModel.friends) { friend in
                            HStack {
                                Image(systemName: friend.imageName)
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                    .foregroundColor(.blue)
                                VStack(alignment: .leading) {
                                    Text(friend.name)
                                        .font(.headline)
                                }
                                Spacer()
                                Button(action: {
                                    viewModel.removeFriend(friend)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                    
                    Section(header: Text("Friend Requests")) {
                        ForEach(viewModel.friendRequests) { request in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(request.senderName)
                                        .font(.headline)
                                }
                                Spacer()
                                Button(action: {
                                    viewModel.acceptFriendRequest(request)
                                }) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.green)
                                }
                                Button(action: {
                                    viewModel.declineFriendRequest(request)
                                }) {
                                    Image(systemName: "xmark")
                                        .foregroundColor(.red)
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
                
                HStack {
                    TextField("Search friend's name", text: $searchQuery)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button(action: {
                        Task {
                            isSearching = true
                            searchResults = await viewModel.searchFriend(by: searchQuery)
                            isSearching = false
                            noResultsFound = searchResults.isEmpty
                        }
                    }) {
                        Image(systemName: "magnifyingglass")
                    }
                    .padding()
                }
                
                if isSearching {
                    ProgressView()
                        .padding()
                } else if noResultsFound {
                    Text("This person does not exist (as a user in this app) Try again :(")
                        .foregroundColor(.red)
                        .padding()
                } else if !searchResults.isEmpty {
                    List(searchResults) { user in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(user.fullName)
                                    .font(.headline)
                            }
                            Spacer()
                            Button(action: {
                                viewModel.sendFriendRequest(to: user)
                            }) {
                                Text("Send Request")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Friends")
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("Alert"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        .onAppear {
            viewModel.loadFriends()
            viewModel.loadFriendRequests()
        }
    }
}

struct FriendsView_Previews: PreviewProvider {
    static var previews: some View {
        FriendsView()
    }
}
