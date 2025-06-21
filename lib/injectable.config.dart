import 'package:injectable/injectable.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'utils/secure_storage_service.dart';
import 'config/environment.dart';
import 'api/auth_service.dart';
import 'api/base_api_service.dart';
import 'api/post_service.dart';
import 'api/story_service.dart';
import 'api/user_service.dart';
import 'data/post_service.dart';
import 'services/auth_service.dart';
import 'utils/token_interceptor.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: r'$initGetIt',
  preferRelativeImports: true,
  asExtension: false,
)
void configureDependencies() {
  $initGetIt(getIt);
}

@module
abstract class AppModule {
  @lazySingleton
  Dio get dio {
    final options = BaseOptions(
      baseUrl: EnvironmentConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    return Dio(options);
  }

  @lazySingleton
  FlutterSecureStorage get storage => const FlutterSecureStorage();

  @factory
  PostService get postService => PostService(gh<Dio>());

  @factory
  AuthService get authService => AuthService(gh<Dio>(), gh<FlutterSecureStorage>());

  @factory
  BaseApiService get baseApiService => BaseApiService(gh<Dio>());

  @factory
  StoryService get storyService => StoryService(gh<Dio>());

  @factory
  UserService get userService => UserService(gh<Dio>());

  @factory
  SecureStorageService get secureStorageService => SecureStorageService(gh<FlutterSecureStorage>());

  @factory
  TokenInterceptor get tokenInterceptor => TokenInterceptor(gh<FlutterSecureStorage>());
}
