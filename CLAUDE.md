# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

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
- Use const for immutable values, final for non-reassignable variables
- Keep widget build methods clean with extracted methods for complex UI
- Document complex physics calculations with comments
- Handle boundary conditions (edge cases) in collision detection
- Normalize vectors before calculations to prevent division by zero
- Apply component-based architecture with clear separation of concerns
- Follow Flutter performance best practices (cached widgets, optimized rendering)
- Maintain game constants at the class level for easy configuration