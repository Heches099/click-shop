class AppUser {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;

  /// Owner flag — a mirror of the backend's `is_admin` (the backend is the
  /// source of truth; never trust a client-supplied value for this).
  final bool isAdmin;

  const AppUser({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    this.isAdmin = false,
  });
}
