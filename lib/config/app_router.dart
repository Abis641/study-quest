// lib/config/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/profile_setup_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/subjects/subject_screen.dart';
import '../screens/quiz/quiz_screen.dart';
import '../screens/quiz/quiz_result_screen.dart';
import '../screens/achievements/achievements_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/missions/missions_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isOnAuth = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.splash;

      if (!isLoggedIn && !isOnAuth) return AppRoutes.login;
      if (isLoggedIn && state.matchedLocation == AppRoutes.login) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.subject}/:subjectId',
        builder: (context, state) {
          final subjectId = state.pathParameters['subjectId']!;
          return SubjectScreen(subjectId: subjectId);
        },
      ),
      GoRoute(
        path: '${AppRoutes.quiz}/:quizId',
        builder: (context, state) {
          final quizId = state.pathParameters['quizId']!;
          return QuizScreen(quizId: quizId);
        },
      ),
      GoRoute(
        path: AppRoutes.quizResult,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return QuizResultScreen(
            score: extra['score'] as int,
            total: extra['total'] as int,
            xpEarned: extra['xpEarned'] as int,
            coinsEarned: extra['coinsEarned'] as int,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.achievements,
        builder: (context, state) => const AchievementsScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.missions,
        builder: (context, state) => const MissionsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
});

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String profileSetup = '/profile-setup';
  static const String home = '/home';
  static const String subject = '/subject';
  static const String quiz = '/quiz';
  static const String quizResult = '/quiz-result';
  static const String achievements = '/achievements';
  static const String profile = '/profile';
  static const String missions = '/missions';
}
