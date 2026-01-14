## 👟 KickzStore
**KickzStore** is a modern Flutter e-commerce mobile application specializing in footwear retail. Built with Flutter and Dart, this application provides a complete shopping experience for sneaker enthusiasts and shoe lovers. The app features a sleek, mobile-optimized interface with real-time product browsing, detailed product views, intelligent search functionality, and seamless navigation.

## Prerequisites
- **Flutter SDK** (3.10.4 or higher) installed and added to your system `PATH`
- **Dart SDK** (comes bundled with Flutter)
- **Android Studio** and/or **Xcode** (for Android/iOS builds and emulators)
- **A physical device or emulator** (Android Emulator, iOS Simulator, or real device)
- (Optional) A code editor like **VS Code** or **Android Studio** for easier code navigation
- Basic understanding of **Dart** and **Flutter** (widgets, state management, navigation)
- (Optional) Running backend/API server (Node.js/Express) for product and auth data

## Installation
1. **Clone the repository** (if not already downloaded):

   ```sh
   git clone <repository-url>
   cd kickzstore_flutter
   ```

2. **Install Flutter dependencies**:

   ```sh
   flutter pub get
   ```

3. **Configure backend API** (if applicable):
   - Update any API base URLs in the project (e.g. in a `config` or `services` file) to point to your Node.js/Express backend.
   - Ensure your backend server is running and accessible from the device/emulator.

## How to Run
1. **Run on a connected device or emulator**:

   ```sh
   flutter run
   ```

2. **Run on specific platforms**:

   ```sh
   # For Android
   flutter run -d android

   # For iOS
   flutter run -d ios

   # For Web (if enabled)
   flutter run -d chrome
   ```

3. **Build release builds** (optional):

   ```sh
   # Android APK/AppBundle
   flutter build apk
   flutter build appbundle

   # iOS (requires Xcode)
   flutter build ios
   ```

## Technologies
### Frontend (Mobile App)
- **Flutter 3.x**
- **Dart 3.x**
- **Material Design components**
- **Provider** (state management)
- **HTTP** (REST API integration)
- **Shared Preferences** (token and local storage)
- **intl** (internationalization and formatting)

### Backend (External, if used)
- **Node.js**
- **Express.js**
- **MongoDB with Mongoose** or another database of your choice
- **CORS**, **JWT authentication**, and environment-based configuration via `.env`

### Development Tools
- **Flutter CLI**
- **Dart DevTools**
- **Android Studio / Xcode**
- **VS Code** (with Flutter & Dart extensions)
- **Git**

## Troubleshooting
- **Device not detected**: Ensure USB debugging is enabled (Android) or device is trusted (iOS), and run `flutter devices`.
- **Build/Run issues**: Try `flutter clean` then `flutter pub get` and re-run.
- **Dependency issues**: Make sure you are using a compatible Flutter SDK version and re-run `flutter pub get`.
- **Backend connection**: Confirm API base URL, backend server status, and that your device/emulator can reach the backend host/port.
- **Authentication/storage**: Check `SharedPreferences` usage for token persistence and clearing on logout.
- **Navigation problems**: Verify routes are correctly defined and used in the Flutter `Navigator`/routing setup.
- **Console errors**: Inspect logs via `flutter run -v` or the Debug console in your IDE.

## Contributing
This is a learning project designed for educational purposes. Feel free to:
- Modify the UI and logic to experiment with different approaches
- Add new features and functionality (filters, wishlists, order history, etc.)
- Improve documentation and in-code comments
- Share your learning experiences
- Report bugs and suggest improvements via issues or pull requests

## Learn More
- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
- [Node.js Documentation](https://nodejs.org/en/docs)
- [Express.js Documentation](https://expressjs.com/)
- [MongoDB Documentation](https://www.mongodb.com/docs/)

For questions or contributions, please open an issue or pull request on the GitHub repository.

## License
This project is licensed under the ISC License - see the LICENSE file for details.
