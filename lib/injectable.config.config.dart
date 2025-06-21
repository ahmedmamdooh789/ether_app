// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i7;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i4;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import 'api/auth_service.dart' as _i13;
import 'api/base_api_service.dart' as _i3;
import 'api/post_service.dart' as _i6;
import 'api/story_service.dart' as _i10;
import 'api/user_service.dart' as _i12;
import 'data/post_service.dart' as _i8;
import 'providers/auth_provider.dart' as _i18;
import 'providers/post_provider.dart' as _i15;
import 'providers/story_provider.dart' as _i16;
import 'providers/user_provider.dart' as _i17;
import 'services/auth_service.dart' as _i14;
import 'services/language_service.dart' as _i5;
import 'utils/secure_storage_service.dart' as _i9;
import 'utils/token_interceptor.dart' as _i11;

// initializes the registration of main-scope dependencies inside of GetIt
_i1.GetIt $initGetIt(
  _i1.GetIt getIt, {
  String? environment,
  _i2.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i2.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  gh.factory<_i3.BaseApiService>(
      () => _i3.BaseApiService(gh<_i4.FlutterSecureStorage>()));
  gh.factory<_i5.LanguageService>(() => _i5.LanguageService());
  gh.factory<_i6.PostService>(() => _i6.PostService(gh<_i7.Dio>()));
  gh.factory<_i8.PostService>(() => _i8.PostService(gh<_i7.Dio>()));
  gh.factory<_i9.SecureStorageService>(
      () => _i9.SecureStorageService(gh<_i4.FlutterSecureStorage>()));
  gh.factory<_i10.StoryService>(() => _i10.StoryService(gh<_i7.Dio>()));
  gh.factoryParam<_i11.TokenInterceptor, _i7.Dio, dynamic>((
    _dio,
    _,
  ) =>
      _i11.TokenInterceptor(
        gh<_i4.FlutterSecureStorage>(),
        _dio,
      ));
  gh.factory<_i12.UserService>(() => _i12.UserService(gh<_i7.Dio>()));
  gh.factory<_i13.AuthService>(() => _i13.AuthService(
        gh<_i7.Dio>(),
        gh<_i9.SecureStorageService>(),
      ));
  gh.factory<_i14.AuthService>(() => _i14.AuthService(
        gh<_i3.BaseApiService>(),
        gh<_i4.FlutterSecureStorage>(),
      ));
  gh.lazySingleton<_i15.PostProvider>(
      () => _i15.PostProvider(gh<_i6.PostService>()));
  gh.lazySingleton<_i16.StoryProvider>(
      () => _i16.StoryProvider(gh<_i10.StoryService>()));
  gh.lazySingleton<_i17.UserProvider>(
      () => _i17.UserProvider(gh<_i12.UserService>()));
  gh.lazySingleton<_i18.AuthProvider>(
      () => _i18.AuthProvider(gh<_i13.AuthService>()));
  return getIt;
}
