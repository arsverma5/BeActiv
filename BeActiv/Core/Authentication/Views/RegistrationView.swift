//
//  RegistrationView.swift
//  BeActiv
//
//  Created by Arshia Verma on 6/29/24.
//

import SwiftUI

struct RegistrationView: View {
    @State private var email = ""
    @State private var fullName = ""
    @State private var password = ""
    @State private var confirm = ""
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack {
            // Image
            Image("FootSteps-Auth")
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 120)
                .padding(.vertical, 32)
            
            // Input fields
            VStack(spacing: 24) {
                InputView(text: $email,
                          title: "Email Address",
                          placeholder: "name@example.com")
                    .autocapitalization(.none)
                
                InputView(text: $fullName,
                          title: "Full Name",
                          placeholder: "Example: Arshia Verma")
                
                InputView(text: $password,
                          title: "Password",
                          placeholder: "Enter your password",
                          isSecureField: true)
                
                ZStack(alignment: .trailing) {
                    InputView(text: $confirm,
                              title: "Confirm Password",
                              placeholder: "Confirm your password",
                              isSecureField: true)
                    
                    if !password.isEmpty && !confirm.isEmpty {
                        if password == confirm {
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.systemGreen))
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.systemRed))
                        }
                    }
                }
                
            
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            // Sign Up Button
            Button {
                Task {
                    do {
                        try await viewModel.createUser(withEmail: email, password: password, fullname: fullName)
                    } catch {
                        print("Failed to create user: \(error.localizedDescription)")
                    }
                }
            } label: {
                Text("SIGN UP")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 48)
            }
            .background(Color(.systemMint))
            .disabled(!formIsValid)
            .opacity(formIsValid ? 1.0 : 0.5)
            .cornerRadius(10)
            .padding(.top, 24)
            
            Spacer()
            
            // Sign in link
            Button {
                dismiss()
            } label: {
                HStack(spacing: 3) {
                    Text("Already have an account?")
                    Text("Sign in!")
                        .fontWeight(.bold)
                }
                .font(.system(size: 14))
            }
        }
        .onReceive(viewModel.$currentUser) { currentUser in
            if currentUser != nil {
                print("Registration successful. Current user: \(currentUser!.fullName)")
                // Optionally dismiss the view or perform other actions upon successful registration
                dismiss()
            }
        }
    }
}

// MARK: - AuthenticationFormProtocol

extension RegistrationView: AuthtenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty && email.contains("@") && !password.isEmpty && password.count > 5 && !fullName.isEmpty && confirm == password
    }
}

#Preview {
    RegistrationView()
}
