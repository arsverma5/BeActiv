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



<img src="https://github.com/user-attachments/assets/5911151c-79d5-4e53-b62e-908b0505204e" width="300" height="600">

<img src="https://github.com/user-attachments/assets/8a4dbe08-1cbe-4c7f-8929-229c49774758" width="300" height="600">

<img src="https://github.com/user-attachments/assets/6e853e42-05a9-4d73-935b-5897c6ef5b5a" width="300" height="600">

<img src="https://github.com/user-attachments/assets/5fd8849a-df3c-4ad6-b4ad-5e6b5c97d5e4" width="300" height="600">
<img src="https://github.com/user-attachments/assets/218bfe6b-0ece-4131-b3d9-81e0e475c122" width="300" height="600">
<img src="https://github.com/user-attachments/assets/1dbc8bfc-2d05-42a9-ae95-acf0b70814b2" width="300" height="600">
<img src="https://github.com/user-attachments/assets/c098a48a-19a7-4983-b64b-35bf5585ae9f" width="300" height="600">



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
