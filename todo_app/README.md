# Pro Genius

Pro Genius is a task and project management application built with Flutter and Supabase. The application allows users to create, update, and delete tasks and projects.

## Features

- **Project Management**: Create, update, and delete projects.
- **Task Management**: Create, update, and delete tasks within projects.
- **Profile Management**: Update user profile and sign out.
- **Authentication**: Register and sign in with email and password.
- **Form Validation**: Validate email and password fields.
- **Responsive Design**: Adaptive user interface for different screen sizes.
- **Color Coding**: Differentiate task states and priorities with colors.

## Technologies Used

- **Flutter**: Framework for building the user interface.
- **Supabase**: Backend-as-a-Service for authentication and database.
- **Provider**: State management for the application.

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/manuelAW99/todo-genius.git
   cd todo-genius
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Supabase:
   - Create an account on Supabase.
   - Create a new project and obtain the URL and anonymous key.
   - Update the `lib/main.dart` file with your Supabase URL and anonymous key.

4. Run the application:
   ```bash
   flutter run
   ```

## Project Structure

```bash
lib/
├── main.dart                # Entry point of the application
├── models/                  # Data models
│   ├── project.dart
│   ├── task.dart
│   └── profile.dart
├── pages/                   # Application pages
│   ├── home.dart
│   ├── login.dart
│   ├── account.dart
│   ├── project.dart
│   ├── projects.dart
│   └── task.dart
├── providers/               # State providers
│   ├── profile_provider.dart
│   ├── project_provider.dart
│   └── task_provider.dart
└── utils/                   # Utilities and helper functions
    ├── validation.dart
    └── colors.dart
```

## Usage

### Authentication
- **Register**: Users can register with their email.
- **Sign In**: Users can sign in with their email.

### Project Management
- **Create Project**: Users can create new projects.
- **Update Project**: Users can update the details of an existing project.
- **Delete Project**: Users can delete projects.

### Task Management
- **Create Task**: Users can create new tasks within a project.
- **Update Task**: Users can update the details of an existing task.
- **Delete Task**: Users can delete tasks.

### Profile Management
- **Update Profile**: Users can update their username and avatar.
- **Sign Out**: Users can sign out of the application.

## Contribution

Contributions are welcome! Please follow these steps to contribute:

1. Fork the repository.
2. Create a new branch:
   ```bash
   git checkout -b feature/new-feature
   ```
3. Make your changes and commit them:
   ```bash
   git commit -am 'Add new feature'
   ```
4. Push your changes to your fork:
   ```bash
   git push origin feature/new-feature
   ```
5. Open a Pull Request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Contact

If you have any questions or suggestions, feel free to contact:

- **Email**: mvilasvaliente@gmail.com
- **GitHub**: [manuelAW99](https://github.com/manuelAW99)