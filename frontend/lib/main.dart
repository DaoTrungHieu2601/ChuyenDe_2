import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class AppColors {
  static const primary = Color(0xFF4D8EFF);
  static const primaryDark = Color(0xFF1A5CCC);
  static const secondary = Color(0xFFFF6B6B);
  static const accent = Color(0xFFFFD93D);
  static const success = Color(0xFF6BCB77);
  static const background = Color(0xFFF4F6FB);
  static const card = Color(0xFFFFFFFF);
  static const textDark = Color(0xFF1A1D2E);
  static const textGrey = Color(0xFF9094A6);
  static const border = Color(0xFFE8ECF4);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: MaterialApp(
        title: 'Học Từ Vựng',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            background: AppColors.background,
          ),
          scaffoldBackgroundColor: AppColors.background,
          fontFamily: 'Roboto',
          useMaterial3: true,
          cardTheme: CardThemeData(
            elevation: 0,
            color: AppColors.card,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: AppColors.textDark,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        if (authService.isLoading) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }
        return authService.isLoggedIn ? const HomeScreen() : const LoginScreen();
      },
    );
  }
}
