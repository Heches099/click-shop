import 'package:firebase_auth/firebase_auth.dart';
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
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
    await _tokenStorage.clear();
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
  Future<String?> getApiToken() => _tokenStorage.read();

  @override
  Future<void> clearApiToken() => _tokenStorage.clear();

  UserModel _fromUser(User user) {
    // Exchange the fresh Firebase ID token for a ClickShop API JWT so the
    // authenticated endpoints (orders, payments, profile) work immediately.
    _exchangeToken(user);
    return UserModel(
      id: user.uid,
      email: user.email!,
      name: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  void _exchangeToken(User user) {
    () async {
      try {
        final idToken = await user.getIdToken();
        if (idToken == null) return;
        await _exchangeFirebaseToken(idToken);
      } catch (_) {
        // A failed exchange is non-fatal — the user is still signed in with
        // Firebase for auth, and the next successful exchange will retry.
      }
    }();
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