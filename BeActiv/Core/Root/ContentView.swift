//
//  ContentView.swift
//  BeActiv
//
//  Created by Arshia Verma on 6/27/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        Group {
            if viewModel.userSession != nil {
                MainView()
                    .environmentObject(LeaderboardsViewModel())
            } else {
                LoginView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthViewModel())
            .environmentObject(LeaderboardsViewModel())
    }
}

