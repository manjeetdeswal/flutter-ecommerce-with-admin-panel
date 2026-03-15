class AppUser {
  final String id;
  final String email;
  final String? displayName;

  AppUser({
    required this.id,
    required this.email,
    this.displayName,
  });
}

// lib/features/auth/domain/repositories/auth_repository.dart

abstract class AuthRepository {
  // A Stream that constantly broadcasts the current user (or null if logged out)
  Stream<AppUser?> get authStateChanges;

  Future<AppUser> signInWithEmailPassword(String email, String password);
  Future<AppUser> signUpWithEmailPassword(String email, String password);
  Future<void> signOut();
}