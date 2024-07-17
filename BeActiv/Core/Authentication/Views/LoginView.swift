
//
//  LoginView.swift
//  BeActiv
//
//  Created by Arshia Verma on 6/29/24.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                // image
                Image("FootSteps-Auth")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 120)
                    .padding(.vertical, 32)
                
                // form fields
                VStack(spacing: 24) {
                    InputView(text: $email,
                              title: "Email Address",
                              placeholder: "name@example.com")
                    .autocapitalization(.none)
                    
                    InputView(text: $password,
                              title: "Password",
                              placeholder: "Enter your password",
                    isSecureField: true)
                }
                .padding(.horizontal)
                .padding(.top, 5)
                
                //sign in button
                Button {
                    Task {
                        try await viewModel.signIn(withEmail: email, password: password)
                    }
                    
                } label: {
                    HStack {
                        Text("SIGN IN")
                            .fontWeight(.semibold)
                        
                    }
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                }
                .background(Color(.systemMint))
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1.0 : 0.5)
                .cornerRadius(10)
                .padding(.top, 24)
                
                Spacer()
                
                //sign up button
                NavigationLink {
                    RegistrationView()
                    
                } label: {
                    HStack(spacing: 3) {
                    Text("Don't have an account?")
                    Text("Sign up!")
                        .fontWeight(.bold)
                }
                .font(.system(size: 14))
                    
                }
            }
        }
    }
}

// MARK - AuthenticationFormProtocol

extension LoginView: AuthtenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty && email.contains("@") && !password.isEmpty
        && password.count > 5
    }
}

#Preview {
    LoginView()
}
