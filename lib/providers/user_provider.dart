import 'package:flutter/material.dart';
import 'package:smart_library/auth/database_helper.dart';
import 'package:smart_library/models/user_model.dart';

class UserProvider with ChangeNotifier {
  Users? _currentUser;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Users? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  Future<bool> login(String username, String password) async {
    final user = Users(usrName: username, password: password);
    final isAuthenticated = await _dbHelper.authenticate(user);
    if (isAuthenticated) {
      _currentUser = await _dbHelper.getUser(username);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> register(Users user) async {
    try {
      await _dbHelper.createUser(user);
      return true;
    } catch (e) {
      return false;
    }
  }

  void setUser(Users user) {
    _currentUser = user;
    notifyListeners();
  }
}
