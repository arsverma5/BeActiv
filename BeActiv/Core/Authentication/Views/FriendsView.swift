import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct FriendsView: View {
    @StateObject private var viewModel = FriendsViewModel()
    @State private var searchQuery: String = ""
    @State private var searchResults: [User] = []
    @State private var isSearching: Bool = false
    @State private var noResultsFound: Bool = false

    @State private var friendToRemove: Friends? = nil
    @State private var alertType: AlertType? = nil

    // issues with this but fixed into an enum data type with a switch case
    // so the alert messages won't clash and get mixes up in SwiftUI
    enum AlertType: Identifiable {
        case sendRequest
        case removeFriend

        var id: String {
            switch self {
            case .sendRequest:
                return "sendRequest"
            case .removeFriend:
                return "removeFriend"
            }
        }
    }

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
                                    friendToRemove = friend
                                    alertType = .removeFriend
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

                                HStack {
                                    Button(action: {
                                        viewModel.declineFriendRequest(request)
                                    }) {
                                        Image(systemName: "xmark")
                                            .foregroundColor(.red)
                                            .padding()
                                    }
                                    .buttonStyle(BorderlessButtonStyle())

                                    Button(action: {
                                        viewModel.acceptFriendRequest(request)
                                    }) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.green)
                                            .padding()
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                                .padding(.vertical, 5)
                            }
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
                                alertType = .sendRequest
                            }) {
                                Text("Send Request")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Friends")
            .alert(item: $alertType) { alert in
                switch alert {
                case .sendRequest:
                    return Alert(title: Text("Alert"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
                case .removeFriend:
                    return Alert(
                        title: Text("Remove Friend"),
                        message: Text("Are you sure you want to remove \(friendToRemove?.name ?? "this friend") as a friend?"),
                        primaryButton: .destructive(Text("Remove")) {
                            if let friend = friendToRemove {
                                viewModel.removeFriend(friend)
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
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
