# SchedMate

A Flutter-based scheduling application that helps users manage their class schedules efficiently.

## Features

- Class schedule management
- Schedule export functionality (PDF and Excel)
- Modern material design interface
- Offline support with local storage
- Calendar view integration
- Dark/Light theme support

## Prerequisites

Before you begin, ensure you have the following installed:
- [Flutter](https://flutter.dev/docs/get-started/install) (SDK ^3.7.2)
- [Dart](https://dart.dev/get-dart)
- Android Studio or VS Code with Flutter extensions

## Getting Started

1. Clone the repository:
```bash
git clone https://github.com/your-username/schedmate.git
```

2. Navigate to the project directory:
```bash
cd schedmate
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run the app:
```bash
flutter run
```

## Dependencies

- provider: ^6.1.2 - State management
- shared_preferences: ^2.2.2 - Local storage
- pdf: ^3.10.8 - PDF export functionality
- excel: ^4.0.2 - Excel export functionality
- google_fonts: ^6.2.1 - Custom fonts
- table_calendar: ^3.1.0 - Calendar widget
- connectivity_plus: ^5.0.2 - Internet connectivity checking
- animated_splash_screen: ^1.3.0 - Splash screen animations

## Project Structure

```
lib/
├── main.dart
├── models/
│   └── class_schedule.dart
├── screens/
│   ├── auth/
│   ├── home/
│   └── splash/
└── services/
    ├── auth_service.dart
    ├── export_service.dart
    ├── schedule_service.dart
    └── theme_service.dart
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the amazing framework
- All contributors who will participate in this project
- Made with ❤️ by kumarjit