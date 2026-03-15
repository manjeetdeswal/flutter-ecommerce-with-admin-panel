import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/app_user.dart';


class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthRepository(this._firebaseAuth);

  // Helper method to convert Firebase's User into our clean AppUser
  AppUser? _userFromFirebase(User? user) {
    if (user == null) return null;
    return AppUser(
      id: user.uid,
      email: user.email!,
      displayName: user.displayName,
    );
  }

  @override
  Stream<AppUser?> get authStateChanges {
    // This listens to Firebase and instantly pushes updates to our app
    return _firebaseAuth.authStateChanges().map(_userFromFirebase);
  }

  @override
  Future<AppUser> signInWithEmailPassword(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _userFromFirebase(credential.user)!;
    } on FirebaseAuthException catch (e) {
      // In a real app, you'd map these to clean, custom exceptions
      throw Exception(e.message ?? 'Sign in failed');
    }
  }

  @override
  Future<AppUser> signUpWithEmailPassword(String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _userFromFirebase(credential.user)!;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Sign up failed');
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}