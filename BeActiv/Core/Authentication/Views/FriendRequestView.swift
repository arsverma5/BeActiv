//
//  FriendRequestView.swift
//  BeActiv
//
//  Created by Arshia Verma on 7/10/24.
//
/*
import SwiftUI

struct FriendRequestsView: View {
    @ObservedObject var viewModel: FriendsViewModel

    var body: some View {
        List {
            ForEach(viewModel.currentUser?.friendRequests ?? [], id: \.self) { requesterID in
                if let requesterID = requesterID as? String, let requester = viewModel.getUserByID(requesterID) {
                    HStack {
                        Text("Friend request from \(requester.fullName)")
                        Spacer()
                        Button("Accept") {
                            Task {
                                await viewModel.acceptFriendRequest(from: requester)
                            }
                        }
                        Button("Reject") {
                            Task {
                                await viewModel.rejectFriendRequest(from: requester)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                } else {
                    Text("Loading...") // Placeholder for loading state
                }
            }
        }
        .onAppear {
            viewModel.fetchFriendRequests() // Fetch friend requests on view appear
        }
        .navigationTitle("Friend Requests") // Set navigation title
    }
}

struct FriendRequestsView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = FriendsViewModel()
        return FriendRequestsView(viewModel: viewModel)
    }
}



*/


