import 'package:ether_app/screens/home_screen.dart';
import 'package:ether_app/screens/login_screen.dart';
import 'package:ether_app/screens/signup_screen.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart'; 
import 'screens/editprofile_screen.dart';
import 'services/language_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final languageService = LanguageService();
  await languageService.init();
  runApp(MyApp(languageService: languageService));
}

class MyApp extends StatefulWidget {
  final LanguageService languageService;
  
  const MyApp({Key? key, required this.languageService}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale _locale;
  
  @override
  void initState() {
    super.initState();
    _locale = widget.languageService.currentLocale;
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ether App',
      debugShowCheckedModeBanner: false,
      locale: _locale,
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
        fontFamily: _locale.languageCode == 'ar' ? 'Cairo' : 'Roboto',
      ),
      // Set the default text direction for the entire app
      builder: (context, child) {
        return Directionality(
          textDirection: _locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/signup': (context) => const SignupScreen(), 
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/editprofile': (context) => const EditProfileScreen(),
      },   
    );
  }
}
