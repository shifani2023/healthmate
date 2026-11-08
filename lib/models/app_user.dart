class AppUser {
  final int? id;
  final String username;
  final String passwordHash;
  final String salt;
  final String createdAt;

  const AppUser({
    this.id,
    required this.username,
    required this.passwordHash,
    required this.salt,
    required this.createdAt,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as int?,
      username: map['username'] as String,
      passwordHash: map['password_hash'] as String,
      salt: map['salt'] as String,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password_hash': passwordHash,
      'salt': salt,
      'created_at': createdAt,
    };
  }
}