# Flutter Game Project Guidelines

## Build & Run Commands
- Run app: `flutter run`
- Hot reload: Press `r` in terminal while app is running
- Hot restart: Press `R` in terminal while app is running
- Run tests: `flutter test`
- Run single test: `flutter test path/to/test_file.dart`
- Lint: `flutter analyze`

## Code Style Guidelines
- Import order: dart:core, flutter packages, third-party packages, local imports
- Use camelCase for variables and methods, PascalCase for classes
- Prefix private members with underscore (_)
- Use const for immutable values
- Prefer final for non-reassignable variables
- Keep widget build methods clean with extracted methods for complex UI
- Always override toString, == and hashCode for model classes
- Handle errors with try/catch and show appropriate user feedback
- Maintain physics constants in a separate constants file
- Document complex physics calculations with comments
