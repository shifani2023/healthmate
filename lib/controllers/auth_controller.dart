import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import '../database/database_helper.dart';
import '../models/app_user.dart';

class AuthController {
  final DatabaseHelper _db = DatabaseHelper.instance;

  // The name of the user who is logged in right now (null = nobody)
  static String? currentUser;

  // A random "salt" makes every scrambled password different
  String _makeSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  // Turns the password into a scrambled text (a hash)
  String _hash(String salt, String password) {
    return sha256.convert(utf8.encode('$salt$password')).toString();
  }

  // Returns null when it worked, or a message when it did not
  Future<String?> register(String username, String password) async {
    final name = username.trim();

    final existing = await _db.getUserByUsername(name);
    if (existing != null) {
      return 'That username is already taken.';
    }

    final salt = _makeSalt();
    final user = AppUser(
      username: name,
      passwordHash: _hash(salt, password),
      salt: salt,
      createdAt: DateTime.now().toIso8601String(),
    );

    await _db.insertUser(user.toMap());
    currentUser = name;
    return null;
  }

  Future<bool> login(String username, String password) async {
    final row = await _db.getUserByUsername(username.trim());
    if (row == null) return false;

    final user = AppUser.fromMap(row);
    if (_hash(user.salt, password) != user.passwordHash) return false;

    currentUser = user.username;
    return true;
  }

  void logout() {
    currentUser = null;
  }
}