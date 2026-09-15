# EDU Campus Bus Tracker

A Flutter-based campus bus tracking application designed to help students check bus routes, schedules, live bus locations, alerts, and profile information in one place.

## Features

- User registration and login
- Student profile management
- Live bus tracking with Google Maps
- Bus and route information
- Bus schedules
- Saved routes
- Home stop selection
- Trip tracking information
- Notifications and alerts
- Firebase Authentication
- Cloud Firestore for application data
- Firebase Realtime Database for live bus locations
- Device location support

## Tech Stack

- **Frontend:** Flutter / Dart
- **Authentication:** Firebase Authentication
- **Database:** Cloud Firestore
- **Real-time Location:** Firebase Realtime Database
- **Maps:** Google Maps Flutter
- **Location:** Geolocator
- **Notifications:** Firebase Cloud Messaging
- **API Requests:** HTTP
- **Development:** Android Studio / VS Code

## Project Structure

```text
lib/
├── config/
├── models/
├── screens/
│   ├── alerts/
│   ├── home/
│   ├── onboarding/
│   ├── profiles/
│   ├── schedule/
│   ├── splash/
│   └── tracker/
├── services/
├── theme/
├── utilis/
├── widgets/
├── main.dart
└── main_screen.dart

assets/
└── images/
```

## Requirements

Before running the project, install:

- Flutter SDK
- Dart SDK (included with Flutter)
- Android Studio
- Android SDK
- A physical Android device or Android Emulator
- A Firebase project
- Google Maps API key

Check your Flutter installation with:

```bash
flutter doctor
```

## Installation

### 1. Clone the repository

```bash
git clone YOUR_GITHUB_REPOSITORY_URL
```

Then enter the project folder:

```bash
cd bus_app
```

### 2. Install Flutter dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

This project uses Firebase Authentication, Cloud Firestore, Firebase Realtime Database, and Firebase Cloud Messaging.

For your own Firebase project, configure the Flutter app using the Firebase setup process and generate the required platform configuration files.

Do **not** upload private service-account credentials such as:

```text
serviceAccountKey.json
```

Keep private Firebase credentials outside the Git repository.

### 4. Configure Google Maps

Add your Google Maps API key to the appropriate Android configuration.

For production use, restrict the API key by application/package and API type.

### 5. Run the application

Check available devices:

```bash
flutter devices
```

Run the app:

```bash
flutter run
```

## Firebase Data

The application uses Firebase services for:

- User authentication
- User profiles
- Bus information
- Routes
- Schedules
- Saved routes
- Notifications
- Live bus locations

The live bus location service uses Firebase Realtime Database.

## Live Bus Tracking

Bus locations are stored under the `liveLocations` path in Firebase Realtime Database.

Each bus location contains:

```text
busId
├── lat
├── lng
└── updatedAt
```

The application listens to these values in real time and displays bus locations on the map.

## Important Security Note

Before making the repository public, review all Firebase configuration and security rules.

Never commit:

- `serviceAccountKey.json`
- passwords
- private API secrets
- `.env` files containing secrets
- local machine configuration
- generated build files

Firebase client configuration files may contain project identifiers and API keys intended for client applications, but access must still be protected using proper Firebase Authentication, Firestore rules, Realtime Database rules, and API-key restrictions.

## GitHub Upload

If you are uploading this project for the first time, make sure generated folders such as these are ignored:

```text
.dart_tool/
build/
.idea/
```

Then initialize Git and push the project:

```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin YOUR_GITHUB_REPOSITORY_URL
git push -u origin main
```

## Future Improvements

- Driver-side bus location management
- More accurate real-time ETA
- Bus occupancy information
- Route search and filtering
- Admin dashboard
- Improved push notification system
- Better offline support
- Production deployment

## Author

Developed as a university mobile application project.

## License

This project is intended for educational and academic purposes.
