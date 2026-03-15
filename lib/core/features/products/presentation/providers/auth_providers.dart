import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../../domain/entities/app_user.dart';



// 1. Provide the Firebase Auth instance
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// 2. Provide our Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return FirebaseAuthRepository(firebaseAuth);
});

// 3. The magic StreamProvider!
// Any UI listening to this will rebuild automatically if the user logs in or out.
final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;

  AuthController(this._authRepository) : super(const AsyncValue.data(null));



  Future<String> loginUser(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      // 1. Authenticate with Firebase
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // 2. Fetch the user's document from Firestore
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        state = const AsyncValue.data(null);

        // 3. Return the role to the UI!
        if (userDoc.exists && userDoc.data()?['role'] == 'merchant') {
          return 'merchant';
        } else {
          return 'customer';
        }
      }
      throw Exception('Login failed');
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow; // Throws the error back to the UI so it can show the Snackbar
    }
  }

  Future<void> signUp(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.signUpWithEmailPassword(email, password);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }
}

// Provider for the controller
final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});