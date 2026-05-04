# Vibzcheck

# Project Description
Vibzcheck is a communal listening party app that utilizes the Spotify API to create a collaborative listening party for any social occasion. Any users who connect to the queue can add tracks to it and vote on the next song to play, creating a sense of community, allowing everyone to add to the listening party. The created playlist will create a taste profile for the group, adding recommended songs to the queue when users want to take a step back from control.


# Team Members
- Jaden Woody – Developer


# Features
- Firebase Authentication for secure user login
- Create and join collaborative playlist rooms
- Real-time song queue using Firestore
- Voting system to rank songs dynamically
- Spotify Web API integration for song search and selection
- Real-time chat system within each playlist
- Push notifications using Firebase Cloud Messaging (FCM)
- Room ID sharing with "copy to clipboard" feature
- Dark mode toggle for UI customization
- Bottom sheet UI for chat and song voting for better usability


# Technologies Used
- Flutter (SDK)
- Dart
- Firebase Authentication
- Firestore Databse
- FCM
- Spotify Web API


# Installation Instructions
## Prerequesites
- Install Flutter SDK
- Install Android Studio or VS Code
- Set up an emulator or connect an android device to PC

1. Clone the repository:
   ```bash
   git clone https://github.com/JayTK13/MADProj2.git
2. Navigate to folder:
    cd MADProj2/proj2
3. Install dependencies:
    flutter pub get
4. Run the app:
    flutter run


# Usage Guide
- Upon launching, users log in using Firebase Authentication
- Create a new playlist room or join an existing one using a Room ID
- Add songs manually or search using Spotify integration
- Vote on songs to influence the playlist order
- Open the chat to communicate with other users in real-time
- Use the “View Songs & Vote” button to manage the queue
- Copy the Room ID to share with others
- Toggle dark mode using the icon in the top navigation bar
- Receive notifications when activity occurs in the playlist


# Database Schema
## Collection: users
| Field    | Type   | Description            |
| -------- | ------ | ---------------------- |
| uid      | STRING | Document ID (User UID) |
| username | STRING | User display name      |
## Collection: playlists
| Field      | Type      | Description            |
| ---------- | --------- | ---------------------- |
| playlistId | STRING    | Document ID            |
| name       | STRING    | Playlist name          |
| hostId     | STRING    | Creator UID            |
| createdAt  | TIMESTAMP | Playlist creation time |
| isActive   | BOOLEAN   | Active status          |
| members    | ARRAY     | List of user IDs       |
### Subcollection: songs
| Field  | Type    | Description     |
| ------ | ------- | --------------- |
| songId | STRING  | Document ID     |
| title  | STRING  | Song title      |
| artist | STRING  | Artist name     |
| votes  | INTEGER | Number of votes |
### Subcollection: messages
| Field     | Type      | Description         |
| --------- | --------- | ------------------- |
| messageId | STRING    | Document ID         |
| text      | STRING    | Message content     |
| senderId  | STRING    | Sender UID          |
| username  | STRING    | Sender display name |
| timestamp | TIMESTAMP | Message timestamp   |



# Known Issues
- Messages may display as sent from "Unknown"
- Mood tags are not visible


# Future Enhancements
- User profiles with consistent usernames
- Joinable public playlists list
- Audio preview by using Spotify SDK
- Spotify-based color-scheme
- Safer Spotify ID implementation


# Liscense
This project is liscensed under the MIT License.

# Flutter Version
- Flutter version: 3.41.5
- Dart version: 3.11.3