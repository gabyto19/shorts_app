import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/main_shell.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // System UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.scaffoldBg,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: LearnHubApp()));
}

class LearnHubApp extends StatelessWidget {
  const LearnHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LearnHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AuthWrapper(),
    );
  }
}

/// Watches auth state and shows the appropriate screen:
/// - Loading → SplashScreen
/// - Not signed in → LoginScreen
/// - Signed in + not onboarded → OnboardingScreen
/// - Signed in + onboarded → MainShell
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return const _OnboardingGate();
        }
        return const LoginScreen();
      },
      loading: () => const SplashScreen(),
      error: (error, stack) => Scaffold(
        backgroundColor: AppTheme.scaffoldBg,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppTheme.errorRed, size: 48),
              const SizedBox(height: 16),
              Text(
                'Failed to initialize',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Checks Firestore to see if onboarding is complete.
/// - Doc doesn't exist → old user, skip onboarding & create doc
/// - Doc exists + onboardingComplete=true → skip
/// - Doc exists + no onboardingComplete → new signup, show onboarding
class _OnboardingGate extends ConsumerStatefulWidget {
  const _OnboardingGate();

  @override
  ConsumerState<_OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends ConsumerState<_OnboardingGate> {
  bool _isLoading = true;
  bool _onboardingComplete = false;

  @override
  void initState() {
    super.initState();
    // Small delay to let any sign-in Firestore writes finish
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _checkOnboarding();
    });
  }

  Future<void> _checkOnboarding() async {
    try {
      final firestore = ref.read(firestoreServiceProvider);
      final profile = await firestore.getUserProfile();

      if (profile == null) {
        // No user doc at all → old user who existed before Firestore
        // Create their profile and skip onboarding
        final user = ref.read(authServiceProvider).currentUser;
        if (user != null) {
          await firestore.createUserProfile(
            uid: user.uid,
            displayName: user.displayName ?? 'User',
            email: user.email ?? '',
          );
          await firestore.updateUserProfile({'onboardingComplete': true});
        }
        if (mounted) {
          setState(() {
            _onboardingComplete = true;
            _isLoading = false;
          });
        }
      } else if (profile.containsKey('onboardingComplete') && profile['onboardingComplete'] == true) {
        // Already completed onboarding
        if (mounted) {
          setState(() {
            _onboardingComplete = true;
            _isLoading = false;
          });
        }
      } else {
        // Doc exists but onboardingComplete is not true → new signup
        if (mounted) {
          setState(() {
            _onboardingComplete = false;
            _isLoading = false;
          });
        }
      }
    } catch (_) {
      // If check fails, skip onboarding to avoid blocking the user
      if (mounted) {
        setState(() {
          _onboardingComplete = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SplashScreen();
    }

    if (!_onboardingComplete) {
      return OnboardingScreen(
        onComplete: () {
          setState(() => _onboardingComplete = true);
        },
      );
    }

    return const MainShell();
  }
}
