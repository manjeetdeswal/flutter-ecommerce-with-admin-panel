import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/features/products/presentation/pages/login_screen.dart';
import 'core/features/products/presentation/pages/main_screen.dart';
import 'core/features/products/presentation/pages/merchant_dashboard_screen.dart';

import 'core/features/products/presentation/providers/auth_providers.dart';
import 'firebase_options.dart';


// 1. Make main() an async function
void main() async {
  // 2. This is CRITICAL. It ensures Flutter's engine is ready before talking to native code (like Firebase).
  WidgetsFlutterBinding.ensureInitialized();

  // 3. Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    // ProviderScope is still required for Riverpod
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter E-Commerce',
      theme: ThemeData(primarySwatch: Colors.blue),
      // Assuming you set up the AuthGuard here earlier
      home: const AuthGuard(),
    );
  }
}

final userRoleProvider = FutureProvider<String>((ref) async {
  // --- THE FIX: Make Riverpod watch for user changes! ---
  // This forces the provider to re-run the Firestore check every time someone new logs in.
  ref.watch(authStateProvider);

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return 'customer';

  final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  if (doc.exists && doc.data()?['role'] == 'merchant') {
    return 'merchant';
  }
  return 'customer';
});

// --- UPDATE YOUR AUTH GUARD ---
class AuthGuard extends ConsumerWidget {
  const AuthGuard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, trace) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (user) {
        if (user == null) {
          // Not logged in -> Show Login
          return const LoginScreen();
        } else {
          // Logged in! Now check their role using our new provider
          final roleState = ref.watch(userRoleProvider);

          return roleState.when(
            loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
            error: (e, trace) => const MainScreen(), // Fallback to customer screen on error
            data: (role) {
              // The Ultimate Router!
              if (role == 'merchant') {
                return const MerchantDashboardScreen();
              } else {
                return const MainScreen();
              }
            },
          );
        }
      },
    );
  }
}