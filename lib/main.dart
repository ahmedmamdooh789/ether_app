import 'package:ether_app/screens/home_screen.dart';
import 'package:ether_app/screens/login_screen.dart';
import 'package:ether_app/screens/signup_screen.dart';
import 'package:ether_app/injectable.config.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'services/language_service.dart';
import 'config/environment.dart';
import 'app.dart';

// Initialize GetIt
final getIt = GetIt.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize environment
  await EnvironmentConfig.init();
  
  // Configure dependency injection
  configureDependencies();
  
  // Configure dependency injection
  configureDependencies();
  
  // Initialize language service through GetIt
  final languageService = getIt<LanguageService>();
  await languageService.init();
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale _locale;
  late final LanguageService _languageService;

  @override
  void initState() {
    super.initState();
    _languageService = getIt<LanguageService>();
    _locale = _languageService.currentLocale;
    _languageService.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    _languageService.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() {
    setState(() {
      _locale = _languageService.currentLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainApp(
      locale: _locale,
    );
  }
}
