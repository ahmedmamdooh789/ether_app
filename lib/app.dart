import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

import 'injectable.config.dart';
import 'providers/providers.dart';
import 'screens/home_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/editprofile_screen.dart';
import 'widgets/auth_wrapper.dart';
import 'services/language_service.dart';

final getIt = GetIt.instance;

class MainApp extends StatelessWidget {
  final Locale locale;

  const MainApp({
    Key? key,
    required this.locale,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => getIt<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<UserProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<PostProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<StoryProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<LanguageService>()),
      ],
      child: Builder(
        builder: (context) {
          final languageService = getIt<LanguageService>();
          return MaterialApp(
            title: 'Ether App',
            debugShowCheckedModeBanner: false,
            locale: locale,
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('ar', 'EG'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
              primarySwatch: Colors.purple,
              fontFamily: locale.languageCode == 'ar' ? 'Cairo' : 'Roboto',
            ),
            builder: (context, child) {
              return Directionality(
                textDirection: locale.languageCode == 'ar' 
                    ? TextDirection.rtl 
                    : TextDirection.ltr,
                child: child!,
              );
            },
            initialRoute: '/',
            routes: {
              '/': (context) => const AuthWrapper(),
              '/welcome': (context) => const WelcomeScreen(),
              '/signup': (context) => const SignupScreen(),
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeScreen(),
              '/editprofile': (context) => const EditProfileScreen(),
            },
          );
        },
      ),
    );
  }
}
