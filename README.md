# Travel Diary App - Flutter Project

A production-level Flutter application for sharing travel experiences, photos, videos, and stories with the community.

## Features

### Account Types
- **Personal Account**: For individual travelers
  - Chat with other users
  - Video calls (when both users follow each other)
  - Follow/Unfollow functionality
  
- **Business Account**: For travel businesses
  - No chat functionality
  - All other features available
  - Profile highlighting

### Core Features
- **Photo & Video Sharing**: Share travel memories with captions, locations, and tags
- **Stories**: Share temporary 24-hour stories
- **Social Features**: Like, comment, and share posts
- **Chat System**: Direct messaging with other travelers
- **Search**: Search for users or content
- **User Profiles**: Customizable profiles with bio, website, and location
- **Follow System**: Follow/unfollow other users
- **Media Downloads**: Download shared photos and videos

## Project Structure
```
travel_diary/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── constants/
│   │   ├── theme/
│   │   ├── utils/
│   │   ├── network/
│   │   └── errors/
│   ├── data/
│   │   ├── models/
│   │   ├── repositories/
│   │   └── services/
│   ├── business_logic/
│   │   ├── auth_bloc/
│   │   └── app_bloc/
│   └── presentation/
│       ├── screens/
│       └── widgets/
└── pubspec.yaml
```

## Getting Started

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Dart 3.0.0 or higher
- Android Studio or Xcode for iOS development

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd travel_diary
```

2. **Get dependencies**
```bash
flutter pub get
```

3. **Set up API Configuration**
- Update `lib/core/constants/api_constants.dart` with your API base URL
- Configure Agora App ID in `lib/core/constants/app_constants.dart`

4. **Run the app**
```bash
flutter run
```

## Architecture

### Clean Architecture with BLoC Pattern

The app follows clean architecture principles with three layers:

1. **Data Layer**
   - Models: Data structures
   - Repositories: Business logic
   - Services: API and storage services

2. **Business Logic Layer (BLoC)**
   - AuthBloc: Authentication management
   - AppBloc: General app operations
   - Events and States for reactive programming

3. **Presentation Layer**
   - Screens: UI pages
   - Widgets: Reusable UI components
   - Bloc consumer widgets for reactive UI

### State Management

- **Flutter BLoC**: Event-driven state management
- **Two BLoC Pattern**: 
  - `AuthBloc`: Handles authentication
  - `AppBloc`: Handles all other operations

## Key Dependencies
```yaml
# State Management
flutter_bloc: ^8.1.3
equatable: ^2.0.5

# Network
dio: ^5.4.0

# Local Storage
flutter_secure_storage: ^9.0.0
shared_preferences: ^2.2.2

# Media
image_picker: ^1.0.7
cached_network_image: ^3.3.1
video_player: ^2.8.2
photo_view: ^0.14.0

# UI
flutter_staggered_grid_view: ^0.7.0
shimmer: ^3.0.0
flutter_svg: ^2.0.9

# Communication
agora_rtc_engine: ^6.3.0
socket_io_client: ^2.0.3+1

# Utils
intl: ^0.18.1
path_provider: ^2.1.2
permission_handler: ^11.2.0
```

## API Integration

The app connects to a backend API with the following endpoints:

### Authentication
- `POST /auth/login` - User login
- `POST /auth/register` - User registration
- `POST /auth/logout` - User logout

### Users
- `GET /users/{id}` - Get user profile
- `PUT /users/update` - Update profile
- `POST /users/follow/{id}` - Follow user
- `POST /users/unfollow/{id}` - Unfollow user

### Posts
- `GET /posts/feed` - Get feed
- `POST /posts/create` - Create post