// Make sure your main.dart has proper provider setup
// Here's an example of how it should look:

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_diary_mob_app/data/services/storage_service.dart';
import 'package:travel_diary_mob_app/presentation/screens/auth/login_screen.dart';
import 'package:travel_diary_mob_app/presentation/screens/home/home_screen.dart';
import 'package:travel_diary_mob_app/routes/app_routes.dart';
// Import your files
import 'business_logic/auth_bloc/auth_bloc.dart';
import 'business_logic/auth_bloc/auth_event.dart';
import 'business_logic/auth_bloc/auth_state.dart';
import 'business_logic/app_bloc/app_bloc.dart';
import 'data/services/api_service.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/storage_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/repositories/post_repository.dart';
import 'data/repositories/chat_repository.dart';
import 'data/repositories/search_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  final apiService = ApiService();
  final storageService = StorageService();
  final storageRepository = StorageRepository(storageService);
  
  // Initialize repositories
  final authRepository = AuthRepository(apiService, storageRepository);
  final userRepository = UserRepository(apiService);
  final postRepository = PostRepository(apiService);
  final chatRepository = ChatRepository(apiService);
  final searchRepository = SearchRepository(apiService);
  
  runApp(MyApp(
    authRepository: authRepository,
    storageRepository: storageRepository,
    userRepository: userRepository,
    postRepository: postRepository,
    chatRepository: chatRepository,
    searchRepository: searchRepository,
  ));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final StorageRepository storageRepository;
  final UserRepository userRepository;
  final PostRepository postRepository;
  final ChatRepository chatRepository;
  final SearchRepository searchRepository;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.storageRepository,
    required this.userRepository,
    required this.postRepository,
    required this.chatRepository,
    required this.searchRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // IMPORTANT: Provide UserRepository so ProfileScreen can access it
        RepositoryProvider<UserRepository>.value(value: userRepository),
        RepositoryProvider<PostRepository>.value(value: postRepository),
        RepositoryProvider<ChatRepository>.value(value: chatRepository),
        RepositoryProvider<SearchRepository>.value(value: searchRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: authRepository,
              storageRepository: storageRepository,
            )..add(AuthCheckRequested()),
          ),
          BlocProvider<AppBloc>(
            create: (context) => AppBloc(
              userRepository: userRepository,
              postRepository: postRepository,
              chatRepository: chatRepository,
              searchRepository: searchRepository,
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Travel Diary',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
          ),
          // Use builder to listen to auth state globally
          builder: (context, child) {
            return BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                // Handle global auth state changes if needed
              },
              child: child,
            );
          },
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthInitial || state is AuthLoading) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (state is AuthAuthenticated) {
                return const HomeScreen();
              }
              return const LoginScreen();
            },
          ),
          onGenerateRoute: AppRoutes.generateRoute,
        ),
      ),
    );
  }
}