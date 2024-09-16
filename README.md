# BeActiv

BeActiv is a social fitness app that combines step tracking and fun challenges to help users stay active and connected with friends. Built with SwiftUI and Firebase, the app integrates with HealthKit to access step data, allowing users to set goals, complete challenges, track their progress on leaderboards, and be able to send/deny friend requests that can also be synced with their contacts.

## Features

- HealthKit Integration
  - Sync daily step counts directly from your iPhone's Health app.

- Fitness Challenges
  - Take on a variety of step-based challenges, such as:
    - Walk 10,000+ steps for an entire week.
    - Add 5 or more friends to your fitness network.

- Leaderboard
  - Compete with friends for top spots based on:
    - Daily steps.
    - Challenges won. Earn gold, silver, or bronze medals for the top three positions.
    
- Friend Management
  - Search for friends by full name.
  - Send and receive friend requests.
  - Accept or decline requests from your inbox.
  - Remove friends from your list with easy-to-use controls.
  
- Progress Tracking
  - Visualize your progress on each challenge with real-time updates and progress bars.
  
- Dark Mode Support
  - The app fully supports light and dark mode, offering an accessible experience across different themes.


## Screenshots:


## Installation: 

1. Clone the repository:
     git clone https://github.com/yourusername/beactiv.git
2. Navigate to the project directory:
     cd beactiv
3. Install dependencies: Ensure that you have Xcode installed, then open the project and build
4. Configure Firebase:
Create a Firebase project and download the GoogleService-Info.plist file.
Add the file to your Xcode project.
5. Enable HealthKit:
In Xcode, enable HealthKit under your app's capabilities.

## Usage

Register or log in using Firebase Authentication.

Connect HealthKit to start tracking your steps.

Join challenges and compete with friends.

Track progress and view the leaderboard.
