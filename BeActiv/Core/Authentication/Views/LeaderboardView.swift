import SwiftUI

extension Color {
    static let gold = Color(red: 255/255, green: 215/255, blue: 0/255)
    static let silver = Color(red: 192/255, green: 192/255, blue: 192/255)
    static let bronze = Color(red: 205/255, green: 127/255, blue: 50/255)
}

struct LeaderboardView: View {
    var leaderboardEntries: [FriendLeaderboard]
    var loggedInUserId: String

    var body: some View {
        VStack {
            Text("Steps Walked Leaderboard")
                .font(.title)
                .padding()

            ForEach(leaderboardEntries.indices, id: \.self) { index in
                HStack {
                    Text("\(index + 1)")
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    Text(leaderboardEntries[index].username)
                        .padding(.horizontal)
                    Spacer()
                    Text("\(leaderboardEntries[index].steps) steps")
                        .padding(.horizontal)
                }
                .padding(.vertical, 8)
                .background(backgroundColor(for: index))
                .cornerRadius(10)
                .padding(.horizontal)
                .overlay(
                    leaderboardEntries[index].id == loggedInUserId ?
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 2)
                        .padding(.horizontal)
                    : nil
                )
            }
        }
        .onAppear {
            print("Logged In User ID: \(loggedInUserId)")
            print("Leaderboard Entries: \(leaderboardEntries)")
        }
    }

    private func backgroundColor(for index: Int) -> Color {
        switch index {
        case 0:
            return .gold
        case 1:
            return .silver
        case 2:
            return .bronze
        default:
            return .clear
        }
    }
}
