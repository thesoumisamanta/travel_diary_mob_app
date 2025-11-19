import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_diary_mob_app/business_logic/auth_bloc/auth_event.dart';
import 'app.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/repositories/post_repository.dart';
import 'data/repositories/chat_repository.dart';
import 'data/repositories/storage_repository.dart';
import 'data/services/api_service.dart';
import 'data/services/storage_service.dart';
import 'business_logic/auth_bloc/auth_bloc.dart';
import 'business_logic/app_bloc/app_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize services
  final storageService = StorageService();
  await storageService.init();

  final apiService = ApiService();

  // Initialize repositories
  final storageRepository = StorageRepository(storageService);
  final authRepository = AuthRepository(apiService, storageRepository);
  final userRepository = UserRepository(apiService);
  final postRepository = PostRepository(apiService);
  final chatRepository = ChatRepository(apiService);

  runApp(
    TravelDiaryApp(
      authRepository: authRepository,
      userRepository: userRepository,
      postRepository: postRepository,
      chatRepository: chatRepository,
      storageRepository: storageRepository,
    ),
  );
}

class TravelDiaryApp extends StatelessWidget {
  final AuthRepository authRepository;
  final UserRepository userRepository;
  final PostRepository postRepository;
  final ChatRepository chatRepository;
  final StorageRepository storageRepository;

  const TravelDiaryApp({
    super.key,
    required this.authRepository,
    required this.userRepository,
    required this.postRepository,
    required this.chatRepository,
    required this.storageRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: userRepository),
        RepositoryProvider.value(value: postRepository),
        RepositoryProvider.value(value: chatRepository),
        RepositoryProvider.value(value: storageRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: authRepository,
              storageRepository: storageRepository,
            )..add(AuthCheckRequested()),
          ),
          BlocProvider(
            create: (context) => AppBloc(
              userRepository: userRepository,
              postRepository: postRepository,
              chatRepository: chatRepository,
            ),
          ),
        ],
        child: const App(),
      ),
    );
  }
}
