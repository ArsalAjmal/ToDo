# My Notes - Flutter Todo App

A modern, cross-platform note-taking application built with Flutter that works on mobile, desktop, and web platforms.

![App Icon](assets/images/list.png)

## Features

- Create, view, edit, and delete notes
- Organize notes by categories with visual color coding
- Mark important notes for quick identification
- Set due dates for time-sensitive tasks
- Customizable user profile with photo support
- Clean, modern UI with a pleasing color scheme
- Cross-platform support (iOS, Android, Windows, macOS, Linux, Web)
- Offline data storage with SQLite (with web fallback)

## Technologies Used

- Flutter 3.8+
- Dart SDK
- SQLite with sqflite for persistent storage
- sqflite_common_ffi for desktop platform support
- Image picker for profile photo functionality
- Intl package for date formatting
- Flutter Launcher Icons for app icon generation

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/my_notes.git
   ```

2. Navigate to the project directory:
   ```bash
   cd my_notes
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Platform Support

- ✅ Android
- ✅ iOS
- ✅ Windows
- ✅ macOS
- ✅ Linux
- ✅ Web

## Project Structure

- `lib/models/` - Data models for notes and user
- `lib/screens/` - UI screens for the application
- `lib/database/` - Database helper for SQLite operations
- `assets/` - Images and other static resources

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

arsal.ajmal621@gmail.com

---

Happy note-taking! 📝
