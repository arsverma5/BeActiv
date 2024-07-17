import SwiftUI

struct FriendsView: View {
    @StateObject private var viewModel = FriendsViewModel()
    @State private var searchQuery: String = ""
    @State private var searchResults: [User] = []
    @State private var isSearching: Bool = false
    @State private var friendToRemove: Friends?
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                List(viewModel.friends) { friend in
                    HStack {
                        Image(systemName: "person.crop.circle")
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
                            showAlert = true
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.vertical, 5)
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
                        }
                    }) {
                        Image(systemName: "magnifyingglass.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                    }
                    .padding()
                }
                .padding(.bottom)
                
                if isSearching {
                    ProgressView()
                } else {
                    List(searchResults) { user in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(user.fullName)
                                    .font(.headline)
                                Text(user.email)
                                    .font(.subheadline)
                                    .foregroundColor(Color.gray)
                            }
                            Spacer()
                            Button(action: {
                                viewModel.addFriend(user)
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                
                NavigationLink(destination: AddFriendsView()) {
                    Text("Add Friends from Contacts")
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding(.bottom)
            }
            .navigationBarTitle("Friends")
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Remove Friend"),
                    message: Text("Do you want to remove this friend?"),
                    primaryButton: .destructive(Text("Yes")) {
                        if let friend = friendToRemove {
                            viewModel.removeFriend(friend)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .onAppear {
                viewModel.loadFriends()
            }
        }
    }
}
