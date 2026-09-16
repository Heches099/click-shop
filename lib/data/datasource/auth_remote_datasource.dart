import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/token_storage.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> signUp(String email, String password, String name);
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();

  /// Fetches the authenticated profile from the ClickShop API (`/auth/me`).
  /// Returns null when the API JWT is missing/expired — callers should fall
  /// back to the local Firebase profile. This is the ONLY trusted source of
  /// the owner (`isAdmin`) flag; it is never taken from the client.
  Future<UserModel?> getApiUser();

  /// ClickShop API JWT exchanged from the Firebase ID token, if available.
  Future<String?> getApiToken();
  Future<void> clearApiToken();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final DioClient _dioClient;
  final TokenStorage _tokenStorage;

  AuthRemoteDataSourceImpl(
    this._firebaseAuth,
    this._googleSignIn,
    this._dioClient,
    this._tokenStorage,
  );

  @override
  Future<UserModel> login(String email, String password) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _fromUser(credential.user!);
  }

  @override
  Future<UserModel> signUp(String email, String password, String name) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user!;
    await user.updateDisplayName(name);
    return _fromUser(user);
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    if (kIsWeb) {
      // google_sign_in's `authenticate()` is NOT supported on web — it throws
      // UnimplementedError silently. Use Firebase's popup flow instead, which
      // is the supported web path for Google sign-in.
      final provider = GoogleAuthProvider();
      provider.addScope('email');
      provider.addScope('profile');
      final userCredential = await _firebaseAuth.signInWithPopup(provider);
      return _fromUser(userCredential.user!);
    }
    final account = await _googleSignIn.authenticate();
    final googleAuth = account.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );
    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    return _fromUser(userCredential.user!);
  }

  @override
  Future<void> signOut() async {
    // Clear the local API JWT FIRST so a throwing 3rd-party sign-out (e.g.
    // Google's web SDK when the user never used Google sign-in) can never
    // leave a valid ClickShop session token behind.
    await _tokenStorage.clear();
    try {
      await _firebaseAuth.signOut();
    } catch (_) {
      // Firebase sign-out failure is non-fatal: a null `currentUser` is what
      // the rest of the app relies on, and the local token is already gone.
    }
    if (kIsWeb) {
      // Never touch the Google plugin on web: it is never initialized there,
      // so calling signOut() awaits an init future that never resolves and
      // hangs logout forever. Firebase sign-out above fully clears the web
      // session (including a Google one).
      return;
    }
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Google sign-out is best-effort; nothing depends on it on mobile.
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      await _tokenStorage.clear();
      return null;
    }
    return _fromUser(user);
  }

  @override
  Future<UserModel?> getApiUser() async {
    try {
      const exchangeDelay = Duration(seconds: 1);
      // The API JWT exchange from Firebase is fire-and-forget; give it a beat
      // so the very first /auth/me call after a fresh sign-in usually works.
      await Future<void>.delayed(exchangeDelay);
      final token = await _tokenStorage.read();
      if (token == null || token.isEmpty) return null;
      final response =
          await _dioClient.dio.get('/auth/me').timeout(const Duration(seconds: 8));
      final data = response.data;
      if (data is! Map) return null;
      final firebase = _firebaseAuth.currentUser;
      final id = data['id'] as String? ?? firebase?.uid ?? '';
      if (id.isEmpty) return null;
      return UserModel(
        id: id,
        email: data['email'] as String? ?? firebase?.email ?? '',
        name: data['name'] as String? ?? firebase?.displayName,
        photoUrl: data['photoUrl'] as String? ?? firebase?.photoURL,
        isAdmin: data['isAdmin'] == true,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> getApiToken() => _tokenStorage.read();

  @override
  Future<void> clearApiToken() => _tokenStorage.clear();

  Future<UserModel> _fromUser(User user) async {
    // Await the JWT exchange before exposing the user: the API session token
    // must be in place so the very next /auth/me (the ONLY source of the owner
    // flag) returns correctly. Bounded so a cold/slow backend can't stall the
    // sign-in UI for too long; a later exchange retry will catch up.
    try {
      final idToken = await user.getIdToken();
      if (idToken != null) {
        await _exchangeFirebaseToken(idToken)
            .timeout(const Duration(seconds: 10));
      }
    } catch (_) {
      // A failed exchange is non-fatal — the user is still signed in with
      // Firebase for auth, and the next successful exchange will retry.
    }
    return UserModel(
      id: user.uid,
      email: user.email!,
      name: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  Future<void> _exchangeFirebaseToken(String idToken) async {
    try {
      final response = await _dioClient.dio
          .post('/auth/firebase', data: {'id_token': idToken});
      final data = response.data;
      final token = data is Map ? data['access_token'] : null;
      if (token is String && token.isNotEmpty) {
        await _tokenStorage.write(token);
      }
    } catch (_) {
      // Ignore exchange failures here; the checkout flow surfaces real errors.
    }
  }
}